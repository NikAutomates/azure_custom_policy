$sourceMg = "07dd2703-e92c-46c0-a5d8-9586bd4bac95"
$targetMg = "test-management"

$sourceScope = "/providers/Microsoft.Management/managementGroups/$sourceMg"
$targetScope = "/providers/Microsoft.Management/managementGroups/$targetMg"

$assignments = Get-AzPolicyAssignment -Scope $sourceScope

foreach ($a in $assignments) {

    $params = @{
        Name             = $a.Name
        Scope            = $targetScope
        PolicyDefinition = $a.PolicyDefinitionId
        DisplayName      = ($a.DisplayName -replace "(?i)Sandbox","NonProd")
        EnforcementMode  = $a.EnforcementMode
    }

    New-AzPolicyAssignment @params
}
