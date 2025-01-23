function Initialize-UnlicensedAccounts() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    $csv = Import-Csv -Path $Path
    $FirstColumn = ($csv[0].PSObject.Properties | Select-Object -First 1).Name
    return $csv.$FirstColumn
}