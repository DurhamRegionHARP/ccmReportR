#' Get attributes related to an exposure
#'
#' `getExposureAttribute()` specifies the object used to
#' get related information about an exposure. This function
#' wraps `getAttribute()` to allow iteration over multiple
#' exposures. See `getAttribute()`
#'
#' @param attribute character scalar. Names the CCM object to
#'   obtain related information about a case. One of the
#'   currently supported objects:
#'   1. `investigations`: Exposure investigations
#'   2. `locations`: Locations
#' @param exposure character scalar or vector. Names the CCM Case Id
#'   to use when obtaining information.
#' @returns a `data.frame` of information related to a case.
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
        'id'
      )
    ),
    locations = list(
      table = 'Exposed_Contact__c',
      name = 'Exposure investigations',
      columns = c(
        'id'
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
