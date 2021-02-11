# ccmReportR 0.1.0
## Release Summary
- Adds `getDBLabels`. This function allows users to specify field labels in the `columns` parameter of `getExposures`, `getCases`, and `getOutbreaks`. Addresses [#2](https://github.com/DurhamRegionHARP/ccmReportR/issues/2).
- Corrects spelling errors in R error messages.
- Fixes a bug where `dplyr::select()` throws an error on queries that do not return results.
- Updates the default value of the `to` parameter in `getCases` and `getExposures` to `Sys.time()`.
- Updates the data returned with `getCases` to a `tibble`.

## Test environments
1. Local machine:
  - Microsoft Windows 10 x64 (build 17763), R version 4.0.2 (2020-06-22)
2. Using GitHub Actions:
  - Microsoft Windows Server 2019, R 4.0.3 (2020-10-10)
  - Mac OS X 10.15.7, R 4.0.3 (2020-10-10)
  - Ubuntu 20.04, R 4.0.3 (2020-10-10)
  - Ubuntu 20.04, R devel (2021-01-25 r79883)

## R CMD check results
Duration: 39.9s

0 errors v | 0 warnings v | 0 notes v

## Downstream dependencies
There are currently no downstream dependencies