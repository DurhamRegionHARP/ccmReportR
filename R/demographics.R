# Check for incomplete data entry on
# demographic risk factors

checkDemographics <- function(investigation_id, access_token) {
  resource_url <- 'https://mohcontacttracing.my.salesforce.com/services/data/v49.0'
  query_endpoint <- '/query/?q='
  risk_factor_endpoint <- '/sobjects/CCM_Risk_Factor__c/'
  # Get all SES risk factors with missing "additional information" for the IDs supplied
  resp <- GET(
    paste(
      resource_url,
      query_endpoint,
      "SELECT+CCM_RiskFactor_Info__c,Id+FROM+CCM_Risk_Factor__c+WHERE+CCM_Investigation__c+=+'",
      investigation_id,
      "'+AND+RecordTypeId+=+'0125X0000004IbIQAU'+AND+CCM_AdditionalRisk_lnfo__c+=+null",
      sep=''
    ),
    add_headers(Authorization = paste('Bearer', access_token))
  )
  warn_for_status(resp, 'fetch demographics.')
  demographics <- fromJSON(content(resp, 'text'))
  if (!demographics$totalSize){
    # No demographic risk factors are missing information
    print("All demographics are entered!")
  } else {
    demographics_df <- data.frame(demographics$records)
    for (row in 1:nrow(demographics_df)) {
      cat(paste(
        'Found a null SES risk factor for ',
        demographics_df[row, 'CCM_RiskFactor_Info__c'],
        '\n'
        )
      )
      # Post back with "Prefer not to answer"
      # data <- list(
      #   Additional_Risk_Factor_Info__c = 'Prefer not to answer',
      # )
      # # Use a PATCH request to update a record
      # # URI: /sobjects/CCM_Risk_Factor__c/<Risk Factor ID>
      # resp <- PATCH(
      #   paste(
      #     resource_url,
      #     risk_factor_endpoint,
      #     demographics[row, 'Id']
      #   ),
      #   add_headers(Authorization = paste('Bearer', access_token)),
      #   body = data,
      #   encode = 'json'
      # )
      # warn_for_status(resp, "update risk factor!")
    }
  }
}
