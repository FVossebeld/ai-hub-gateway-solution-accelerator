# Floris Agent Playground - Citadel Access Contract

## Overview

This access contract provides the **floris-agent-playground** spoke with full access to all available AI models through the Citadel AI Gateway.

## Available Models

This contract grants access to all models deployed in the AI Foundry:

| Model | Publisher | Type | Region |
|-------|-----------|------|--------|
| `gpt-5` | OpenAI | Chat/Reasoning | East US 2 |
| `gpt-4o` | OpenAI | Chat/Reasoning | Sweden Central |
| `gpt-4o-mini` | OpenAI | Chat (Cost-efficient) | Sweden Central |
| `DeepSeek-R1` | DeepSeek | Reasoning | Sweden Central, East US 2 |
| `Phi-4` | Microsoft | Small Language Model | Sweden Central |
| `text-embedding-3-large` | OpenAI | Embeddings | Sweden Central, East US 2 |

## Rate Limits

| Limit | Value |
|-------|-------|
| Calls per minute | 200 |
| Daily token quota | 1,000,000 |

## Created Resources

When deployed, this contract creates:

| Resource | Name | Description |
|----------|------|-------------|
| APIM Product | `OAI-Floris-AgentPlayground-DEV` | Product with policy enforcement |
| APIM Subscription | `OAI-Floris-AgentPlayground-DEV-SUB-01` | Subscription with API key |
| Key Vault Secret | `FLORIS-PLAYGROUND-OPENAI-ENDPOINT` | Gateway endpoint URL |
| Key Vault Secret | `FLORIS-PLAYGROUND-OPENAI-API-KEY` | Subscription API key |

## Deployment

### Prerequisites

1. Ensure the target Key Vault exists:
   - Resource Group: `rg-floris-agent-playground`
   - Key Vault Name: `kv-floris-playground`

2. The deploying identity needs:
   - `API Management Service Contributor` on the APIM instance
   - `Key Vault Secrets Officer` on the target Key Vault

### Deploy the Contract

```bash
az deployment sub create \
  --name floris-agent-playground-contract \
  --location swedencentral \
  --template-file ./bicep/infra/citadel-access-contracts/main.bicep \
  --parameters ./bicep/infra/citadel-access-contracts/contracts/floris-agent-playground/usecase.bicepparam
```

## Usage

After deployment, retrieve the credentials from Key Vault:

```bash
# Get the endpoint
az keyvault secret show \
  --vault-name kv-floris-playground \
  --name FLORIS-PLAYGROUND-OPENAI-ENDPOINT \
  --query value -o tsv

# Get the API key
az keyvault secret show \
  --vault-name kv-floris-playground \
  --name FLORIS-PLAYGROUND-OPENAI-API-KEY \
  --query value -o tsv
```

### Example Request

```python
import openai

client = openai.OpenAI(
    base_url="https://apim-xot5i4klj5zea.azure-api.net/openai",
    api_key="<your-api-key-from-keyvault>"
)

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {"role": "user", "content": "Hello from Floris Agent Playground!"}
    ]
)
```

## Policy Details

The policy enforces:
- ✅ Model allowlist (all available models)
- ✅ Rate limiting (200 calls/min)
- ✅ Token quota (1M tokens/day)
- ✅ Content safety filtering
- ✅ Usage tracking headers

## Support

For questions or issues, contact the Platform Team.
