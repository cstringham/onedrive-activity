<p align="center">
    <a href="https://www.powershellgallery.com/packages/OneDrive-Activity"><img src="https://img.shields.io/powershellgallery/v/OneDrive-Activity"></a>
    <img src="https://img.shields.io/powershellgallery/dt/OneDrive-Activity">
    <br>
    <img src="https://img.shields.io/github/license/cstringham/onedrive-activity">    
</p>

# OneDrive Activity
This module aims to simplify the process of auditing and documenting the activity of a OneDrive account. It provides a function that allows the user to generate a report of activities from the Unified Audit Log of a OneDrive account. The report is saved in a CSV file and contains the following information:
- ActivityDateTime
- ActivityDateTime(UTC)
- RecordType
- Operation
- Workload
- UserId
- ClientIP
- BrowserName
- BrowserVersion
- IsManagedDevice
- DeviceDisplayName
- SiteUrl
- SourceFileExtension
- SourceFileName
- SourceRelativeUrl
- ModifiedProperties
- ObjectId

Additionally, the module provides the ability to audit activity on unlicensed OneDrive accounts by supplying the unlicensed OneDrive account report CSV. To generate this report, navigate to your organization's SharePoint Admin Center > Reports > OneDrive accounts and click the "Download report" button.

![Unlicensed OneDrive Accounts Report](images/Unlicensed%20OneDrive%20Accounts.png)

> **Note:** The Unified Audit Log must be enabled in the Security & Compliance Center for the OneDrive account to be audited. For more information, see [Search the audit log in the Security & Compliance Center](https://docs.microsoft.com/en-us/microsoft-365/compliance/search-the-audit-log-in-security-and-compliance?view=o365-worldwide).

## Installation
```powershell
Install-Module -Name OneDrive-Activity
```
### Prerequisites
- [Exchange Online Management Module](https://www.powershellgallery.com/packages/ExchangeOnlineManagement)
    - Used to access the Unified Audit Log
## Usage

### Parameters
- **-Url**: The URL of the OneDrive account to audit in the format of https://contoso-my.sharepoint.com/personal/user_contoso_com (Cannot be used with -UnlicensedAccountReportPath).
- **-UnlicensedAccountReportPath**: The path to the unlicensed OneDrive accounts report CSV file. (Cannot be used with -Url).
- **-OutputFolder**: The path to the folder where the report(s) will be saved. If not specified, the report will be saved to ./OneDriveActivityReports.
- **-DayRange**: The number of days to look back for activities. Default is 30 days.
- **-MaxActivityCount**: The maximum number of activities to retrieve per OneDrive Account. Default is 10.
- **-IncludeRawResults**: Include the raw Unified Audit Log searh results as an additional output CSV file.
- **-ExcludeSystemAndDeletedAccounts**: Exclude activities performed by system accounts and deleted accounts from the report.

### Examples
**Example 1: Audit a single OneDrive account**
```powershell
Get-OneDriveActivity -Url "https://contoso-my.sharepoint.com/personal/user_contoso_com" -OutputFolder "C:\Reports" -DayRange 90 -MaxActivityCount 20
```

**Example 2: Audit unlicensed OneDrive accounts**
```powershell
Get-OneDriveActivity -UnlicensedAccountReportPath "C:\Reports\UnlicensedOneDriveAccounts.csv" -OutputFolder "C:\Reports" -DayRange 90 -MaxActivityCount 20
```

**Example 3: Include raw results in the report**
```powershell
Get-OneDriveActivity -Url "https://contoso-my.sharepoint.com/personal/user_contoso_com" -OutputFolder "C:\Reports" -DayRange 90 -MaxActivityCount 20 -IncludeRawResults
```

**Example 4: Exclude system and deleted accounts from the report**
```powershell
Get-OneDriveActivity -Url "https://contoso-my.sharepoint.com/personal/user_contoso_com" -OutputFolder "C:\Reports" -DayRange 90 -MaxActivityCount 20 -ExcludeSystemAndDeletedAccounts
```

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.