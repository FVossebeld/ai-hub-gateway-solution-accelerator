# Google Custom Search API Integration

This folder contains the Azure API Management (APIM) configuration for integrating Google Custom Search API into the Citadel AI Gateway.

## 📁 Files

- **`openapi.json`** - OpenAPI 3.0 specification for the Google Custom Search API
- **`policy.xml`** - APIM policy for request/response transformation, authentication, and governance
- **`INTEGRATION.bicep`** - Quick reference for integration parameters

## 🚀 Quick Start

### 1. Get Google Credentials

1. Create a Custom Search Engine at https://programmablesearchengine.google.com/
2. Get your Search Engine ID (cx parameter)
3. Enable Custom Search API in Google Cloud Console
4. Create an API Key

### 2. Enable in Your Deployment

Add to `main.bicepparam`:

```bicep
param enableGoogleSearchAPI = true
param googleSearchEngineId = 'YOUR_SEARCH_ENGINE_ID'
param googleSearchApiKey = 'YOUR_API_KEY'
```

### 3. Deploy

```bash
azd up
```

### 4. Test

```bash
# Get your APIM gateway URL and subscription key
GATEWAY_URL=$(az apim show -n <apim-name> -g <rg-name> --query gatewayUrl -o tsv)
SUB_KEY=$(az apim subscription show -n <apim-name> -g <rg-name> --subscription-id <sub-id> --query primaryKey -o tsv)

# Make a search request
curl -X GET "${GATEWAY_URL}/google-search/?q=Azure+AI+Gateway&cx=YOUR_SEARCH_ENGINE_ID" \
  -H "api-key: ${SUB_KEY}"
```

## 🔧 Configuration

### Rate Limits

Default: **100 calls per minute**

To change, edit `policy.xml`:

```xml
<rate-limit calls="1000" renewal-period="3600" />
```

### API Key Storage

The Google API key is stored as an APIM Named Value with `secret: true`.

For production, use Key Vault reference in the policy:

```xml
<set-query-parameter name="key" exists-action="override">
    <value>{{kv-google-search-api-key}}</value>
</set-query-parameter>
```

## 📊 Features

✅ **Rate Limiting** - Protect against quota exhaustion  
✅ **API Key Injection** - Secure credential management  
✅ **Parameter Validation** - Ensure required fields are present  
✅ **Error Handling** - Custom error responses  
✅ **Usage Logging** - Track all requests in Application Insights  
✅ **Diagnostics** - Full observability integration  

## 📚 Documentation

See the complete guide: [`/guides/external-api-integration-google-search.md`](../../../../guides/external-api-integration-google-search.md)

## 🔄 Reuse This Pattern

This integration pattern can be reused for any external API:

1. Create a folder: `bicep/infra/modules/apim/your-api/`
2. Add `openapi.json` and `policy.xml`
3. Add parameters to `apim.bicep`
4. Create the module definition
5. Update `main.bicep` to pass parameters

See the guide for detailed instructions.
