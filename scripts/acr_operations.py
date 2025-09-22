#!/usr/bin/env python3
"""
ACR Operations Script

This script helps with Azure Container Registry operations for the Kelix infrastructure.
It provides utilities for building, pushing, and managing container images.
"""

import subprocess
import sys
import json
import argparse
from typing import Optional

def run_command(command: str, check: bool = True) -> subprocess.CompletedProcess:
    """Run a shell command and return the result."""
    print(f"🔄 Running: {command}")
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    
    if check and result.returncode != 0:
        print(f"❌ Command failed: {result.stderr}")
        sys.exit(1)
    
    return result

def get_acr_info() -> Optional[dict]:
    """Get ACR information from Terraform outputs."""
    try:
        # Get ACR name
        result = run_command("terraform output -raw spoke_api_acr_name", check=False)
        if result.returncode != 0:
            print("❌ Could not get ACR name from Terraform outputs")
            print("   Make sure you're in the Terraform directory and have run 'terraform apply'")
            return None
        
        acr_name = result.stdout.strip()
        acr_login_server = f"{acr_name}.azurecr.io"
        
        return {
            "name": acr_name,
            "login_server": acr_login_server
        }
    except Exception as e:
        print(f"❌ Error getting ACR info: {e}")
        return None

def login_to_acr(acr_name: str) -> bool:
    """Login to Azure Container Registry."""
    print(f"🔐 Logging in to ACR: {acr_name}")
    
    try:
        run_command(f"az acr login --name {acr_name}")
        print("✅ Successfully logged in to ACR")
        return True
    except Exception as e:
        print(f"❌ Failed to login to ACR: {e}")
        return False

def build_image(image_name: str, dockerfile_path: str = "Dockerfile", context: str = ".") -> bool:
    """Build a Docker image."""
    print(f"🔨 Building image: {image_name}")
    
    try:
        run_command(f"docker build -t {image_name} -f {dockerfile_path} {context}")
        print("✅ Image built successfully")
        return True
    except Exception as e:
        print(f"❌ Failed to build image: {e}")
        return False

def push_image(image_name: str) -> bool:
    """Push a Docker image to ACR."""
    print(f"📤 Pushing image: {image_name}")
    
    try:
        run_command(f"docker push {image_name}")
        print("✅ Image pushed successfully")
        return True
    except Exception as e:
        print(f"❌ Failed to push image: {e}")
        return False

def list_images(acr_name: str) -> bool:
    """List images in ACR."""
    print(f"📋 Listing images in ACR: {acr_name}")
    
    try:
        result = run_command(f"az acr repository list --name {acr_name} --output table")
        print(result.stdout)
        return True
    except Exception as e:
        print(f"❌ Failed to list images: {e}")
        return False

def show_image_tags(acr_name: str, repository: str) -> bool:
    """Show tags for a specific repository."""
    print(f"🏷️  Showing tags for repository: {repository}")
    
    try:
        result = run_command(f"az acr repository show-tags --name {acr_name} --repository {repository} --output table")
        print(result.stdout)
        return True
    except Exception as e:
        print(f"❌ Failed to show tags: {e}")
        return False

def delete_image(acr_name: str, repository: str, tag: str) -> bool:
    """Delete a specific image tag from ACR."""
    print(f"🗑️  Deleting image: {repository}:{tag}")
    
    try:
        run_command(f"az acr repository delete --name {acr_name} --image {repository}:{tag} --yes")
        print("✅ Image deleted successfully")
        return True
    except Exception as e:
        print(f"❌ Failed to delete image: {e}")
        return False

def update_web_app_image(acr_login_server: str, image_name: str, tag: str = "latest") -> bool:
    """Update the Web App to use a new container image."""
    full_image_name = f"{acr_login_server}/{image_name}:{tag}"
    
    print(f"🔄 Updating Web App to use image: {full_image_name}")
    
    try:
        # Update the config.tfvars file
        config_file = "configuration/config.tfvars"
        
        # Read current config
        with open(config_file, 'r') as f:
            content = f.read()
        
        # Replace container_image_name
        import re
        pattern = r'container_image_name\s*=\s*"[^"]*"'
        replacement = f'container_image_name = "{full_image_name}"'
        
        if re.search(pattern, content):
            new_content = re.sub(pattern, replacement, content)
        else:
            # Add the line if it doesn't exist
            new_content = content + f'\n# The container image name to deploy in the Web App\ncontainer_image_name = "{full_image_name}"\n'
        
        # Write updated config
        with open(config_file, 'w') as f:
            f.write(new_content)
        
        print("✅ Updated configuration file")
        print("📝 Next steps:")
        print("   1. Review the changes in configuration/config.tfvars")
        print("   2. Run: terraform plan -var-file='configuration/config.tfvars' -var-file='configuration/secrets.tfvars'")
        print("   3. Run: terraform apply -var-file='configuration/config.tfvars' -var-file='configuration/secrets.tfvars'")
        
        return True
    except Exception as e:
        print(f"❌ Failed to update configuration: {e}")
        return False

def main():
    """Main function to handle command line arguments."""
    parser = argparse.ArgumentParser(description="ACR Operations for Kelix Infrastructure")
    parser.add_argument("action", choices=[
        "info", "login", "build", "push", "list", "tags", "delete", "update-webapp"
    ], help="Action to perform")
    
    parser.add_argument("--image-name", help="Image name for build/push operations")
    parser.add_argument("--dockerfile", default="Dockerfile", help="Dockerfile path")
    parser.add_argument("--context", default=".", help="Build context")
    parser.add_argument("--repository", help="Repository name for tags/delete operations")
    parser.add_argument("--tag", default="latest", help="Image tag")
    
    args = parser.parse_args()
    
    print("🚀 ACR Operations for Kelix Infrastructure")
    print("=" * 50)
    
    # Get ACR info
    acr_info = get_acr_info()
    if not acr_info:
        return
    
    print(f"📋 ACR Name: {acr_info['name']}")
    print(f"🌐 Login Server: {acr_info['login_server']}")
    print()
    
    # Perform requested action
    if args.action == "info":
        print("✅ ACR information retrieved successfully")
        
    elif args.action == "login":
        login_to_acr(acr_info['name'])
        
    elif args.action == "build":
        if not args.image_name:
            print("❌ --image-name is required for build action")
            return
        full_image_name = f"{acr_info['login_server']}/{args.image_name}:{args.tag}"
        build_image(full_image_name, args.dockerfile, args.context)
        
    elif args.action == "push":
        if not args.image_name:
            print("❌ --image-name is required for push action")
            return
        full_image_name = f"{acr_info['login_server']}/{args.image_name}:{args.tag}"
        push_image(full_image_name)
        
    elif args.action == "list":
        list_images(acr_info['name'])
        
    elif args.action == "tags":
        if not args.repository:
            print("❌ --repository is required for tags action")
            return
        show_image_tags(acr_info['name'], args.repository)
        
    elif args.action == "delete":
        if not args.repository:
            print("❌ --repository is required for delete action")
            return
        delete_image(acr_info['name'], args.repository, args.tag)
        
    elif args.action == "update-webapp":
        if not args.image_name:
            print("❌ --image-name is required for update-webapp action")
            return
        update_web_app_image(acr_info['login_server'], args.image_name, args.tag)

if __name__ == "__main__":
    main() 