# SSL Certificates Directory

This directory should contain SSL certificates required for Azure Application Gateway configuration.

## Required Files

For the infrastructure to work properly, you need to place the following SSL certificate files in this directory:

### **ssl_cert.pfx**
- **Format**: PKCS#12 (.pfx/.p12)
- **Purpose**: SSL certificate for Application Gateway HTTPS listeners
- **Requirements**:
  - Must include both private key and certificate
  - Should be password-protected
  - Certificate should be valid for your domain(s)

### **Certificate Requirements**

Your SSL certificate should:
- Be in PFX (PKCS#12) format
- Include the complete certificate chain
- Have a secure password
- Be valid for your application domain(s)
- Include Subject Alternative Names (SAN) if needed for multiple domains

## Certificate Sources

You can obtain SSL certificates from:

### **1. Production Certificates (Recommended)**
- **Certificate Authorities**: Let's Encrypt, DigiCert, GlobalSign, etc.
- **Azure Key Vault**: Store and manage certificates securely
- **Automated Renewal**: Use ACME protocol for automatic renewal

### **2. Self-Signed Certificates (Development/Testing Only)**
For development and testing purposes, you can generate self-signed certificates using OpenSSL or other certificate generation tools. Please refer to OpenSSL documentation or your preferred certificate generation method.

### **3. Azure App Service Managed Certificates**
- Free SSL certificates for custom domains
- Automatically managed and renewed by Azure
- Can be exported for use with Application Gateway

## Configuration

Update your `secrets.tfvars` file with the certificate password:

```hcl
# SSL Certificate Configuration
spoke_api_ag_ssl_certificate_password = "YourCertificatePassword123!"
```

The infrastructure will automatically:
- Load the certificate from `ssl_certs/ssl_cert.pfx`
- Configure Application Gateway HTTPS listeners
- Set up SSL termination and forwarding

## Security Best Practices

1. **Password Protection**: Always use strong passwords for PFX files
2. **File Permissions**: Restrict access to certificate files (chmod 600)
3. **Environment Variables**: Store passwords in environment variables or Azure Key Vault
4. **Rotation**: Plan for regular certificate renewal and rotation
5. **Backup**: Maintain secure backups of certificate files

## Troubleshooting

### **Certificate Not Found**
```
Error: Certificate file not found at ssl_certs/ssl_cert.pfx
```
**Solution**: Ensure the PFX file is present in this directory

### **Invalid Password**
```
Error: Unable to read certificate with provided password
```
**Solution**: Verify the password in `secrets.tfvars` matches the PFX password

### **Certificate Validation Errors**
```
Error: Certificate chain incomplete or invalid
```
**Solution**: Ensure the PFX includes the complete certificate chain

### **Application Gateway Health Check Failures**
- Verify certificate covers the correct domain(s)
- Check certificate expiration date
- Ensure certificate includes required SAN entries

## File Structure

```
ssl_certs/
├── README.md              # This file
├── ssl_cert.pfx          # Required: SSL certificate (you provide)
└── .gitignore            # Excludes certificate files from git
```

## Important Notes

- **Never commit certificate files to version control**
- The `.gitignore` file ensures certificate files are excluded
- For production, consider using Azure Key Vault for certificate management
- Test certificates thoroughly before deploying to production
- Monitor certificate expiration dates and plan for renewal
