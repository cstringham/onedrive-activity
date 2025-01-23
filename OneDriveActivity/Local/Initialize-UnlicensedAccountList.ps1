
<#PSScriptInfo

.VERSION 0.0.1

.GUID eb6d7f00-c151-4745-abb0-5316a9c6d049

.AUTHOR Chris Stringham

.PROJECTURI https://github.com/cstringham/unlicensed-onedrive-activity

#>

<# 

.DESCRIPTION 
 Used for parsing the input list of Unlicensed OneDrive Accounts. 

#> 

Param()


function Initialize-UnlicensedAccountList() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    $csv = Import-Csv -Path $Path
    $FirstColumn = ($csv[0].PSObject.Properties | Select-Object -First 1).Name
    $regex = '^https:\/\/[^\/]+-my\.sharepoint\.com\/personal\/[^\/]+$'
    $Urls = $csv.$FirstColumn | Where-Object {$_ -match $regex}
    return $Urls
}
