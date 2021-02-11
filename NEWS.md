# v0.1.0
- Adds `getDBLabels`. This function allows users to specify field labels in the `columns` attribute of `getExposures`, `getCases`, and `getOutbreaks`. Addresses [#2](https://github.com/DurhamRegionHARP/ccmReportR/issues/2).
- Corrects spelling errors in R error messages.
- Fixes a bug where `dplyr::select()` throws an error on queries that do not return results.
- Updates the default value of the `to` parameter in `getCases` and `getExposures` to `Sys.time()`.
- Updates the data returned with `getCases` to a `tibble`.

# v0.0.3 2021-01-26
- Adds `getExposures` and `getOutbreaks`. These functions retrieve data from Exposure and Outbreak objects, respectively.
- Adds `getExposureAttribute` and `getOutbreakAttribute`. These retrieve data related to an exposure or an outbreak.
- Adds `tibble` as a new import.
- Removes the `attribute` property from the data returned with `getExposures`, `getCases`, and `getOutbreaks`.
- Updates the Salesforce API version to v50.0.
- Updates the DESCRIPTION file to show the project URL and BugReport links.
- Updates the function reference with consistent wording across similar functions.
