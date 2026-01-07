// ============================================================================
// Citadel Access Contract: Banking - KYC-Bank-POC
// ============================================================================
// Created: 2026-01-07
// Purpose: Banking/Financial Services KYC (Know Your Customer) proof of concept
//          with access to Azure OpenAI and Universal LLM API
// ============================================================================

using '../../main.bicep'

// ============================================================================
// HUB CONFIGURATION (Managed by platform team)
// ============================================================================
param apim = {
  subscriptionId: '3a0eed45-6d6a-4200-a0f1-85e73312a1a8'
  resourceGroupName: 'rg-citadel-dev'
  name: 'apim-xot5i4klj5zea'
}

// ============================================================================
// KEY VAULT CONFIGURATION
// ============================================================================
// For this POC, credentials can be retrieved directly from APIM
// Set useTargetAzureKeyVault = false to skip Key Vault storage

param keyVault = {
  subscriptionId: ''
  resourceGroupName: ''
  name: ''
}

// No Key Vault - retrieve credentials from APIM directly
param useTargetAzureKeyVault = false

// ============================================================================
// USE CASE IDENTIFICATION
// ============================================================================
// Product name will be: OAI-Banking-KYC-Bank-POC-DEV

param useCase = {
  businessUnit: 'Banking'
  useCaseName: 'KYC-Bank-POC'
  environment: 'DEV'
}

// ============================================================================
// API ACCESS
// ============================================================================
// Access to Azure OpenAI and Universal LLM API for KYC processing

param apiNameMapping = {
  OAI: ['azure-openai-api', 'universal-llm-api']
}

// ============================================================================
// SERVICE CONFIGURATION
// ============================================================================
// OpenAI service with default platform policy
// Default policy includes: 300 tokens/min, gpt-4o/DeepSeek-R1 allowlist, content safety

param services = [
  {
    code: 'OAI'
    endpointSecretName: 'BANKING-KYC-OPENAI-ENDPOINT'
    apiKeySecretName: 'BANKING-KYC-OPENAI-API-KEY'
    // Uses default platform policy: 300 tokens/min, gpt-4o/DeepSeek-R1 only, content safety enabled
    // This is appropriate for a banking POC with security-conscious defaults
    policyXml: ''
  }
]

// ============================================================================
// PRODUCT TERMS
// ============================================================================
param productTerms = '''
# Banking KYC POC - Terms of Use

## Scope
This API subscription provides access to Azure OpenAI models for KYC (Know Your Customer) proof of concept development.

## Rate Limits
- Uses default platform policy (300 tokens/minute, 100K tokens/month)
- Subject to fair use policy

## Allowed Models
- gpt-4o
- DeepSeek-R1

## Usage Guidelines
- For KYC proof of concept development only
- Not for production workloads
- All requests are logged for monitoring and cost attribution
- Content safety policies are enforced

## Data Handling
- Do not use with real customer PII data
- Treat as a non-production environment
- Comply with banking/financial data handling requirements

## Support
Contact: Platform Team
'''
