function Update-OPWItem {
    <#
    .SYNOPSIS
        Update items in the vault

    .DESCRIPTION
        Either individual properties of an item or several properties can be updated.

    .PARAMETER ID
        Specify the vault item ID

    .PARAMETER UUID
        Specify the vault UUID.

    .PARAMETER Operation
        Applies an add, remove, or replace operation on an item or the fields of an item. Uses the RFC6902 JSON Patch document standard.
    .PARAMETER Path
        An RFC6901 JSON Pointer to the item, an item attribute, an item field by field ID, or an item field attribute. For example: "/fields/username/value"
    .PARAMETER Value
        The new value to apply at the path.

    .PARAMETER InputObject
        For multiple changes at the same time. Create a new JSONPatchOPW object with New-JsonPatch and add the changes.


    .NOTES
        Author:      Steven Knight
        Contact:     @StevenKnight
        Created:     2023-01-01
        Updated:

        Version history:
        1.0.0 - (2023-01-01) Function created
    #>
    param (

        [parameter(Mandatory = $true)]
        [ValidatePattern('^[\da-z]{26}$')]
        [string] $Id,

        [parameter(Mandatory = $true)]
        [ValidatePattern('^[\da-z]{26}$')]
        [string] $VaultUUID,

        [parameter(HelpMessage = 'Support operations is add,replace,remove')]
        [string] $Operation,

        [parameter(HelpMessage = 'JSON path to item attribute')]
        [string] $path,

        [parameter(HelpMessage = 'New value to item attribute')]
        [string] $value,

        [parameter(HelpMessage = 'For multiple changes at the same time')]
        [JSONPatchOPW] $InputObject

    )

    #Check debug and verbose settings
    If ($PSBoundParameters['Debug'] -Or $OpwDebug ) {
        $DebugPreference = 'Continue'
        $VerbosePreference = 'Continue'
        $PSFN = "[$($MyInvocation.MyCommand)] "
    }

    #Prepare action
    $opwr = [OPWRespons]::New()

    if ( $null -ne $InputObject)
    {
     $jsonBody = $InputObject.OutJSONPatch()
     Write-Debug ("$($PSFN) JSON: $($jsonBody)")

    } elseif ( ($path -match '([\/]{1}[a-z0-9.]+)+([a-z0-9.])$') -and ('' -ne $value) -and ('add', 'replace', 'remove').Contains($Operation)) {

            $Body = New-Object -TypeName JSONPatchOPW
            $Body.Add($operation, $path, $value)
            $jsonBody = $body.OutJSONPatch()
            Write-Debug ("$($PSFN) JSON: $($jsonBody)")

    } else {

            $opwr.status = '402'
            $opwr.message = 'No vaild parameter to update funtion'
            Write-Debug ("$($PSFN) Status: $($opwr.status): $($opwr.message) $($opwr.payload)")
            return $opwr
    }

    $uri = "https://$($global:OpwHost)/v1/vaults/$($VaultUUID)/items/$($id)"

    #Action
    try {
        $respons = Invoke-RestMethod -Method PATCH -Uri $uri -Body $jsonBody -Headers $global:OpwAuthToken -ContentType 'application/json-patch+json'
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