# Return the risk factors for a list of cases
getAttribute <- function(caseId, optionsList) {
  query <- paste(
    "SELECT+",
    paste(optionsList$columns, collapse = ','),
    "+FROM+",
    optionsList$table,
    "+WHERE+",
    optionsList$columns[[2]],
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
  print(data)
  if (!data$totalSize) {
    attribute <- list()
    for (index in 1:length(optionsList$columns)) {
      attribute[[optionsList$columns[[index]]]] <- NA
    }
    attribute[[2]] <- caseId
  } else {
    flatData <- jsonlite::flatten(as.data.frame(data$records))
    attribute <- select(flatData, all_of(optionsList$columns))
  }
  return(attribute)
}
