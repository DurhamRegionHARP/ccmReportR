# ccmReportR

<!-- badges: start -->
[![R-CMD-check](https://github.com/DurhamRegionHARP/ccmReportR/workflows/R-CMD-check/badge.svg)](https://github.com/DurhamRegionHARP/ccmReportR/actions)
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/ccmReportR)](https://cran.r-project.org/package=ccmReportR)
[![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/ccmReportR)](https://cran.r-project.org/package=ccmReportR)
<!-- badges: end -->

`ccmReportR` is an R package that warps the CCM API with user friendly functions. The package implements actions from the [Salesforce REST API](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/intro_what_is_rest_api.htm).

Current features include:
- OAuth2.0 authorization
- Query records using the REST API

## Installation
```r
# install from CRAN
install.packages("ccmReportR")

# install the development version from GitHub
# install.packages("devtools")
devtools::install_github("DurhamRegionHARP/ccmReportR")
```
## Usage
### Authenticate
Authorization with CCM implements the [OAuth2.0 Device Authorization Grant](https://oauth.net/2/device-flow/). After a successful authentication, an access token is stored in the operating system's keyring program (Keychain on macOS, Credential Store on Windows, etc.) for use in subsequent requests.
```r
library(ccmReportR)

# Start the login process
login()
# You'll be prompted to visit a URL to complete the process
Open a browser and login at: https://mohcontacttracing.my.salesforce.com/setup/connect?user_code=25XPR
```

After completing the login process in a web browser, you should see `Login successful!` when you return to your R terminal.

### Get Data
Use `getCases`, `getExposures`, and `getOutbreaks` to get a `tibble` of data from CCM. Typically, this is the starting point for most applications. Function parameters allow you to control how data are filtered and what fields are returned. Below, we fetch a list of cases from CCM. We specify the health unit, the data to return, the date range to include, and limit the results to confirmed cases. Notice the `columns` parameter contains a combination of CCM field names and labels.

```r
# *N.B.* Health unit names in CCM follow a specific spelling.
# Id's have been truncated for safety.
myCases <- getCases(
    healthUnit = 'Durham Region Health Department',
    columns = c('Id', 'Reported Date', 'Classification'),
    from = "2020-10-12",
    to = "2020-10-15 23:59:59",
    confirmedOnly = TRUE
)
str(myCases)
# tibble [127 x 3] (S3: tbl_df/tbl/data.frame)
#  $ Id                   : chr [1:127] "5005X0000028f" "5005X0000028q" "5005X0000028v" "5005X0000028x" ...
#  $ CCM_Classification__c: chr [1:127] "CONFIRMED" "CONFIRMED" "CONFIRMED" "CONFIRMED" ...
#  $ CCM_ReportedDate__c  : chr [1:127] "2020-10-13T00:28:19.000+0000" "2020-10-13T08:23:53.000+0000" "2020-10-12T12:00:00.000+0000" 2020-10-12T12:00:00.000+0000" ...
 ```
### Attributes
Use `getCaseAttribute`, `getExposureAttribute`, or `getOutbreakAttribute` to get a `tibble` of related information. Currently supported attributes for cases include:
- Exposures
- Interventions
- Lab Results
- Outbreaks
- Risk Factors
- Symptoms

for exposures:
- Exposure investigations

and for outbreaks:
- Exposures
- Investigations
- Locations

Continuing with our previous example, let's get the interventions related to our list of cases. 
```r
# Id's have been redacted for safety.
interventions <- getCaseAttribute('interventions', myCases$Id)
str(interventions)
# tibble [314 x 8] (S3: tbl_df/tbl/data.frame)
#  $ Id                         : chr [1:314] "a1u5X0000005" "a1u5X0000005" "a1u5X0000005" "a1u5X0000005" ...
#  $ Case__c                    : chr [1:314] "5005X0000028f" "5005X0000028f" "5005X0000028f" "5005X0000028q" ...
#  $ RecordType.Name            : chr [1:314] "Non-Hospital Intervention" "Non-Hospital Intervention" "Non-Hospital Intervention" "Non-Hospital Intervention" ...
#  $ Intervention__c            : chr [1:314] "Self-Isolation at Private Residence" "Active Monitoring by PHU" "Education" "Active Monitoring by PHU" ...
#  $ Intervention_Information__c: chr [1:314] "YES" "YES" "YES" "YES" ...
#  $ Hospital_Name__r.Name      : chr [1:314] NA NA NA NA ...
#  $ Start_Date__c              : chr [1:314] "2020-10-10" "2020-10-12" "2020-10-12" "2020-10-16" ...
#  $ End_Date__c                : chr [1:314] "2020-10-18" "2020-10-18" "2020-10-18" NA ...
```

## Road Map
This project is actively seeking input on how to best serve the community. We want to hear from you! Please file a issue or start a discussion.

## Contributing
This project is an open-source initiative and we welcome all contributions. Thank you to all contributors for your time and support!
