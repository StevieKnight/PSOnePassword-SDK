# 1Password Connect PowerShell SDK

1Password is a great password manager in the cloud. You can find it [here](https://1password.com).
The private 1Password Connect PowerShell SDK provides access to the [1Password Connect](https://support.1password.com/secrets-automation/) API. This communicates with the 1Password Connect server which must be hosted on your infrastructure.
The idea to write a PowerShell module came out of necessity, because I wanted to use 1Password with an Azure function to solve an IT task.  The library offers you the possibility to build automation scripts with PowerShell and thus create, update or delete 1Password elements automatically. The SDK does not yet support everything that is available via the API. But the foundation is laid.     

## Prerequisites

- [1Password Connect](https://support.1password.com/secrets-automation/#step-2-deploy-a-1password-connect-server) deployed in your infrastructure

## Importing

To download the file local:

```PowerShell
git clone https://github.com/StevieKnight/PSOnePassword-SDK
```

To import the 1Password Connect SDK into your Poweshell environment or script:

```PowerShell
Import-Module ".\PSOnePassword-SDK"
#Check whether a module has been imported
Get-Module PSOne*
```

## Usage

Below is a selection of the most frequently used functions of the Connect Powershell SDK. Unfortunately, more detailed information is not yet available.

### Get Vaults

Get all the tressors you have access to:

```PowerShell
$authToken = "<your_connect_token>"
$1PasswordConnectHost = "<your_connect_host>"
$respons = Connect-OPWServer -ConnectionHost $1PasswordConnectHost -BearerToken $authToken

if ($respons.status -eq 200){
   $respons = Get-OPWVaults
   if ($respons.status -eq 200){
       Write-Host $respons.payload
    }
 }
#Clean-UP
Disconnect-OPWServer
```

### Get items from vault

Get all the basic information from the items in the special vault:

```PowerShell
$respons = Get-OPWItem  -VaultUUID "<your_vault_uuid>"
if ($respons.status -eq 200){
    Write-Host $respons.payload
}
```

Get all informations and secrets from the special items in the special vault:

```PowerShell
$respons = Get-OPWItem -id "<your_item_uuid>" -VaultUUID "<your_vault_uuid>"
if ($respons.status -eq 200){
    # Display the Object field within the item
    Write-Host $respons.payload.fields
}
```

### Create new item in vault
If you want create new item, you must create new OPWVaultItem object and add data. After that you add the new item object into the vault.

```PowerShell

#create new item object
$item = New-OPWItemObject -Title "GitHub" -VaultUUID "<your_vault_uuid>" -Category "LOGIN"
$item.AddLogin("Maxmuster","PASSWORD1234")
$sectionID = $item.AddSections("Server")
$item.AddText("Server1","GitHub01", $sectionID)
$item.AddText("Server2","GitHub02", $sectionID)

# add new item object into the vault
$respons = Add-OPWItem -InputObject $item
if ($respons.status -eq 200){
    Write-Host $respons.message
}
```
### Update a item in vault

I had decided to implement Create/Update/Delete of properties with [JSON Patch](https://tools.ietf.org/html/rfc6902). This turned out to be particularly tricky for me. Especially when not individual properties are to be added, but several attributes at once. e.g. web page of type URL. Update (replace) and remove (remove) work well so far. Be careful when using them, it might not work right away. 

If you update item in the vault, do you create a JSON patch object (JSONPatchOPW). 

```PowerShell
$JSONPatch = New-OPWJsonPatch
# The different inverted commas are important, they must not be identical within the value.
$JSONPatch.Add('add','/fields','{"type": "URL","label": "Example","value": "https://example.com"}')
$JsonPatch.Add('replace','/fields/password/value','PASSWORD1234')
 
$respons = Update-OPWItem -id "<your_item_uuid>" -VaultUUID "<your_vault_uuid>" -InputObject $JSONPatch
if ($respons.status -eq 200){
    Write-Host $respons.message
}
```

### Delete item in vault
If you want to delete our article in the vault, you can use this command: 

```PowerShell

$respons = Remove-OPWItem -id "<your_item_uuid>" -VaultUUID "<your_vault_uuid>"
if ($respons.status -eq 200){
    Write-Host $respons.message
}
```


### Model Objects

The `OPWVaultItem` class represents items in 1Password. The class `OPWRespons` is the default respons object returned by all funtions in the SDK.


### Environment Variables

The Connect Go SDK makes use of the following environment variables:
* `OpwAuthToken`: the API token to be used to authenticate the client to your 1Password Connect instance.
* `OpwHost`: the hostname of your 1Password Connect instance.
* `OpwDebug `: global debug mode, if OpWDebug true. You can set this with the function `Connect-OPWServer -debug`.

### Errors
All errors returned by the OnePassword-SDK are in an `OPWRespons` object, the orginal error message, you can find in the attribut `OPWRespons.payload`:

|Code|Message|
|:---:|:---|
|200|Returns a OPW object|
|201|Item removed|
|401|Several values were returned|
|402|Unknow parameter|
|404|Item not found|
|500|Unknow Error|
|503|Service Unavailable|
