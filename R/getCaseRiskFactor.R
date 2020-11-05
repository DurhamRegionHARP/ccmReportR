# Return the risk factors for a list of cases
getCaseRiskFactor <- function(cases) {
  results <- map(cases, function(case) {
    query <- paste(
      "SELECT+Id,CCM_Investigation__c,RecordTypeId,CCM_RiskFactor_Info__c,CCM_AdditionalRisk_lnfo__c",
      "+FROM+CCM_Risk_Factor__c",
      "+WHERE+CCM_Investigation__c='",
      case,
      "'",
      sep=""
    )
    resource_uri <- 'https://mohcontacttracing.my.salesforce.com/services/data/v49.0/query/?q='
    resp <- GET(
      url = paste(resource_uri, query, sep=''),
      add_headers(Authorization = paste('Bearer', key_get('CCM', 'AccessToken')))
    )
    stop_for_status(resp, paste('get risk factors!\n', content(resp)$message))
    data <- fromJSON(content(resp, 'text'))
    if(!data$totalSize) {
      return(list(
        Id = NA,
        CCM_Investigation__c = case,
        RecordTypeId = NA,
        CCM_RiskFactor_Info_c = NA,
        CCM_AdditionalRisk_lnfo__c = NA
      ))
    } else {
      return(list(
        Id = data$records$Id,
        CCM_Investigation__c = data$records$CCM_Investigation__c,
        RecordTypeId = data$records$RecordTypeId,
        CCM_RiskFactor_Info__c = data$records$CCM_RiskFactor_Info__c,
        CCM_AdditionalRisk_lnfo__c = data$records$CCM_AdditionalRisk_lnfo__c
      ))
    }
  })
}
