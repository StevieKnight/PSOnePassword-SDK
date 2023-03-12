function Add-OPWItem {
    <#
    .SYNOPSIS
        Add a new item in the vault
    
    .DESCRIPTION
        Add a new item object in the vault.   
    
    .PARAMETER UUID
        Specify the vault UUID.

    .PARAMETER InputObject
        1Password VaultItem object which is to be created
    
    .PARAMETER InputJSON
        JSON which is to be created
  
    .NOTES
        Author:      Steven Knight
        Contact:     @StevenKnight
        Created:     2023-01-01
        Updated:     
    
        Version history:
        1.0.0 - (2023-01-01) Function created
    #>  
    param (

        [parameter(Mandatory = $false, HelpMessage = "Optional. Read VaultID from Object")]
        [ValidatePattern('^[\da-z]{26}$')]
        [string] $VaultUUID,

        [parameter(HelpMessage = 'For multiple changes at the same time')]
        [OPWVaultItem] $InputObject
    )
   
    #Prepare action
    $opwr = [OPWRespons]::New()
    
    if( "" -eq $VaultUUID){
        $VaultUUID = $InputObject.vault.id  
        
    }
    

    $uri = "https://$($global:OpwHost)/v1/vaults/$($VaultUUID)/items"
   
    $jsonBody = $InputObject | Remove-NullProperties | ConvertTo-Json -Depth 10

    #Action 
    try {
        $respons = Invoke-RestMethod -Method POST -Uri $uri -Body $jsonBody -Headers $global:OpwAuthToken -ContentType 'application/json'
    }

    catch {
        $opwr = $_ | ConvertFrom-Json 
        Write-Debug ("$($PSFN) Status: $($opwr.status): $($opwr.message) $($opwr.payload)") 
        return $opwr
    } 
    $opwr.payload = $respons
    return $opwr
}