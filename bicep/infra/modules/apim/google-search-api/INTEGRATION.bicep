// ============================================================================
// Google Custom Search API - Quick Configuration
// ============================================================================
// Add these parameters to: bicep/infra/main.bicep
// ============================================================================

// 1. Add parameter declarations at the top of main.bicep
@description('Enable Google Custom Search API integration')
param enableGoogleSearchAPI bool = false

@description('Google Custom Search Engine ID')
param googleSearchEngineId string = ''

@description('Google Custom Search API Key')
@secure()
param googleSearchApiKey string = ''

// ============================================================================
// 2. Update the APIM module call (around line 853)
// ============================================================================

module apim './modules/apim/apim.bicep' = {
  name: 'apim'
  scope: resourceGroup
  params: {
    // ... existing parameters ...
    
    // Add these three lines to the APIM module parameters:
    enableGoogleSearchAPI: enableGoogleSearchAPI
    googleSearchEngineId: googleSearchEngineId
    googleSearchApiKey: googleSearchApiKey
  }
}

// ============================================================================
// 3. Add to your .bicepparam file (e.g., main.parameters.dev.bicepparam)
// ============================================================================

using './main.bicep'

// ... existing parameters ...

// Google Custom Search API Configuration
param enableGoogleSearchAPI = true
param googleSearchEngineId = 'YOUR_SEARCH_ENGINE_ID_HERE'
param googleSearchApiKey = 'YOUR_GOOGLE_API_KEY_HERE'

// ============================================================================
// ALTERNATIVE: Use Key Vault reference (recommended for production)
// ============================================================================

using './main.bicep'

// ... existing parameters ...

// Google Custom Search API Configuration
param enableGoogleSearchAPI = true
param googleSearchEngineId = 'YOUR_SEARCH_ENGINE_ID_HERE'
param googleSearchApiKey = az.getSecret('YOUR_KEYVAULT_NAME', 'google-search-api-key')

// ============================================================================
// ALTERNATIVE: Pass at deployment time (most secure)
// ============================================================================

# Deploy with inline parameter
az deployment sub create \
  --location swedencentral \
  --template-file ./bicep/infra/main.bicep \
  --parameters @./bicep/infra/main.parameters.dev.bicepparam \
  --parameters enableGoogleSearchAPI=true \
  --parameters googleSearchEngineId='YOUR_SEARCH_ENGINE_ID' \
  --parameters googleSearchApiKey='YOUR_API_KEY'
