#' Helper function for building date strings
#'
#' `makeTimestame()` generates ISO-8601 formatted
#'   date strings in UTC. This is the format required
#'   to query datetime fields in CCM.
#'
#' @param dateString character scalar. Names the date
#'   which the function will use to create the formatted
#'   datetime.
#' @returns character scalar. An ISO-8601 formatted date
#'   in the UTC timezone suitable for use in CCM queries.

makeTimestamp <- function(dateString) {
  # We need to work with datetime objects
  dateObj <- as.POSIXct(dateString)
  # Dates must be in the UTC timezome
  utcDate <- lubridate::with_tz(dateObj, tz = 'UTC')
  # Apply the correct date format
  return(format(utcDate, '%Y-%m-%dT%H:%M:%SZ'))
}
