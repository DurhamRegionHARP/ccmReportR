# Release Summary
- Adds `getExposures` and `getOutbreaks`. These functions retrieve data from Exposure and Outbreak objects, respectively.
- Adds `getExposureAttribute` and `getOutbreakAttribute`. These retrieve data related to an exposure or an outbreak.
- Adds `tibble` as a new import.
- Removes the `attribute` property from the data returned with `getExposures`, `getCases`, and `getOutbreaks`.
- Updates the Salesforce API version to v50.0.
- Updates the DESCRIPTION file to show the project URL and BugReport links.
- Updates the function reference with consistent wording across similar functions.

## Test environments
1. Local machine:
  - Microsoft Windows 10 x64 (build 17763), R version 4.0.2 (2020-06-22)
2. Using Travis CI:
  - Ubuntu 16.04.6 LTS, R version 4.0.3 (2020-10-10)
  - Mac OS X 10.13.6, R version 4.0.3 (2020-10-10)

## R CMD check results
Duration: 29.1s

0 errors v | 0 warnings v | 0 notes v

## Downstream dependencies
There are currently no downstream dependencies