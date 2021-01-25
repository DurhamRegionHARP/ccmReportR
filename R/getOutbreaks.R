#' Execute a SOQL query against the Outbreak object.
#'
#' `getOutbreaks()` returns user-defined data from the CCM Outbreak object.
#' The Outbreak object maps to Outbreaks on the client-side.
#'
#' @param confirmedOnly Logical scalar. Should the query limit
#'   results to confirmed outbreaks? Returns confirmed and suspect outbreaks
#'   by default.
#' @param openOnly Logical scalar. Should the query limit
#'   results to open outbreaks? Returns open and closed outbreaks
#'   by default.
#' @param from Character scalar. Identifies the start of the date range
#'   to include in the query. Defaults to the origin date of CCM.
#' @param to Character scalar. Identifies the end of the date range
#'   to include in the query. Defaults to `Sys.Date()` (i.e. today's date).
#' @param columns Character scalar or character vector. Names the columns to
#'   return from the Outbreak object. Defaults to `Id`.
#' @param healthUnit Character vector or scalar. Names the Public Health Unit
#'   used to filter the query. `getOutbreaks()` filters on Primary Health Unit.
#'   Defaults to NULL (i.e. no health unit filter).
#' @return If the query succeeds, a `tibble` containing `columns`.
#' @export
#' @examples
#' \dontrun{
#' Get all open outbreaks for Durham.
#' outbreaks <- getOutbreaks(
#'   confirmedOnly = FALSE,
#'   healthUnit = 'Durham Region Health Department'
#' )
#' Specify the data to return.
#' outbreaks <- getOutbreaks(
#'   columns = c("Id", "Name", "CCM_SFDC_Outbreak_Number__c")
#' )
#' Limit the data to a specific time period.
#' outbreaks <- getOutbreaks(
#'   from = "2021-01-01",
#'   to = "2020-01-17"
#' )
#' }'

getOutbreaks <- function(
  confirmedOnly = TRUE,
  openOnly = TRUE,
  healthUnit = NULL,
  from = "1990-01-01",
  to = as.character(Sys.Date()),
  columns = "Id"
) {
    # Translate each option to language Salesforce expects
  statements <- list()
  if (from > to) {
    stop('Arguement `from` must preceed arguement `to`.\n', call. = FALSE)
  }
  statements$dateRange <- paste(
    "CCM_Reported_Date__c>=",
    from,
    "+AND+",
    "CCM_Reported_Date__c<=",
    to,
    sep = ''
  )
  if (confirmedOnly) {
    statements$classification <- "CCM_Outbreak_Classification_NEW__c='Confirmed'"
  } else {
    statements$classification <- "(CCM_Outbreak_Classification_NEW__c='Confirmed'+OR+CCM_Outbreak_Classification_NEW__c='Suspect')"
  }
  if (openOnly) {
    statements$classification <- "CCM_Outbreak_Status__c='Open'"
  } else {
    statements$classification <- "(CCM_Outbreak_Status__c='Open'+OR+CCM_Outbreak_Status__c='Close')"
  }
  if (!is.null(healthUnit)) {
    statements$phu <- paste(
      "CCM_PHU_Stage_Table__c='",
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
    "FROM+Outbreak__c",
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
      'get outbreaks!\n',
      jsonlite::fromJSON(httr::content(resp, 'text'))$message
    )
  )
  # Parse the results
  data <- jsonlite::fromJSON(httr::content(resp, 'text'))
  if ('MALFORMED_QUERY' %in% names(data)) {
    stop('The query was rejected due to a syntax error.\n', call. = FALSE)
  } else {
    return(tibble::as_tibble(dplyr::select(data$records, !attributes)))
  }
}
