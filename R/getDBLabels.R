# Extract field labels from field description
getDBLabels <- function(table, colNames) {
  resource_uri <- paste0(
    'https://mohcontacttracing.my.salesforce.com//services/data/v50.0/sobjects/',
    table,
    '/describe'
  )
  resp <- httr::GET(
    url = resource_uri,
    httr::add_headers(Authorization = paste('Bearer', keyring::key_get('CCM', 'AccessToken')))
  )
  httr::stop_for_status(
    resp,
    paste(
      'table information!\n',
      jsonlite::fromJSON(httr::content(resp, 'text'))$message
    )
  )

  data <- jsonlite::fromJSON(httr::content(resp, 'text'))

  # Match the field name or the field label to user request
  details <- dplyr::select(data$fields, name, label)
  keepRows <- dplyr::filter(details, label %in% colNames | name %in% colNames)

  # Warn for unmatched requests
  if(length(keepRows$name) < length(colNames)) {
    warning('An unmatched column name was removed from the query.', call. = FALSE)
  }

  return(keepRows$name)
}
