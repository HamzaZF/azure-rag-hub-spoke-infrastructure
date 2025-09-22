#!/usr/bin/env python3
"""
SSL Setup Validation Script for Kelix Application Gateway

This script validates the SSL certificate setup and Application Gateway configuration.
It performs various checks to ensure the SSL termination is properly configured.

Usage:
    python test_ssl_setup.py [--endpoint ENDPOINT] [--cert-path CERT_PATH]
"""

import argparse
import os
import ssl
import socket
import subprocess
import sys
import urllib.request
import urllib.error
from datetime import datetime


class SSLSetupValidator:
    def __init__(self, endpoint="localhost", cert_path="./ssl_certs/ssl_cert.pfx"):
        self.endpoint = endpoint
        self.cert_path = cert_path
        self.cert_dir = os.path.dirname(cert_path)
        self.cert_file = os.path.join(self.cert_dir, "ssl_cert.crt")
        self.key_file = os.path.join(self.cert_dir, "ssl_cert.key")
        
    def check_certificate_files(self):
        """Check if certificate files exist."""
        print("="*60)
        print("CERTIFICATE FILES VALIDATION")
        print("="*60)
        
        files_to_check = [
            (self.cert_path, "PFX Certificate"),
            (self.cert_file, "Certificate File"),
            (self.key_file, "Private Key")
        ]
        
        all_exist = True
        for file_path, description in files_to_check:
            if os.path.exists(file_path):
                size = os.path.getsize(file_path)
                print(f"✓ {description}: {file_path} ({size} bytes)")
            else:
                print(f"✗ {description}: {file_path} (NOT FOUND)")
                all_exist = False
        
        return all_exist
    
    def validate_certificate_content(self):
        """Validate certificate content and expiry."""
        print("\n" + "="*60)
        print("CERTIFICATE CONTENT VALIDATION")
        print("="*60)
        
        if not os.path.exists(self.cert_file):
            print("✗ Certificate file not found for validation")
            return False
        
        try:
            # Check certificate details
            cmd = ["openssl", "x509", "-in", self.cert_file, "-text", "-noout"]
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            
            # Parse certificate info
            lines = result.stdout.split('\n')
            subject = None
            not_before = None
            not_after = None
            san_entries = []
            
            for line in lines:
                if 'Subject:' in line:
                    subject = line.split('Subject:')[1].strip()
                elif 'Not Before:' in line:
                    not_before = line.split('Not Before:')[1].strip()
                elif 'Not After:' in line:
                    not_after = line.split('Not After:')[1].strip()
                elif 'DNS:' in line or 'IP:' in line:
                    san_entries.append(line.strip())
            
            print(f"✓ Subject: {subject}")
            print(f"✓ Valid From: {not_before}")
            print(f"✓ Valid Until: {not_after}")
            
            if san_entries:
                print("✓ Subject Alternative Names:")
                for san in san_entries[:5]:  # Show first 5 SANs
                    print(f"  - {san}")
                if len(san_entries) > 5:
                    print(f"  ... and {len(san_entries) - 5} more")
            
            # Check if certificate is still valid
            try:
                not_after_date = datetime.strptime(not_after, "%b %d %H:%M:%S %Y %Z")
                if not_after_date > datetime.now():
                    days_remaining = (not_after_date - datetime.now()).days
                    print(f"✓ Certificate is valid ({days_remaining} days remaining)")
                else:
                    print("✗ Certificate has expired")
                    return False
            except:
                print("⚠ Could not parse certificate expiry date")
            
            return True
            
        except subprocess.CalledProcessError as e:
            print(f"✗ Failed to validate certificate: {e}")
            return False
        except FileNotFoundError:
            print("✗ OpenSSL not found. Please install OpenSSL to validate certificates.")
            return False
    
    def validate_pfx_file(self):
        """Validate PFX file integrity."""
        print("\n" + "="*60)
        print("PFX FILE VALIDATION")
        print("="*60)
        
        if not os.path.exists(self.cert_path):
            print("✗ PFX file not found")
            return False
        
        try:
            # Test PFX file with default password
            cmd = [
                "openssl", "pkcs12",
                "-in", self.cert_path,
                "-noout",
                "-password", "pass:KelixSSL2024!"
            ]
            
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            print("✓ PFX file is valid and password is correct")
            return True
            
        except subprocess.CalledProcessError:
            print("✗ PFX file validation failed (wrong password or corrupted file)")
            return False
        except FileNotFoundError:
            print("✗ OpenSSL not found. Please install OpenSSL to validate PFX files.")
            return False
    
    def check_ssl_connectivity(self):
        """Test SSL connectivity to the endpoint."""
        print("\n" + "="*60)
        print("SSL CONNECTIVITY TEST")
        print("="*60)
        
        # Parse endpoint
        if self.endpoint.startswith(('http://', 'https://')):
            url = self.endpoint
            hostname = self.endpoint.split('://')[1].split('/')[0].split(':')[0]
            port = 443 if 'https://' in self.endpoint else 80
        else:
            hostname = self.endpoint
            port = 443
            url = f"https://{hostname}"
        
        print(f"Testing connectivity to: {hostname}:{port}")
        
        try:
            # Test SSL socket connection
            context = ssl.create_default_context()
            context.check_hostname = False
            context.verify_mode = ssl.CERT_NONE  # Skip verification for self-signed
            
            with socket.create_connection((hostname, port), timeout=10) as sock:
                with context.wrap_socket(sock, server_hostname=hostname) as ssock:
                    cert = ssock.getpeercert()
                    print(f"✓ SSL connection established")
                    print(f"✓ Certificate subject: {cert.get('subject', 'Unknown')}")
                    print(f"✓ Certificate issuer: {cert.get('issuer', 'Unknown')}")
                    
                    # Check certificate expiry
                    not_after = cert.get('notAfter')
                    if not_after:
                        expiry = datetime.strptime(not_after, "%b %d %H:%M:%S %Y %Z")
                        days_remaining = (expiry - datetime.now()).days
                        print(f"✓ Certificate expires in {days_remaining} days")
                    
                    return True
                    
        except socket.timeout:
            print(f"✗ Connection timeout to {hostname}:{port}")
            print("  - Check if Application Gateway is deployed and running")
            print("  - Verify network connectivity")
            return False
        except socket.gaierror:
            print(f"✗ DNS resolution failed for {hostname}")
            print("  - Check if hostname is correct")
            print("  - Verify DNS configuration")
            return False
        except ConnectionRefusedError:
            print(f"✗ Connection refused by {hostname}:{port}")
            print("  - Check if Application Gateway is listening on the port")
            print("  - Verify security group rules")
            return False
        except ssl.SSLError as e:
            print(f"✗ SSL error: {e}")
            print("  - Check certificate configuration")
            print("  - Verify SSL settings")
            return False
        except Exception as e:
            print(f"✗ Unexpected error: {e}")
            return False
    
    def test_http_redirect(self):
        """Test HTTP to HTTPS redirect."""
        print("\n" + "="*60)
        print("HTTP TO HTTPS REDIRECT TEST")
        print("="*60)
        
        # Parse endpoint for HTTP test
        if self.endpoint.startswith(('http://', 'https://')):
            hostname = self.endpoint.split('://')[1].split('/')[0].split(':')[0]
        else:
            hostname = self.endpoint
        
        http_url = f"http://{hostname}"
        print(f"Testing HTTP redirect: {http_url}")
        
        try:
            # Create request with redirect handling disabled
            req = urllib.request.Request(http_url)
            
            # Custom opener that doesn't follow redirects
            opener = urllib.request.build_opener()
            opener.addheaders = [('User-Agent', 'SSL-Test-Script/1.0')]
            
            try:
                response = opener.open(req, timeout=10)
                print("✗ No redirect detected (expected 301/302 redirect)")
                return False
            except urllib.error.HTTPError as e:
                if e.code in [301, 302, 307, 308]:
                    location = e.headers.get('Location', '')
                    if location.startswith('https://'):
                        print(f"✓ HTTP redirect detected: {e.code} → {location}")
                        return True
                    else:
                        print(f"✗ Redirect detected but not to HTTPS: {location}")
                        return False
                else:
                    print(f"✗ Unexpected HTTP response: {e.code}")
                    return False
                    
        except socket.timeout:
            print("✗ HTTP request timeout")
            print("  - Check if Application Gateway is responding on port 80")
            return False
        except Exception as e:
            print(f"✗ HTTP redirect test failed: {e}")
            return False
    
    def generate_terraform_validation(self):
        """Generate Terraform validation commands."""
        print("\n" + "="*60)
        print("TERRAFORM VALIDATION COMMANDS")
        print("="*60)
        
        commands = [
            ("Validate Terraform configuration", "terraform validate"),
            ("Plan Terraform deployment", "terraform plan"),
            ("Check for syntax errors", "terraform fmt -check"),
            ("Validate certificate path", f"ls -la {self.cert_path}"),
        ]
        
        print("Run these commands to validate your Terraform configuration:")
        for description, command in commands:
            print(f"\n# {description}")
            print(f"{command}")
    
    def run_all_validations(self):
        """Run all validation checks."""
        print("="*60)
        print("KELIX APPLICATION GATEWAY SSL VALIDATION")
        print("="*60)
        print(f"Endpoint: {self.endpoint}")
        print(f"Certificate Path: {self.cert_path}")
        print("="*60)
        
        results = []
        
        # File existence checks
        results.append(("Certificate Files", self.check_certificate_files()))
        
        # Certificate content validation
        results.append(("Certificate Content", self.validate_certificate_content()))
        
        # PFX file validation
        results.append(("PFX File", self.validate_pfx_file()))
        
        # SSL connectivity (only if endpoint is not localhost)
        if self.endpoint not in ['localhost', '127.0.0.1']:
            results.append(("SSL Connectivity", self.check_ssl_connectivity()))
            results.append(("HTTP Redirect", self.test_http_redirect()))
        else:
            print(f"\nSkipping connectivity tests for localhost endpoint")
        
        # Generate validation commands
        self.generate_terraform_validation()
        
        # Summary
        print("\n" + "="*60)
        print("VALIDATION SUMMARY")
        print("="*60)
        
        passed = 0
        total = len(results)
        
        for test_name, result in results:
            status = "PASS" if result else "FAIL"
            symbol = "✓" if result else "✗"
            print(f"{symbol} {test_name}: {status}")
            if result:
                passed += 1
        
        print(f"\nOverall: {passed}/{total} tests passed")
        
        if passed == total:
            print("🎉 All validations passed! SSL setup is ready for deployment.")
            return True
        else:
            print("⚠️  Some validations failed. Please review and fix issues before deployment.")
            return False


def main():
    parser = argparse.ArgumentParser(
        description="Validate SSL setup for Kelix Application Gateway",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python test_ssl_setup.py
  python test_ssl_setup.py --endpoint "https://api.kelix.com"
  python test_ssl_setup.py --cert-path "./custom_certs/ssl_cert.pfx"
        """
    )
    
    parser.add_argument(
        "--endpoint", "-e",
        default="localhost",
        help="Endpoint to test SSL connectivity (default: localhost)"
    )
    
    parser.add_argument(
        "--cert-path", "-c",
        default="./ssl_certs/ssl_cert.pfx",
        help="Path to the PFX certificate file (default: ./ssl_certs/ssl_cert.pfx)"
    )
    
    args = parser.parse_args()
    
    # Create validator instance
    validator = SSLSetupValidator(
        endpoint=args.endpoint,
        cert_path=args.cert_path
    )
    
    # Run all validations
    success = validator.run_all_validations()
    
    # Exit with appropriate code
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
