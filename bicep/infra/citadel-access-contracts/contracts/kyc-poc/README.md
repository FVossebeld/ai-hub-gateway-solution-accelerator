# KYC POC Access Contract

## Overview

This access contract provides AI services for the Know Your Customer (KYC) Proof of Concept use case.

## Services Requested

| Service | API Names | Purpose |
|---------|-----------|---------|
| **OpenAI (OAI)** | `azure-openai-api`, `universal-llm-api` | Document analysis, verification workflows using GPT-4o |
| **Document Intelligence (DOC)** | `document-intelligence-api` | OCR and document parsing for KYC documents |

## Configuration Details

- **Business Unit**: KYC
- **Use Case Name**: POC
- **Environment**: DEV
- **Product Name**: `OAI-KYC-POC-DEV` and `DOC-KYC-POC-DEV`

## Key Vault Configuration

Credentials will be stored in the spoke Key Vault:
- **Subscription**: 3a0eed45-6d6a-4200-a0f1-85e73312a1a8
- **Resource Group**: rg-kyc-poc-dev
- **Key Vault**: kv-kyc-poc-dev

## Secret Names

After deployment, the following secrets will be available in the Key Vault:

| Secret Name | Description |
|-------------|-------------|
| `kyc-poc-openai-endpoint` | Gateway URL for OpenAI API |
| `kyc-poc-openai-api-key` | Subscription key for OpenAI API |
| `kyc-poc-docintell-endpoint` | Gateway URL for Document Intelligence API |
| `kyc-poc-docintell-api-key` | Subscription key for Document Intelligence API |

## Policy Configuration

Both services use the **default platform policy**, which includes:

- **Rate Limiting**: 300 tokens/minute, 100K tokens/month
- **Model Allowlist**: gpt-4o, DeepSeek-R1
- **Content Safety**: Prompt shields and harmful content detection enabled
- **PII Detection**: Platform-level PII handling

The default policy is centrally managed by the platform team, ensuring automatic security updates.

## API Names Verification

✅ **API names have been verified to avoid the common "API not found" error:**

- `azure-openai-api` - Correct API name in APIM
- `universal-llm-api` - Correct API name in APIM
- `document-intelligence-api` - Correct API name in APIM

## Deployment

To deploy this contract:

```bash
cd bicep/infra/citadel-access-contracts/contracts/kyc-poc
az deployment sub create \
  --name kyc-poc \
  --location swedencentral \
  --template-file ../../main.bicep \
  --parameters usecase.bicepparam
```

## Usage Example

After deployment, retrieve credentials and use them:

```bash
# Get credentials from Key Vault
ENDPOINT=$(az keyvault secret show --vault-name kv-kyc-poc-dev --name kyc-poc-openai-endpoint --query value -o tsv)
API_KEY=$(az keyvault secret show --vault-name kv-kyc-poc-dev --name kyc-poc-openai-api-key --query value -o tsv)

# Test API call
curl -X POST "$ENDPOINT/chat/completions?api-version=2024-02-01" \
  -H "api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4o",
    "messages": [{"role": "user", "content": "Analyze this KYC document..."}]
  }'
```

## Compliance & Security

- All API calls are logged for audit purposes
- Content safety policies enforce responsible AI usage
- PII handling complies with data protection requirements
- Credentials are securely stored in Azure Key Vault with RBAC

## Support

For questions or issues, contact the Platform Team.
