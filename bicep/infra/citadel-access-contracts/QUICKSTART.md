# Quick Reference: Use Case Onboarding

## 🚀 Quick Deploy Commands

### Healthcare Chatbot
```powershell
cd bicep/infra/usecase-onboarding/samples/healthcare-chatbot
# Edit usecase.bicepparam first
az deployment sub create --name healthcare --location swedencentral --template-file ../../main.bicep --parameters usecase-local.bicepparam
```

### Customer Support Agent
```powershell
cd bicep/infra/usecase-onboarding/samples/customer-support-agent
# Edit usecase.bicepparam first
az deployment sub create --name support --location eastus --template-file ../../main.bicep --parameters usecase.bicepparam
```

### Document Analysis Pipeline
```powershell
cd bicep/infra/usecase-onboarding/samples/document-analysis-pipeline
# Edit usecase.bicepparam first
az deployment sub create --name docpipeline --location eastus --template-file ../../main.bicep --parameters usecase.bicepparam
```

## 📋 Common Parameters

### ⚠️ Pre-Deployment Check: Verify API Names

**CRITICAL**: Before deploying, verify that all API names in your `apiNameMapping` exist in your APIM instance:

```bash
# List all available APIs in APIM
az apim api list --resource-group <rg> --service-name <apim> --query "[].name" -o tsv

# Example output:
# azure-openai-api
# universal-llm-api
# document-intelligence-api
# ai-search-api

# Copy these exact names (case-sensitive) to your apiNameMapping parameter
```

**Deployment will fail with "ValidationError: API not found" if API names don't exist in APIM.**

### Minimum Required Parameters
```bicep
using '../../main.bicep'

param apim = { subscriptionId: '...', resourceGroupName: '...', name: '...' }
param keyVault = { subscriptionId: '...', resourceGroupName: '...', name: '...' }
param useCase = { businessUnit: '...', useCaseName: '...', environment: 'DEV' }
param apiNameMapping = { LLM: ['azure-openai-service-api', 'universal-llm-api'] }
param services = [{ code: 'OAI', endpointSecretName: 'OAI-ENDPOINT', apiKeySecretName: 'OAI-KEY', policyXml: '' }]
```

### With Custom Policy
```bicep
param services = [
  {
    code: 'LLM'
    endpointSecretName: 'OAI-ENDPOINT'
    apiKeySecretName: 'OAI-KEY'
    policyXml: loadTextContent('custom-policy.xml')
  }
]
```

### Without Key Vault
```bicep
param useTargetAzureKeyVault = false
param keyVault = { subscriptionId: '00000000-0000-0000-0000-000000000000', resourceGroupName: 'placeholder', name: 'placeholder' }
```

## 🔍 Verification Commands

### Check APIs in APIM (Run this BEFORE deployment)
```bash
# List all available APIs
az apim api list --resource-group <rg> --service-name <apim> --query "[].name" -o tsv

# Verify specific API exists
az apim api show --resource-group <rg> --service-name <apim> --api-id azure-openai-api

# Show API details in table format
az apim api list --resource-group <rg> --service-name <apim> --output table
```

### Check Products
```powershell
az apim product list --resource-group <rg> --service-name <apim> --query "[?contains(name,'<usecase>')].{Name:name,State:state}"
```

### Check Subscriptions
```powershell
az apim subscription list --resource-group <rg> --service-name <apim> --query "[?contains(name,'<usecase>')].{Name:name,State:state}"
```

### Check Key Vault Secrets
```powershell
az keyvault secret list --vault-name <kv-name> --query "[?contains(name,'<prefix>')].name"
```

## 🔑 Get Credentials

### From Key Vault
```powershell
$endpoint = az keyvault secret show --vault-name <kv> --name <secret-name> --query value -o tsv
$key = az keyvault secret show --vault-name <kv> --name <secret-name> --query value -o tsv
```

### From Deployment Output (no KV)
```powershell
$output = az deployment sub show --name <deployment> --query properties.outputs.endpoints.value -o json | ConvertFrom-Json
$creds = $output | Where-Object { $_.code -eq 'OAI' }
$endpoint = $creds.endpoint
$key = $creds.apiKey
```

## 🧪 Test API Call

```powershell
curl -X POST "$endpoint/chat/completions?api-version=2024-02-01" `
  -H "api-key: $key" `
  -H "Content-Type: application/json" `
  -d '{"model":"gpt-4o","messages":[{"role":"user","content":"test"}]}'
```

## 🗑️ Cleanup

```powershell
# Delete product (also deletes subscriptions)
az apim product delete --resource-group <rg> --service-name <apim> --product-id <product-id>

# Delete Key Vault secrets
az keyvault secret delete --vault-name <kv> --name <secret-name>
```

## 📊 Service Codes Reference

| Code | Service | API Name Example |
|------|---------|------------------|
| OAI | Azure OpenAI | `azure-openai-service-api` |
| DOC | Document Intelligence | `document-intelligence-api` |
| SRCH | Azure AI Search | `azure-ai-search-index-api` |
| OAIRT | OpenAI Realtime | `openai-realtime-ws-api` |
| LLM | AI Model Inference | `ai-model-inference-api` |

## 🎯 Use Case Naming Examples

| Business Unit | Use Case Name | Environment | Product Name |
|---------------|---------------|-------------|--------------|
| Healthcare | PatientAssistant | DEV | `OAI-Healthcare-PatientAssistant-DEV` |
| CustomerService | SupportAgent | PROD | `OAI-CustomerService-SupportAgent-PROD` |
| Operations | DocAnalysisPipeline | TEST | `DOC-Operations-DocAnalysisPipeline-TEST` |
| Retail | FinancialAssistant | DEV | `OAI-Retail-FinancialAssistant-DEV` |

## 🔒 Required Permissions

| Resource | Role |
|----------|------|
| APIM Resource Group | `API Management Service Contributor` |
| Key Vault (if used) | `Key Vault Secrets Officer` |
| Subscription | `Reader` |

## ⚠️ Common Errors

| Error | Fix |
|-------|-----|
| `ValidationError: API not found` | **MOST COMMON**: Run `az apim api list -g <rg> -n <apim> --query "[].name" -o tsv` to see available APIs. Update your `apiNameMapping` to use exact API names (case-sensitive). Or deploy missing APIs to APIM first. |
| `Authorization failed` | Check RBAC roles: `API Management Service Contributor` on APIM RG |
| `Secret not created` | Check Key Vault permissions: `Key Vault Secrets Officer` |
| `401 on API call` | Verify subscription key is correct from Key Vault or deployment output |
| `403 - Model Not Allowed` | Check policy allowed models in your policy XML file |

### Detailed Troubleshooting for "API not found" Error

If you get: `ValidationError: One or more fields contain incorrect values: aid: API not found`

**This means**: One or more API names in your `apiNameMapping` parameter do not exist in your APIM instance.

**To fix**:

1. List all available APIs in your APIM:
   ```bash
   az apim api list --resource-group <rg> --service-name <apim> --query "[].name" -o tsv
   ```

2. Compare the output with your `apiNameMapping` in `usecase.bicepparam`

3. Update your `apiNameMapping` to use the exact API names (they are case-sensitive):
   ```bicep
   param apiNameMapping = {
     OAI: ['azure-openai-api']        // ✅ Correct (matches APIM)
     // OAI: ['azure-openai-service-api']  // ❌ Wrong (doesn't exist)
   }
   ```

4. Common API name mappings:
   - OpenAI: `azure-openai-api` or `universal-llm-api`
   - Document Intelligence: `document-intelligence-api`
   - AI Search: `ai-search-api`
   - Language: `language-api`
   - Speech: `speech-api`
   - Translator: `translator-api`

## 📚 Example Use Cases

- **[Healthcare Chatbot](samples/healthcare-chatbot/README.md)** - HIPAA compliance, medical records
- **[Customer Support](samples/customer-support-agent/README.md)** - Multi-tier, RAG integration
- **[Document Pipeline](samples/document-analysis-pipeline/README.md)** - Batch processing, OCR

---

**Full Documentation**: [README.md](README.md)
