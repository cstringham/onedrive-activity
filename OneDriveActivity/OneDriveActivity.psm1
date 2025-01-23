#Requires -Module ExchangeOnlineManagement

. $PSScriptRoot\Local\Initialize-UnlicensedAccountList.ps1

function Get-OneDriveActivity {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = 'UrlSet', Mandatory = $true)]
        [ValidateScript({
                if ($_ -match '^https:\/\/[^\/]+-my\.sharepoint\.com\/personal\/[^\/]+$') {
                    $true
                }
                else {
                    throw "Invalid Url. Please provide a valid OneDrive Url in the format https://contoso-my.sharepoint.com/personal/user_contoso_com"
                } })]
        [string] $Url,

        [Parameter(ParameterSetName = 'ReportSet', Mandatory = $true)]
        [ValidateScript({
                if ((Test-Path $_ -PathType Leaf) -and ($_ -match '\.csv$')) {
                    $true
                }
                else {
                    throw "Invalid UnlicensedAccountReportPath. Please provide a valid path to a CSV file."
                }
            })]
        [string] $UnlicensedAccountReportPath,

        [ValidateScript({
                if (Test-Path $_ -PathType Container -IsValid) {
                    $true
                }
                else {
                    throw "Invalid Output Folder. Please provide a valid path."
                }
            })]
        [string] $OutputFolder = ".\OneDriveActivityReports",
        [int] $DayRange = 30,
        [int] $MaxActivityCount = 10
    )

    begin {
        try {
            Connect-ExchangeOnline -ShowBanner:$false
        }
        catch {
            Write-Error "Failed to connect to Audit Log."
            exit
        }
        $AuditLogStatus = Get-AdminAuditLogConfig | Select-Object UnifiedAuditLogIngestionEnabled
        if (-not $AuditLogStatus.UnifiedAuditLogIngestionEnabled) {
            Write-Error "Unified Audit Log Ingestion is not enabled. Please enable it and try again. (Note: Earliest results will be from when Unifieid Audit Log Ingestion was enabled)"
            exit
        }
    }

    process {
        if (-not (Test-Path $OutputFolder -PathType Container)) {
            New-Item -ItemType Directory -Path $OutputFolder | Out-Null
        }
        New-Item -ItemType Directory -Path "$OutputFolder\$(Get-Date -Format "yyyyMMdd_HHmmss")" -Force | Out-Null
        $OutputFolder = "$OutputFolder\$(Get-Date -Format "yyyyMMdd_HHmmss")"
        if ($Url) {
            $Urls = @($Url)
        }
        elseif ($UnlicensedAccountReportPath) {
            $Urls = @(Initialize-UnlicensedAccountList -Path $UnlicensedAccountReportPath)
            if (-not $Urls) {
                Write-Error "No valid OneDrive Urls found in the report."
                exit
            }
        }

        $total = $Urls.Count
        $count = 0

        foreach ($Url in $Urls) {
            Write-Progress -Activity "Processing OneDrive Urls" -Status "Processing $Url" -PercentComplete (($count / $total) * 100)
            $OutFileName = "$(($Url -split "/")[-1]).csv"
            $Results = Search-UnifiedAuditLog -ObjectIds "$Url*" -StartDate (Get-Date).AddDays( - ($DayRange)) -EndDate (Get-Date) -ResultSize $MaxActivityCount
            if ($Results) {
                foreach ($Result in $Results) {
                    $AuditData = ConvertFrom-Json $Result.AuditData
                    [PSCustomObject]@{
                        RecordType          = $Result.RecordType
                        Operation           = $AuditData.Operation
                        Workload            = $AuditData.Workload
                        UserId              = $Result.UserIds
                        ClientIP            = $AuditData.ClientIP
                        BrowserName         = $AuditData.BrowserName
                        BrowserVersion      = $AuditData.BrowserVersion
                        IsManagedDevice     = $AuditData.IsManagedDevice
                        DeviceDisplayName   = $AuditData.DeviceDisplayName
                        SiteUrl             = $AuditData.SiteUrl
                        SourceFileExtension = $AuditData.SourceFileExtension
                        SourceFileName      = $AuditData.SourceFileName
                        SourceRelativeUrl   = $AuditData.SourceRelativeUrl
                        ModifiedProperties  = $AuditData.ModifiedProperties | ConvertTo-Json -Depth 100
                        ObjectId            = $AuditData.ObjectId
                    } | Export-Csv -Path "$OutputFolder\$OutFileName" -Append -NoTypeInformation
                }
            }
            else {
                Write-Warning "No activity found for $Url"
            }
            $count++
        }
        Write-Progress -Activity "Processing OneDrive Urls" -Status "Processing $count of $total" -PercentComplete 100
    }

    end {
        Disconnect-ExchangeOnline -Confirm:$false
    }
}

Export-ModuleMember -Function Get-OneDriveActivity