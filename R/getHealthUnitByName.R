# Look up a Health Unit's Id by name

getHealthUnitIdByName <- function(healthUnitName) {
  resp <- GET(
    paste(
      'https://mohcontacttracing.my.salesforce.com/services/data/v49.0/query/?q=',
      "SELECT+Id+FROM+PHU_Stage_Table__c+WHERE+Name='",
      healthUnitName,
      "'",
      sep=''
    ),
    add_headers(Authorization = paste('Bearer', access_token))
  )
  stop_for_status(resp, "get a health unit ID")
  healthUnitId <- fromJSON(content(resp, 'text'))
  return(healthUnitId$records)
}