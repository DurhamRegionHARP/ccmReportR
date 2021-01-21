#' Get attributes related to an outbreak
#'
#' `getOutbreakAttribute()` specifies the object used to
#' get related information about an outbreak. This function
#' wraps `getAttribute()` to allow iteration over multiple
#' outbreaks.
#'
#' @param attribute character scalar. Names the CCM object to
#'   obtain related information about a case. One of the
#'   currently supported objects:
#' @param outbreak character scalar or vector. Names the CCM Case Id
#'   to use when obtaining information.
#' @returns a `data.frame` of information related to an Outbreak.
#' @seealso [getAttribute()] for information on how the CCM
#'   query is executed. [getOutbreaks()] for obtaining outbreak Ids
#'   required for this function.
#' @export

getOutbreakAttribute <- function(attribute, outbreak) {
  # Check attribute
  if (!length(attribute) == 1) {
    stop('function parameter attribute must have length == 1!', call. = FALSE)
  }
  # Set function options
  fnOptions <- list(
    location = list(
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
  data <- purrr::map_dfr(outbreak, function(el) {
    getAttribute(el, fnOptions[[attribute]])
  })
}
