#' Look up a Health Unit's Id by name
#'
#' `getHealthUnitByName()` searches the PHU_Stage_Table__c object
#' and returns the Id for the specified health unit.
#'
#' @param healthUnitName character scalar or vector. Names the
#'   health unit to use when searching for an Id.
#' @returns If the query succeeds, a character scalar or vector
#'   of health unit Id's. Otherwise an error is returned.

getHealthUnitByName <- function(healthUnitName) {
  resp <- httr::GET(
    url = paste(
      'https://mohcontacttracing.my.salesforce.com/services/data/v49.0/query/?q=',
      "SELECT+Id+FROM+PHU_Stage_Table__c+WHERE+Name='",
      gsub(' ', '+', healthUnitName),
      "'",
      sep=''
    ),
    httr::add_headers(Authorization = paste('Bearer', keyring::key_get('CCM', 'AccessToken')))
  )
  httr::stop_for_status(resp,
    paste(
      "get a health unit ID\n",
      jsonlite::fromJSON(httr::content(resp, 'text'))$message
    )
  )
  data <- jsonlite::fromJSON(httr::content(resp, 'text'))
  if (!data$totalSize) {
    stop(
      paste('There is no health unit with name', healthUnitName, '\n', sep = ''),
      call. = FALSE
    )
  }
  return(data$records$Id)
}
