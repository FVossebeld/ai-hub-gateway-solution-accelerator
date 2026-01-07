// ============================================================================
// Citadel Access Contract: KYC POC
// ============================================================================
// Created: 2026-01-07
// Purpose: Know Your Customer (KYC) Proof of Concept - Document verification
//          and identity validation using AI models
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
// KEY VAULT CONFIGURATION (Spoke)
// ============================================================================
// Credentials will be stored in the spoke Key Vault for this use case

param keyVault = {
  subscriptionId: '3a0eed45-6d6a-4200-a0f1-85e73312a1a8'
  resourceGroupName: 'rg-kyc-poc-dev'
  name: 'kv-kyc-poc-dev'
}

// Store credentials in spoke Key Vault
param useTargetAzureKeyVault = true

// ============================================================================
// USE CASE IDENTIFICATION
// ============================================================================
// Product name will be: OAI-KYC-POC-DEV

param useCase = {
  businessUnit: 'KYC'
  useCaseName: 'POC'
  environment: 'DEV'
}

// ============================================================================
// API ACCESS
// ============================================================================
// Access to Azure OpenAI for document analysis and verification
// API names verified against APIM instance to avoid "API not found" errors

param apiNameMapping = {
  OAI: ['azure-openai-api', 'universal-llm-api']
  DOC: ['document-intelligence-api']
}

// ============================================================================
// SERVICE CONFIGURATION
// ============================================================================
// OpenAI service with default platform policy
// Document Intelligence for KYC document processing

param services = [
  {
    code: 'OAI'
    endpointSecretName: 'KYC-POC-OPENAI-ENDPOINT'
    apiKeySecretName: 'KYC-POC-OPENAI-API-KEY'
    // Uses default platform policy: 300 tokens/min, gpt-4o/DeepSeek-R1 allowlist, content safety enabled
    // Default policy is centrally managed for automatic security updates
    policyXml: ''
  }
  {
    code: 'DOC'
    endpointSecretName: 'KYC-POC-DOCINTELL-ENDPOINT'
    apiKeySecretName: 'KYC-POC-DOCINTELL-API-KEY'
    // Uses default platform policy for document intelligence
    policyXml: ''
  }
]

// ============================================================================
// PRODUCT TERMS
// ============================================================================
param productTerms = '''
# KYC POC - Terms of Use

## Scope
This API subscription provides access to AI models and document intelligence services for KYC proof of concept development.

## Available Services
- **Azure OpenAI API**: GPT-4o for document analysis and verification workflows
- **Universal LLM API**: Multi-provider access for experimentation
- **Document Intelligence API**: OCR and document parsing for KYC documents

## Rate Limits
- 300 tokens per minute (OpenAI)
- 100,000 tokens per month (OpenAI)
- Subject to platform default policy

## Allowed Models (OpenAI)
- gpt-4o (primary model for document analysis)
- DeepSeek-R1 (alternative reasoning model)

## Usage Guidelines
- For KYC proof of concept and development only
- All requests are logged for observability and cost attribution
- Content safety policies are enforced (prompt shields, harmful content detection)
- PII data must be handled according to compliance requirements

## Data Handling
- Treat KYC documents with appropriate security measures
- Do not use production PII data in POC environment
- All API calls are logged for audit purposes

## Support
Contact: Platform Team
'''
