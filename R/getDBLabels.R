#' Helper function for building SOQL queries
#'
#' `getDBLabels()` retrieves the description of a specified
#'   object in CCM then searches for field names using the
#'   field label seen on the client-side.
#'
#' @param table Character scalar. Names the CCM object
#'   which the function will use to search for field names.
#' @param colNames Character vector. Contains a combination
#'   field names and labels to search for in `table`.
#' @returns Character vector. Field names suitable for use in
#'   subsequent SOQL queries. Elements form `colNames` not found
#'   in `table` are removed from the results.
#' @importFrom rlang .data

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
  details <- dplyr::select(data$fields, .data$name, .data$label)
  keepRows <- dplyr::filter(details, .data$label %in% colNames | .data$name %in% colNames)

  # Warn for unmatched requests
  if(length(keepRows$name) < length(colNames)) {
    warning('An unmatched column name was removed from the query.', call. = FALSE)
  }

  return(keepRows$name)
}
