function New-AzurePolicyDefinition {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        [Parameter(Mandatory = $true)]
        [string]$Scope,
        [Parameter(Mandatory = $true)]
        [string]$AccessToken
    )

$headers = @{
    "Authorization" = "Bearer $($AccessToken)"
    "Content-Type"  = "application/json"    
}


    $azure_policy_json_payload = Get-Content -Path $FilePath -Raw
    $azure_policy_api_internal_displayname = (($azure_policy_json_payload | ConvertFrom-Json).properties.displayName).Replace(" ", "").Replace(",", "-")

    $uri = "https://management.azure.com/providers/$($Scope)/providers/Microsoft.Authorization/policyDefinitions/$($azure_policy_api_internal_displayname)?api-version=2021-06-01"

    $existing_policy = Invoke-RestMethod `
        -Uri $uri `
        -Headers $headers `
        -Method GET `
        -ErrorAction SilentlyContinue

    if ($null -ne $existing_policy) {

        Write-Warning "Azure Policy Definition Exists: $azure_policy_api_internal_displayname"
        
    } 
    else {
        Write-Host "Creating Azure Policy Definition: $azure_policy_api_internal_displayname" -ForegroundColor Green
        Invoke-RestMethod `
            -Uri $uri `
            -Headers $headers `
            -Method PUT `
            -Body $azure_policy_json_payload `
            -ContentType "application/json"
    }
}
