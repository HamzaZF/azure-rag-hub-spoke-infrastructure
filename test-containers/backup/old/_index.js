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
const AZURE_STORAGE_ACCOUNT_NAME = process.env.AZURE_STORAGE_ACCOUNT_NAME;
const AZURE_OPENAI_ENDPOINT = process.env.AZURE_OPENAI_ENDPOINT;
const AZURE_SEARCH_ENDPOINT = process.env.AZURE_SEARCH_ENDPOINT;
const POSTGRES_HOST = process.env.POSTGRES_HOST;
const POSTGRES_DATABASE = process.env.POSTGRES_DATABASE;
const POSTGRES_USERNAME = process.env.POSTGRES_USERNAME;
const AZURE_CONTAINER_REGISTRY_URL = process.env.AZURE_CONTAINER_REGISTRY_URL;

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

// Enhanced Blob Storage test (Storage Blob Data Contributor role)
app.get('/test-blob', async (req, res) => {
    try {
        const blobServiceClient = new BlobServiceClient(
            `https://${AZURE_STORAGE_ACCOUNT_NAME}.blob.core.windows.net`,
            credential
        );

        const testResults = {
            accountName: AZURE_STORAGE_ACCOUNT_NAME,
            tests: {}
        };

        // Test 1: List containers
        const containers = [];
        for await (const container of blobServiceClient.listContainers()) {
            containers.push({
                name: container.name,
                lastModified: container.properties.lastModified
            });
        }
        testResults.tests.listContainers = {
            success: true,
            count: containers.length,
            containers: containers.slice(0, 5)
        };

        // Test 2: Create a test container
        const testContainerName = `test-container-${Date.now()}`;
        const containerClient = blobServiceClient.getContainerClient(testContainerName);
        
        try {
            await containerClient.create();
            testResults.tests.createContainer = { success: true, containerName: testContainerName };

            // Test 3: Upload a test blob
            const testBlobName = `test-blob-${Date.now()}.txt`;
            const testContent = `Test content created at ${new Date().toISOString()}`;
            const blockBlobClient = containerClient.getBlockBlobClient(testBlobName);
            
            await blockBlobClient.upload(testContent, testContent.length);
            testResults.tests.uploadBlob = { 
                success: true, 
                blobName: testBlobName,
                size: testContent.length 
            };

            // Test 4: List blobs in container
            const blobs = [];
            for await (const blob of containerClient.listBlobsFlat()) {
                blobs.push({
                    name: blob.name,
                    size: blob.properties.contentLength,
                    lastModified: blob.properties.lastModified
                });
            }
            testResults.tests.listBlobs = { success: true, count: blobs.length, blobs };

            // Test 5: Read blob content
            const downloadResponse = await blockBlobClient.download();
            const downloadedContent = await streamToString(downloadResponse.readableStreamBody);
            testResults.tests.downloadBlob = { 
                success: true, 
                contentMatch: downloadedContent === testContent 
            };

            // Test 6: Set blob metadata
            const metadata = { testKey: 'testValue', timestamp: Date.now().toString() };
            await blockBlobClient.setMetadata(metadata);
            const properties = await blockBlobClient.getProperties();
            testResults.tests.setBlobMetadata = { 
                success: true, 
                metadata: properties.metadata 
            };

            // Test 7: Delete blob
            await blockBlobClient.delete();
            testResults.tests.deleteBlob = { success: true };

            // Test 8: Delete container
            await containerClient.delete();
            testResults.tests.deleteContainer = { success: true };

        } catch (containerError) {
            testResults.tests.containerOperations = { 
                success: false, 
                error: containerError.message 
            };
        }

        res.json({
            success: true,
            service: 'Azure Blob Storage',
            role: 'Storage Blob Data Contributor',
            result: testResults
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

// Helper function to convert stream to string
async function streamToString(readableStream) {
    return new Promise((resolve, reject) => {
        const chunks = [];
        readableStream.on('data', (data) => {
            chunks.push(data.toString());
        });
        readableStream.on('end', () => {
            resolve(chunks.join(''));
        });
        readableStream.on('error', reject);
    });
}

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

// Enhanced OpenAI test (Cognitive Services User role)
app.get('/test-openai', async (_req, res) => {
    try {
        const { DefaultAzureCredential, getBearerTokenProvider } = require('@azure/identity');
        const { AzureOpenAI } = require('openai');

        const credential = new DefaultAzureCredential();
        const scope = "https://cognitiveservices.azure.com/.default";
        const azureADTokenProvider = getBearerTokenProvider(credential, scope);

        const client = new AzureOpenAI({
            endpoint: AZURE_OPENAI_ENDPOINT,
            apiVersion: "2024-10-21",
            azureADTokenProvider,
        });

        const testResults = {
            endpoint: AZURE_OPENAI_ENDPOINT,
            tests: {}
        };

        // Test 1: List models/deployments
        try {
            const models = await client.models.list();
            testResults.tests.listModels = {
                success: true,
                count: models.data?.length || 0,
                models: models.data?.slice(0, 5).map(m => ({ id: m.id, object: m.object })) || []
            };
        } catch (error) {
            testResults.tests.listModels = { success: false, error: error.message };
        }

        // Test 2: Chat completion
        try {
            const chatResult = await client.chat.completions.create({
                model: "gpt-4o-mini",
                messages: [{ role: "user", content: "ping!" }],
                max_tokens: 2,
            });

            testResults.tests.chatCompletion = {
                success: true,
                reply: chatResult.choices?.[0]?.message?.content,
                usage: chatResult.usage
            };
        } catch (error) {
            testResults.tests.chatCompletion = { success: false, error: error.message };
        }

        // Test 3: Multiple chat messages
        try {
            const conversationResult = await client.chat.completions.create({
                model: "gpt-4o-mini",
                messages: [
                    { role: "system", content: "You are a helpful assistant." },
                    { role: "user", content: "What's 2+2?" },
                    { role: "assistant", content: "2+2 equals 4." },
                    { role: "user", content: "What about 3+3?" }
                ],
                max_tokens: 20,
            });

            testResults.tests.conversationCompletion = {
                success: true,
                reply: conversationResult.choices?.[0]?.message?.content,
                usage: conversationResult.usage
            };
        } catch (error) {
            testResults.tests.conversationCompletion = { success: false, error: error.message };
        }

        res.json({
            success: true,
            service: "Azure OpenAI",
            role: "Cognitive Services User",
            result: testResults
        });

    } catch (error) {
        res.status(500).json({
            success: false,
            service: "Azure OpenAI",
            error: error.message,
            code: error.code,
            stack: error.stack
        });
    }
});

// Enhanced AI Search test (Search Service Contributor role)
app.get('/test-search', async (req, res) => {
    try {
        const testResults = {
            endpoint: AZURE_SEARCH_ENDPOINT,
            tests: {}
        };

        // Get access token
        const tokenResponse = await credential.getToken('https://search.azure.com/.default');
        const headers = {
            'Authorization': `Bearer ${tokenResponse.token}`,
            'Content-Type': 'application/json'
        };

        // Test 1: Get service statistics
        const statsResponse = await fetch(`${AZURE_SEARCH_ENDPOINT}/servicestats?api-version=2023-11-01`, {
            method: 'GET',
            headers
        });

        if (statsResponse.ok) {
            const stats = await statsResponse.json();
            testResults.tests.serviceStats = { success: true, stats };
        } else {
            testResults.tests.serviceStats = { 
                success: false, 
                error: `HTTP ${statsResponse.status}: ${statsResponse.statusText}` 
            };
        }

        // Test 2: List indexes
        const indexesResponse = await fetch(`${AZURE_SEARCH_ENDPOINT}/indexes?api-version=2023-11-01`, {
            method: 'GET',
            headers
        });

        if (indexesResponse.ok) {
            const indexes = await indexesResponse.json();
            testResults.tests.listIndexes = {
                success: true,
                count: indexes.value?.length || 0,
                indexes: indexes.value?.slice(0, 5).map(idx => ({ 
                    name: idx.name, 
                    fields: idx.fields?.length 
                })) || []
            };
        } else {
            testResults.tests.listIndexes = { 
                success: false, 
                error: `HTTP ${indexesResponse.status}: ${indexesResponse.statusText}` 
            };
        }

        // Test 3: Create a test index
        const testIndexName = `test-index-${Date.now()}`;
        const indexDefinition = {
            name: testIndexName,
            fields: [
                {
                    name: "id",
                    type: "Edm.String",
                    key: true,
                    filterable: true
                },
                {
                    name: "content",
                    type: "Edm.String",
                    searchable: true,
                    filterable: false
                },
                {
                    name: "timestamp",
                    type: "Edm.DateTimeOffset",
                    filterable: true,
                    sortable: true
                }
            ]
        };

        const createResponse = await fetch(`${AZURE_SEARCH_ENDPOINT}/indexes?api-version=2023-11-01`, {
            method: 'POST',
            headers,
            body: JSON.stringify(indexDefinition)
        });

        if (createResponse.ok) {
            testResults.tests.createIndex = { success: true, indexName: testIndexName };

            // Test 4: Get index definition
            const getIndexResponse = await fetch(`${AZURE_SEARCH_ENDPOINT}/indexes/${testIndexName}?api-version=2023-11-01`, {
                method: 'GET',
                headers
            });

            if (getIndexResponse.ok) {
                const indexDef = await getIndexResponse.json();
                testResults.tests.getIndex = { 
                    success: true, 
                    fieldCount: indexDef.fields?.length 
                };
            } else {
                testResults.tests.getIndex = { success: false, error: 'Failed to retrieve index' };
            }

            // Test 5: Delete test index
            const deleteResponse = await fetch(`${AZURE_SEARCH_ENDPOINT}/indexes/${testIndexName}?api-version=2023-11-01`, {
                method: 'DELETE',
                headers
            });

            testResults.tests.deleteIndex = { 
                success: deleteResponse.ok,
                status: deleteResponse.status 
            };

        } else {
            const errorText = await createResponse.text();
            testResults.tests.createIndex = { 
                success: false, 
                error: `HTTP ${createResponse.status}: ${errorText}` 
            };
        }

        res.json({
            success: true,
            service: 'Azure AI Search',
            role: 'Search Service Contributor',
            result: testResults
        });

    } catch (error) {
        res.status(500).json({
            success: false,
            service: 'Azure AI Search',
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
