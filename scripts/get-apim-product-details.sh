#!/bin/bash

# Script: get-apim-product-details.sh
# Purpose: Get comprehensive details about an APIM product including APIs, operations, policies, backends, and subscriptions
# Usage: ./get-apim-product-details.sh <product-id> [resource-group] [apim-service-name] [subscription-id]

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}\n"
}

# Function to print error
print_error() {
    echo -e "${RED}ERROR: $1${NC}" >&2
}

# Function to print warning
print_warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

# Check required parameters
if [ -z "$1" ]; then
    print_error "Product ID is required"
    echo "Usage: $0 <product-id> [resource-group] [apim-service-name] [subscription-id]"
    echo ""
    echo "Example:"
    echo "  $0 OAI-Support-CustomerAgent-DEV"
    echo "  $0 OAI-Support-CustomerAgent-DEV rg-citadel-dev apim-xot5i4klj5zea"
    exit 1
fi

PRODUCT_ID="$1"
RESOURCE_GROUP="${2:-}"
APIM_SERVICE="${3:-}"
SUBSCRIPTION_ID="${4:-}"

# Auto-detect parameters if not provided
if [ -z "$SUBSCRIPTION_ID" ]; then
    print_warning "Subscription ID not provided, using default subscription"
    SUBSCRIPTION_ID=$(az account show --query id -o tsv)
    echo "Using subscription: $SUBSCRIPTION_ID"
fi

if [ -z "$RESOURCE_GROUP" ] || [ -z "$APIM_SERVICE" ]; then
    print_warning "Resource group or APIM service not provided, searching..."
    
    # Find APIM services in subscription
    APIM_LIST=$(az apim list --subscription "$SUBSCRIPTION_ID" --query "[].{rg:resourceGroup, name:name}" -o json)
    APIM_COUNT=$(echo "$APIM_LIST" | jq '. | length')
    
    if [ "$APIM_COUNT" -eq 0 ]; then
        print_error "No APIM services found in subscription"
        exit 1
    elif [ "$APIM_COUNT" -eq 1 ]; then
        RESOURCE_GROUP=$(echo "$APIM_LIST" | jq -r '.[0].rg')
        APIM_SERVICE=$(echo "$APIM_LIST" | jq -r '.[0].name')
        echo "Found APIM service: $APIM_SERVICE in resource group: $RESOURCE_GROUP"
    else
        print_error "Multiple APIM services found. Please specify resource group and service name."
        echo "$APIM_LIST" | jq -r '.[] | "  - \(.name) in \(.rg)"'
        exit 1
    fi
fi

# Verify APIM service exists
if ! az apim show --name "$APIM_SERVICE" --resource-group "$RESOURCE_GROUP" --subscription "$SUBSCRIPTION_ID" &>/dev/null; then
    print_error "APIM service '$APIM_SERVICE' not found in resource group '$RESOURCE_GROUP'"
    exit 1
fi

# ============================================================================
# PRODUCT DETAILS
# ============================================================================
print_header "1. PRODUCT DETAILS"

PRODUCT_INFO=$(az apim product show \
    --resource-group "$RESOURCE_GROUP" \
    --service-name "$APIM_SERVICE" \
    --product-id "$PRODUCT_ID" \
    --subscription "$SUBSCRIPTION_ID" \
    -o json 2>/dev/null) || {
    print_error "Product '$PRODUCT_ID' not found"
    exit 1
}

echo "$PRODUCT_INFO" | jq -r '
"Product ID:           \(.name)",
"Display Name:         \(.displayName)",
"Description:          \(.description // "N/A")",
"State:                \(.state)",
"Subscription Req:     \(.subscriptionRequired)",
"Subscriptions Limit:  \(.subscriptionsLimit // "Unlimited")",
"Approval Required:    \(.approvalRequired)",
"Terms:                \(.terms // "N/A")"
'

# ============================================================================
# ASSOCIATED APIs
# ============================================================================
print_header "2. ASSOCIATED APIs"

APIS=$(az apim product api list \
    --resource-group "$RESOURCE_GROUP" \
    --service-name "$APIM_SERVICE" \
    --product-id "$PRODUCT_ID" \
    --subscription "$SUBSCRIPTION_ID" \
    -o json)

echo "$APIS" | jq -r '.[] | 
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
"API Name:        \(.name)",
"Display Name:    \(.displayName)",
"Description:     \(.description // "N/A")",
"Path:            \(.path)",
"Protocols:       \(.protocols | join(", "))",
"Subscription:    \(.subscriptionRequired)",
""
'

# ============================================================================
# API OPERATIONS
# ============================================================================
print_header "3. API OPERATIONS"

API_NAMES=$(echo "$APIS" | jq -r '.[].name')

for API_NAME in $API_NAMES; do
    echo -e "${YELLOW}API: $API_NAME${NC}\n"
    
    OPERATIONS=$(az rest --method GET \
        --url "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ApiManagement/service/$APIM_SERVICE/apis/$API_NAME/operations?api-version=2023-05-01-preview" \
        --query "value[].{name:name, displayName:properties.displayName, method:properties.method, urlTemplate:properties.urlTemplate}" \
        -o json)
    
    echo "$OPERATIONS" | jq -r '.[] | 
    "  ▸ \(.method | ascii_upcase) \(.urlTemplate)",
    "    Name: \(.name)",
    "    Display: \(.displayName)",
    ""
    '
done

# ============================================================================
# PRODUCT POLICY
# ============================================================================
print_header "4. PRODUCT POLICY"

PRODUCT_POLICY=$(az rest --method GET \
    --url "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ApiManagement/service/$APIM_SERVICE/products/$PRODUCT_ID/policies/policy?api-version=2023-05-01-preview&format=rawxml" \
    --query "properties.value" \
    -o tsv 2>/dev/null) || {
    print_warning "No product-level policy found"
    PRODUCT_POLICY=""
}

if [ -n "$PRODUCT_POLICY" ]; then
    echo "$PRODUCT_POLICY" | head -80
    POLICY_LINES=$(echo "$PRODUCT_POLICY" | wc -l)
    if [ "$POLICY_LINES" -gt 80 ]; then
        echo -e "\n${YELLOW}... (showing first 80 lines of $POLICY_LINES total)${NC}"
    fi
fi

# ============================================================================
# API POLICIES
# ============================================================================
print_header "5. API POLICIES"

for API_NAME in $API_NAMES; do
    echo -e "${YELLOW}API: $API_NAME${NC}\n"
    
    API_POLICY=$(az rest --method GET \
        --url "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ApiManagement/service/$APIM_SERVICE/apis/$API_NAME/policies/policy?api-version=2023-05-01-preview&format=rawxml" \
        --query "properties.value" \
        -o tsv 2>/dev/null) || {
        print_warning "No API-level policy found for $API_NAME"
        continue
    }
    
    echo "$API_POLICY" | head -50
    POLICY_LINES=$(echo "$API_POLICY" | wc -l)
    if [ "$POLICY_LINES" -gt 50 ]; then
        echo -e "\n${YELLOW}... (showing first 50 lines of $POLICY_LINES total)${NC}\n"
    fi
done

# ============================================================================
# BACKEND POOLS
# ============================================================================
print_header "6. BACKEND POOLS"

BACKEND_POOLS=$(az rest --method GET \
    --url "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ApiManagement/service/$APIM_SERVICE/backends?api-version=2023-05-01-preview" \
    --query "value[?contains(name, 'pool')]" \
    -o json)

if [ "$(echo "$BACKEND_POOLS" | jq '. | length')" -eq 0 ]; then
    print_warning "No backend pools found"
else
    echo "$BACKEND_POOLS" | jq -r '.[] | 
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "Pool Name:       \(.name)",
    "Type:            \(.properties.type)",
    "Description:     \(.properties.description // "N/A")",
    (if .properties.pool.services then
        "Backends:        \(.properties.pool.services | length) service(s)",
        (.properties.pool.services[] | 
            "  ▸ Priority: \(.priority), Weight: \(.weight), ID: \(.id | split("/") | last)"
        )
    else
        "Backends:        Direct backend (no pool)"
    end),
    ""
    '
fi

# ============================================================================
# BACKEND DETAILS
# ============================================================================
print_header "7. BACKEND DETAILS"

# Get all unique backend IDs from pools
BACKEND_IDS=$(echo "$BACKEND_POOLS" | jq -r '.[].properties.pool.services[]?.id | split("/") | last' | sort -u)

if [ -z "$BACKEND_IDS" ]; then
    print_warning "No individual backends found in pools"
else
    for BACKEND_ID in $BACKEND_IDS; do
        BACKEND_INFO=$(az rest --method GET \
            --url "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ApiManagement/service/$APIM_SERVICE/backends/$BACKEND_ID?api-version=2023-05-01-preview" \
            -o json 2>/dev/null) || continue
        
        echo "$BACKEND_INFO" | jq -r '
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
        "Backend ID:      \(.name)",
        "URL:             \(.properties.url)",
        "Protocol:        \(.properties.protocol)",
        "Description:     \(.properties.description // "N/A")",
        (if .properties.circuitBreaker then
            "Circuit Breaker: Enabled",
            "  Trip Duration: \(.properties.circuitBreaker.rules[0].tripDuration // "N/A")",
            "  Failure Count: \(.properties.circuitBreaker.rules[0].failureCondition.count // "N/A")",
            "  Interval:      \(.properties.circuitBreaker.rules[0].failureCondition.interval // "N/A")"
        else
            "Circuit Breaker: Disabled"
        end),
        ""
        '
    done
fi

# ============================================================================
# POLICY FRAGMENTS
# ============================================================================
print_header "8. POLICY FRAGMENTS"

FRAGMENTS=$(az rest --method GET \
    --url "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ApiManagement/service/$APIM_SERVICE/policyFragments?api-version=2023-05-01-preview" \
    --query "value[].{name:name, description:properties.description}" \
    -o json)

echo "$FRAGMENTS" | jq -r '.[] | 
"  ▸ \(.name)",
(if .description then "    \(.description)" else "" end),
""
'

# ============================================================================
# SUBSCRIPTIONS
# ============================================================================
print_header "9. PRODUCT SUBSCRIPTIONS"

SUBSCRIPTIONS=$(az rest --method GET \
    --url "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ApiManagement/service/$APIM_SERVICE/products/$PRODUCT_ID/subscriptions?api-version=2023-05-01-preview" \
    --query "value[].{name:name, displayName:properties.displayName, state:properties.state, createdDate:properties.createdDate}" \
    -o json)

if [ "$(echo "$SUBSCRIPTIONS" | jq '. | length')" -eq 0 ]; then
    print_warning "No active subscriptions found for this product"
else
    echo "$SUBSCRIPTIONS" | jq -r '.[] | 
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "Subscription ID:     \(.name)",
    "Display Name:        \(.displayName // "N/A")",
    "State:               \(.state)",
    "Created:             \(.createdDate)",
    ""
    '
fi

# ============================================================================
# SUMMARY
# ============================================================================
print_header "10. SUMMARY"

API_COUNT=$(echo "$APIS" | jq '. | length')
SUB_COUNT=$(echo "$SUBSCRIPTIONS" | jq '. | length')
POOL_COUNT=$(echo "$BACKEND_POOLS" | jq '. | length')
FRAGMENT_COUNT=$(echo "$FRAGMENTS" | jq '. | length')

echo -e "${GREEN}Product Analysis Complete!${NC}\n"
echo "Product:           $PRODUCT_ID"
echo "APIs:              $API_COUNT"
echo "Subscriptions:     $SUB_COUNT"
echo "Backend Pools:     $POOL_COUNT"
echo "Policy Fragments:  $FRAGMENT_COUNT"
echo ""
echo -e "${BLUE}Resource Details:${NC}"
echo "Subscription:      $SUBSCRIPTION_ID"
echo "Resource Group:    $RESOURCE_GROUP"
echo "APIM Service:      $APIM_SERVICE"
echo ""

print_header "END OF REPORT"
