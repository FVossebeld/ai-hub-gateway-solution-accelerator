# Citadel Governance Hub - Copilot Instructions
 
This document provides a comprehensive overview of the **AI Citadel Governance Hub** repository to help you navigate and understand its structure, purpose, and key components.
 
---
 
## 🏰 What is This Repository?
 
This repository contains the **AI Citadel Governance Hub** - an enterprise-grade AI landing zone solution accelerator. It provides a centralized, governable, and observable control plane for AI service consumption across multiple teams, use cases, and environments using Azure API Management (APIM) as a unified AI gateway.
 
### Key Capabilities
 
- **Unified AI Gateway** - Central entry point for all AI requests with consistent policy enforcement
- **Intelligent Routing & Load Balancing** - Automatic failover and traffic distribution across AI backends
- **Security & Compliance** - Entra ID authentication, PII detection/masking, content safety
- **Usage Analytics & Cost Attribution** - Token tracking, cost allocation by team/application
- **AI Registry** - Catalog for discovering LLMs, tools, and agents (via API Center)
- **Automated Onboarding** - Infrastructure-as-code approach for adding new use cases
 
---
 
# 🏛️ Hub-Spoke Architecture Philosophy
 
The Citadel Governance Hub follows an **enterprise hub-spoke architecture** that integrates with Azure Landing Zones. Understanding this philosophy is critical when working with or extending this solution.
 
### Core Principles
 
1. **Centralized Governance** - All AI traffic flows through the central hub for consistent policy enforcement
2. **Decentralized Workloads** - AI agents and applications run in spoke networks with isolation
3. **Zero Trust Security** - Every request is authenticated and authorized, regardless of network location
4. **Observable by Default** - All AI calls are logged, metered, and traceable without agent code changes
5. **Infrastructure as Code** - All configurations are declarative and version-controlled
 
### Network Deployment Approaches
 
#### Approach 1: Hub-Based (Citadel as Part of Hub Network)
 
Citadel deployed **within** the existing hub VNet:
 
```
┌─────────────────────────────────────┐
│         Hub Network (VNet)          │
│  ┌──────────────────────────────┐   │
│  │   Citadel Governance Hub     │   │
│  │   - APIM Gateway             │   │
│  │   - Private Endpoints        │   │
│  │   - AI Backends              │   │
│  └──────────────────────────────┘   │
│  ┌──────────────────────────────┐   │
│  │   Shared Services            │   │
│  │   - Azure Firewall           │   │
│  │   - DNS                      │   │
│  └──────────────────────────────┘   │
└─────────────────────────────────────┘
           │           │
           ▼           ▼
    ┌──────────┐  ┌──────────┐
    │ Spoke 1  │  │ Spoke 2  │
    │ Agents   │  │ Agents   │
    └──────────┘  └──────────┘
```
 
**Traffic Flow:**
1. Requests originate from spoke-hosted agents
2. Traffic forwarded directly to AI Gateway in hub
3. Gateway enforces governance, security, and observability
4. Requests routed to managed LLMs, tools, or downstream agents
 
**When to Use:**
- ✅ Citadel manages all enterprise AI traffic
- ✅ Direct spoke-to-hub connectivity needed
- ✅ Simplified network topology preferred
 
#### Approach 2: Spoke-Based (Citadel as Dedicated Spoke)
 
Citadel deployed in a **dedicated spoke** with hub firewall in between:
 
```
                 ┌─────────────┐
                 │ Hub Network │
                 │  - Firewall │
                 │  - DNS      │
                 └──────┬──────┘
                        │
         ┌──────────────┼──────────────┐
         ▼              ▼              ▼
  ┌────────────┐ ┌────────────┐ ┌────────────┐
  │  Spoke 1   │ │  Citadel   │ │  Spoke 2   │
  │  Agents    │ │  Gateway   │ │  Agents    │
  └────────────┘ │   Spoke    │ └────────────┘
                 └────────────┘
```
 
**Traffic Flow:**
1. Requests originate from spoke-hosted agents
2. Traffic routed through hub firewall for inspection
3. Firewall forwards to Citadel Gateway spoke
4. Gateway enforces governance and routes to AI backends
5. Responses may route back through firewall
 
**When to Use:**
- ✅ Defense-in-depth security (dual inspection layers)
- ✅ Isolated AI workloads from general traffic
- ✅ Separate cost centers/subscriptions required
- ✅ Compliance requirements for network isolation
 
### Three Pillars of AI Citadel
 
#### 1️⃣ Governance & Security Pillar
 
**Purpose:** Trustworthy AI operations at scale
 
| Capability | Description |
|------------|-------------|
| Unified AI Gateway | Central APIM entry point with consistent policy enforcement |
| Managed Credentials | Gateway-keys pattern with scoped, revocable tokens and JWT support |
| Policy Enforcement | Rate/token limiting, quotas, traffic mediation |
| Multi-Cloud Support | Govern Azure OpenAI, open-source, third-party models |
| AI Content Safety | Prompt shields, harmful content detection |
| Cost Governance | Centralized logging, usage tracking, cost attribution |
| AI Registry | Unified catalog for LLMs, tools, and agents |
| Data Security | PII detection, Microsoft Purview integration |
 
#### 2️⃣ Observability & Compliance Pillar
 
**Purpose:** End-to-end monitoring, evaluation, and trust
 
| Feature | Description |
|---------|-------------|
| Central APM | Azure Monitor and Application Insights for system health |
| Usage Tracking | Token consumption, request volumes, cost allocation |
| Centralized AI Evaluation | Automated quality evaluations without code changes |
| Enterprise Alerts | Configurable alerts with automated remediation |
 
**Key Principle:** Platform observability is enabled out-of-the-box for all AI workloads routing through the gateway.
 
#### 3️⃣ AI Development Velocity Pillar
 
**Purpose:** Accelerate innovation with templates and tools
 
| Capability | Description |
|------------|-------------|
| Citadel Access Contract | Declare required LLM/tool access with governance policies |
| Citadel Publish Contract | Publish agents and tools to the hub registry |
| Citadel AI Registry | Central catalog for discovering and reusing AI assets |
| DevOps Integration | Source-controlled, automatable contract configurations |
 
---
 
## 📋 Guidelines for Working with This Repository
 
### General Development Guidelines
 
1. **Always Use Infrastructure as Code**
   - Never manually configure APIM, backends, or policies through the portal
   - All changes must be made through Bicep templates
   - Version control all configuration changes
 
2. **Follow the Contract Pattern**
   - Use **Citadel Access Contracts** for onboarding new use cases
   - Define all AI service dependencies declaratively
   - Include governance policies in the contract
 
3. **Maintain Hub-Spoke Separation**
   - Hub contains shared governance infrastructure
   - Spokes contain workload-specific resources
   - Traffic between spokes must flow through the hub
 
### Security Guidelines
 
1. **Zero Trust Principles**
   - Always require authentication (Entra ID JWT or API keys)
   - Use managed identities for service-to-service communication
   - Never expose AI backends directly; always route through APIM
 
2. **Secrets Management**
   - Store all secrets in Azure Key Vault
   - Use Key Vault references in Bicep parameters
   - Never commit secrets to version control
   - Rotate credentials regularly
 
3. **Network Security**
   - Production deployments must use private endpoints
   - Disable public network access on all backend services
   - Use NSGs on all subnets
   - Force traffic through firewall when using spoke-based deployment
 
4. **PII Protection**
   - Enable PII detection for sensitive workloads
   - Configure appropriate confidence thresholds
   - Log PII events for compliance auditing
 
### APIM Policy Guidelines
 
1. **Use Policy Fragments**
   - Create reusable fragments for common logic
   - Store fragments in `bicep/infra/modules/apim/policies/`
   - Always include `<base />` to inherit parent policies
 
2. **Policy Hierarchy**
   - Global policies → Product policies → API policies → Operation policies
   - Use appropriate level based on scope of enforcement
 
3. **Required Policy Elements**
   - Authentication validation
   - Rate limiting and quota enforcement
   - Usage logging to Event Hub
   - Error handling with appropriate responses
 
4. **Content Safety**
   - Enable Azure AI Content Safety for all LLM APIs
   - Configure prompt shields for production workloads
   - Log blocked content for security review
 
### Backend Configuration Guidelines
 
1. **LLM Backend Configuration**
   - Use `llmBackendConfig` parameter for all backend definitions
   - Define `supportedModels` for each backend
   - Configure circuit breakers for resilience
   - Use priority and weight for load balancing
 
2. **Multi-Region Deployments**
   - Deploy AI Foundry instances in multiple regions
   - Configure backend pools for automatic failover
   - Use priority routing (primary/secondary)
 
3. **Authentication**
   - Prefer managed identity over API keys
   - Use `authScheme: 'managedIdentity'` in backend config
   - Store fallback keys in Key Vault
 
### Use Case Onboarding Guidelines
 
1. **Product Naming Convention**
   - Format: `{ServiceCode}-{BusinessUnit}-{UseCaseName}-{Environment}`
   - Example: `OAI-Healthcare-PatientAssistant-PROD`
 
2. **Subscription Management**
   - One subscription per product
   - Store credentials in Key Vault
   - Use descriptive secret names
 
3. **Policy Customization**
   - Start with default policy template
   - Customize rate limits based on use case
   - Add model allowlists as needed
   - Include specific error handling
 
4. **Testing Before Production**
   - Validate in development environment first
   - Use `az deployment sub what-if` to preview changes
   - Test rate limits and error responses
 
### Monitoring Guidelines
 
1. **Application Insights**
   - Enable for all APIM instances
   - Configure sampling for high-volume scenarios
   - Create custom dashboards per use case
 
2. **Usage Analytics**
   - Ensure Event Hub logging is configured
   - Verify Logic App/Function processing
   - Populate model-pricing.json for cost calculations
 
3. **Alerting**
   - Configure throttling event alerts
   - Set up capacity threshold notifications
   - Create alerts for error rate spikes
 
### Cost Management Guidelines
 
1. **SKU Selection**
   - Development: Use `Developer` APIM SKU
   - Production: Use `StandardV2` or `PremiumV2`
   - Right-size Cosmos DB RUs and Event Hub capacity
 
2. **Tagging Strategy**
   - Always include `Environment`, `CostCenter`, `Owner` tags
   - Use tags for cost allocation and reporting
 
3. **Capacity Planning**
   - Monitor token usage trends
   - Plan PTU (Provisioned Throughput Units) for predictable workloads
   - Use pay-as-you-go for variable workloads
 
---
 
## 🔐 RBAC Model: Platform Team vs. Developer Team
 
Citadel follows a clear separation of responsibilities between the **Platform Team** (manages the hub) and **Developer Teams** (build use cases in spokes).
 
### Platform Team Responsibilities
 
The Platform Team manages the centralized Citadel Hub infrastructure:
 
| Responsibility | Details |
|----------------|---------|
| **Infrastructure** | Deploy & manage APIM, AI Foundry, Cosmos DB, Event Hub |
| **Model Management** | Deploy models, manage quotas, capacity planning |
| **Governance Policies** | Rate limits, token quotas, content safety rules |
| **Use Case Onboarding** | Create APIM products, grant developer access |
| **Cost Management** | Usage monitoring, chargeback, cost attribution |
| **Security** | Network security, Key Vault management, RBAC |
 
**Required Roles on Hub Resource Group:**
- `Owner` or `Contributor + User Access Administrator`
- `API Management Service Contributor`
- `Key Vault Administrator`
- `Cognitive Services Contributor`
- `Cosmos DB Account Contributor`
- `Monitoring Contributor`
 
### Developer Team Responsibilities
 
Developer Teams build AI applications in their spoke resource groups:
 
| Responsibility | Details |
|----------------|---------|
| **Application Development** | Build agents, apps, integrations |
| **Spoke Resources** | Manage AI Search indexes, storage, apps |
| **Data Management** | Upload documents, create embeddings |
| **Testing** | Validate against APIM gateway |
| **App Monitoring** | Debug application-level issues |
 
**Required Roles on Spoke Resource Group:**
- `Contributor` (full control of spoke RG)
- `Storage Blob Data Contributor`
- `Search Index Data Contributor`
- `Key Vault Secrets Officer` (on spoke Key Vault)
 
**Limited Roles on Hub (granted by Platform Team):**
- `Key Vault Secrets User` (read API keys only)
- `Cognitive Services User` (use models, not manage)
 
### RBAC Assignment Examples
 
```bash
# Platform team - full control of hub
az role assignment create \
  --assignee <platform-team-group-id> \
  --role "Owner" \
  --scope /subscriptions/<sub>/resourceGroups/rg-citadel-hub
 
# Developer - full control of their spoke RG
az role assignment create \
  --assignee <developer-or-team-id> \
  --role "Contributor" \
  --scope /subscriptions/<sub>/resourceGroups/rg-customer-demo
 
# Developer - limited access to hub (read API keys only)
az role assignment create \
  --assignee <developer-or-team-id> \
  --role "Key Vault Secrets User" \
  --scope /subscriptions/<sub>/resourceGroups/rg-citadel-hub/providers/Microsoft.KeyVault/vaults/kv-citadel-hub
```
 
---
 
## 🏗️ Resource Placement: Hub vs. Spoke
 
Understanding where resources belong is critical for proper governance and isolation.
 
### Hub Resources (Platform Team Managed)
 
These resources are **centralized** and **shared** across all use cases:
 
| Resource | Purpose | Why in Hub |
|----------|---------|------------|
| **APIM Gateway** | Unified AI Gateway | Central governance, single entry point |
| **AI Foundry** | Model deployments (GPT-4o, etc.) | Centralized quota, cost control |
| **Foundry Projects** | Per-customer isolation | Lightweight, uses shared models |
| **Cosmos DB** | Usage tracking | Cross-use-case analytics |
| **Event Hub** | Usage streaming | Centralized logging |
| **Log Analytics** | Monitoring | Enterprise observability |
| **App Insights** | APM | Platform-wide monitoring |
| **Hub Key Vault** | Master secrets, model keys | Security boundary |
| **Content Safety** | AI guardrails | Enterprise policy |
| **PII Detection** | Data protection | Compliance |
| **API Center** | AI Registry | Discovery & governance |
 
### Spoke Resources (Developer Team Managed)
 
These resources are **isolated** per use case/customer:
 
| Resource | Purpose | Why in Spoke |
|----------|---------|--------------|
| **Spoke Key Vault** | App-specific secrets | Developer autonomy |
| **AI Search Index** | RAG knowledge base | Use-case specific data |
| **Storage Account** | Documents, embeddings | Data isolation |
| **Container Apps / App Service** | Agent applications | Workload isolation |
| **Function Apps** | Event-driven logic | Custom processing |
| **Cosmos DB (optional)** | Agent state/memory | If needed for agent persistence |
| **Spoke App Insights** | App-level monitoring | Developer debugging |
 
### Decision Framework
 
| Question | Answer |
|----------|--------|
| Should each spoke have its own AI Foundry? | ❌ No - Use projects connected to hub's Foundry |
| Should each spoke have its own models? | ❌ No - Centralized in hub for quota control |
| Should each spoke have its own APIM? | ❌ No - Use products in central APIM |
| Should each spoke have its own Key Vault? | ✅ Yes - For app-specific secrets |
| Should each spoke have its own AI Search? | ✅ Yes - Data isolation per customer |
| Should each spoke have its own Storage? | ✅ Yes - Document/data isolation |
| Who controls token/usage limits? | 🔒 Platform team via APIM policies |
| Who controls model access? | 🔒 Platform team via APIM products |
| Who can deploy agents? | 👨‍💻 Developer team in their spoke RG |
 
---
 
## 🏷️ Multi-Tenant Demo & Customer Management
 
When using Citadel for demos or multi-customer scenarios, use a "Deploy Once, Demo Many" pattern.
 
### Tagging Strategy for Customer/Demo Isolation
 
Use consistent tags to track and manage customer demos:
 
| Tag Key | Purpose | Example Values |
|---------|---------|----------------|
| `Customer` | Customer/prospect name | `Contoso`, `Fabrikam`, `Northwind` |
| `DemoType` | Type of demo | `MultiAgent`, `DocumentProcessing`, `RAG`, `Chatbot` |
| `DemoDate` | Demo/presentation date | `2025-12-15` |
| `DemoOwner` | Owner name or team | `flvossebeld`, `Sales-NL` |
| `DemoStatus` | Lifecycle state | `Active`, `Archived`, `Scheduled` |
| `Industry` | Customer industry | `Healthcare`, `Finance`, `Retail` |
 
### Where Tags Apply
 
- **APIM Products** - Each customer demo gets its own product with tags
- **Key Vault Secrets** - Prefix by customer name (e.g., `CONTOSO-OPENAI-KEY`)
- **Spoke Resource Groups** - Tag entire RG for cost allocation
- **Usage Tracking** - Cosmos DB records tagged by subscription/product
 
### Customer Demo Workflow
 
1. **Platform Team: Create APIM Product**
   ```bash
   az deployment sub create \
     --template-file ./bicep/infra/citadel-access-contracts/main.bicep \
     --parameters ./bicep/infra/citadel-access-contracts/samples/contoso-demo/usecase.bicepparam
   ```
 
2. **Platform Team: Grant Developer Access**
   - Assign `Key Vault Secrets User` for API key access
   - Create spoke resource group with `Contributor` role
 
3. **Developer Team: Build in Spoke**
   - Create spoke-specific resources (AI Search, Storage, Apps)
   - Retrieve API keys from hub Key Vault
   - Deploy agent applications
 
4. **After Demo: Cleanup**
   ```bash
   # Delete APIM product
   az apim product delete --product-id OAI-Contoso-Demo-DEV ...
   
   # Delete spoke resource group
   az group delete --name rg-contoso-demo
   ```
 
### Product Naming Convention
 
Format: `{ServiceCode}-{Customer}-{UseCaseName}-{Environment}`
 
Examples:
- `OAI-Contoso-MultiAgent-DEMO`
- `DOC-Fabrikam-InvoiceProcess-DEMO`
- `SRCH-Northwind-RAGChatbot-DEMO`
 
---
 
## 🤖 AI Foundry Hub-Spoke Pattern
 
For AI Foundry, use a hub-spoke pattern where models are centralized but projects are isolated.
 
### Architecture
 
```
┌─────────────────────────────────────────────────────────────┐
│                AI FOUNDRY HUB (Central)                     │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Foundry Resource (AI Services)                       │  │
│  │  • GPT-4o, GPT-4o-mini, DeepSeek-R1                   │  │
│  │  • Centralized quota & capacity                       │  │
│  │                                                       │  │
│  │  Projects (one per customer/use case):                │  │
│  │  ├── contoso-multiagent-project                       │  │
│  │  ├── fabrikam-docprocess-project                      │  │
│  │  └── northwind-rag-project                            │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```
 
### Benefits
 
- **Shared Models** - Deploy once, use everywhere
- **Centralized Quota** - Platform team controls capacity
- **Project Isolation** - Each customer has separate project context
- **Unified Billing** - All usage tracked centrally
 
### Creating Customer Projects
 
```bash
# Create project in existing Foundry resource
az cognitiveservices account project create \
  --name contoso-multiagent-demo \
  --resource-group rg-citadel-hub \
  --account-name aif-citadel-hub \
  --location swedencentral
```
 
---
 
## 📁 Repository Structure
 
### Root Files
 
| File | Description |
|------|-------------|
| `README.md` | Main documentation with architecture overview, quick start, and comprehensive guides |
| `azure.yaml` | Azure Developer CLI (azd) configuration for deployment |
| `LICENSE` | MIT License |
| `.env.template` | Template for environment variables |
| `.gitignore` | Git ignore patterns |
 
---
 
### `/bicep/infra/` - Infrastructure as Code
 
The main Bicep templates for deploying the entire solution.
 
| File | Description |
|------|-------------|
| `main.bicep` | Main orchestration template - entry point for all deployments |
| `main.bicepparam` | Default parameter file for Azure Developer CLI (azd) deployments |
| `main.parameters.dev.bicepparam` | Development environment parameters (cost-optimized) |
| `main.parameters.prod.bicepparam` | Production environment parameters (HA configuration) |
| `main.parameters.complete.bicepparam` | Reference file with ALL available parameters documented |
| `abbreviations.json` | Standard Azure resource naming abbreviations |
 
#### `/bicep/infra/modules/` - Bicep Modules
 
Modular Bicep components organized by Azure service:
 
| Folder/File | Description |
|-------------|-------------|
| `apim/` | API Management configuration - APIs, policies, products, backends, MCP servers |
| `ai/` | AI services (Content Safety, Language Service for PII) |
| `apic/` | API Center (AI Registry) configuration including MCP server registration |
| `cosmos-db/` | Cosmos DB for usage data storage |
| `event-hub/` | Event Hub for real-time usage streaming |
| `foundry/` | Azure AI Foundry instances and model deployments |
| `functionapp/` | Azure Functions for usage processing |
| `logicapp/` | Logic Apps for workflow-based processing |
| `monitor/` | Application Insights, Log Analytics, dashboards |
| `networking/` | Virtual Network, subnets, NSGs, private endpoints, DNS |
| `security/` | Managed identities for APIM and usage processing |
| `azure-roles.json` | Azure RBAC role definitions reference |
 
#### `/bicep/infra/modules/apim/` - APIM Configuration Details
 
| File/Folder | Description |
|-------------|-------------|
| `apim.bicep` | Main APIM module orchestration |
| `api.bicep` | Generic API creation module |
| `policy-fragments.bicep` | APIM policy fragments deployment |
| `llm-backends.bicep` | Dynamic LLM backend creation |
| `llm-backend-pools.bicep` | Backend pool configuration for load balancing |
| `llm-policy-fragments.bicep` | LLM-specific policy fragment generation |
| `inference-api.bicep` | AI Model Inference API |
| `inference-backend.bicep` | Backend for inference endpoints |
| `api-center-onboarding.bicep` | API Center integration |
| `mcp-existing.bicep` | MCP server integration from existing APIs |
| `mcp-from-api.bicep` | MCP server creation from API specifications |
| `README-llm-backends.md` | Documentation for LLM backend configuration |
| `API-CENTER-ALL-APIS.md` | Documentation for API Center integration |
| `openai-api/` | Azure OpenAI API definitions and policies |
| `universal-llm-api/` | Universal LLM API (multi-provider support) |
| `ai-search-api/` | Azure AI Search API integration |
| `doc-intel-api/` | Document Intelligence API |
| `language-api/` | Azure Language Service API |
| `speech-api/` | Azure Speech Service API |
| `translator-api/` | Azure Translator API |
| `ai-model-inference/` | AI Model Inference API |
| `policies/` | XML policy files for all API configurations |
| `sample/` | Sample API configurations (weather example) |
 
#### `/bicep/infra/citadel-access-contracts/` - Citadel Access Contracts (Use Case Onboarding)
 
Automated onboarding of new AI use cases to the gateway using Citadel Access Contracts.
 
| File/Folder | Description |
|-------------|-------------|
| `main.bicep` | Main onboarding orchestration |
| `main.bicepparam` | Default onboarding parameters |
| `README.md` | Comprehensive onboarding documentation |
| `QUICKSTART.md` | Quick start guide for onboarding |
| `modules/` | Reusable onboarding modules (`apimOnboardService.bicep`, `apimProduct.bicep`, `apimSubscription.bicep`, `kvSecrets.bicep`) |
| `policies/` | Default product policies (`default-ai-product-policy.xml`) |
| `samples/` | Example use case configurations (`customer-support-agent/`, `document-analysis-pipeline/`, `healthcare-chatbot/`) |
 
#### `/bicep/infra/llm-backend-onboarding/` - LLM Backend Onboarding
 
Independent LLM backend routing deployment with load balancing and failover.
 
| File/Folder | Description |
|-------------|-------------|
| `main.bicep` | Main LLM backend onboarding orchestration |
| `main.bicepparam` | Default LLM backend parameters |
| `README.md` | LLM backend onboarding documentation |
| `modules/` | Reusable modules (`llm-backends.bicep`, `llm-backend-pools.bicep`, `llm-policy-fragments.bicep`, `universal-llm-api.bicep`, `policies/`) |
 
---
 
### `/src/` - Application Source Code
 
#### `/src/usage-ingestion-function/` - Azure Function (.NET)
 
Usage data processing function for Cosmos DB ingestion.
 
| File | Description |
|------|-------------|
| `Program.cs` | Function app entry point and DI configuration |
| `UsageProcessorFunction.cs` | Event Hub trigger function for usage processing |
| `usage-ingestion-func.csproj` | .NET 8 project file |
| `host.json` | Azure Functions host configuration |
 
#### `/src/usage-ingestion-logicapp/` - Logic Apps Workflows
 
Workflow-based processing for AI usage events.
 
| Folder | Description |
|--------|-------------|
| `ai-usage-ingestion/` | General AI usage ingestion workflow |
| `ai-usage-streaming-ingestion/` | Streaming usage data workflow |
| `llm-usage-ingestion/` | LLM-specific usage ingestion |
| `pii-usage-ingestion/` | PII detection results processing |
| `workflow-designtime/` | Design-time workflow artifacts |
| `connections.json` | Logic App connections configuration |
| `host.json` | Logic App host configuration |
 
#### `/src/usage-reports/` - Reporting Assets
 
| File | Description |
|------|-------------|
| `AI-Hub-Gateway-Usage-Report-v1-5-Incremetal.pbix` | Power BI dashboard template |
| `model-pricing.json` | AI model pricing data for cost calculations |
| `usage-record.json` | Sample usage record schema |
| `AI-Search-Cost-Estimation-Logic.md` | Cost estimation methodology for AI Search |
 
#### `/src/testing/` - Testing Resources
 
| File | Description |
|------|-------------|
| `openai-testing.http` | HTTP request samples for API testing |
 
---
 
### `/guides/` - Documentation Guides
 
Comprehensive guides for deployment and configuration.
 
| Guide | Description |
|-------|-------------|
| `quick-deployment-guide.md` | Fast deployment for non-production environments |
| `full-deployment-guide.md` | Complete guide for dev, staging, and production |
| `parameters-usage-guide.md` | Bicep parameter file usage and customization |
| `LLM-Backend-Onboarding-Guide.md` | Adding Azure OpenAI instances and models (including Realtime API) |
| `Citadel-Access-Contracts.md` | Use case onboarding automation with contracts |
| `entraid-auth-validation.md` | JWT validation and Entra ID authentication setup |
| `pii-masking-apim.md` | PII detection, anonymization, and deanonymization |
| `power-bi-dashboard.md` | Usage analytics dashboard setup |
| `llm-routing-architecture.md` | Technical dive into LLM model and backend routing logic |
| `network-approach.md` | Detailed networking approach for Citadel Governance Hub deployment |
 
---
 
### `/scripts/` - Utility Scripts
 
| Script | Description |
|--------|-------------|
| `apim-event-hub-logger.ps1` | PowerShell script for Event Hub logger configuration |
| `azure-key-vault-certificate-import.sh` | Bash script for Key Vault certificate import |
 
---
 
### `/shared/` - Shared Utilities
 
| File | Description |
|------|-------------|
| `apimtools.py` | Python utilities for APIM operations |
| `utils.py` | General Python utility functions |
| `requirements.txt` | Python dependencies |
 
#### `/shared/snippets/` - Reusable Code Snippets
 
| File | Description |
|------|-------------|
| `README.md` | Instructions for using snippets in notebooks |
| `openai-api-requests.py` | OpenAI API request examples |
| `api-http-requests.py` | Generic HTTP request utilities |
| `create-az-deployment.py` | Azure deployment creation |
| `create-az-resource-group.py` | Resource group creation |
| `deployment-outputs.py` | Deployment output retrieval |
 
---
 
### `/validation/` - Validation and Testing
 
| File | Description |
|------|-------------|
| `citadel-governance-hub-primary-tests.ipynb` | Jupyter notebook for governance hub validation tests |
| `llm-backend-onboarding-runner.ipynb` | Jupyter notebook for LLM backend onboarding automation |
| `requirements.txt` | Python dependencies for validation |
 
---
 
### `/assets/` - Visual Assets
 
Contains images, diagrams, and logos used in documentation:
 
- Architecture diagrams
- Power BI dashboard screenshots
- Flow diagrams
- Citadel logo and branding
 
---
 
### `/.vscode/` - VS Code Configuration
 
| File | Description |
|------|-------------|
| `settings.json` | Workspace settings |
| `launch.json` | Debug configurations |
| `tasks.json` | Build and run tasks |
| `extensions.json` | Recommended extensions |
 
---
 
### `/.azure/` - Azure Developer CLI
 
| Path | Description |
|------|-------------|
| `config.json` | azd configuration |
| `citadel-hub/` | Environment-specific azd settings |
 
---
 
### `/.azdo/` - Azure DevOps
 
| Path | Description |
|------|-------------|
| `pipelines/azure-dev.yml` | Azure DevOps CI/CD pipeline for azd |
 
---
 
## 🚀 Deployment Methods
 
### 1. Azure Developer CLI (Recommended for Quick Start)
 
```bash
# Initialize and deploy
azd init --template Azure-Samples/ai-hub-gateway-solution-accelerator --branch citadel-v1
azd auth login
azd up
```
 
### 2. Azure CLI with Bicep Parameters
 
```bash
# Deploy with parameter file
az deployment sub create \
  --location eastus \
  --template-file ./bicep/infra/main.bicep \
  --parameters ./bicep/infra/main.parameters.dev.bicepparam
```
 
---
 
## 🔧 Key Configuration Files
 
### For Infrastructure Deployment
 
1. **`bicep/infra/main.bicepparam`** - Default parameters for azd
2. **`bicep/infra/main.parameters.dev.bicepparam`** - Development settings
3. **`bicep/infra/main.parameters.prod.bicepparam`** - Production settings
4. **`bicep/infra/main.parameters.complete.bicepparam`** - All parameters reference
 
### For Use Case Onboarding
 
1. **`bicep/infra/citadel-access-contracts/main.bicep`** - Onboarding template
2. **`bicep/infra/citadel-access-contracts/samples/`** - Example configurations
 
### For LLM Backend Onboarding
 
1. **`bicep/infra/llm-backend-onboarding/main.bicep`** - LLM backend onboarding template
2. **`bicep/infra/llm-backend-onboarding/main.bicepparam`** - Default LLM backend parameters
 
### For Usage Processing
 
1. **`src/usage-ingestion-function/`** - .NET Function App
2. **`src/usage-ingestion-logicapp/`** - Logic App workflows
3. **`src/usage-reports/model-pricing.json`** - Pricing data
 
---
 
## 📊 Key Azure Services Used
 
| Service | Purpose |
|---------|---------|
| **Azure API Management** | Unified AI Gateway |
| **Azure AI Foundry** | LLM model hosting |
| **Azure Cosmos DB** | Usage data storage |
| **Azure Event Hub** | Real-time usage streaming |
| **Azure Key Vault** | Secrets management |
| **Azure Application Insights** | Monitoring and diagnostics |
| **Azure Log Analytics** | Centralized logging |
| **Azure AI Language** | PII detection |
| **Azure AI Content Safety** | Content filtering |
| **Azure API Center** | AI service registry |
| **Azure Functions** | Event processing |
| **Azure Logic Apps** | Workflow automation |
 
---
 
## 🔑 Important Concepts
 
### Citadel Access Contracts
 
Declarative configuration files that define:
- Which AI services a use case needs access to
- Rate limits and quotas
- Security policies
- Cost allocation
 
### LLM Backend Configuration
 
Dynamic backend management supporting:
- Azure OpenAI
- Azure AI Foundry
- Third-party OpenAI-compatible APIs
- Automatic load balancing and failover
 
### PII Handling
 
Built-in support for:
- NLP-based PII detection
- Regex pattern matching
- Anonymization before backend calls
- Deanonymization in responses
 
---
 
## 📚 Where to Find More Information
 
| Topic | Location |
|-------|----------|
| Architecture overview | `README.md` |
| Deployment instructions | `guides/quick-deployment-guide.md`, `guides/full-deployment-guide.md` |
| Parameter configuration | `guides/parameters-usage-guide.md` |
| Adding LLM backends | `guides/LLM-Backend-Onboarding-Guide.md` |
| Use case onboarding | `guides/Citadel-Access-Contracts.md`, `bicep/infra/citadel-access-contracts/README.md` |
| Security setup | `guides/entraid-auth-validation.md` |
| PII protection | `guides/pii-masking-apim.md` |
| Usage analytics | `guides/power-bi-dashboard.md` |
| LLM routing architecture | `guides/llm-routing-architecture.md` |
| Network configuration | `guides/network-approach.md` |
 
---
 
## 🛠️ Development Tips
 
### When Modifying APIM Policies
 
- Policy files are in `bicep/infra/modules/apim/policies/`
- Use policy fragments for reusable logic
- Test policies in APIM portal before deploying
 
### When Adding New AI Services
 
1. Create API definition in `bicep/infra/modules/apim/`
2. Add policy files for the API
3. Update `main.bicep` to include the new API
4. Document in the appropriate guide
 
### When Working with Usage Processing
 
- Function App handles Event Hub events
- Logic Apps process different event types
- Cosmos DB stores aggregated usage data
- Power BI connects for visualization
 
---
 
## ⚠️ Important Notes
 
1. **Environment Variables**: Use `.azure/<env>/.env` for sensitive values (not committed to git)
2. **API Keys**: Never hardcode keys; use Key Vault references
3. **Network Configuration**: Production deployments should use private endpoints
4. **APIM SKU**: StandardV2/PremiumV2 recommended for production; Developer for testing
 
---
 
This document should help you quickly locate files and understand the purpose of each component in the repository.
 
---
 
## 💼 Practical Demo Scenario Examples
 
### Multi-Agent with Document Processing Demo
 
For a demo combining multi-agent orchestration with document processing:
 
**Hub Resources (already deployed):**
- APIM with OpenAI, Document Intelligence, AI Search APIs
- AI Foundry with GPT-4o, GPT-4o-mini models
 
**Spoke Resources (create for customer):**
```
rg-contoso-multiagent-demo/
├── kv-contoso-demo              # Customer Key Vault
├── srch-contoso-demo            # AI Search for RAG
├── st-contoso-demo              # Storage for documents
├── ca-contoso-orchestrator      # Container App - Orchestrator Agent
├── ca-contoso-doc-agent         # Container App - Document Agent
├── ca-contoso-research-agent    # Container App - Research Agent
└── appi-contoso-demo            # App Insights for debugging
```
 
**APIM Products (created by platform team):**
- `OAI-Contoso-MultiAgent-DEMO` - OpenAI access
- `DOC-Contoso-MultiAgent-DEMO` - Document Intelligence access
- `SRCH-Contoso-MultiAgent-DEMO` - AI Search access
 
### RAG Chatbot Demo
 
**Spoke Resources:**
```
rg-northwind-rag-demo/
├── kv-northwind-demo            # Customer Key Vault
├── srch-northwind-demo          # AI Search with knowledge index
├── st-northwind-demo            # Storage for knowledge base docs
└── ca-northwind-chatbot         # Container App - Chatbot
```
 
**APIM Products:**
- `OAI-Northwind-RAGChatbot-DEMO` - OpenAI for chat
- `SRCH-Northwind-RAGChatbot-DEMO` - AI Search for retrieval
 
---
 
## 🔄 Lifecycle Management
 
### Creating a New Customer Demo
 
1. **Copy template from samples:**
   ```bash
   cp -r bicep/infra/citadel-access-contracts/samples/document-analysis-pipeline \
         bicep/infra/citadel-access-contracts/samples/contoso-demo
   ```
 
2. **Customize `usecase.bicepparam`:**
   - Update `apim` and `keyVault` references
   - Set `useCase.businessUnit` to customer name
   - Configure services and secret names
 
3. **Deploy APIM products:**
   ```bash
   az deployment sub create \
     --name contoso-demo-onboarding \
     --location swedencentral \
     --template-file ./bicep/infra/citadel-access-contracts/main.bicep \
     --parameters ./bicep/infra/citadel-access-contracts/samples/contoso-demo/usecase.bicepparam
   ```
 
4. **Create spoke resource group with tags:**
   ```bash
   az group create \
     --name rg-contoso-demo \
     --location swedencentral \
     --tags Customer=Contoso DemoType=MultiAgent DemoDate=2025-12-15 Owner=flvossebeld
   ```
 
### Archiving a Demo
 
```bash
# 1. Export any important data/configurations
 
# 2. Delete APIM products
az apim product delete \
  --resource-group rg-citadel-hub \
  --service-name apim-citadel \
  --product-id OAI-Contoso-MultiAgent-DEMO --yes
 
# 3. Delete spoke resource group
az group delete --name rg-contoso-demo --yes --no-wait
```
 
### Cost Tracking Per Customer
 
Query usage by customer from Cosmos DB:
```sql
SELECT
  c.subscriptionId,
  SUM(c.totalTokens) as totalTokens,
  SUM(c.estimatedCost) as estimatedCost
FROM c
WHERE c.subscriptionId LIKE '%Contoso%'
GROUP BY c.subscriptionId
```
 
 