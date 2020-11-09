# Execute a SOQL query against the Case object
# The Case object maps to Investigations on the client-side
# Options:
#    - confirmedOnly: Limit the query to select confirmed cases
#    - from: Query cases beginning on this date
#    - to: Query cases up to this date
#    - columns: character vector of data to query
#    - healthUnit: Limit the query using `Permanent PHU`

getCases <- function(
  options = list(
    confirmedOnly = FALSE,
    from = 'YESTERDAY',
    to = NULL,
    columns = NULL,
    healthUnit = NULL
  )
) {
  # Translate each option to language Salesforce expects
  statements <- list()
  if (options$confirmedOnly) {
    statements$classification <- "CCM_Classification__c='CONFIRMED'"
  } else {
    statements$classification <- "CCM_Classification__c+includes+('CONFIRMED','PROBABLE')"
  }
  if (!is.null(options$to)) {
    statements$dateRange <- paste(
      "CCM_ReportedDate__c>=",
      options$from,
      "+AND+",
      "CCM_ReportedDate__c<=",
      options$to,
      sep='')
  } else {
    statements$dateRange <- paste('CCM_ReportedDate__c=', options$from, sep='')
  }
  if (!('from' %in% names(options))) {
    statements$dateRange <- 'CCM_ReportedDate__c=YESTERDAY'
  }
  if (!is.null(options$healthUnit)) {
    statements$phu <- paste(
      "CCM_New_Diagnosing_PHU__c='",
      getHealthUnitByName(options$healthUnit),
      "'",
      sep=''
    )
  }
  if (is.null(options$columns)) {
    options$columns <- 'Id'
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
        sep=''
      )
    }
  }

  query <- paste(
    "SELECT",
    paste(options$columns, collapse=","),
    "FROM+Case",
    "WHERE",
    whereClause,
    sep="+"
  )
  # See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/intro_what_is_rest_api.htm
  resource_uri <- 'https://mohcontacttracing.my.salesforce.com/services/data/v49.0/query/?q='
  # Post the query to Salesforce
  resp <- GET(
    url = paste(resource_uri, query, sep=''),
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
