# Helper function for working with datetime values
makeTimestamp <- function(dateString) {
  # We need to work with datetime objects
  dateObj <- as.POSIXct(dateString)
  # Dates must be in the UTC timezome
  utcDate <- with_tz(dateObJ, tz = 'UTC')
  # Apply the correct date format
  zulu <- stamp("2013-01-01T06:00:00Z")
  return(zulu(dateString))
}
