// ============================================================================
// Citadel Access Contract: Sandbox - Learning
// ============================================================================
// Created: 2026-01-05
// Purpose: Sandbox environment for learning and experimentation with all AI models
// ============================================================================

using '../../main.bicep'

// ============================================================================
// HUB CONFIGURATION (Do not change - provided by platform team)
// ============================================================================
param apim = {
  subscriptionId: '3a0eed45-6d6a-4200-a0f1-85e73312a1a8'
  resourceGroupName: 'rg-citadel-dev'
  name: 'apim-xot5i4klj5zea'
}

// ============================================================================
// KEY VAULT CONFIGURATION
// ============================================================================
// For sandbox learning, credentials can be retrieved directly from APIM
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
// Product name will be: OAI-Sandbox-Learning-DEV

param useCase = {
  businessUnit: 'Sandbox'
  useCaseName: 'Learning'
  environment: 'DEV'
}

// ============================================================================
// API ACCESS
// ============================================================================
// Access to all available AI services for comprehensive learning

param apiNameMapping = {
  OAI: ['azure-openai-api', 'universal-llm-api']
  DOC: ['document-intelligence-api']
  SRCH: ['ai-search-api']
  LANG: ['language-api']
  SPCH: ['speech-api']
  TRAN: ['translator-api']
}

// ============================================================================
// SERVICE CONFIGURATION
// ============================================================================
// All services with custom policy allowing access to all models

param services = [
  {
    code: 'OAI'
    endpointSecretName: 'SANDBOX-OPENAI-ENDPOINT'
    apiKeySecretName: 'SANDBOX-OPENAI-API-KEY'
    // Custom policy with no model restrictions for learning
    policyXml: loadTextContent('./policy.xml')
  }
  {
    code: 'DOC'
    endpointSecretName: 'SANDBOX-DOCINTELL-ENDPOINT'
    apiKeySecretName: 'SANDBOX-DOCINTELL-API-KEY'
    // Uses default platform policy for document intelligence
    policyXml: ''
  }
  {
    code: 'SRCH'
    endpointSecretName: 'SANDBOX-SEARCH-ENDPOINT'
    apiKeySecretName: 'SANDBOX-SEARCH-API-KEY'
    // Uses default platform policy for AI search
    policyXml: ''
  }
  {
    code: 'LANG'
    endpointSecretName: 'SANDBOX-LANGUAGE-ENDPOINT'
    apiKeySecretName: 'SANDBOX-LANGUAGE-API-KEY'
    // Uses default platform policy for language services
    policyXml: ''
  }
  {
    code: 'SPCH'
    endpointSecretName: 'SANDBOX-SPEECH-ENDPOINT'
    apiKeySecretName: 'SANDBOX-SPEECH-API-KEY'
    // Uses default platform policy for speech services
    policyXml: ''
  }
  {
    code: 'TRAN'
    endpointSecretName: 'SANDBOX-TRANSLATOR-ENDPOINT'
    apiKeySecretName: 'SANDBOX-TRANSLATOR-API-KEY'
    // Uses default platform policy for translator services
    policyXml: ''
  }
]

// ============================================================================
// PRODUCT TERMS
// ============================================================================
param productTerms = '''
# Sandbox Learning Environment - Terms of Use

## Scope
This API subscription provides access to all available AI models and services for learning and experimentation purposes.

## Rate Limits
- 500 calls per minute
- Higher token quotas for experimentation (1M tokens per month)

## Allowed Models
- **ALL MODELS** available in the hub (no restrictions)
- GPT-4o, GPT-4o-mini, GPT-3.5-turbo, DeepSeek-R1, etc.
- Text embeddings (all versions)
- Any other models deployed in the hub

## Usage Guidelines
- For learning, development, and experimentation only
- Not for production workloads
- All requests are logged for monitoring and cost attribution
- Content safety policies still apply

## Data Handling
- Do not use with sensitive or production data
- Treat as a non-production environment

## Support
Contact: Platform Team
'''
