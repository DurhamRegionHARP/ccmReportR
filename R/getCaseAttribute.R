# Get attributes related to a case
getCaseAttribute <- function(attribute, case) {
  # Check attribute
  if (!length(attribute) == 1) {
    stop('Error: function parameter attribute must have length == 1!', call. = FALSE)
  }
  # Set function options
  fnOptions <- list(
    riskFactors = list(
      table = 'CCM_Risk_Factor__c',
      columns = c('Id', 'CCM_Investigation__c', 'RecordTypeId', 'CCM_RiskFactor_Info__c', 'CCM_AdditionalRisk_lnfo__c')
    ),
    symptoms = list(
      table = 'CCM_Risk_Factor__c',
      columns = c('Id', 'CCM_Investigation__c', 'RecordTypeId', 'CCM_RiskFactor_Info__c', 'CCM_AdditionalRisk_lnfo__c')
    ),
    interventions = list(
      table = 'CCM_Risk_Factor__c',
      columns = c('Id', 'CCM_Investigation__c', 'RecordTypeId', 'CCM_RiskFactor_Info__c', 'CCM_AdditionalRisk_lnfo__c')
    ),
    labResults = list(
      table = 'CCM_Risk_Factor__c',
      columns = c('Id', 'CCM_Investigation__c', 'RecordTypeId', 'CCM_RiskFactor_Info__c', 'CCM_AdditionalRisk_lnfo__c')
    ),
  )
  # Map through `cases` and return `attribute` data
  data <- map_dfr(case, function(el) {

  })
}
