function Get-OPWVaults {
    <#
    .SYNOPSIS
        Get all vaults

    .DESCRIPTION
        Get all vaults that the API key has access to.
    .NOTES
        Author:      Steven Knight
        Contact:     @StevenKnight
        Created:     2023-01-01
        Updated:

        Version history:
        1.0.0 - (2023-01-01) Function created
    #>

    #Check debug and verbose settings
    If ($PSBoundParameters['Debug'] -Or $OpwDebug ) {
        $DebugPreference = 'Continue'
        $VerbosePreference = 'Continue'
        $PSFN = "[$($MyInvocation.MyCommand)] "
    }

    #Prepare action
    $opwr = [OPWRespons]::New()

    $uri = "https://$($global:OpwHost)/v1/vaults"

    #Action
    try {
        $respons = Invoke-RestMethod -Method Get -Uri $uri -Headers $global:OpwAuthToken
    }
    catch {
        $opwr = $_ | ConvertFrom-Json
        Write-Debug ("$($PSFN) Status: $($opwr.status): $($opwr.message) $($opwr.payload)")
        return $opwr
    }

    #Interpretation
    $opwr.payload = $respons
    Write-Debug ("$($PSFN) Status: $($opwr.status): $($opwr.message) $($opwr.payload)")
    return $opwr
}