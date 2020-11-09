# Execute a SOQL query against the Case object
# The Case object maps to Investigations on the client-side
# Options:
#    - confirmedOnly: Limit the query to select confirmed cases
#    - from: Query cases beginning on this date
#    - to: Query cases up to this date
#    - columns: character vector of fields to query
#    - healthUnit: Limit the query using `Permanent PHU`

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
    stop('Arguement `from` must preceed arguement `to`.\n')
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
    statements$classification <- "CCM_Classification__c+includes+('CONFIRMED','PROBABLE')"
  }
  if (!is.null(healthUnit)) {
    statements$phu <- paste(
      "CCM_New_Diagnosing_PHU__c='",
      getHealthUnitByName(healthUnit),
      "'",
      sep = ''
    )
  } else {
    warning('No health unit specified. This may return a lot of results!\n')
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
  resource_uri <- 'https://mohcontacttracing.my.salesforce.com/services/data/v49.0/query/?q='
  # Post the query to Salesforce
  resp <- GET(
    url = paste(resource_uri, query, sep = ''),
    add_headers(Authorization = paste('Bearer', key_get('CCM', 'AccessToken')))
  )
  stop_for_status(resp, paste('get cases!\n', fromJSON(content(resp, 'text'))$message))
  # Parse the results
  data <- fromJSON(content(resp, 'text'))
  if ('MALFORMED_QUERY' %in% names(data)) {
    cat('The query was rejected due to a syntax error.\n')
  } else {
    return(data$records)
  }
}
