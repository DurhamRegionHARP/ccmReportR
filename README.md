# ccmReportR
`ccmReportR` is an R package that warps the CCM API with user friendly functions. The package implements actions from the [Salesforce REST API](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/intro_what_is_rest_api.htm).

Current features include:
- OAuth2.0 authentication
- Query records using the REST API

## Installation
```r
# install from CRAN
install.packages(ccmReportR)

# install the development version from GitHub
# install.packages(devtools)
devtools::install_github("lanejames35/ccmReportR")
```
## Usage
### Authenticate
Authentication with CCM implements the OAuth2.0 Device Grant flow. User credentials are stored in the Operating System's keyring program (Keychain on macOS, Credential Store on Windows, etc.) 
```r
library(ccmReportR)

# Start the login process
login()
# You'll be prompted to visit a URL to complete the process
Open a browser and login at: https://mohcontacttracing.my.salesforce.com/setup/connect?user_code=25XPRH6C
```

After entering user credentials, you should see `Login successful!` when you return to your R terminal.
### Get Cases
Use the `getCases()` function to get a `list()` of cases from CCM. Function parameters allow you to control how cases are identified. Below, we fetch a list of cases from CCM. We specify the health unit, the data to return, the date range to include, and limit the results to confirmed cases.

```r
# *N.B.* Health unit names in CCM follow a specific spelling.
myCases <- getCases(
    healthUnit = 'Simcoe Muskoka',
    columns = c('Id', 'CCM_ReportedDate__c'),
    from = "2020-10-12",
    to = "2020-10-15",
    confirmedOnly = TRUE
)
str(myCases)
# data.frame':   32 obs. of  3 variables:
# $ attributes         :'data.frame':    32 obs. of  2 variables:
#  ..$ type: chr  "Case" "Case" "Case" "Case" ...
#  ..$ url : chr  "/services/data/v49.0/sobjects/Case/5005X0000028zhGQAQ" "/services/data/v49.0/sobjects/Case/  5005X0000029173QAA" "/services/data/v49.0/sobjects/Case/5005X00000292dEQAQ" "/services/data/v49.0/sobjects/Case/  5005X00000293QJQAY" ...
# $ Id                 : chr  "5005X0000028zhGQAQ" "5005X0000029173QAA" "5005X00000292dEQAQ" "5005X00000293QJQAY" ...
# $ CCM_ReportedDate__c: chr  "2020-10-12T12:54:36.000+0000" "2020-10-12T15:43:31.000+0000" "2020-10-12T16:00:00.000+0000" # "2020-10-12T19:18:11.000+0000" ...
```
### Case Attributes
Use the `getCaseAttribute` function to get a `data.frame` of useful information related to a case. Currently supported objects include:
- Exposures
- Interventions
- Lab Results
- Outbreaks
- Risk Factors
- Symptoms

Continuing with our previous example, let's get the interventions related to our list of cases
```r
interventions <- getCaseAttribute('interventions', myCases$Id)
str(interventions)
# tibble [46 x 8] (S3: tbl_df/tbl/data.frame)
#  $ Id                         : chr [1:46] "a1u5X0000005Q3hQAE" "a1u5X0000005T7xQAE" "a1u5X0000005T87QAE" "a1u5X0000005T8CQAU" ...
#  $ Case__c                    : chr [1:46] "5005X0000028zhGQAQ" "5005X0000029173QAA" "5005X0000029173QAA" "5005X0000029173QAA" ...
#  $ RecordType.Name            : chr [1:46] "Non-Hospital Intervention" "Non-Hospital Intervention" "Non-Hospital Intervention" "Non-Hospital Intervention" ...
#  $ Intervention__c            : chr [1:46] "Education" "Education" "Self Monitoring by Client" "Self-Isolation at Private Residence" ...
#  $ Intervention_Information__c: chr [1:46] "YES" "YES" "YES" "YES" ...
#  $ Hospital_Name__r.Name      : chr [1:46] NA NA NA NA ...
#  $ Start_Date__c              : chr [1:46] "2020-10-12" "2020-10-14" "2020-10-14" "2020-10-14" ...
#  $ End_Date__c                : chr [1:46] NA NA NA NA ...
```

## Road Map
As this projects grows and matures, possible areas for improvement include:
1. Outbreak information
2. Exposure information
3. Client information

## Contributing
This project is an open-source initiative and we welcome all contributions. Thank you to all contributors for your time and support!