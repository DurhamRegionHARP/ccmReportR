# Return the risk factors for a list of cases
getAttribute <- function(caseId, optionsList) {
  query <- paste(
    "SELECT+",
    paste(optionsList$columns, collapse = ','),
    "+FROM+",
    optionsList$table,
    "+WHERE+",
    optionsList$caseField,
    "='",
    caseId,
    "'",
    sep=""
  )
  resource_uri <- 'https://mohcontacttracing.my.salesforce.com/services/data/v49.0/query/?q='
  resp <- GET(
    url = paste(resource_uri, query, sep=''),
    add_headers(Authorization = paste('Bearer', key_get('CCM', 'AccessToken')))
  )
  stop_for_status(resp, paste('get attributes!\n',  fromJSON(content(resp, 'text'))$message))
  data <- fromJSON(content(resp, 'text'))
  if (!data$totalSize) {
    for (index in 1:length(optionList$columns)) {
      dataWithLabels <- list(
        optionsList$columns[[index]] = NA
      )
      # Override the case id property
      dataWithLabels$investigationId <- caseId
    }
  } else {
    for (index in 1:length(optionList$columns)) {
      dataWithLabels <- list(
        optionsList$columns[[index]] = data$records[[index]]
      )
    }
  }
  return(dataWithLabels)
}
