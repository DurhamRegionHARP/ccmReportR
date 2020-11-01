# Check for incomplete data entry on
# demographic risk factors

demographics <- function(investigation_id) {
  resource_url <- 'https://mohcontacttracing.my.salesforce.com/services/data/v49.0'
  query_endpoint <- '/query/?q='
  risk_factor_endpoint <- '/sobjects/CCM_Risk_Factor__c/'
  # Get all SES risk factors with missing "additional information" for the IDs supplied
  demographics <- data.frame(
    GET(
      url = paste(
        resource_url,
        "SELECT+CCM_RiskFactor_Info__c,Id+FROM+CCM_Risk_Factor__c+WHERE+CCM_Investigation__c+='",
        investigation_id,
        "'+AND+RecordTypeId='",
        "'+AND+Additional_Risk_Factor_Info__c=null",
        sep=''
      ),
      add_headers(Authorization = paste('Bearer', access_token))
    )$records
  )
  for (row in 1:nrow(demograpnics)) {
    # Post back with "Prefer not to answer
    data <- list(
      Additional_Risk_Factor_Info__c = 'Prefer not to answer',
    )
    # Use a PATCH request to update a record
    # URI: /sobjects/CCM_Risk_Factor__c/<Risk Factor ID>
    resp <- PATCH(
      paste(
        resource_url,
        risk_factor_endpoint,
        demographics[row, 'Id']
      ),
      add_headers(Authorization = paste('Bearer', access_token)),
      body = data,
      encode = 'json'
    )
    warn_for_status(resp, "update risk factor!")
  }
}
