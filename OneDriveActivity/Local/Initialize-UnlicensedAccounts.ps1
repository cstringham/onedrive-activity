function Initialize-UnlicensedAccounts() {
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