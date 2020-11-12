#' Get attributes related to a case
#'
#' `getCaseAttribute()` specifies the object used to
#' get related information about a case. This function
#' wraps `getAttribute()` to allow iteration over multiple
#' cases. See `getAttribute()`
#'
#' @param attribute character scalar. Names the CCM object to
#'   obtain related information about a case. One of the
#'   currently supported objects:
#'   1. `exposures`: Exposures
#'   2. `interventions`: Interventions
#'   3. `labResults`: Lab Results
#'   4. `outbreaks`: Outbreaks
#'   5. `riskFactor`: Risk Factors
#'   6. `symptoms`: Symptoms
#' @param case character scalar or vector. Names the CCM Case Id
#'   to use when obtaining information.
#' @returns a `data.frame` of information related to a case.
#' @seealso [getAttribute()] for information on how the CCM
#'   query is executed. [getCases()] for obtaining Case Id's
#'   required for this function.
#' @export

getCaseAttribute <- function(attribute, case) {
  # Check attribute
  if (!length(attribute) == 1) {
    stop('function parameter attribute must have length == 1!', call. = FALSE)
  }
  # Set function options
  fnOptions <- list(
    riskFactors = list(
      table = 'CCM_Risk_Factor__c',
      name = 'Risk Factors',
      columns = c(
        'Id',
        'CCM_Investigation__c',
        'RecordType.Name',
        'CCM_RiskFactor_Info__c',
        'CCM_AdditionalRisk_lnfo__c'
      )
    ),
    symptoms = list(
      table = 'CCM_Symptoms__c',
      name = 'Symptoms',
      columns = c(
        'Id',
        'CCM_Case__c',
        'Name'
      )
    ),
    interventions = list(
      table = 'Hospitalization__c',
      name = 'Interventions',
      columns = c(
        'Id',
        'Case__c',
        'RecordType.Name',
        'Intervention__c',
        'Intervention_Information__c',
        'Hospital_Name__r.Name',
        'Start_Date__c',
        'End_Date__c'
      )
    ),
    labResults = list(
      table = 'Lab_Results__c',
      name = 'Lab Results',
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
      name = 'Exposures',
      columns = c(
        'Id',
        'Investigation__c',
        'Exposure_Mode__c',
        'Exposure__r.Name',
        'Exposure__r.Exposure_Setting_Type__c',
        'Beginning_Date_of_Exposure_Contact__c',
        'CCM_IsPrimary_or_Indexed_Investigation__c'
      )
    ),
    outbreaks = list(
      table = 'Case',
      name = 'Outbreaks',
      columns = c(
        'CCM_Investigation_Outbreak__c',
        'Id',
        'CCM_Investigation_Outbreak__r.CCM_Outbreak_Number__c',
        'CCM_Investigation_Outbreak__r.Name',
        'CCM_Investigation_Outbreak__r.CCM_Outbreak_Status__c'
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
  data <- purrr::map_dfr(case, function(el) {
    getAttribute(el, fnOptions[[attribute]])
  })
}
