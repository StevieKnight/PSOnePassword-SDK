function Remove-OPWItem {
    <#
    .SYNOPSIS
        Remove item from the vault
    
    .DESCRIPTION
        Remove item from the vault using the exact title or with the ID of the item in the vault.  
    
    .PARAMETER ID
        Specify the vault item ID

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

    if ( '' -ne $Title) {
             
        # Get ID from Vault Item
        $opwr = Get-OPWItem -Title $Title -VaultUUID $VaultUUID
        
        if ($opwr.status -eq 200) {
            $Id = $opwr.respons.id 
           
        }
        else {
            $opwr.message = "Item cannot be removed. $($opwr.message)"
            Write-Debug ("$($PSFN) Status: $($opwr.status): $($opwr.message) $($opwr.respons)") 
            return $opwr
        }
    
    }
    
    #ID action
    if (('' -ne $Id)) {
        $uri = "https://$($global:OpwHost)/v1/vaults/$($VaultUUID)/items/$($id)"
    }
    else {
        $opwr = $_ | ConvertFrom-Json 
        Write-Debug ("$($PSFN) Status: item $($Id) removed from vault. $($opwr.status): $($opwr.message) $($opwr.respons)") 
        return $opwr
    }
            
            
    #Action 
    try {
        Invoke-RestMethod -Method Delete -Uri $uri -Headers $global:OpwAuthToken -ContentType 'application/json;charset=utf-8' 
    }
    catch {
        $opwr = $_ | ConvertFrom-Json 
        Write-Debug ("$($PSFN) Status: $($opwr.status): $($opwr.message) $($opwr.respons)") 
        return $opwr
    } 
        
    # Interpretation
    $opwr.status = 201
    $opwr.message = "item $($Id) removed from vault $($VaultUUID)"
    $opwr.respons = $null
    Write-Debug ("$($PSFN) Status: $($opwr.status): $($opwr.message) $($opwr.respons)") 
    return $opwr
 
}