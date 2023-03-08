 function New-OPWJsonPatch {
    <#
    .SYNOPSIS
        Create new JSONPatchOPW object
    
    .DESCRIPTION
        Create a new JSONPatchOPW object for multi changes with update-item function.  
         
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

    $JsonPatch = [JSONPatchOPW]::New()
    Write-Debug ("$($PSFN) Create new JSONPatchOPW Object") 
    return [JSONPatchOPW] $JsonPatch
}