# Customer Support Agent - Use Case Onboarding

This directory contains the Citadel Access Contract configuration for onboarding the Customer Support Agent use case to the AI Citadel Governance Hub.

## What Gets Created

This deployment creates the following resources in APIM:

- **APIM Product**: `OAI-Support-CustomerAgent-DEV`
- **APIM Subscription**: Scoped API key for the spoke to use
- **Governance Policies**:
  - Rate limiting: 100 requests/minute per subscription
  - Token quota: 50,000 tokens/day
  - Model allowlist: gpt-4o-mini, gpt-4o, text-embedding-3-large
  - Usage tracking metadata

## Prerequisites

- Azure CLI authenticated
- Contributor access to APIM resource group (`rg-citadel-dev`)
- APIM instance already deployed (`apim-xot5i4klj5zea`)

## Deployment

```bash
cd /home/flvossebeld/ai-hub-gateway-solution-accelerator

az deployment sub create \
  --name customer-support-onboarding \
  --location swedencentral \
  --template-file ./bicep/infra/citadel-access-contracts/main.bicep \
  --parameters ./bicep/infra/citadel-access-contracts/samples/customer-support-demo/usecase.bicepparam
```

## Retrieve Subscription Key

After deployment, retrieve the subscription key from outputs:

```bash
# Get the subscription key
SUBSCRIPTION_KEY=$(az deployment sub show \
  --name customer-support-onboarding \
  --query 'properties.outputs.endpoints.value[0].apiKey' -o tsv)

echo "APIM Subscription Key: $SUBSCRIPTION_KEY"

# Update spoke .env file
cd /home/flvossebeld/citadel-spoke-customer-support
sed -i "s/APIM_SUBSCRIPTION_KEY=.*/APIM_SUBSCRIPTION_KEY=$SUBSCRIPTION_KEY/" .env
```

## Test the Connection

```bash
# Test API call through gateway
curl -X POST "https://apim-xot5i4klj5zea.azure-api.net/openai/deployments/gpt-4o-mini/chat/completions?api-version=2024-08-01-preview" \
  -H "api-key: $SUBSCRIPTION_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "Hello from customer support agent!"}
    ],
    "max_tokens": 50
  }'
```

## Next Steps

After successful onboarding:

1. Update spoke `.env` with subscription key
2. Deploy spoke infrastructure: `cd ~/citadel-spoke-customer-support && ./scripts/deploy-infrastructure.sh`
3. Deploy agent application: `./scripts/deploy-agent.sh`
4. Test end-to-end connectivity

## Governance Policies

### Rate Limits
- **100 requests per minute** per subscription
- Prevents abuse and ensures fair usage

### Token Quota
- **50,000 tokens per day** per subscription
- Tracks cumulative token usage across all calls

### Model Allowlist
Only these models are permitted:
- `gpt-4o-mini` (cost-effective for most support queries)
- `gpt-4o` (advanced reasoning for complex cases)
- `text-embedding-3-large` (for RAG embeddings)

Attempts to use other models (e.g., `gpt-5-1`, `DeepSeek-R1`) will be rejected with 403 Forbidden.

## Architecture

```
┌─────────────────────────────────────┐
│   PLATFORM TEAM (Hub)               │
│   ┌─────────────────────────────┐   │
│   │  APIM Gateway               │   │
│   │  - Product Created ✅       │   │
│   │  - Subscription Created ✅  │   │
│   │  - Policies Applied ✅      │   │
│   └─────────────────────────────┘   │
└─────────────────────────────────────┘
                 ▲
                 │ Subscription Key
                 │
┌─────────────────────────────────────┐
│   DEVELOPER TEAM (Spoke)            │
│   /home/.../citadel-spoke-customer  │
│   - Uses subscription key           │
│   - Deploys agent in spoke RG       │
│   - Calls APIM gateway              │
└─────────────────────────────────────┘
```
