// ============================================================================
// Citadel Access Contract: Healthcare - PurchasingAgent
// ============================================================================
// Created: 2025-12-17
// Purpose: Healthcare purchasing agent with GPT-5 access for procurement
// ============================================================================

using '../../main.bicep'

// ============================================================================
// HUB CONFIGURATION (Do not change - provided by platform team)
// ============================================================================
param apim = {
  subscriptionId: '3a0eed45-6d6a-4200-a0f1-85e73312a1a8'
  resourceGroupName: 'rg-citadel-dev'
  name: 'apim-citadel-dev'
}

// ============================================================================
// KEY VAULT CONFIGURATION (Spoke)
// ============================================================================
// Credentials will be stored in the spoke Key Vault for this use case

param keyVault = {
  subscriptionId: '3a0eed45-6d6a-4200-a0f1-85e73312a1a8'
  resourceGroupName: 'rg-healthcare-purchasing-agent-dev'
  name: 'kv-healthcare-pa-dev'
}

// Store credentials in spoke Key Vault
param useTargetAzureKeyVault = true

// ============================================================================
// USE CASE IDENTIFICATION
// ============================================================================
// Product name will be: OAI-Healthcare-PurchasingAgent-DEV

param useCase = {
  businessUnit: 'Healthcare'
  useCaseName: 'PurchasingAgent'
  environment: 'DEV'
}

// ============================================================================
// API ACCESS
// ============================================================================
// Access to Azure OpenAI and Universal LLM API for GPT-5 access

param apiNameMapping = {
  OAI: ['azure-openai-api', 'universal-llm-api']
}

// ============================================================================
// SERVICE CONFIGURATION
// ============================================================================
// OpenAI service with custom policy for GPT-5 access and rate limiting

param services = [
  {
    code: 'OAI'
    endpointSecretName: 'HEALTHCARE-PA-OPENAI-ENDPOINT'
    apiKeySecretName: 'HEALTHCARE-PA-OPENAI-API-KEY'
    policyXml: loadTextContent('./policy.xml')
  }
]

// ============================================================================
// PRODUCT TERMS
// ============================================================================
param productTerms = '''
# Healthcare Purchasing Agent - Terms of Use

## Scope
This API subscription provides access to GPT-5 models for healthcare procurement use cases.

## Rate Limits
- 100 calls per minute
- Subject to token quotas as defined in policy

## Allowed Models
- gpt-5 (primary)
- gpt-4o (fallback)

## Usage Guidelines
- For healthcare purchasing and procurement workflows only
- PII handling must comply with HIPAA requirements
- All requests are logged for compliance and cost attribution

## Support
Contact: Platform Team
'''
