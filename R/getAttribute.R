#' Get data from CCM for a specified case
#'
#' `getAttribute()` queries CCM for details about
#' a case. the parameter `optionsList` specifies the
#' columns to return.
#'
#' @param caseId character scalar. Names the case to
#'   obtain information about.
#' @param optionsList list object. Controls the behaviour
#'  of the query, including the filter for the query, and
#'  data to return.
#' @returns If the query succeeds, a `list()` containing data
#'  for the specified `caseId`. Otherwise, a `list()` of
#'  `NA` values.

getAttribute <- function(caseId, optionsList) {
  # Outbreaks require both case Id and outbreak Id in the WHERE clause
  whereClause <- paste(optionsList$columns[[2]], "='", caseId, "'", sep = '')
  if (optionsList$name == 'Outbreaks') {
    whereClause <- paste(
      whereClause,
      '+AND+',
      optionsList$columns[[1]],
      '!=null',
      sep = ''
    )
  }
  query <- paste(
    "SELECT+",
    paste(optionsList$columns, collapse = ','),
    "+FROM+",
    optionsList$table,
    "+WHERE+",
    whereClause,
    sep = ''
  )
  resource_uri <- 'https://mohcontacttracing.my.salesforce.com/services/data/v50.0/query/?q='
  resp <- httr::GET(
    url = paste(resource_uri, query, sep=''),
    httr::add_headers(Authorization = paste('Bearer', keyring::key_get('CCM', 'AccessToken')))
  )
  httr::stop_for_status(
    resp,
    paste(
      'get attributes!\n',
      jsonlite::fromJSON(httr::content(resp, 'text'))$message
    )
  )
  data <- jsonlite::fromJSON(httr::content(resp, 'text'))
  attribute <- list()
  if (!data$totalSize) {
    for (index in 1:length(optionsList$columns)) {
      attribute[optionsList$columns[[index]]] <- NA
    }
    attribute[[2]] <- caseId
  } else {
    for (index in 1:length(data$records)) {
      if (!typeof(data$records[[index]]) == 'list') {
        attribute[optionsList$columns[length(attribute) + 1]] <- data$records[index]
      } else {
        if (!names(data$records[index]) == 'attributes') {
          for (id in 1:length(data$records[[index]])) {
            if(!names(data$records[[index]][id]) == 'attributes') {
              attribute[optionsList$columns[length(attribute) + 1]] <- data$records[[index]][id]
            }
          }
        }
      }
    }
  }
  return(attribute)
}
