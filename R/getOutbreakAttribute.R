#' Get attributes related to an outbreak
#'
#' `getOutbreakAttribute()` specifies the object used to
#' get related information about an outbreak. This function
#' wraps `getAttribute()` to allow iteration over multiple
#' outbreaks.
#'
#' @param attribute Character scalar. Names the CCM object to
#'   obtain related information about a case. One of the
#'   currently supported objects:
#'   1. `exposures`
#'   2. `investigations`
#'   3. `locations`
#' @param outbreak Character scalar or vector. Names the Outbreak Id
#'   to use when obtaining information.
#' @returns A `tibble` of information related to an Outbreak.
#' @seealso [getAttribute()] for information on how the CCM
#'   query is executed. [getOutbreaks()] for obtaining Outbreak Ids
#'   required for this function.
#' @export

getOutbreakAttribute <- function(attribute, outbreak) {
  # Check attribute
  if (!length(attribute) == 1) {
    stop('function parameter attribute must have length == 1!', call. = FALSE)
  }
  # Set function options
  fnOptions <- list(
    locations = list(
      table = "Location_Outbreak__c",
      name = "Location",
      columns = c(
        "Id",
        "MD_Outbreak__c",
        "MD_Location__r.Name",
        "MD_Location__r.CCM_Location_Type__c",
        "MD_Location__r.CCM_Street__c",
        "MD_Location__r.CCM_City__c",
        "MD_Location__r.CCM_Postal_Code__c"
      )
    ),
    exposures = list(
      table = "CCM_Exposure__c",
      name = "Exposure",
      columns = c(
        "Id",
        "CCM_Exposure_Outbreak__c",
        "Name",
        "CCM_Location__r.Name",
        "Exposure_Setting_Type__c",
        "CCM_Date_Time_Arrived__c",
        "CCM_Date_Time_Departed__c",
        "PHU_Exposure__r.Name"
      )
    ),
    investigations = list(
      table = "Case",
      name = "Investigations",
      columns = c(
        "Id",
        "CCM_Investigation_Outbreak__c",
        "CaseNumber",
        "RecordType.Name",
        "Status",
        "CCM_Classification__c",
        "CCM_New_Responsible_PHU__r.Name"
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
  # Map through `outbreaks` and return `attribute` data
  data <- purrr::map_dfr(outbreak, function(el) {
    getAttribute(el, fnOptions[[attribute]])
  })
}
