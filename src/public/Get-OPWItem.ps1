function Get-OPWItem {
    <#
    .SYNOPSIS
        Get item from the vault

    .DESCRIPTION
        Retrieve items from the vault using the exact title or with the ID of the item in the vault.

    .PARAMETER ID
        Specify the vault item ID to

    .PARAMETER UUID
        Specify the vault UUID.

    .PARAMETER Title
        Search title in the vault. The title must be searched for exactly as it appears in the vault.


    .NOTES
        Author:      Steven Knight
        Contact:     @StevenKnight
        Created:     2023-01-01
        Updated:

        Version history:
        1.0.0 - (2023-01-01) Function created
    #>
    [CmdletBinding()]
    param (
        [parameter(HelpMessage = 'The title must be searched for exactly')]
        [string] $Title,

        [ValidatePattern('^[\da-z]{26}$')]
        [string] $Id,

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

    #Prepare action
    $opwr = [OPWRespons]::New()

    if (('' -ne $Id)) {
        # ID action
        $uri = "https://$($global:OpwHost)/v1/vaults/$($VaultUUID)/items/$($id)"


    }
    elseif ( '' -ne $Title) {
        # Title action
        $filter = 'title eq "' + $($Title) + '"'
        $uri = "https://$($global:OpwHost)/v1/vaults/$($VaultUUID)/items?filter=$($filter)"
    } else {
        $uri = "https://$($global:OpwHost)/v1/vaults/$($VaultUUID)/items"
    }



    #Action
    try {
        $respons = Invoke-RestMethod -Method GET -Uri $uri -Headers $global:OpwAuthToken -ContentType 'application/json;charset=utf-8'
    }
    catch {
        $opwr = $_ | ConvertFrom-Json
        Write-Debug ("$($PSFN) Status: $($opwr.status): $($opwr.message) $($opwr.payload)")
        return $opwr
    }

    # Interpretation
    # ID action
    if (('' -ne $Id)) {
        $opwr.message = "item $($Id) found"
        $opwr.payload = $respons
        Write-Debug ("$($PSFN) Status: $($opwr.status): $($opwr.message) $($opwr.payload)")
        return $opwr
    }

    # Title filter action
    # No result
    if ($respons.Count -eq 0) {
        $opwr.status = 404
        $opwr.message = "item with title '$($Title)' not found"
        Write-Debug ("$($PSFN) Status: $($opwr.status): $($opwr.message) $($opwr.payload)")
        return $opwr
    }

    # To many result found
    if (($respons.Count -gt 1) -and ("" -ne $Title)) {
        $opwr.status = 401
        $opwr.message = "Found $($respons.Count) items in vault $($VaultUUID) with title '$($Title)'. Please prefer to use UUID"
        Write-Debug ("$($PSFN) Status: $($opwr.status): $($opwr.message) $($opwr.payload)")
        return $opwr

    }
    if (($respons.Count -gt 1) -and ("" -eq $Title)) {

        $opwr.message = "Many items found in vault $($VaultUUID)."
        $opwr.payload = $respons
        Write-Debug ("$($PSFN) Status: $($opwr.status): $($opwr.message) $($opwr.payload)")
        return $opwr
    }

    # Found one item with title and read details
    if ($respons.Count -eq 1) {

        $itemDetails = Get-OPWItem -id $respons.ID -VaultUUID $VaultUUID
        $opwr.message = "Found item in vault $($VaultUUID) with title '$($Title)'."
        $opwr.payload = $itemDetails.payload
        Write-Debug ("$($PSFN) Status: $($opwr.status): $($opwr.message) $($opwr.payload)")
        return $opwr
    }
}