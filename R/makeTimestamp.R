# Helper function for working with datetime values
makeTimestamp <- function(dateString) {
  # We need to work with datetime objects
  dateObj <- as.POSIXct(dateString)
  # Dates must be in the UTC timezome
  utcDate <- with_tz(dateObj, tz = 'UTC')
  # Apply the correct date format
  return(format(utcDate, '%Y-%m-%dT%H:%M:%SZ'))
}
