# Return the risk factors for a list of cases
getCaseRiskFactor <- function(cases) {
  results <- map(cases, function(case) {
    query <- paste(
      "SELECT+Id,RecordTypeId,CCM_RiskFactor_Info__c,CCM_AdditionalRisk_lnfo__c",
      "FROM+CCM_Risk_Factor__c",
      "WHERE+CCM_Investigation__c='",
      case,
      "'"
      sep="+"
    )
    resp <- GET(
      url = paste(resource_uri, query, sep=''),
      add_headers(Authorization = paste('Bearer', key_get('CCM', 'AccessToken')))
    )
    stop_for_status(resp, paste('get risk factors!\n', content(resp)$message))
    data <- fromJSON(content(resp, 'text'))
    if(!data$totalSize) {
      return(list(
        Id = NA,
        RecordTypeId = NA,
        CCM_Risk_Factor__c = NA,
        CCM_AdditionalRisk_lnfo__c = NA
      ))
    } else {
      return (data$records)
    }
  })
}
b
