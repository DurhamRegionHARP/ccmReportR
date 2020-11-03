# Find risk factors associatted with an investigation ID
checkRiskFactor <- function(investigation_id, risk_factor) {
  # Query CCM for "risk_factor" with "investigation_id"
  # If no return, risk factor is missing, we can add it
  # If risk factor is return, taken no action
  resource_uri <- 'https://mohcontacttracing.my.salesforce.com/services/data/v49.0'
  query_endpoint <- '/query/?q='
  risk_factor_endpoint <- '/sobjects/CCM_Risk_Factor__c/'

  query <- paste(
    "SELECT+CCM_RiskFactor_Info__c,Id+FROM+CCM_Risk_Factor__c+WHERE+CCM_Investigation__c+='",
    investigation_id,
    "'+AND+CCM_RiskFactor_Info__c+='",
    str_replace_all(risk_factor, "\\s", "+"),
    "'",
    sep=""
  )
  resp <- GET(
    url = paste(resource_uri, query_endpoint, query, sep=''),
    add_headers(Authorization = paste('Bearer', key_get('Case and Conatct Management', 'AccessToken')))
  )
  warn_for_status(resp)
  data <- fromJSON(content(resp, 'text'))
  if (!data$totalSize) {
    # Add the risk factor
    data <- list(
      CCM_Investigation__c = investigation_id,
      CCM_RiskFactor_Info__c = risk_factor,
      RecordTypeId = '0125X0000004ILJQA2'
    )
    resp <- POST(
      url = paste(resource_uri, risk_factor_endpoint, sep=''),
      add_headers(Authorization = paste('Bearer', access_token)),
      body = data,
      encode = 'json'
    )
    warn_for_status(resp, "update risk factor!")
    message_for_status(resp)
  } else {
    # Take no action
    print("All clear!")
  }
}
