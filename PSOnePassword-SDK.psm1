$Private = @( Get-ChildItem -Path $PSScriptRoot\src\private\*.ps1 -ErrorAction SilentlyContinue )
$Public  = @( Get-ChildItem -Path $PSScriptRoot\src\public\*.ps1 -ErrorAction SilentlyContinue )


#Dot source the files
ForEach($ImportScriptFile In @($Private + $Public) )
{
    Try
    {
        . $ImportScriptFile.Fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($ImportScriptFile.Fullname): $_"
    }
}


Export-ModuleMember -Function $Public.Basename