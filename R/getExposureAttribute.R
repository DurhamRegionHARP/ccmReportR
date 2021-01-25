#' Get attributes related to an exposure
#'
#' `getExposureAttribute()` specifies the object used to
#' get related information about an exposure. This function
#' wraps `getAttribute()` to allow iteration over multiple
#' exposures. See `getAttribute()`.
#'
#' @param attribute character scalar. Names the CCM object used to
#'   obtain information about an exposure. One of the currently
#'   supported objects:
#'   1. `investigations`: Exposure Investigations
#' @param exposure character scalar or vector. Names the CCM Exposure Id
#'   to obtain information about.
#' @returns a `tibble` of information related to an exposure.
#' @seealso [getAttribute()] for information on how the CCM
#'   query is executed. [getExposures()] for obtaining Exposure Id's
#'   required for this function.
#' @export

getExposureAttribute <- function(attribute, exposure) {
  # Check attribute
  if (!length(attribute) == 1) {
    stop('function parameter attribute must have length == 1!', call. = FALSE)
  }
  # Set function options
  fnOptions <- list(
    investigations = list(
      table = 'Exposed_Contact__c',
      name = 'Exposure investigations',
      columns = c(
        'Id',
        'Exposure__c',
        'Name',
        'Exposure_Mode__c',
        'Investigation__c',
        'Investigation__r.CaseNumber',
        'Beginning_Date_of_Exposure_Contact__c',
        'End_Date_of_Exposure_Contact__c'
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
  data <- purrr::map_dfr(exposure, function(el) {
    getAttribute(el, fnOptions[[attribute]])
  })
}
