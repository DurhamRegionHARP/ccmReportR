# Salesforce ReportR
library(httr)
library(jsonlite)
source('./R/login.R')
source('./R/getCases.R')
source('./R/checkRiskFactor.R')

access_token <- login()
cases_list <- data.frame(
  getCases(
    "SELECT+Epidemiologic_link_Status__c,Id+FROM+Case+WHERE+CCM_New_Diagnosing_PHU__c+=+'a1z5X00000006ZRQAY'+AND+CCM_ReportedDate__c+=+YESTERDAY+AND+CCM_Classification__c+=+'CONFIRMED'+AND+Epidemiologic_linkage__c+=+'Yes'",
    access_token
  )$records
)
for (row in 1:nrow(cases_list)) {
  # Look for the required risk factor
  # based on the value of 'Epidemiologic_link_Status__c'
  switch (
    cases_list[row, 'Epidemiologic_link_Status__c'],
    'Household contact' = checkRiskFactor(cases_list[row, 'Id'], 'Household contact with a case', access_token),
    'Close contact' = checkRiskFactor(cases_list[row, 'Id'], 'Close contact with a case', access_token),
    'Travel' = checkRiskFactor(cases_list[row, 'Id'], 'Travel outside province in the last 14 days (specify province or country)', access_token)
    # 'Outbreak related' = checkOutbreakRiskFactor(cases_list[row, 'Id'])
    )
}
