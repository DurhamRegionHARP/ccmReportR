# Get attributes related to a case
getCaseAttribute <- function(attribute, case) {
  # Check attribute
  if (!length(attribute) == 1) {
    stop('function parameter attribute must have length == 1!', call. = FALSE)
  }
  # Set function options
  fnOptions <- list(
    riskFactors = list(
      table = 'CCM_Risk_Factor__c',
      columns = c(
        'Id',
        'CCM_Investigation__c',
        'RecordTypeId',
        'CCM_RiskFactor_Info__c',
        'CCM_AdditionalRisk_lnfo__c'
      )
    ),
    symptoms = list(
      table = 'CCM_Symptoms__c',
      columns = c(
        'Id',
        'CCM_Case__c',
        'Name'
      )
    ),
    interventions = list(
      table = 'Hospitalization__c',
      columns = c(
        'Id',
        'Case__c',
        'RecordTypeId',
        'Intervention__c',
        'Intervention_Information__c',
        'StartDate__c',
        'EndDate__c',
        'Hospital__c'
      )
    ),
    labResults = list(
      table = 'Lab_Results__c',
      columns = c(
        'Id',
        'Case__c',
        'CCM_LabOrderID__c',
        'CCM_ObservationResultStatus__c',
        'CCM_InterpretationValue__c',
        'CCM_ObservationDateTime__c',
        'CCM_ReportedDate__c'
      )
    ),
    exposures = list(
      table = 'Exposed_Contact__c',
      columns = c(
        'Id',
        'Investigation__c',
        'Exposure_Mode__c',
        'Exposure__c',
        'Beginning_Date_of_Exposure_Contact__c',
        'CCM_IsPrimary_or_Indexed_Investigation__c',
      )
    )
  )
  # Check correct attribute name
  if (!(attribute %in% names(fnOptions))) {
    stop(
      paste(attribute, "is not a valid attribute name!\n"),
      call. = FALSE
    )
  }
  # Map through `cases` and return `attribute` data
  data <- map_dfr(case, function(el) {
    getAttribute(el, fnOptions[[attribute]])
  })
}
