#!/usr/bin/env python3
"""
APIM Policy Validator
Validates APIM policy XML by attempting to apply it via Azure REST API
"""
import json
import subprocess
import sys
from pathlib import Path

def validate_policy(policy_file_path, subscription_id, resource_group, apim_name, product_id):
    """Validate APIM policy XML by attempting to apply it"""
    
    # Read policy XML
    policy_xml = Path(policy_file_path).read_text()
    
    # Prepare request body
    body = {
        "properties": {
            "format": "rawxml",
            "value": policy_xml
        }
    }
    
    # REST API URL
    url = (
        f"https://management.azure.com/subscriptions/{subscription_id}"
        f"/resourceGroups/{resource_group}"
        f"/providers/Microsoft.ApiManagement/service/{apim_name}"
        f"/products/{product_id}/policies/policy?api-version=2024-05-01"
    )
    
    # Write body to temp file
    body_file = Path("/tmp/policy-body.json")
    body_file.write_text(json.dumps(body))
    
    # Execute validation via az rest (dry-run)
    print(f"🔍 Validating policy: {policy_file_path}")
    print(f"📍 Product: {product_id}")
    print(f"🔗 APIM: {apim_name}\n")
    
    cmd = [
        "az", "rest",
        "--method", "put",
        "--url", url,
        "--body", f"@{body_file}"
    ]
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        print("✅ Policy is VALID!")
        print("\nAPIM accepted the policy without errors.")
        return True
    except subprocess.CalledProcessError as e:
        print("❌ Policy VALIDATION FAILED!")
        print(f"\nError: {e.stderr}")
        
        # Try to parse error details
        try:
            error_data = json.loads(e.stderr)
            if "error" in error_data:
                error = error_data["error"]
                print(f"\nCode: {error.get('code')}")
                print(f"Message: {error.get('message')}")
                if "details" in error:
                    print("\nDetails:")
                    for detail in error["details"]:
                        print(f"  - {detail.get('target')}: {detail.get('message')}")
        except:
            pass
        
        return False

if __name__ == "__main__":
    policy_file = "bicep/infra/citadel-access-contracts/contracts/healthcare-purchasing-agent/policy.xml"
    subscription_id = "3a0eed45-6d6a-4200-a0f1-85e73312a1a8"
    resource_group = "rg-citadel-dev"
    apim_name = "apim-xot5i4klj5zea"
    product_id = "OAI-Healthcare-PurchasingAgent-DEV"
    
    success = validate_policy(policy_file, subscription_id, resource_group, apim_name, product_id)
    sys.exit(0 if success else 1)
