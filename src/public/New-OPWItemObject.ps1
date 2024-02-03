function New-OPWItemObject {
    <#
    .SYNOPSIS
        Create new OPWVaultItem object

    .DESCRIPTION
        Create a new OPWVaultItem object

    .NOTES
        Author:      Steven Knight
        Contact:     @StevenKnight
        Created:     2023-01-01
        Updated:

        Version history:
        1.0.0 - (2023-01-01) Function created
    #>
    # Parameter help description
    param(
        [parameter(Mandatory = $true)]
        [string] $Title,

        [parameter(Mandatory = $true)]
        [string] $Category,

        [parameter(Mandatory = $true)]
        [ValidatePattern('^[\da-z]{26}$')]
        [string] $VaultUUID

    )

    #Check debug and verbose settings
    If ($PSBoundParameters['Debug'] -Or $OpwDebug ) {
        $DebugPreference = 'Continue'
        $VerbosePreference = 'Continue'
        $PSFN = "[$($MyInvocation.MyCommand)] "
    }

    $opwv = [OPWVaultItem]::New($Title, $Category, $VaultUUID)
    Write-Debug ("$($PSFN) Create new OPWVaultItem Object")
    return [OPWVaultItem] $opwv
}