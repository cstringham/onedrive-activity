#Requires -Module ExchangeOnlineManagement

. $PSScriptRoot\Local\Initialize-UnlicensedAccounts.ps1

function Get-OneDriveActivity {
    [CmdletBinding()]
    param (
        [string] $Url,
        [string] $UnlicensedAccountReportPath,
        [string] $OutputFolder = ".\OneDriveActivityReports",
        [int] $DayRange = 30,
        [int] $MaxActivityCount = 100
    )

    begin {
        try{
            Connect-ExchangeOnline -ShowBanner:$false
            Write-Host "Connected!" -ForegroundColor Green
        }
        catch [Microsoft.Exchange.WebServices.Data.ServiceResponseException] {
            Write-Error $_.Exception.Message
            exit
        }
    }

    process {
        if(-not (Test-Path $OutputFolder -PathType Container)) {
            New-Item -ItemType Directory -Path $OutputFolder
        }
        else {
            Test-Path $OutputFolder/*
        }

        if ($Url -and $UnlicensedAccountReportPath) {
            Write-Error "Both Url and UnlicensedAccountReportPath cannot be provided."
            exit
        }
        
        if ($Url) {
            if ($Url -notlike "*-my.sharepoint.com/personal/*") {
                Write-Error "Invalid Url. Please provide a valid OneDrive Url."
                exit
            }
            $Urls = @($Url)
        } elseif ($UnlicensedAccountReportPath) {
            if (-not (Test-Path $UnlicensedAccountReportPath) -or $UnlicensedAccountReportPath -notlike "*.csv") {
                Write-Error "Invalid UnlicensedAccountReportPath. Please provide a valid path."
                exit
            }
            $Urls = @(Initialize-UnlicensedAccounts -Path $UnlicensedAccountReportPath)
        } else {
            Write-Error "Either Url or UnlicensedAccountReportPath must be provided."
            exit
        }

        $total = $Urls.Count
        $count = 0

        foreach($Url in $Urls) {
            Write-Host "Processing $Url" -ForegroundColor Cyan
            Write-Progress -Activity "Processing OneDrive Urls" -Status "Processing $count of $total" -PercentComplete (($count/$total)*100)
            $OutFileName = ($Url -split "/")[-1]
            $Results = Search-UnifiedAuditLog -ObjectIds "$Url*" -StartDate (Get-Date).AddDays(-($DayRange)) -EndDate (Get-Date) -ResultSize $MaxActivityCount
            if($Results) {
                $Results
            } else {
                Write-Host "No activities found for $Url" -ForegroundColor Yellow
            }
        #     # foreach($Result in $Results) {
        #     #     $Result
        #     #     $AuditData = ConvertFrom-Json $Result.AuditData
        #     #     $AuditData | Add-Member -MemberType NoteProperty -Name ActivityRecordType -Value $Result.RecordType
        #     #     $AuditData | Add-Member -MemberType NoteProperty -Name ActivityCreationTime -Value $Result.CreationTime
        #     #     $AuditData | Add-Member -MemberType NoteProperty -Name ActivityUserIds -Value $Result.UserIds
        #     #     $AuditData | Add-Member -MemberType NoteProperty -Name ActivityOperations -Value $Result.Operations
        #     #     $AuditData | Add-Member -MemberType NoteProperty -Name ActivityIdentity -Value $Result.Identity
        #     #     # if(-not $AuditData.ListId) {
        #     #     #     $AuditData | Add-Member -MemberType NoteProperty -Name ListId -Value $Result.ObjectId
        #     #     # }
        #     #     $AuditData | Export-Csv -Path "$OutputFolder\$OutFileName.csv" -Append -NoTypeInformation
        #     # }
        $count++
        }
        Write-Progress -Activity "Processing OneDrive Urls" -Status "Processing $count of $total" -PercentComplete 100
    }

    end {
        Disconnect-ExchangeOnline -Confirm:$false
    }
}

Export-ModuleMember -Function Get-OneDriveActivity