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
myCases
