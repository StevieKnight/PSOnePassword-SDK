function BuildInvokeParameter {
    param (
        [parameter(Mandatory = $true, Position = 1)]
        [string] $method,

        [parameter(Mandatory = $true, Position = 2)]
        [string] $path
    )


    if ((Test-Path variable:global:OpwHost) -and (Test-Path variable:global:OpwToken)){

        $url = "https://$($global:OpwHost)$($path)"

        $Param = @{
          Method = $method
          Uri = $url


        }
    }
    #Prüfen ob HOST / Token set

    return [System.Object] $Param

}