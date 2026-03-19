$hash = @{
    azapi    = "https://management.azure.com/"
    graphapi = "https://graph.microsoft.com/"
}
$tokenResponse = Get-AzAccessToken -ResourceUrl $hash.azapi
$secureToken = $tokenResponse.Token
$ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken)
$azure_token = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)

$json_files = Get-ChildItem -Path '/Users/nikchikersal/Downloads/azure_policies' -Filter "*.json"

foreach ($json in $json_files) {

    $azure_policy_definition = New-AzurePolicyDefinition `
        -FilePath $json.FullName `
        -Scope 'Microsoft.Management/managementGroups/07dd2703-e92c-46c0-a5d8-9586bd4bac95' `
        -AccessToken $azure_token -ErrorAction SilentlyContinue 

    #24 char max internal api name for assignment check / fix

    if ($azure_policy_definition.name.Length -gt 24) {
        $azure_policy_assignment_name = ""
        foreach ($w in ($azure_policy_definition.name -split '[-\s]')) {
            $n = if ($azure_policy_assignment_name) { "$azure_policy_assignment_name-$w" } else { $w }
            if ($n.Length -gt 24) { break }
            $azure_policy_assignment_name = $n
        }
        if (-not $azure_policy_assignment_name) {
            $azure_policy_assignment_name = $azure_policy_definition.name.Substring(0, 24)
        }
    }
    else {
        $azure_policy_assignment_name = $azure_policy_definition.name
    }

    New-AzurePolicyAssignment `
        -DisplayName $azure_policy_definition.properties.displayName `
        -AssignmentName $azure_policy_assignment_name `
        -PolicyDefinitionID $azure_policy_definition.id `
        -Scope "/providers/Microsoft.Management/managementGroups/07dd2703-e92c-46c0-a5d8-9586bd4bac95" `
        -AccessToken $azure_token
}