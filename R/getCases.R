# Execute a SOQL query against the Case object
# The Case object maps to Investigations on the client-side
# Options:
#    - confirmedOnly: Limit the query to select confirmed cases
#    - from: Query cases beginning on this date
#    - to: Query cases up to this date
#    - columns: character vector of data to query

getCases <- function(healthUnit, options) {
  # Look up the heath unit Id
  # healthUnitId <- getHealthUnitByName(healthUnit)

  # Fall back to defaults when no options are passed in
  if(!length(options)) {
    options$confirmedOnly <- FALSE
    options$from <- 'YESTERDAY'
    options$to <- NULL
    options$columns <- 'Id'
  }

  # Translate each option to language Salesforce expects
  statements <- list()
  if (options$confirmedOnly) {
    statements$classification <- "CCM_Classification__c='CONFIRMED'"
  } else {
    statements$classification <- "CCM_Classification__c+includes+('CONFIRMED','PROBABLE')"
  }
  if (!is.null(options$to)) {
    statements$dateRange <- paste(
      "CCM_ReportedDate__c>='",
      options$from,
      "'",
      " AND ",
      "CCM_ReportedDate__c<='",
      options$to,
      "'",
      sep='')
  } else {
    statements$dateRange <- "CCM_ReportedDate__c='YESTERDAY'"
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
    options$columns,
    "FROM+Case",
    "WHERE",
    whereClause,
    sep="+")

  print(query)
  # # Define some constants
  # resource_uri <- 'https://mohcontacttracing.my.salesforce.com/services/data/v49.0/query/?q='
  # # Validate the query
  # if (is.null(query)) {
  #   cat('gotCases: Expected a query to execute...Please try again!\n')
  # } else {
  #   # Post the query to Salesforce
  #   resp <- GET(
  #     url = paste(resource_uri, query, sep=''),
  #     add_headers(Authorization = paste('Bearer', key_get('Case and Conatct Management', 'AccessToken')))
  #   )
  #   # Parse the results
  #   data <- fromJSON(content(resp, 'text'))
  #   if ('MALFORMED_QUERY' %in% names(data)) {
  #     cat('Your query returned an error\n')
  #   } else {
  #     data
  #   }
  # }
}
