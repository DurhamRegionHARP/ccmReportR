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
Open a bowser and login at: https://mohcontacttracing.my.salesforce.com/setup/connect?user_code=25XPRH6C
```

After entering user credentials, you should see `Login successful!` when you return to your R terminal.
## Get Cases
Use the `getCases()` function to get a `list()` of cases from CCM. Function parameters allow you to control how cases are identified. Below, we fetch a list of cases from CCM. We specify the health unit, the data to return, the date range to include, and limit the results to confirmed cases.
```r
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
