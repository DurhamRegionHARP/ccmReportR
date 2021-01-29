#' Execute a SOQL query against the Case object.
#'
#' `getCases()` returns a `tibble` of data from the CCM Case object.
#' The Case object maps to Investigations on the client-side.
#'
#' @param confirmedOnly Logical scalar. Should the query limit
#'   results to confirmed cases? Returns confirmed and probable cases
#'   by default.
#' @param from Character scalar. Identifies the start of the date range
#'   to include in the query. Defaults to the origin date of CCM.
#' @param to Character scalar. Identifies the end of the date range
#'   to include in the query. Defaults to `Sys.Date()` (i.e. today's date).
#' @param columns Character scalar or character vector. Names the columns to
#'   return from the Case object. Defaults to `Id`
#' @param healthUnit Character vector or scalar. Names the Public Health Unit
#'   used to filter the query. `getCases()` filters on Permanent PHU. Defaults
#'   to NULL (i.e. no health unit filter).
#' @return If the query succeeds, a `tibble` containing `columns`.
#' @export
#' @examples
#' \dontrun{
#' Get all confirmed cases for Waterloo Region
#' cases <- getCases(
#'   confirmedOnly = TRUE,
#'   healthUnit = 'Durham Region Health Department'
#' )
#' Specify the data to return.
#' cases <- getCases(
#'   columns = c("Id", "CCM_ReportedDate__c", "CCM_Episode_Date__c", "CCM_Episode_Date_Type__c")
#' )
#' Limit the data to a specific time period.
#' cases <- getCases(
#'   from = "2020-10-12",
#'   to = "2020-10-17"
#' )
#' }

getCases <- function(
    confirmedOnly = FALSE,
    from = "1990-01-01",
    to = as.character(Sys.Date()),
    columns = 'Id',
    healthUnit = NULL
  ) {
  # Translate each option to language Salesforce expects
  statements <- list()
  if (from > to) {
    stop('Argument `from` must precede argument `to`.\n', call. = FALSE)
  }
  statements$dateRange <- paste(
    "CCM_ReportedDate__c>=",
    makeTimestamp(from),
    "+AND+",
    "CCM_ReportedDate__c<=",
    makeTimestamp(to),
    sep = ''
  )
  if (confirmedOnly) {
    statements$classification <- "CCM_Classification__c='CONFIRMED'"
  } else {
    statements$classification <- "(CCM_Classification__c='CONFIRMED'+OR+CCM_Classification__c='PROBABLE')"
  }
  if (!is.null(healthUnit)) {
    statements$phu <- paste(
      "CCM_New_Diagnosing_PHU__c='",
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
    paste(columns, collapse = ','),
    "FROM+Case",
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
      'get cases!\n',
      jsonlite::fromJSON(httr::content(resp, 'text'))$message
    )
  )
  # Parse the results
  data <- jsonlite::fromJSON(httr::content(resp, 'text'))
  if ('MALFORMED_QUERY' %in% names(data)) {
    stop('The query was rejected due to a syntax error.\n', call. = FALSE)
  } else {
    return(data$records)
  }
}
