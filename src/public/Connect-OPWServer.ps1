function Connect-OPWServer {
    <#
      .SYNOPSIS
          Connect to our 1 Password connection server

      .DESCRIPTION
          Connect to your 1-password connection server and check if the connection can be established.
          Host and Authtoken save in environment for other function.

      .PARAMETER ConnectionHost
          The Hostname or IP-Adresse from your 1-password connection server

      .PARAMETER BearerToken
          The bearer acces token from your 1-password connection server

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
    [Cmdletbinding()]

    param (
      [parameter(Mandatory = $true, Position = 1)]
      [ValidatePattern('^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$')]
      [string]$ConnectionHost,

      [parameter(Mandatory = $true, Position = 2)]
      [ValidatePattern('^[A-Za-z0-9-_=]+\.[A-Za-z0-9-_=]+\.?[A-Za-z0-9-_.+/=]*$')]
      [string]$BearerToken


    )

    If ($PSBoundParameters['Debug']) {
      $DebugPreference = 'Continue'
      $VerbosePreference = 'Continue'
      New-Variable -Name OpwDebug -Scope Global -Value $True -Force:$True
      $PSFN = "[$($MyInvocation.MyCommand)] "
      Write-Debug "$($PSFN)Set OPWDebug as globle variable"
    }

    #Prepare action
    $opwr = New-Object -Type OPWRespons

    $authToken = @{ 'ContentType' = 'application/json'
      'Authorization'             = 'Bearer ' + $BearerToken
    }

    #Save OPW Host and AuthToken in the environment.
    New-Variable -Name OpwHost -Scope Global -Value $ConnectionHost -Force:$True
    Write-Debug "$($PSFN)Set OPWHost as globle variable"
    New-Variable -Name OpwAuthToken -Scope Global -Value $authToken -Force:$True
    Write-Debug "$($PSFN)Set OPWAuthToken as globle variable"

    # Get vaults because the heartbeat or health no need beare token for request
    $uri = "https://$($global:OpwHost)/v1/vaults"

    #Action
    try {
      $respons = Invoke-RestMethod -Method GET -Uri $uri -Headers $authToken
    }
    catch {
      $opwr.status = '503'
      $opwr.message = 'Service Unavailable'
      $opwr.payload = $_
      Write-Debug ("$($PSFN)Status: $($opwr.status): $($opwr.message) $($opwr.payload)")
      return $opwr
    }

    if ($null -ne $respons) {
      $opwr.message = 'Service reachable'
      Write-Debug ("$($PSFN)Status: $($opwr.status): $($opwr.message) $($opwr.payload)")
      return $opwr

    }
    else {
      $opwr.status = '500'
      $opwr.message = 'Unknow Error'
      Write-Debug ("$($PSFN) Status: $($opwr.status): $($opwr.message) $($opwr.payload)")
      return $opwr
    }



}