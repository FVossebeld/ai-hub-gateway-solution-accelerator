---
name: Citadel Access Contract Request
about: Request access to AI Gateway services for your use case
title: '[Access Contract] <BusinessUnit> - <UseCaseName>'
labels: access-contract, needs-review
assignees: ''
---

## Use Case Summary

**Business Unit:** <!-- e.g., Healthcare, Finance, Customer Support -->
**Use Case Name:** <!-- e.g., PatientAssistant, FraudDetection -->
**Environment:** <!-- DEV / TEST / STAGING / PROD -->
**Spoke Team Contact:** <!-- Your name and email -->

## Business Justification

<!-- Why do you need access to the AI Gateway? What problem are you solving? -->



## Services Requested

<!-- Check all that apply -->

- [ ] Azure OpenAI (OAI) - Chat completions, embeddings
- [ ] Document Intelligence (DOC) - Document analysis, extraction
- [ ] AI Search (SRCH) - Vector search, RAG
- [ ] Language Service (LANG) - PII detection, sentiment analysis
- [ ] Speech Service (SPCH) - Speech-to-text, text-to-speech
- [ ] Translator (TRAN) - Translation

## Expected Usage

| Metric | Estimate |
|--------|----------|
| Requests per day | <!-- e.g., 1,000 --> |
| Peak requests per minute | <!-- e.g., 50 --> |
| Tokens per day (for LLM) | <!-- e.g., 100,000 --> |
| Users/Applications | <!-- e.g., 10 internal users --> |

## Target Key Vault

<!-- Where should credentials be stored? -->

- **Subscription ID:** 
- **Resource Group:** 
- **Key Vault Name:** 

## Custom Policy Requirements

<!-- Any special rate limits, model restrictions, or content filtering? -->

- [ ] Using default policy (no customization needed)
- [ ] Custom policy included in `policy.xml` (please review)

## Checklist

- [ ] I have copied the `_template` folder to a new folder with my use case name
- [ ] I have filled in `usecase.bicepparam` with correct values
- [ ] My target Key Vault exists and is accessible
- [ ] I have reviewed the [Citadel Access Contracts guide](../README.md)

## Additional Context

<!-- Any other information the platform team should know -->

