#!/usr/bin/env python3
"""
SSL Certificate Generation Script for Kelix Application Gateway

This script generates a self-signed SSL certificate in PFX format for use with
Azure Application Gateway SSL termination. The certificate is valid for common
domain names and includes Subject Alternative Names (SAN) for flexibility.

Requirements:
- OpenSSL must be installed and available in PATH
- Python 3.6+

Usage:
    python generate_ssl_certificate.py [--domain DOMAIN] [--password PASSWORD] [--output OUTPUT_DIR]

The script generates:
- A private key (RSA 2048-bit)
- A self-signed certificate (valid for 365 days)
- A PFX file combining both for Application Gateway use
"""

import argparse
import os
import subprocess
import sys
from datetime import datetime, timedelta
import tempfile


class SSLCertificateGenerator:
    def __init__(self, domain="kelix-api.local", password=None, output_dir="./ssl_certs"):
        self.domain = domain
        self.password = password or os.environ.get('SSL_CERT_PASSWORD', 'DefaultSSL2024!')
        if self.password == 'DefaultSSL2024!':
            print("Warning: Using default password. Set SSL_CERT_PASSWORD environment variable for production use.")
        self.output_dir = output_dir
        self.key_file = os.path.join(output_dir, "ssl_cert.key")
        self.cert_file = os.path.join(output_dir, "ssl_cert.crt")
        self.pfx_file = os.path.join(output_dir, "ssl_cert.pfx")
        
    def check_openssl(self):
        """Check if OpenSSL is available in the system PATH."""
        try:
            subprocess.run(["openssl", "version"], capture_output=True, check=True)
            print("✓ OpenSSL is available")
            return True
        except (subprocess.CalledProcessError, FileNotFoundError):
            print("✗ OpenSSL is not available in PATH")
            print("Please install OpenSSL:")
            print("  Windows: Download from https://slproweb.com/products/Win32OpenSSL.html")
            print("  macOS: brew install openssl")
            print("  Ubuntu/Debian: apt-get install openssl")
            return False
    
    def create_output_directory(self):
        """Create the output directory if it doesn't exist."""
        os.makedirs(self.output_dir, exist_ok=True)
        print(f"✓ Output directory created/verified: {self.output_dir}")
    
    def generate_private_key(self):
        """Generate RSA private key."""
        print("Generating RSA private key (2048-bit)...")
        cmd = [
            "openssl", "genrsa",
            "-out", self.key_file,
            "2048"
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            print(f"✓ Private key generated: {self.key_file}")
            return True
        except subprocess.CalledProcessError as e:
            print(f"✗ Failed to generate private key: {e.stderr.decode()}")
            return False
    
    def generate_certificate(self):
        """Generate self-signed certificate with SAN extension."""
        print(f"Generating self-signed certificate for domain: {self.domain}")
        
        # Create a temporary config file for SAN extension
        san_domains = [
            self.domain,
            f"*.{self.domain}",
            "localhost",
            "127.0.0.1",
            "kelix-api.azurewebsites.net",
            "*.kelix-api.azurewebsites.net"
        ]
        
        config_content = f"""[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
C=US
ST=State
L=City
O=Kelix Organization
OU=IT Department
CN={self.domain}

[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
"""
        
        for i, domain in enumerate(san_domains, 1):
            if domain.replace(".", "").replace("*", "").isdigit() or "." in domain and domain.split(".")[-1].isdigit():
                config_content += f"IP.{i} = {domain}\n"
            else:
                config_content += f"DNS.{i} = {domain}\n"
        
        # Write config to temporary file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.conf', delete=False) as config_file:
            config_file.write(config_content)
            config_path = config_file.name
        
        try:
            cmd = [
                "openssl", "req",
                "-new", "-x509",
                "-key", self.key_file,
                "-out", self.cert_file,
                "-days", "365",
                "-config", config_path,
                "-extensions", "v3_req"
            ]
            
            subprocess.run(cmd, check=True, capture_output=True)
            print(f"✓ Certificate generated: {self.cert_file}")
            print(f"  Valid for 365 days from {datetime.now().strftime('%Y-%m-%d')}")
            print(f"  Subject Alternative Names: {', '.join(san_domains)}")
            return True
            
        except subprocess.CalledProcessError as e:
            print(f"✗ Failed to generate certificate: {e.stderr.decode()}")
            return False
        finally:
            # Clean up temporary config file
            try:
                os.unlink(config_path)
            except:
                pass
    
    def generate_pfx(self):
        """Generate PFX file from private key and certificate."""
        print("Generating PFX file for Application Gateway...")
        
        cmd = [
            "openssl", "pkcs12",
            "-export",
            "-out", self.pfx_file,
            "-inkey", self.key_file,
            "-in", self.cert_file,
            "-password", f"pass:{self.password}"
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            print(f"✓ PFX file generated: {self.pfx_file}")
            print(f"  Password: {self.password}")
            return True
        except subprocess.CalledProcessError as e:
            print(f"✗ Failed to generate PFX file: {e.stderr.decode()}")
            return False
    
    def display_certificate_info(self):
        """Display certificate information."""
        print("\n" + "="*60)
        print("CERTIFICATE INFORMATION")
        print("="*60)
        
        try:
            # Get certificate details
            cmd = ["openssl", "x509", "-in", self.cert_file, "-text", "-noout"]
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            
            # Parse and display key information
            lines = result.stdout.split('\n')
            for i, line in enumerate(lines):
                if 'Subject:' in line:
                    print(f"Subject: {line.split('Subject:')[1].strip()}")
                elif 'Not Before:' in line:
                    print(f"Valid From: {line.split('Not Before:')[1].strip()}")
                elif 'Not After:' in line:
                    print(f"Valid Until: {line.split('Not After:')[1].strip()}")
                elif 'DNS:' in line or 'IP:' in line:
                    print(f"SAN: {line.strip()}")
                    
        except subprocess.CalledProcessError:
            print("Could not retrieve certificate details")
    
    def generate_terraform_instructions(self):
        """Generate instructions for using the certificate in Terraform."""
        print("\n" + "="*60)
        print("TERRAFORM INTEGRATION INSTRUCTIONS")
        print("="*60)
        
        rel_pfx_path = os.path.relpath(self.pfx_file, "Kelix-Terraform/modules/spoke-api/modules/application-gateway")
        
        instructions = f"""
1. The PFX certificate is ready at: {self.pfx_file}

2. The Application Gateway configuration will be updated to use:
   - Certificate file: {rel_pfx_path}
   - Certificate password: {self.password}

3. For production use, consider:
   - Using Azure Key Vault to store the certificate
   - Implementing certificate rotation
   - Using a trusted CA-signed certificate

4. DNS Configuration:
   - Point your domain ({self.domain}) to the Application Gateway public IP
   - Update any DNS records as needed

5. Testing:
   - The certificate includes SAN for localhost and common Azure domains
   - Browsers will show a security warning for self-signed certificates
"""
        print(instructions)
    
    def generate_all(self):
        """Generate complete SSL certificate setup."""
        print("="*60)
        print("KELIX APPLICATION GATEWAY SSL CERTIFICATE GENERATOR")
        print("="*60)
        print(f"Domain: {self.domain}")
        print(f"Output Directory: {self.output_dir}")
        print(f"Certificate Password: {self.password}")
        print("="*60)
        
        # Check prerequisites
        if not self.check_openssl():
            return False
        
        # Create output directory
        self.create_output_directory()
        
        # Generate components
        steps = [
            self.generate_private_key,
            self.generate_certificate,
            self.generate_pfx
        ]
        
        for step in steps:
            if not step():
                print(f"\n✗ SSL certificate generation failed at step: {step.__name__}")
                return False
        
        # Display information
        self.display_certificate_info()
        self.generate_terraform_instructions()
        
        print("\n" + "="*60)
        print("✓ SSL CERTIFICATE GENERATION COMPLETED SUCCESSFULLY!")
        print("="*60)
        
        return True


def main():
    parser = argparse.ArgumentParser(
        description="Generate self-signed SSL certificate for Kelix Application Gateway",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python generate_ssl_certificate.py
  python generate_ssl_certificate.py --domain api.kelix.com --password MySecurePass123!
  python generate_ssl_certificate.py --output ./certificates
        """
    )
    
    parser.add_argument(
        "--domain", "-d",
        default="kelix-api.local",
        help="Primary domain name for the certificate (default: kelix-api.local)"
    )
    
    parser.add_argument(
        "--password", "-p",
        default="KelixSSL2024!",
        help="Password for the PFX file (default: KelixSSL2024!)"
    )
    
    parser.add_argument(
        "--output", "-o",
        default="./ssl_certs",
        help="Output directory for certificate files (default: ./ssl_certs)"
    )
    
    args = parser.parse_args()
    
    # Create generator instance
    generator = SSLCertificateGenerator(
        domain=args.domain,
        password=args.password,
        output_dir=args.output
    )
    
    # Generate certificates
    success = generator.generate_all()
    
    # Exit with appropriate code
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
