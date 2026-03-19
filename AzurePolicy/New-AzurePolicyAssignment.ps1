function New-AzurePolicyAssignment {
    param (
        [Parameter(Mandatory = $true)]
        [string]$DisplayName,
        [Parameter(Mandatory = $true)]
        [string]$PolicyDefinitionID,
        [Parameter(Mandatory = $true)]
        [string]$Scope,
        [Parameter(Mandatory = $true)]
        [string]$AssignmentName,
        [Parameter(Mandatory = $true)]
        [string]$AccessToken

    )

    $headers = @{
        "Authorization" = "Bearer $($AccessToken)"
        "Content-Type"  = "application/json"    
    }

    $uri = "https://management.azure.com$($Scope)/providers/Microsoft.Authorization/policyAssignments/$($AssignmentName)?api-version=2023-04-01"

    $azure_policy_assignment = @"
{
  "properties": {
    "displayName": "$DisplayName",
    "policyDefinitionId": "$PolicyDefinitionID"
  }
}
"@
    
    Invoke-RestMethod -Method 'PUT' -Uri $uri -Headers $headers -Body $azure_policy_assignment | Out-Null
    Write-Host "Creating Azure Policy Assignment $($DisplayName)" -ForegroundColor Green
}