#' Execute a SOQL query against the Exposure object
#'
#' `getExposures()` returns a user-defined data from the CCM Exposure object.
#' The Exposure object maps to Exposures on the client-side.
#'
#' @param type Character vector or scalar. Names the exposure type used
#'   to filter the query. Defaults to all exposure types. One or more of:
#'   1. `Community`
#'   2. `Congregate Living`
#'   3. `Household`
#'   4. `Institutional`
#'   5. `Travel`
#' @param from Character scalar. Identifies the start of the date range
#'   to include in the query. Defaults to the origin date of CCM.
#' @param to Character scalar. Identifies the end of the date range
#'   to include in the query. Defaults to `Sys.time()` (i.e. today's date and time).
#' @param columns Character scalar or character vector. Names the columns to
#'   return from the exposure object. Defaults to `Id`.
#' @param healthUnit Character vector or scalar. Names the Public Health Unit
#'   used to filter the query. `getExposures()` filters on Exposure PHU. Defaults
#'   to NULL (i.e. no health unit filter).
#' @return If the query succeeds, a `tibble` containing `columns`.
#' @export
#' @examples
#' \dontrun{
#' Get all community exposures for Durham
#' exposures <- getExposures(
#'   type = 'Community',
#'   healthUnit = 'Durham Region Health Department'
#' )
#' Specify the data to return.
#' exposures <- getExposures(
#'   columns = c("Id", "Name", "CCM_Exposure_Setting__c")
#' )
#' Limit the data to a specific time period.
#' exposures <- getExposures(
#'   from = "2020-12-12",
#'   to = "2020-12-17"
#' )
#' }

getExposures <- function(
    type = NULL,
    from = "1990-01-01",
    to = as.character(Sys.time()),
    columns = 'Id',
    healthUnit = NULL
  ) {
  # Translate each option to language Salesforce expects
  statements <- list()
  if (from > to) {
    stop('Argument `from` must precede argument `to`.\n', call. = FALSE)
  }
  statements$dateRange <- paste(
    "CCM_Date_Time_Arrived__c>=",
    makeTimestamp(from),
    "+AND+",
    "CCM_Date_Time_Arrived__c<=",
    makeTimestamp(to),
    sep = ''
  )
  if (!is.null(type)) {
    for (typ in 1:length(type)) {
      if (typ == 1) {
        statements$type <- paste(
          "(RecordType.Name='",
          type[typ],
          "'",
          sep=""
        )
      } else {
        statements$type <- paste(
          statements$type,
          "+OR+RecordType.Name='",
          type[typ],
          "'",
          sep=""
        )
      }
    }
    statements$type <- paste(statements$type, ")", sep="")
  }
  if (!is.null(healthUnit)) {
    statements$phu <- paste(
      "PHU_Exposure__c='",
      getHealthUnitByName(healthUnit),
      "'",
      sep = ''
    )
  } else {
    warning('No health unit specified. This may return a lot of results!\n', call. = FALSE)
  }
  # Build the WHERE clause for the query
  for (statement in 1:length(statements)) {
    if (statement == 1) {
      whereClause <- statements[[statement]]
    } else {
      whereClause <- paste(
        whereClause,
        "+AND+",
        statements[[statement]],
        sep = ''
      )
    }
  }
  query <- paste(
    "SELECT",
    paste(getDBLabels('CCM_Exposure__c', columns), collapse = ','),
    "FROM+CCM_Exposure__c",
    "WHERE",
    whereClause,
    sep = '+'
  )
  # See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/intro_what_is_rest_api.htm
  resource_uri <- 'https://mohcontacttracing.my.salesforce.com/services/data/v50.0/query/?q='
  # Post the query to Salesforce
  resp <- httr::GET(
    url = paste(resource_uri, query, sep = ''),
    httr::add_headers(Authorization = paste('Bearer', keyring::key_get('CCM', 'AccessToken')))
  )
  httr::stop_for_status(
    resp,
    paste(
      'get exposures!\n',
      jsonlite::fromJSON(httr::content(resp, 'text'))$message
    )
  )
  # Parse the results
  data <- jsonlite::fromJSON(httr::content(resp, 'text'))
  if ('MALFORMED_QUERY' %in% names(data)) {
    stop('The query was rejected due to a syntax error.\n', call. = FALSE)
  }
  if (data$totalSize == 0) {
    return(tibble::as_tibble(data$records))
  }
  return(tibble::as_tibble(dplyr::select(data$records, !attributes)))
}
