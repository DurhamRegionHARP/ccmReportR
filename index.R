# Salesforce ReportR
library(httr)
library(jsonlite)
source('./R/auth.R')
source ('./R/getCases.R')

access_token <- login()
getCases(
  "SELECT+CCM_ReportedDate__c,Id+FROM+Case+WHERE+CCM_New_Diagnosing_PHU__c+=+'a1z5X00000006ZRQAY'+AND+CCM_ReportedDate__c+=+TODAY",
  access_token
)
