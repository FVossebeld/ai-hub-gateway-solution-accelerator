#!/bin/bash
# ============================================================================
# Publish Citadel Access Contract as Template Spec
# ============================================================================
# Run this script to publish (or update) the Citadel Access Contract framework
# as an Azure Template Spec. Spoke teams can then reference it without needing
# access to the hub source code.
#
# Usage:
#   ./scripts/publish-template-spec.sh [version]
#
# Example:
#   ./scripts/publish-template-spec.sh 1.0
#   ./scripts/publish-template-spec.sh 1.1
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ============================================================================
# CONFIGURATION - Update these for your organization
# ============================================================================
TEMPLATE_SPEC_NAME="citadel-access-contracts"
RESOURCE_GROUP="rg-citadel-hub"           # Where to store the Template Spec
LOCATION="swedencentral"
DESCRIPTION="Citadel Access Contract framework for onboarding AI use cases to the gateway"
# ============================================================================

VERSION="${1:-1.0}"
TEMPLATE_FILE="$ROOT_DIR/bicep/infra/citadel-access-contracts/main.bicep"

echo -e "${GREEN}📦 Publishing Citadel Access Contract Template Spec${NC}"
echo "========================================"
echo "Template Spec: $TEMPLATE_SPEC_NAME"
echo "Version: $VERSION"
echo "Resource Group: $RESOURCE_GROUP"
echo ""

# Check Azure CLI
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI not found${NC}"
    exit 1
fi

# Check template file exists
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo -e "${RED}❌ Template file not found: $TEMPLATE_FILE${NC}"
    exit 1
fi

# Get current subscription info
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
SUBSCRIPTION_NAME=$(az account show --query name -o tsv)

echo -e "${YELLOW}Using subscription: $SUBSCRIPTION_NAME ($SUBSCRIPTION_ID)${NC}"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

# Ensure resource group exists
echo -e "${BLUE}📍 Ensuring resource group exists...${NC}"
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none 2>/dev/null || true

# Check if template spec exists
EXISTING=$(az ts show \
    --name "$TEMPLATE_SPEC_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query id -o tsv 2>/dev/null || echo "")

if [ -n "$EXISTING" ]; then
    echo -e "${YELLOW}📝 Template Spec exists, creating new version $VERSION...${NC}"
else
    echo -e "${BLUE}📝 Creating new Template Spec...${NC}"
fi

# Create/update Template Spec
az ts create \
    --name "$TEMPLATE_SPEC_NAME" \
    --version "$VERSION" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --template-file "$TEMPLATE_FILE" \
    --description "$DESCRIPTION" \
    --output table

# Get the reference for spoke teams
TEMPLATE_SPEC_REF="ts:${SUBSCRIPTION_ID}/${RESOURCE_GROUP}/${TEMPLATE_SPEC_NAME}:${VERSION}"

echo ""
echo -e "${GREEN}✅ Template Spec published successfully!${NC}"
echo "========================================"
echo ""
echo -e "${BLUE}📋 Reference for spoke teams:${NC}"
echo ""
echo "   $TEMPLATE_SPEC_REF"
echo ""
echo -e "Add this to your spoke template README or portal."
echo ""
echo -e "${YELLOW}📌 Spoke teams add this to their usecase.bicepparam:${NC}"
echo ""
echo "   using '$TEMPLATE_SPEC_REF'"
echo ""

# List all versions
echo -e "${BLUE}📋 All available versions:${NC}"
az ts list \
    --resource-group "$RESOURCE_GROUP" \
    --query "[?name=='$TEMPLATE_SPEC_NAME'].{Name:name, Version:version, Created:systemData.createdAt}" \
    --output table
