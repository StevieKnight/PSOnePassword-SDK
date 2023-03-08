function Disconnect-OPWServer {
    <#
    .SYNOPSIS
        Clear all connection variable
    
    .DESCRIPTION
        Cleaning all variables that the connection function has set in the global area
        
    .NOTES
        Author:      Steven Knight
        Contact:     @StevenKnight
        Created:     2023-01-01
        Updated:     
    
        Version history:
        1.0.0 - (2023-01-01) Function created
    #>   
    [Cmdletbinding()]
    param()

    
    #Check debug and verbose settings
    If ($PSBoundParameters['Debug'] -Or $OpwDebug ) {
        $DebugPreference = 'Continue'
        $PSFN = "[$($MyInvocation.MyCommand)] "
    }

    $opwr = New-Object -Type OPWRespons

    #OpwDebug
    if( Get-Variable -Name OpwDebug -ErrorAction SilentlyContinue) {
        Remove-Variable -Name OpwDebug -Scope Global
        Write-Debug "$($PSFN)Remove OPWDebug variable"
    } 
    #OpwHost
    if( Get-Variable -Name OpwHost -ErrorAction SilentlyContinue) {
        Remove-Variable -Name OpwHost -Scope Global
        Write-Debug "$($PSFN)Remove OpwHost variable"
    } 
   
    #OpwAuthToken
    if( Get-Variable -Name OpwAuthToken -ErrorAction SilentlyContinue) {
        Remove-Variable -Name OpwAuthToken -Scope Global
        Write-Debug "$($PSFN)Remove OpwAuthToken variable"
    } 
    
    return $opwr
}
