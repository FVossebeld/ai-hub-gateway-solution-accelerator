using '../../main.bicep'

// ============================================================================
// Customer Support Agent Demo - Citadel Access Contract
// ============================================================================
// This configuration onboards a customer support agent use case to the
// AI Citadel Governance Hub. It creates:
// - APIM Product: OAI-Support-CustomerAgent-DEV
// - APIM Subscription with scoped API key
// - Rate limiting and governance policies
// - Token quota enforcement
//
// The spoke repository at /home/flvossebeld/citadel-spoke-customer-support
// will use this subscription to access AI services through the gateway.
// ============================================================================

// ============================================================================
// APIM Configuration (Hub)
// ============================================================================
param apim = {
  subscriptionId: '3a0eed45-6d6a-4200-a0f1-85e73312a1a8'
  resourceGroupName: 'rg-citadel-dev'
  name: 'apim-xot5i4klj5zea'
}

// ============================================================================
// Key Vault Configuration
// ============================================================================
// Since no Key Vault exists in the hub, we'll output secrets directly
// The spoke can retrieve these from deployment outputs
param useTargetAzureKeyVault = false
param keyVault = {
  subscriptionId: '00000000-0000-0000-0000-000000000000'
  resourceGroupName: 'placeholder'
  name: 'placeholder'
}

// ============================================================================
// Use Case Identification
// ============================================================================
param useCase = {
  businessUnit: 'Support'
  useCaseName: 'CustomerAgent'
  environment: 'DEV'
}

// ============================================================================
// API Mapping
// ============================================================================
// Map service codes to existing APIM APIs
param apiNameMapping = {
  OAI: [
    'azure-openai-api'
    'universal-llm-api'
  ]
}

// ============================================================================
// Services Configuration
// ============================================================================
param services = [
  {
    code: 'OAI'
    endpointSecretName: 'SUPPORT-OPENAI-ENDPOINT'
    apiKeySecretName: 'SUPPORT-OPENAI-KEY'
    policyXml: loadTextContent('policy.xml')
  }
]

// ============================================================================
// Product Terms
// ============================================================================
param productTerms = 'Customer Support Agent - Development Environment. Usage monitored and subject to rate limits and token quotas.'
