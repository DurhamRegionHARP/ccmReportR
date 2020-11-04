# Execute a SOQL query against the CCM_Risk_Factor__c object
# The CCM_Risk_Factor__c object maps to Risk Factors
# on the client side
#
# 1. Get risk Id and case id over date range
# 2. for each element, look up case then return TURE or FALSE for health unit
# 3. Filter list in #1 with results from #2

getRiskFactors <- function(healthUnit, riskFactorType = NULL) {
  # Translate each option to language Salesforce expects
  # TODO: allow array of record types
  query <- paste(
    "SELECT+Id,CCM_Investigation__c",
    "FROM+CCM_Risk_Factor__c",
    "WHERE+CCM_Investigation__c!=null"
    sep="+"
  )
  if (!is.null(riskFactorType)) {
    query <- paste(
      query,
      "+AND+RecordTypeId='",
      getRecordTypeId(riskFactorType),
      "'",
      sep=''
    )
  }
  # See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/intro_what_is_rest_api.htm
  resource_uri <- 'https://mohcontacttracing.my.salesforce.com/services/data/v49.0/query/?q='
  resp <- GET(
    url = paste(resource_uri, query, sep=''),
    add_headers(Authorization = paste('Bearer', key_get('CCM', 'AccessToken')))
  )
  stop_for_status(resp, paste('get risk factors!\n', content(resp)$message))
  data <- fromJSON(content(resp, 'text'))
  # Look up each investigation and determine health unit
  results <- map(data$records, function(case) {
    resp <- GET(
      paste(
        'https://mohcontacttracing.my.salesforce.com/services/data/v49.0/sobjects/Case/',
        case$CCM_Investigation__c,
        '?fields=CCM_New_Diagnosing_PHU__c',
        sep=''
      ),
      add_headers(Authorization = paste('Bearer', key_get('CCM', 'AccessToken')))
    )
    stop_for_status(resp, paste('get case while searching risk factors\n', content(resp)$message))
    caseData <- fromJSON(content(resp, 'text'))
    return(
      identical(
        caseData$CCM_New_Diagnosing_PHU__c,
        getHealthUnitByName(healthUnit)
      )
    )
  })
  for (index in 1:length(data$records$Id)) {
    if (results[index]) {
      filteredRiskFactors <- data$records[index,-1]
    }
  }
  return(filteredRiskFactors)
}
