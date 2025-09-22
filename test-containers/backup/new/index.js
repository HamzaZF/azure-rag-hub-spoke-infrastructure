// Disable Application Insights telemetry
process.env.APPLICATIONINSIGHTS_DISABLED = 'true';

const express = require('express');
const { DefaultAzureCredential } = require('@azure/identity');
const { BlobServiceClient } = require('@azure/storage-blob');
const { AzureOpenAI } = require('openai');
const { SearchClient } = require('@azure/search-documents');
const { ContainerRegistryClient } = require('@azure/container-registry');
const { Client } = require('pg');

const app = express();
const port = process.env.PORT || 3000;

// Initialize Azure credential for managed identity
const credential = new DefaultAzureCredential();

// Environment variables (should be set in Azure Web App)
const AZURE_STORAGE_ACCOUNT_NAME = process.env.AZURE_STORAGE_ACCOUNT_NAME || 'mhkxstghubstwus3q58b';
const AZURE_OPENAI_ENDPOINT = process.env.AZURE_OPENAI_ENDPOINT || 'https://mh-kx-stg-hub-cog-wus3-92sq.openai.azure.com/';
const AZURE_SEARCH_ENDPOINT = process.env.AZURE_SEARCH_ENDPOINT || 'https://mh-kx-stg-hub-srch-wus3-frfd.search.windows.net';
const POSTGRES_HOST = process.env.POSTGRES_HOST || 'mh-kx-stg-hub-psql-wus3-drip.postgres.database.azure.com';
const POSTGRES_DATABASE = process.env.POSTGRES_DATABASE || 'postgres';
const POSTGRES_USERNAME = process.env.POSTGRES_USERNAME || 'your-managed-identity-name';
const AZURE_CONTAINER_REGISTRY_URL = process.env.AZURE_CONTAINER_REGISTRY_URL || 'mhkxstghubacrwus3SkWxrxtc.azurecr.io';

app.use(express.json());

// Health check endpoint
app.get('/healthcheck', (req, res) => {
    res.json({
        message: 'Azure Managed Identity Test API',
        endpoints: [
            'GET /test-blob - Test Blob Storage access',
            'GET /test-openai - Test OpenAI access',
            'GET /test-search - Test Cognitive Search access',
            'GET /test-pgsql - Test PostgreSQL access',
            'GET /test-acr - Test Container Registry access',
            'GET /test-all - Test all services'
        ]
    });
});

// Test Azure Blob Storage access (Storage Blob Data Contributor role)
app.get('/test-blob', async (req, res) => {
    try {
        const blobServiceClient = new BlobServiceClient(
            `https://${AZURE_STORAGE_ACCOUNT_NAME}.blob.core.windows.net`,
            credential
        );

        // List containers to test access
        const containers = [];
        for await (const container of blobServiceClient.listContainers()) {
            containers.push({
                name: container.name,
                lastModified: container.properties.lastModified
            });
        }

        res.json({
            success: true,
            service: 'Azure Blob Storage',
            role: 'Storage Blob Data Contributor',
            result: {
                accountName: AZURE_STORAGE_ACCOUNT_NAME,
                containersCount: containers.length,
                containers: containers.slice(0, 5) // Show first 5 containers
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            service: 'Azure Blob Storage',
            error: error.message,
            code: error.code
        });
    }
});

app.get('/test-network', async (req, res) => {
    try {
        const response = await fetch(AZURE_OPENAI_ENDPOINT);
        res.json({
            success: true,
            status: response.status,
            endpoint: AZURE_OPENAI_ENDPOINT
        });
    } catch (error) {
        res.json({
            success: false,
            error: error.message,
            endpoint: AZURE_OPENAI_ENDPOINT
        });
    }
});


app.get('/test-openai', async (_req, res) => {
    try {
      const { DefaultAzureCredential, getBearerTokenProvider } = require('@azure/identity');
      const { AzureOpenAI } = require('openai');
  
      const credential = new DefaultAzureCredential();
      const scope = "https://cognitiveservices.azure.com/.default";
      const azureADTokenProvider = getBearerTokenProvider(credential, scope);
  
      const client = new AzureOpenAI({
        endpoint: AZURE_OPENAI_ENDPOINT,           // e.g. https://<resource>.openai.azure.com/
        apiVersion: "2024-10-21",                  // GA data-plane version
        azureADTokenProvider,                      // Managed identity
      });
  
      const result = await client.chat.completions.create({
        model: "gpt-4.1-mini",
        messages: [{ role: "user", content: "ping" }],
        max_tokens: 2,
      });
  
      res.json({
        success: true,
        service: "Azure OpenAI",
        role: "Cognitive Services User",
        result: {
          endpoint: AZURE_OPENAI_ENDPOINT,
          reply: result.choices?.[0]?.message?.content ?? null
        }
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        service: "Azure OpenAI",
        error: error.message,
        code: error.code,
        stack: error.stack,
        cause: error.cause
      });
    }
  });
  

// Test Azure Cognitive Search access (Search Service Contributor role)
app.get('/test-search', async (req, res) => {
    try {
        // Create a search client for testing
        const searchClient = new SearchClient(
            AZURE_SEARCH_ENDPOINT,
            'your-index-name', // You may need to create an index or use an existing one
            credential
        );

        // Try to get service statistics
        const response = await fetch(`${AZURE_SEARCH_ENDPOINT}/servicestats?api-version=2023-11-01`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${(await credential.getToken('https://search.azure.com/.default')).token}`,
                'Content-Type': 'application/json'
            }
        });

        if (response.ok) {
            const stats = await response.json();
            res.json({
                success: true,
                service: 'Azure Cognitive Search',
                role: 'Search Service Contributor',
                result: {
                    endpoint: AZURE_SEARCH_ENDPOINT,
                    serviceStats: stats
                }
            });
        } else {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
    } catch (error) {
        res.status(500).json({
            success: false,
            service: 'Azure Cognitive Search',
            error: error.message,
            code: error.code
        });
    }
});

// Test PostgreSQL Flexible Server access (Contributor role)
app.get('/test-pgsql', async (req, res) => {
    let client;
    try {
        // Get access token for PostgreSQL
        const tokenResponse = await credential.getToken('https://ossrdbms-aad.database.windows.net/.default');

        // Create PostgreSQL client with managed identity token
        client = new Client({
            host: POSTGRES_HOST,
            database: POSTGRES_DATABASE,
            user: POSTGRES_USERNAME,
            password: tokenResponse.token,
            port: 5432,
            ssl: { rejectUnauthorized: false }
        });

        await client.connect();

        // Test with a simple query
        const result = await client.query('SELECT version(), current_user, current_database()');

        res.json({
            success: true,
            service: 'PostgreSQL Flexible Server',
            role: 'Contributor',
            result: {
                host: POSTGRES_HOST,
                database: POSTGRES_DATABASE,
                user: POSTGRES_USERNAME,
                version: result.rows[0].version,
                currentUser: result.rows[0].current_user,
                currentDatabase: result.rows[0].current_database
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            service: 'PostgreSQL Flexible Server',
            error: error.message,
            code: error.code
        });
    } finally {
        if (client) {
            await client.end();
        }
    }
});

// Test Azure Container Registry access (AcrPull role)
app.get('/test-acr', async (req, res) => {
    try {
        const client = new ContainerRegistryClient(
            `https://${AZURE_CONTAINER_REGISTRY_URL}`,
            credential
        );

        // List repositories to test access
        const repositories = [];
        for await (const repository of client.listRepositoryNames()) {
            repositories.push(repository);
        }

        res.json({
            success: true,
            service: 'Azure Container Registry',
            role: 'AcrPull',
            result: {
                registryUrl: AZURE_CONTAINER_REGISTRY_URL,
                repositoriesCount: repositories.length,
                repositories: repositories.slice(0, 10) // Show first 10 repositories
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            service: 'Azure Container Registry',
            error: error.message,
            code: error.code
        });
    }
});

// Test all services at once
app.get('/test-all', async (req, res) => {
    try {
        const results = {};

        // Test each service and collect results
        const services = [
            { name: 'blob', endpoint: '/test-blob' },
            { name: 'openai', endpoint: '/test-openai' },
            { name: 'search', endpoint: '/test-search' },
            { name: 'pgsql', endpoint: '/test-pgsql' },
            { name: 'acr', endpoint: '/test-acr' }
        ];

        for (const service of services) {
            try {
                // Simulate internal API call
                const testResult = await testService(service.name);
                results[service.name] = { success: true, ...testResult };
            } catch (error) {
                results[service.name] = {
                    success: false,
                    error: error.message
                };
            }
        }

        res.json({
            success: true,
            message: 'Tested all services',
            results: results
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

// Helper function to test individual services
async function testService(serviceName) {
    switch (serviceName) {
        case 'blob':
            const blobClient = new BlobServiceClient(`https://${AZURE_STORAGE_ACCOUNT_NAME}.blob.core.windows.net`, credential);
            const containerCount = (await blobClient.listContainers().byPage().next()).value.length;
            return { service: 'Blob Storage', containerCount };

        case 'openai':
            const tokenResponse = await credential.getToken('https://cognitiveservices.azure.com/.default');
            const openaiClient = new AzureOpenAI({
                apiKey: tokenResponse.token,
                endpoint: AZURE_OPENAI_ENDPOINT,
                apiVersion: "2024-10-01-preview"
            });
            const deployments = [];
            for await (const deployment of openaiClient.deployments.list()) {
                deployments.push(deployment.id);
            }
            return { service: 'OpenAI', deploymentsCount: deployments.length };

        // Add other services as needed
        default:
            throw new Error(`Unknown service: ${serviceName}`);
    }
}

// Graceful shutdown handling
let server;

// Enhanced error handling
process.on('uncaughtException', (error) => {
    console.error('Uncaught Exception:', error);
    gracefulShutdown('uncaughtException');
});

process.on('unhandledRejection', (reason, promise) => {
    console.error('Unhandled Rejection at:', promise, 'reason:', reason);
    gracefulShutdown('unhandledRejection');
});

process.on('SIGTERM', () => {
    console.log('SIGTERM received, starting graceful shutdown...');
    gracefulShutdown('SIGTERM');
});

process.on('SIGINT', () => {
    console.log('SIGINT received, starting graceful shutdown...');
    gracefulShutdown('SIGINT');
});

function gracefulShutdown(signal) {
    console.log(`Graceful shutdown initiated by ${signal}`);

    if (server) {
        server.close((err) => {
            if (err) {
                console.error('Error during server shutdown:', err);
                process.exit(1);
            }
            console.log('HTTP server closed.');
            process.exit(0);
        });

        // Force close after 10 seconds
        setTimeout(() => {
            console.error('Could not close connections in time, forcefully shutting down');
            process.exit(1);
        }, 10000);
    } else {
        process.exit(0);
    }
}

// Start server with proper error handling
server = app.listen(port, '0.0.0.0', (error) => {
    if (error) {
        console.error('Failed to start server:', error);
        process.exit(1);
    }
    console.log(`Azure Managed Identity Test API running on port ${port}`);
    console.log(`Health check: http://localhost:${port}/`);
    console.log(`Server listening on 0.0.0.0:${port}`);
    console.log('Environment variables:');
    console.log(`- PORT: ${port}`);
    console.log(`- NODE_ENV: ${process.env.NODE_ENV || 'not set'}`);
    console.log(`- WEBSITE_HOSTNAME: ${process.env.WEBSITE_HOSTNAME || 'not set'}`);
});
