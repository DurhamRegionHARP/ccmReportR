# Execute a SOQL query against the CCM_Risk_Factor__c object
# The CCM_Risk_Factor__c object maps to Risk Factors
# on the client side

getRiskFactors <- function(options = list()) {
  # Fall back to defaults when no options are passed in
  if(!length(options)) {
    options$riskFactorType <- FALSE
    options$from <- 'YESTERDAY'
    options$to <- NULL
    options$columns <- 'Id'
    options$healthUnit <- NULL
  }
}
