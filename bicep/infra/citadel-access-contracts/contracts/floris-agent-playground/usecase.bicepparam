// ============================================================================
// Citadel Access Contract: Floris - AgentPlayground
// ============================================================================
// Created: 2026-01-05
// Purpose: Floris Agent Playground - Full access to all available AI models
//          for experimentation and agent development
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
// KEY VAULT CONFIGURATION (Spoke)
// ============================================================================
// Credentials will be stored in the spoke Key Vault for this use case

param keyVault = {
  subscriptionId: '3a0eed45-6d6a-4200-a0f1-85e73312a1a8'
  resourceGroupName: 'rg-floris-agent-playground'
  name: 'kv-floris-playground'
}

// Store credentials in spoke Key Vault
param useTargetAzureKeyVault = true

// ============================================================================
// USE CASE IDENTIFICATION
// ============================================================================
// Product name will be: OAI-Floris-AgentPlayground-DEV

param useCase = {
  businessUnit: 'Floris'
  useCaseName: 'AgentPlayground'
  environment: 'DEV'
}

// ============================================================================
// API ACCESS
// ============================================================================
// Full access to Azure OpenAI and Universal LLM API for all models

param apiNameMapping = {
  OAI: ['azure-openai-api', 'universal-llm-api']
}

// ============================================================================
// SERVICE CONFIGURATION
// ============================================================================
// OpenAI service with custom policy granting access to ALL available models:
// - gpt-4o-mini, gpt-4o, gpt-5 (OpenAI)
// - DeepSeek-R1 (DeepSeek)
// - Phi-4 (Microsoft)
// - text-embedding-3-large (OpenAI Embeddings)

param services = [
  {
    code: 'OAI'
    endpointSecretName: 'FLORIS-PLAYGROUND-OPENAI-ENDPOINT'
    apiKeySecretName: 'FLORIS-PLAYGROUND-OPENAI-API-KEY'
    policyXml: loadTextContent('./policy.xml')
  }
]

// ============================================================================
// PRODUCT TERMS
// ============================================================================
param productTerms = '''
# Floris Agent Playground - Terms of Use

## Scope
This API subscription provides full access to all available AI models for agent development and experimentation.

## Available Models
### Chat & Reasoning Models
- gpt-5 (Latest OpenAI reasoning model)
- gpt-4o (OpenAI optimized model)
- gpt-4o-mini (Cost-efficient chat model)
- DeepSeek-R1 (Deep reasoning model)
- Phi-4 (Microsoft SLM)

### Embedding Models
- text-embedding-3-large (OpenAI)

## Rate Limits
- 200 calls per minute
- 1,000,000 tokens per day quota
- Subject to fair use policy

## Usage Guidelines
- For agent development and experimentation
- All requests are logged for observability and cost attribution
- Content safety policies are enforced

## Support
Contact: Platform Team
'''
