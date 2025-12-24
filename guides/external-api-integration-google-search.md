# Google Custom Search API Integration Guide

This guide shows how to integrate an external API (Google Custom Search API) into your Citadel AI Gateway using Azure API Management.

## 📋 Overview

The Google Custom Search API has been integrated into the APIM module following the Citadel architecture pattern. This allows you to:

- Route Google search requests through your centralized AI Gateway
- Apply governance policies (rate limiting, authentication, monitoring)
- Track usage and costs alongside your AI workloads
- Provide a unified API surface for all AI and search capabilities

## 🏗️ Architecture

```
Client Application
    ↓
APIM Gateway (Citadel Hub)
├── Authentication & Authorization
├── Rate Limiting (100 calls/min)
├── API Key Injection (from Named Values)
├── Usage Logging
    ↓
Google Custom Search API
```

## 📁 Files Created

The integration consists of three main components:

### 1. API Definition Files

**Location:** `bicep/infra/modules/apim/google-search-api/`

- **`openapi.json`** - OpenAPI 3.0 specification defining:
  - Endpoints and operations
  - Request/response schemas
  - Parameters (q, cx, num, start)
  - Authentication requirements

- **`policy.xml`** - APIM policy defining:
  - Rate limiting (100 calls/60 seconds)
  - Backend URL configuration
  - API key injection from Named Values
  - Parameter validation
  - Error handling
  - Response header manipulation

### 2. APIM Module Integration

**Modified:** `bicep/infra/modules/apim/apim.bicep`

Added:
- Parameter `enableGoogleSearchAPI` (boolean) - Feature flag to enable/disable the API
- Parameter `googleSearchEngineId` (string) - Your Custom Search Engine ID
- Parameter `googleSearchApiKey` (secure string) - Your Google API key
- Named Value resource for storing the API key securely
- Module definition for deploying the API

## 🚀 Deployment Steps

### Step 1: Get Google Custom Search Credentials

1. **Create a Custom Search Engine:**
   - Go to [Google Custom Search](https://programmablesearchengine.google.com/)
   - Create a new search engine
   - Note your **Search Engine ID (cx parameter)**

2. **Get an API Key:**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Enable the "Custom Search API"
   - Create credentials → API Key
   - Copy your **API Key**

### Step 2: Update Parameter Files

Add the following parameters to your deployment parameter file (e.g., `main.bicepparam` or `main.parameters.dev.bicepparam`):

```bicep
// In main.bicepparam or your environment-specific parameter file
using './main.bicep'

// ... existing parameters ...

// Google Custom Search API Configuration
param enableGoogleSearchAPI = true
param googleSearchEngineId = 'your-search-engine-id-here'
param googleSearchApiKey = 'your-google-api-key-here'
```

**⚠️ Security Best Practice:**

Instead of hardcoding the API key in the parameter file, use Key Vault references:

```bicep
param googleSearchApiKey = az.getSecret('kv-your-keyvault', 'google-search-api-key')
```

Or pass it at deployment time:

```bash
az deployment sub create \
  --location swedencentral \
  --template-file ./bicep/infra/main.bicep \
  --parameters @./bicep/infra/main.bicepparam \
  --parameters googleSearchApiKey='your-api-key-here'
```

### Step 3: Update Main Bicep Module Call

In `bicep/infra/main.bicep`, add the Google Search parameters to the APIM module call:

```bicep
module apim './modules/apim/apim.bicep' = {
  name: 'apim'
  scope: resourceGroup
  params: {
    // ... existing parameters ...
    
    // Google Custom Search API
    enableGoogleSearchAPI: enableGoogleSearchAPI
    googleSearchEngineId: googleSearchEngineId
    googleSearchApiKey: googleSearchApiKey
  }
}
```

### Step 4: Deploy

```bash
# Using Azure Developer CLI (azd)
azd up

# Or using Azure CLI
az deployment sub create \
  --name citadel-with-google-search \
  --location swedencentral \
  --template-file ./bicep/infra/main.bicep \
  --parameters @./bicep/infra/main.bicepparam
```

## 🧪 Testing the API

### 1. Get APIM Gateway URL

```bash
# Get APIM gateway URL
az apim show \
  --name <your-apim-name> \
  --resource-group <your-rg-name> \
  --query gatewayUrl -o tsv
```

### 2. Create a Subscription (if needed)

The API requires a subscription. Create one via the Azure Portal or CLI:

```bash
az apim subscription create \
  --resource-group <your-rg-name> \
  --service-name <your-apim-name> \
  --subscription-id google-search-sub \
  --display-name "Google Search API Subscription" \
  --scope /apis/google-search-api
```

Get the subscription key:

```bash
az apim subscription show \
  --resource-group <your-rg-name> \
  --service-name <your-apim-name> \
  --subscription-id google-search-sub \
  --query primaryKey -o tsv
```

### 3. Test the API

```bash
# Using curl
curl -X GET "https://<your-apim-gateway>.azure-api.net/google-search/?q=Azure%20API%20Management&cx=<your-search-engine-id>" \
  -H "api-key: <your-subscription-key>"

# Using HTTPie
http GET "https://<your-apim-gateway>.azure-api.net/google-search/?q=Azure+API+Management&cx=<your-search-engine-id>" \
  api-key:<your-subscription-key>
```

### 4. Test with Python

```python
import requests

apim_gateway_url = "https://<your-apim-gateway>.azure-api.net"
subscription_key = "<your-subscription-key>"
search_engine_id = "<your-search-engine-id>"

response = requests.get(
    f"{apim_gateway_url}/google-search/",
    params={
        "q": "Azure AI Gateway",
        "cx": search_engine_id,
        "num": 5
    },
    headers={
        "api-key": subscription_key
    }
)

print(response.json())
```

## 🔒 Security Considerations

### 1. API Key Storage

The Google API key is stored as a **Named Value** in APIM with `secret: true`, which:
- Encrypts the value at rest
- Hides it from portal views
- Prevents it from appearing in logs

### 2. Key Vault Integration (Recommended)

For production environments, use Key Vault:

1. Store the Google API key in Key Vault:
```bash
az keyvault secret set \
  --vault-name <your-keyvault> \
  --name google-search-api-key \
  --value <your-api-key>
```

2. Update the policy.xml to use Key Vault reference:
```xml
<set-query-parameter name="key" exists-action="override">
    <value>{{kv-google-search-api-key}}</value>
</set-query-parameter>
```

3. Create a Key Vault Named Value in APIM:
```bicep
resource googleSearchApiKeyNamedValue 'Microsoft.ApiManagement/service/namedValues@2022-08-01' = if (enableGoogleSearchAPI) {
  name: 'kv-google-search-api-key'
  parent: apimService
  properties: {
    displayName: 'kv-google-search-api-key'
    secret: true
    keyVault: {
      secretIdentifier: 'https://${keyVaultName}.vault.azure.net/secrets/google-search-api-key'
    }
  }
}
```

### 3. Network Isolation

For production deployments:
- Deploy APIM in internal VNet mode
- Use private endpoints for backend connections
- Restrict outbound traffic through Azure Firewall

## 📊 Monitoring & Observability

### Application Insights Integration

The API is configured with diagnostics enabled, so all requests are logged to Application Insights:

```kusto
// Query API usage
requests
| where url contains "google-search"
| summarize count() by bin(timestamp, 1h), resultCode
| render timechart
```

### Usage Tracking

Since the API has diagnostics enabled, usage data flows through:
1. **APIM Diagnostics** → Application Insights
2. **Event Hub Logger** (if configured) → Usage processing pipeline
3. **Cosmos DB** → Usage analytics

## 🎯 Use Cases

### 1. Multi-Agent RAG System

Use Google Search as a tool for AI agents:

```json
{
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "google_search",
        "description": "Search the web using Google Custom Search",
        "parameters": {
          "type": "object",
          "properties": {
            "query": {
              "type": "string",
              "description": "The search query"
            },
            "num_results": {
              "type": "integer",
              "description": "Number of results to return (1-10)"
            }
          },
          "required": ["query"]
        }
      }
    }
  ]
}
```

### 2. Augmented Knowledge Base

Combine Google Search with Azure AI Search for comprehensive retrieval:

1. Query internal knowledge base (Azure AI Search)
2. If insufficient results, fallback to Google Custom Search
3. Combine and rank results

### 3. Real-time Information Retrieval

Enable LLMs to access current information beyond their training data.

## ⚙️ Policy Customization

### Adjust Rate Limits

Edit `google-search-api/policy.xml`:

```xml
<!-- Change from 100 calls/minute to 1000 calls/hour -->
<rate-limit calls="1000" renewal-period="3600" />
```

### Add Custom Headers

```xml
<outbound>
    <base />
    <set-header name="X-Search-Source" exists-action="override">
        <value>Google Custom Search via Citadel Gateway</value>
    </set-header>
</outbound>
```

### Add Quota Management

```xml
<inbound>
    <base />
    <quota calls="10000" renewal-period="2592000" /> <!-- 10k calls per month -->
</inbound>
```

### Content Filtering

```xml
<inbound>
    <base />
    <!-- Block certain query terms -->
    <choose>
        <when condition="@(context.Request.Url.Query.GetValueOrDefault("q", "").Contains("restricted-term"))">
            <return-response>
                <set-status code="403" reason="Forbidden" />
                <set-body>Query contains restricted content</set-body>
            </return-response>
        </when>
    </choose>
</inbound>
```

## 🔄 Pattern for Other External APIs

This same pattern can be used to integrate any external API:

### 1. Create API Folder Structure

```
bicep/infra/modules/apim/your-api-name/
├── openapi.json    # API specification
└── policy.xml      # APIM policies
```

### 2. Add Parameters to APIM Module

```bicep
param enableYourAPI bool = false
@secure()
param yourAPIKey string = ''
```

### 3. Create Named Value for Credentials

```bicep
resource yourAPIKeyNamedValue 'Microsoft.ApiManagement/service/namedValues@2022-08-01' = if (enableYourAPI) {
  name: 'your-api-key'
  parent: apimService
  properties: {
    displayName: 'your-api-key'
    secret: true
    value: yourAPIKey
  }
}
```

### 4. Create API Module

```bicep
module yourAPI './api.bicep' = if (enableYourAPI) {
  name: 'your-api-name'
  params: {
    serviceName: apimService.name
    apiName: 'your-api-name'
    path: 'your-api-path'
    // ... other parameters
  }
  dependsOn: [
    yourAPIKeyNamedValue
  ]
}
```

## 📚 Additional Resources

- [Google Custom Search JSON API Documentation](https://developers.google.com/custom-search/v1/overview)
- [APIM Policy Reference](https://learn.microsoft.com/azure/api-management/api-management-policies)
- [Citadel Architecture Guide](../../README.md)
- [APIM Backend Configuration](./README-llm-backends.md)

## 🆘 Troubleshooting

### Issue: "Missing required parameter 'cx'"

**Solution:** Ensure you're passing the Custom Search Engine ID in the request:
```bash
curl "...?q=test&cx=YOUR_SEARCH_ENGINE_ID"
```

### Issue: "Invalid API key"

**Solution:** 
1. Verify the API key is correct in APIM Named Values
2. Ensure the key has Custom Search API enabled in Google Cloud Console
3. Check for quota/billing issues in Google Cloud Console

### Issue: API not appearing in APIM

**Solution:**
1. Verify `enableGoogleSearchAPI = true` in parameters
2. Check deployment logs for errors
3. Ensure the API module has proper dependencies

### Issue: Rate limit errors

**Solution:**
1. Increase rate limits in policy.xml
2. Check Google API quotas in Cloud Console
3. Implement caching for repeated queries

---

**Next Steps:**
- Add the API to a Citadel Access Contract for specific use cases
- Set up usage analytics in Power BI
- Configure alerts for quota thresholds
- Implement response caching for common queries
