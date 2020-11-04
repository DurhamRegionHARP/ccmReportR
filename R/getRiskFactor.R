# Execute a SOQL query against the CCM_Risk_Factor__c object
# The CCM_Risk_Factor__c object maps to Risk Factors
# on the client side

getRiskFactors <- function(options = list()) {
  # Fall back to defaults when no options are passed in
  if(!length(options)) {
    options$riskFactorType <- NULL
    options$from <- 'YESTERDAY'
    options$to <- NULL
    options$columns <- 'Id'
    options$healthUnit <- NULL
  }
  # Translate each option to language Salesforce expects
  statements <- list()
  if (!is.null(options$to)) {
    statements$dateRange <- paste(
      "LastModifiedDate>='",
      options$from,
      "'",
      " AND ",
      "LastModifiedDate<='",
      options$to,
      "'",
      sep=''
    )
  } else {
    statements$dateRange <- paste('LastModifiedDate=', options$from, sep='')
  }
  if (!is.null(options$riskFactorType)) {
    statements$recordTypeId <- paste(
      "RecordTypeId='",
      getRecordTypeId(options$riskFactorType),
      "'",
      sep=''
    )
  }
  if (!is.null(options$healthUnit)) {
    statements$phu <- paste(
      "CCM_New_Diagnosing_PHU__c='",
      getHealthUnitByName(options$healthUnit),
      "'",
      sep=''
    )
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
  resp <- GET(
    url = paste(resource_uri, query, sep=''),
    add_headers(Authorization = paste('Bearer', key_get('CCM', 'AccessToken')))
  )
  warn_for_status(resp, paste('get cases!\n', content(resp)$message))
  data <- fromJSON(content(resp, 'text'))
  if ('MALFORMED_QUERY' %in% names(data)) {
    cat('The query was rejected due to a syntax error.\n')
  } else {
    return(data$records)
  }
}
