using './main.bicep'

/*
 * Development Environment Configuration
 * Optimized for cost and quick deployments
 */

// ============================================================================
// BASIC PARAMETERS
// ============================================================================
param environmentName = 'citadel-dev'
param location = 'swedencentral'
param apicLocation = 'swedencentral'
param resourceGroupName = ''  // Auto-generated based on environmentName
param tags = {
  'azd-env-name': 'citadel-dev'
  SecurityControl: 'Ignore'
  Environment: 'Development'
  CostCenter: 'Engineering'
}

// ============================================================================
// RESOURCE NAMES - Auto-generated, leave empty for defaults
// ============================================================================
param apimIdentityName = ''
param usageLogicAppIdentityName = ''
param apimServiceName = ''
param logAnalyticsName = ''
param apimApplicationInsightsDashboardName = ''
param funcAplicationInsightsDashboardName = ''
param foundryApplicationInsightsDashboardName = ''
param apimApplicationInsightsName = ''
param funcApplicationInsightsName = ''
param foundryApplicationInsightsName = ''
param eventHubNamespaceName = ''
param cosmosDbAccountName = ''
param usageProcessingLogicAppName = ''
param storageAccountName = ''
param languageServiceName = ''
param aiContentSafetyName = ''
param apicServiceName = ''
param aiFoundryResourceName = ''
param keyVaultName = ''

// ============================================================================
// MONITORING - Log Analytics configuration
// ============================================================================
param useExistingLogAnalytics = false
param existingLogAnalyticsName = ''
param existingLogAnalyticsRG = ''
param existingLogAnalyticsSubscriptionId = ''

// ============================================================================
// NETWORKING PARAMETERS - Network configuration and access controls
// ============================================================================
param vnetName = ''
param useExistingVnet = false
param existingVnetRG = ''

// Subnet names
param apimSubnetName = ''
param privateEndpointSubnetName = ''
param functionAppSubnetName = ''

// NSG & route table names
param apimNsgName = ''
param privateEndpointNsgName = ''
param functionAppNsgName = ''
param apimRouteTableName = ''

// VNet address space and subnet prefixes
param vnetAddressPrefix = '10.170.0.0/24'
param apimSubnetPrefix = '10.170.0.0/26'
param privateEndpointSubnetPrefix = '10.170.0.64/26'
param functionAppSubnetPrefix = '10.170.0.128/26'

// DNS Zone parameters (legacy approach - single subscription/RG)
param dnsZoneRG = ''
param dnsSubscriptionId = ''

// Existing Private DNS Zones (BYO approach)
param existingPrivateDnsZones = {
  openai: ''
  keyVault: ''
  monitor: ''
  eventHub: ''
  cosmosDb: ''
  storageBlob: ''
  storageFile: ''
  storageTable: ''
  storageQueue: ''
  cognitiveServices: ''
  apimGateway: ''
  aiServices: ''
}

// Private Endpoint names
param storageBlobPrivateEndpointName = ''
param storageFilePrivateEndpointName = ''
param storageTablePrivateEndpointName = ''
param storageQueuePrivateEndpointName = ''
param cosmosDbPrivateEndpointName = ''
param eventHubPrivateEndpointName = ''
param languageServicePrivateEndpointName = ''
param aiContentSafetyPrivateEndpointName = ''
param apimV2PrivateEndpointName = ''
param aiFoundryPrivateEndpointName = ''
param keyVaultPrivateEndpointName = ''

// Services network access configuration - Public for dev environment
param apimNetworkType = 'External'
param apimV2UsePrivateEndpoint = true
param apimV2PublicNetworkAccess = true
param cosmosDbPublicAccess = 'Enabled'
param eventHubNetworkAccess = 'Enabled'
param languageServiceExternalNetworkAccess = 'Enabled'
param aiContentSafetyExternalNetworkAccess = 'Enabled'
param aiFoundryExternalNetworkAccess = 'Enabled'
param keyVaultExternalNetworkAccess = 'Enabled'
param useAzureMonitorPrivateLinkScope = false

// ============================================================================
// FEATURE FLAGS - Deploy specific capabilities
// ============================================================================
param createAppInsightsDashboards = false
param enableAIModelInference = true
param enableDocumentIntelligence = true
param enableAzureAISearch = true
param enableAIGatewayPiiRedaction = true
param enableOpenAIRealtime = true
param enableAIFoundry = true
param entraAuth = false
param enableAPICenter = true

// ============================================================================
// COMPUTE SKU & SIZE - SKUs and capacity settings for services
// ============================================================================
// Use Developer SKU for lower cost in dev
param apimSku = 'Developer'
param apimSkuUnits = 1

// Minimal capacity for dev
param cosmosDbRUs = 400
param eventHubCapacityUnits = 1
param logicAppsSkuCapacityUnits = 1
param languageServiceSkuName = 'S'
param aiContentSafetySkuName = 'S0'
param apicSku = 'Free'
param keyVaultSkuName = 'standard'

// ==========================='usage-logic-content'

// AI Search instances configuration
param aiSearchInstances = []

// AI Foundry instances configuration array
param aiFoundryInstances = [
  {
    name: ''
    location: 'swedencentral'
    customSubDomainName: ''
    defaultProjectName: 'citadel-governance-project'
  }
  {
    name: ''
    location: 'eastus2'
    customSubDomainName: ''
    defaultProjectName: 'citadel-governance-project'
  }
]

// AI Foundry model deployments configuration
param aiFoundryModelsConfig = [
  {
    name: 'gpt-4o-mini'
    publisher: 'OpenAI'
    version: '2024-07-18'
    sku: 'GlobalStandard'
    capacity: 100
    aiserviceIndex: 0
  }
  {
    name: 'gpt-4o'
    publisher: 'OpenAI'
    version: '2024-11-20'
    sku: 'GlobalStandard'
    capacity: 100
    aiserviceIndex: 0
  }
  {
    name: 'DeepSeek-R1'
    publisher: 'DeepSeek'
    version: '1'
    sku: 'GlobalStandard'
    capacity: 1
    aiserviceIndex: 0
  }
  {
    name: 'Phi-4'
    publisher: 'Microsoft'
    version: '3'
    sku: 'GlobalStandard'
    capacity: 1
    aiserviceIndex: 0
  }
  {
    name: 'text-embedding-3-large'
    publisher: 'OpenAI'
    version: '1'
    sku: 'GlobalStandard'
    capacity: 100
    aiserviceIndex: 0
  }
  {
    name: 'gpt-5'
    publisher: 'OpenAI'
    version: '2025-08-07'
    sku: 'GlobalStandard'
    capacity: 100
    aiserviceIndex: 1
  }
  {
    name: 'DeepSeek-R1'
    publisher: 'DeepSeek'
    version: '1'
    sku: 'GlobalStandard'
    capacity: 1
    aiserviceIndex: 1
  }
  {
    name: 'text-embedding-3-large'
    publisher: 'OpenAI'
    version: '1'
    sku: 'GlobalStandard'
    capacity: 100
    aiserviceIndex: 1
  }
]

// ============================================================================
// ENTRA ID AUTHENTICATION
// ============================================================================
param entraTenantId = ''
param entraClientId = ''
param entraAudience = ''

// ============================================================================
// GOOGLE CUSTOM SEARCH API
// ============================================================================
param enableGoogleSearchAPI = true
// Retrieve secrets from Key Vault (secrets: google-search-engine-id, google-search-api-key)
param googleSearchEngineId = az.getSecret('3a0eed45-6d6a-4200-a0f1-85e73312a1a8', 'rg-citadel-dev', 'kv-xot5i4klj5zea', 'google-search-engine-id')
param googleSearchApiKey = az.getSecret('3a0eed45-6d6a-4200-a0f1-85e73312a1a8', 'rg-citadel-dev', 'kv-xot5i4klj5zea', 'google-search-api-key')
