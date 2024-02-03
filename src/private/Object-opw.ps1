# This is the default respons object from opw-lib
class OPWRespons {
    [string] $status
    [string] $message
    [System.Object] $payload

    OPWRespons() {
        $this.status = "200"
        $this.message= "Done"
        $this.payload= $null
    }
}

#Help object for deploy JSON patches
class JSONPatchOPW {

    [JSONPatchOperation[]] $itmes

    [void] Add([string]$op, [string] $path, [string] $value)
    {
        $jp = New-Object -TypeName JSONPatchOperation
        $jp.op = $op
        $jp.path = $path
        $jp.value = $value

        $this.itmes +=$jp
    }

    hidden [string] OutJSONPatch() {
        $json = ConvertTo-Json -InputObject $this.itmes
        $json = $json -replace '\\', ''
        $json= $json -replace '"{', '{'
        $json= $json -replace '}"', '}'
        return $json
    }
}

# JSON operation object
class JSONPatchOperation {
    [string] $op
    [string] $path
    [string] $value

}


class OPWVaultItemFile {
    [string] $id
    [string] $name
    [string] $section
	[int]    $size
    [string] $content_path
}

# OPW selection item object
class OPWVaultItemSection {
    [string] $id
	[string] $label

    OPWVaultItemSection(){}

    OPWVaultItemSection([string] $label){
        $this.label = $label
        $this.id = New-Guid
    }

}

# OPWVaultItem
# vault item object
class OPWVault {
    [string] $id
    [string] $name

    OPWVault([string] $uuid){
        $this.id = $uuid
    }
}

# OPWVaultItem
# URL item object
class OPWVaultItemURL {
    [bool]   $primary
	[string] $label
	[string] $url
}

# OPWVaultItem
# Field item object
class OPWVaultItemField {
    [string]        $id
	[OPWVaultItemSection]   $section
	[string]        $type
	[string]        $purpose
	[string]        $label
	[string]        $value

    OPWVaultItemField(){}

    OPWVaultItemField([string] $type,[string] $purpose, [string] $label, [string] $value,[string] $sectionID){
        $this.type = $type
        if("" -ne $purpose){
            $this.purpose = $purpose
        }
        $this.type = $type
        $this.label = $label
        $this.value = $value
        if("" -ne $sectionID){
            $this.section = [OPWVaultItemSection]::New()
            $this.section.id = $sectionID
        }
    }
}

# OPWVaultItem
# Main object
class OPWVaultItem {

    [string]                $id
	[string]                $title
	[OPWVaultItemURL]       $urls
	[bool]                  $favorite
	[string[]]              $tags
	[int]                   $version
	[OPWVault]              $vault
	[string]                $category
	[OPWVaultItemSection[]] $sections
    [OPWVaultItemField[]]   $fields
	[OPWVaultItemFile[]]    $files
    [string]                $lastEditedBy
	[string]                $createdAt
    [string]	            $updatedAt

    # Create OPWVaultItem
    OPWVaultItem([string] $title,[string] $category, [string] $vaultUUID )
    {
        # ToDo: Prüfen
        $this.category = "LOGIN"

        $this.title = $title
        $this.vault = [OPWVault]::New($vaultUUID)
        $this.fields = @()
        $this.sections = @()
        $this.files = @()
    }


    #Adding a login credential to the vault item
    [void] AddLogin ([string] $name, [string] $pw)
    {
        $username = [OPWVaultItemField]::New()
        $username.value = $name
        $username.purpose = "USERNAME"
        $this.fields = $username

        $password = [OPWVaultItemField]::New()
        $password.value = $pw
        $password.purpose = "PASSWORD"
        $this.fields += $password

    }
    # Adding text to the vault entry without selection ID
    [void] AddText ([string] $label, [string] $text){

        $field = [OPWVaultItemField]::New("STRING", "", $label, $text, "" )
        $this.fields += $field
    }

    # Adding text to vault item with spetific selection ID
    [void] AddText ([string] $label, [string] $text, [string] $sectionID){

        $field = [OPWVaultItemField]::New("STRING", "", $label, $text, $sectionID )
        $this.fields += $field
    }

    # Adding the new Section to the vault and return the section ID
    [string] AddSections([string] $label)
    {
        $section = [OPWVaultItemSection]::New($label)
        $this.sections += $section
        return $section.id
    }

}

