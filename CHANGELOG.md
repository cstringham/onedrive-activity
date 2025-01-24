# Changelog

All notable changes to this project will be documented in this file.

## [0.0.1] - 2025-01-23

### Added
- Initial release of the OneDrive Activity module.
- Added `Get-OneDriveActivity` function to audit and document the activity of a OneDrive account.
- Added support for auditing unlicensed OneDrive accounts using a report CSV.
- Added parameters:
  - `-Url`: The URL of the OneDrive account to audit.
  - `-UnlicensedAccountReportPath`: The path to the unlicensed OneDrive accounts report CSV file.
  - `-OutputFolder`: The path to the folder where the report(s) will be saved.
  - `-DayRange`: The number of days to look back for activities.
  - `-MaxActivityCount`: The maximum number of activities to retrieve per OneDrive Account.
- Added validation for `Url` and `UnlicensedAccountReportPath` parameters to ensure correct formats.
- Added progress bar and loading animation for long-running operations.
- Added support for exporting activity data in a format recognized by Excel.

### Changed

### Fixed

## [0.1.0] - 2025-01-24

### Added
- Added `-IncludeRawResults` parameter to include raw Unified Audit Log search results in the output.
- Added timestamps for activity records.
- Added additional console outputs for increased clarity during execution.

### Changed

### Fixed

## [0.1.1] - 2025-01-24

### Added
- Added `-ExcludeSystemAndDeletedAccounts` parameter to exclude activities performed by system accounts and deleted accounts.
- Added additional console outputs for increased clarity during execution.

### Changed

### Fixed