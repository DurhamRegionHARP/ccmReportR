#' Execute an SOQL query against the Outbreak object
#'

getOutbreaks <- function(
  confirmedOnly = TRUE,
  openOnly = TRUE,
  healthUnit = NULL,
  from = "1990-01-01",
  to = as.character(Sys.Date()),
  columns = "CCM_SFDC_Outbreak_Number__c"
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
    return(data$records)
  }
}
