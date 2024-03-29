function Remove-NullProperties {
    <#
    .SYNOPSIS
        Removes null properties from an object.
    .DESCRIPTION
        This function recursively removes all null properties from a PowerShell object.
    .PARAMETER InputObject
        A PowerShell Object from which to remove null properties.
    .EXAMPLE
        $Object | Remove-NullProperties
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [object]
        $InputObject
    )
    foreach ($object in $InputObject) {
        if ($object -is [string] -or $object.GetType().IsPrimitive) {
            $object
            return
        }

        $NewObject = @{ }
        $NewArray = @()

        $PropertyList = $object.PSObject.Properties | Where-Object { $null -ne $_.Value }
        foreach ($Property in $PropertyList) {
            if ($Property.Value -is [array]) {
                $NewArray += Remove-NullProperties $Property.Value
                if ($NewArray.Count -cgt 0){
                    $NewObject[$Property.Name] = $NewArray
                }
                $NewArray = @()
            }
            else {
                $NewObject[$Property.Name] = Remove-NullProperties $Property.Value
            }

        }

        [PSCustomObject]$NewObject
    }

}

