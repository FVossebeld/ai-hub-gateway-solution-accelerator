# Citadel Access Contracts

This folder contains all approved use case access contracts for the Citadel AI Gateway.

## Structure

```
contracts/
├── _template/                    # Template for new contracts (copy this)
│   ├── usecase.bicepparam        # Contract configuration
│   └── policy.xml                # Custom APIM policy (optional)
├── healthcare-chatbot/           # Healthcare team's patient assistant
├── customer-support-agent/       # CS team's support agent
├── contoso-demo/                 # Demo for Contoso prospect
└── ...
```

## How to Request Access

### For Spoke Teams

1. **Fork this repo** or create a branch
2. **Copy the `_template/` folder** to a new folder with your use case name
3. **Fill in `usecase.bicepparam`** with your requirements
4. **Submit a Pull Request** with:
   - Title: `[Access Contract] <BusinessUnit> - <UseCaseName>`
   - Description: Business justification, expected usage, etc.
5. **Platform team reviews** and merges if approved
6. **CI/CD automatically deploys** the contract
7. **Credentials appear** in your spoke's Key Vault

### Naming Convention

Folder name: `{business-unit}-{use-case-name}` (lowercase, hyphens)

Examples:
- `healthcare-patient-assistant`
- `finance-fraud-detection`
- `customer-support-agent`
- `demo-contoso-multiagent`

## What Gets Created

When a contract is deployed, it creates:

| Resource | Description |
|----------|-------------|
| **APIM Product** | Groups your APIs together with policies |
| **APIM Subscription** | Your API key for authentication |
| **Key Vault Secrets** | Endpoint URL and API key in your spoke's KV |

## Contract Parameters

| Parameter | Description |
|-----------|-------------|
| `apim` | Hub APIM coordinates (provided by platform team) |
| `keyVault` | Your spoke's Key Vault for credentials |
| `useCase` | Business unit, use case name, environment |
| `apiNameMapping` | Which APIs you need (OAI, DOC, SRCH, etc.) |
| `services` | Detailed service configuration with secrets |

## Available Service Codes

| Code | Service | APIs |
|------|---------|------|
| `OAI` | Azure OpenAI | `azure-openai-api`, `universal-llm-api` |
| `DOC` | Document Intelligence | `document-intelligence-api` |
| `SRCH` | AI Search | `ai-search-api` |
| `LANG` | Language Service | `language-api` |
| `SPCH` | Speech Service | `speech-api` |
| `TRAN` | Translator | `translator-api` |

## Approval Process

```
┌────────────────┐     ┌────────────────┐     ┌────────────────┐
│  Spoke Team    │     │ Platform Team  │     │    CI/CD       │
│  submits PR    │────▶│  reviews PR    │────▶│  deploys on    │
│  with contract │     │  & approves    │     │  merge to main │
└────────────────┘     └────────────────┘     └────────────────┘
```

## Questions?

Contact the Platform Team via:
- Slack: #citadel-support
- Email: platform-team@company.com
