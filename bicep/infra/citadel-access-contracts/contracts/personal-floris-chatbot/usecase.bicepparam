// ============================================================================
// Citadel Access Contract: Personal - FlorisChatbot
// ============================================================================
// Created: 2024-12-16
// Purpose: Personal chatbot with GPT-5 access
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
// KEY VAULT CONFIGURATION
// ============================================================================
// Since no spoke Key Vault is available, credentials will be stored in the
// hub's Key Vault. Set useTargetAzureKeyVault = false.

param keyVault = {
  subscriptionId: '3a0eed45-6d6a-4200-a0f1-85e73312a1a8'
  resourceGroupName: 'rg-citadel-dev'
  name: 'kv-citadel-dev'
}

// Store credentials in hub Key Vault (no spoke KV available)
param useTargetAzureKeyVault = false

// ============================================================================
// USE CASE IDENTIFICATION
// ============================================================================
// Product name will be: OAI-Personal-FlorisChatbot-DEV

param useCase = {
  businessUnit: 'Personal'
  useCaseName: 'FlorisChatbot'
  environment: 'DEV'
}

// ============================================================================
// API ACCESS
// ============================================================================
// Access to Azure OpenAI and Universal LLM API for GPT-5 access

param apiNameMapping = {
  OAI: [
    'azure-openai-api'
    'universal-llm-api'
  ]
}

// ============================================================================
// SERVICES CONFIGURATION
// ============================================================================

param services = [
  {
    code: 'OAI'
    endpointSecretName: 'FLORIS-CHATBOT-OPENAI-ENDPOINT'
    apiKeySecretName: 'FLORIS-CHATBOT-OPENAI-API-KEY'
    policyXml: ''
  }
]

// ============================================================================
// OPTIONAL: Terms of Service
// ============================================================================
param productTerms = ''
