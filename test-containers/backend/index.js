const express = require('express');
const { DefaultAzureCredential } = require('@azure/identity');
const { BlobServiceClient } = require('@azure/storage-blob');
const { AzureOpenAI } = require('openai');
const { SearchClient } = require('@azure/search-documents');
const { ContainerRegistryClient } = require('@azure/container-registry');
const { SecretClient } = require('@azure/keyvault-secrets');
const { Client } = require('pg');

const app = express();
const port = process.env.PORT || 3000;

// Initialize Azure credential for managed identity
const credential = new DefaultAzureCredential();

// Environment variables (should be set in Azure Web App)
const AZURE_STORAGE_ACCOUNT_NAME = process.env.AZURE_STORAGE_ACCOUNT_NAME;
const AZURE_OPENAI_ENDPOINT = process.env.AZURE_OPENAI_ENDPOINT;
const AZURE_SEARCH_ENDPOINT = process.env.AZURE_SEARCH_ENDPOINT;
const AZURE_KEYVAULT_URL = process.env.AZURE_KEYVAULT_URL;
const POSTGRES_HOST = process.env.POSTGRES_HOST;
const POSTGRES_DB = process.env.POSTGRES_DB;
const POSTGRES_USERNAME = process.env.POSTGRES_USERNAME;
const AZURE_CONTAINER_REGISTRY_URL = process.env.AZURE_CONTAINER_REGISTRY_URL;
const APP_SERVICE_BACKEND_NAME = process.env.APP_SERVICE_BACKEND_NAME;

app.use(express.json());

// Root endpoint redirect to healthcheck for compatibility
app.get('/', (req, res) => {
    res.redirect('/healthcheck');
});

// Health check endpoint
app.get('/healthcheck', (req, res) => {
    res.json({
        message: 'Azure Managed Identity Test API',
        endpoints: [
            'GET /test-blob - Test Blob Storage access',
            'GET /test-openai - Test OpenAI access',
            'GET /test-search - Test Cognitive Search access',
            'GET /test-keyvault - Test Key Vault access',
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
  
// // Test Azure Cognitive Search access (Search Service Contributor role)
// app.get('/test-search', async (req, res) => {
//     try {
//         const searchClient = new SearchClient(
//             AZURE_SEARCH_ENDPOINT,
//             'your-index-name', // Replace with actual index name
//             credential
//         );

//         // Simple test - search for documents
//         const searchResults = await searchClient.search("*", {
//             top: 1
//         });

//         res.json({
//             success: true,
//             service: 'Azure AI Search',
//             role: 'Search Service Contributor',
//             result: {
//                 endpoint: AZURE_SEARCH_ENDPOINT,
//                 searchResults: searchResults
//             }
//         });
//     } catch (error) {
//         res.status(500).json({
//             success: false,
//             service: 'Azure AI Search',
//             error: error.message
//         });
//     }
// });

// Test Azure AI Search - Create Index
app.get('/test-search/create-index', async (req, res) => {
    try {
        const indexClient = new SearchIndexClient(AZURE_SEARCH_ENDPOINT, credential);
        
        const testIndexName = `test-index-${Date.now()}`;
        
        const indexDefinition = {
            name: testIndexName,
            fields: [
                {
                    name: "id",
                    type: "Edm.String",
                    key: true,
                    searchable: false,
                    filterable: true,
                    retrievable: true
                },
                {
                    name: "title",
                    type: "Edm.String",
                    searchable: true,
                    filterable: false,
                    retrievable: true,
                    analyzer: "standard.lucene"
                },
                {
                    name: "content",
                    type: "Edm.String",
                    searchable: true,
                    filterable: false,
                    retrievable: true,
                    analyzer: "standard.lucene"
                },
                {
                    name: "category",
                    type: "Edm.String",
                    searchable: false,
                    filterable: true,
                    facetable: true,
                    retrievable: true
                },
                {
                    name: "createdDate",
                    type: "Edm.DateTimeOffset",
                    searchable: false,
                    filterable: true,
                    sortable: true,
                    retrievable: true
                }
            ],
            corsOptions: {
                allowedOrigins: ["*"],
                maxAgeInSeconds: 300
            }
        };

        const result = await indexClient.createIndex(indexDefinition);

        res.json({
            success: true,
            service: 'Azure AI Search',
            operation: 'Create Index',
            role: 'Search Service Contributor',
            result: {
                endpoint: AZURE_SEARCH_ENDPOINT,
                indexName: testIndexName,
                fieldsCount: result.fields.length,
                etag: result.etag
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            service: 'Azure AI Search',
            operation: 'Create Index',
            error: error.message,
            code: error.code
        });
    }
});

// Test Azure AI Search - List Indexes
app.get('/test-search/list-indexes', async (req, res) => {
    try {
        const indexClient = new SearchIndexClient(AZURE_SEARCH_ENDPOINT, credential);
        
        const indexes = [];
        for await (const index of indexClient.listIndexes()) {
            indexes.push({
                name: index.name,
                fieldsCount: index.fields.length,
                etag: index.etag
            });
        }

        res.json({
            success: true,
            service: 'Azure AI Search',
            operation: 'List Indexes',
            role: 'Search Service Contributor',
            result: {
                endpoint: AZURE_SEARCH_ENDPOINT,
                indexesCount: indexes.length,
                indexes: indexes
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            service: 'Azure AI Search',
            operation: 'List Indexes',
            error: error.message,
            code: error.code
        });
    }
});

// Test Azure AI Search - Add Documents
app.post('/test-search/add-documents/:indexName', async (req, res) => {
    try {
        const { indexName } = req.params;
        const searchClient = new SearchClient(AZURE_SEARCH_ENDPOINT, indexName, credential);
        
        const documents = [
            {
                id: "1",
                title: "Azure AI Search Test Document 1",
                content: "This is a test document for Azure AI Search managed identity testing.",
                category: "test",
                createdDate: new Date().toISOString()
            },
            {
                id: "2",
                title: "Azure AI Search Test Document 2",
                content: "Another test document to verify search functionality with managed identity.",
                category: "test",
                createdDate: new Date().toISOString()
            },
            {
                id: "3",
                title: "Sample Content",
                content: "Sample content for search operations and filtering tests.",
                category: "sample",
                createdDate: new Date().toISOString()
            }
        ];

        const result = await searchClient.uploadDocuments(documents);

        res.json({
            success: true,
            service: 'Azure AI Search',
            operation: 'Add Documents',
            role: 'Search Service Contributor',
            result: {
                endpoint: AZURE_SEARCH_ENDPOINT,
                indexName: indexName,
                documentsAdded: documents.length,
                results: result.results.map(r => ({
                    key: r.key,
                    status: r.status,
                    succeeded: r.succeeded
                }))
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            service: 'Azure AI Search',
            operation: 'Add Documents',
            error: error.message,
            code: error.code
        });
    }
});

// Test Azure AI Search - Search Documents
app.get('/test-search/search/:indexName', async (req, res) => {
    try {
        const { indexName } = req.params;
        const { q = "*", filter, orderby } = req.query;
        
        const searchClient = new SearchClient(AZURE_SEARCH_ENDPOINT, indexName, credential);
        
        const searchOptions = {
            top: 10,
            includeTotalCount: true,
            facets: ["category"],
            highlightFields: ["title", "content"],
            select: ["id", "title", "content", "category", "createdDate"]
        };

        if (filter) searchOptions.filter = filter;
        if (orderby) searchOptions.orderBy = [orderby];

        const searchResults = await searchClient.search(q, searchOptions);

        const results = [];
        for await (const result of searchResults.results) {
            results.push({
                score: result.score,
                document: result.document,
                highlights: result.highlights
            });
        }

        res.json({
            success: true,
            service: 'Azure AI Search',
            operation: 'Search Documents',
            role: 'Search Service Contributor',
            result: {
                endpoint: AZURE_SEARCH_ENDPOINT,
                indexName: indexName,
                query: q,
                totalCount: searchResults.count,
                resultsCount: results.length,
                facets: searchResults.facets,
                results: results
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            service: 'Azure AI Search',
            operation: 'Search Documents',
            error: error.message,
            code: error.code
        });
    }
});

// Test Azure AI Search - Get Document
app.get('/test-search/document/:indexName/:docId', async (req, res) => {
    try {
        const { indexName, docId } = req.params;
        const searchClient = new SearchClient(AZURE_SEARCH_ENDPOINT, indexName, credential);
        
        const document = await searchClient.getDocument(docId);

        res.json({
            success: true,
            service: 'Azure AI Search',
            operation: 'Get Document',
            role: 'Search Service Contributor',
            result: {
                endpoint: AZURE_SEARCH_ENDPOINT,
                indexName: indexName,
                documentId: docId,
                document: document
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            service: 'Azure AI Search',
            operation: 'Get Document',
            error: error.message,
            code: error.code
        });
    }
});

// Test Azure AI Search - Get Service Statistics
app.get('/test-search/service-stats', async (req, res) => {
    try {
        const indexClient = new SearchIndexClient(AZURE_SEARCH_ENDPOINT, credential);
        
        const serviceStats = await indexClient.getServiceStatistics();

        res.json({
            success: true,
            service: 'Azure AI Search',
            operation: 'Get Service Statistics',
            role: 'Search Service Contributor',
            result: {
                endpoint: AZURE_SEARCH_ENDPOINT,
                counters: {
                    documentCount: serviceStats.counters.documentCount,
                    indexCount: serviceStats.counters.indexCount,
                    indexerCount: serviceStats.counters.indexerCount,
                    dataSourceCount: serviceStats.counters.dataSourceCount,
                    storageSizeInBytes: serviceStats.counters.storageSizeInBytes,
                    synonymMapCount: serviceStats.counters.synonymMapCount
                },
                limits: {
                    maxFieldsPerIndex: serviceStats.limits.maxFieldsPerIndex,
                    maxFieldNestingDepthPerIndex: serviceStats.limits.maxFieldNestingDepthPerIndex,
                    maxComplexCollectionFieldsPerIndex: serviceStats.limits.maxComplexCollectionFieldsPerIndex,
                    maxComplexObjectsInCollectionsPerDocument: serviceStats.limits.maxComplexObjectsInCollectionsPerDocument
                }
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            service: 'Azure AI Search',
            operation: 'Get Service Statistics',
            error: error.message,
            code: error.code
        });
    }
});

// Test Azure AI Search - Delete Index
app.delete('/test-search/delete-index/:indexName', async (req, res) => {
    try {
        const { indexName } = req.params;
        const indexClient = new SearchIndexClient(AZURE_SEARCH_ENDPOINT, credential);
        
        await indexClient.deleteIndex(indexName);

        res.json({
            success: true,
            service: 'Azure AI Search',
            operation: 'Delete Index',
            role: 'Search Service Contributor',
            result: {
                endpoint: AZURE_SEARCH_ENDPOINT,
                indexName: indexName,
                deleted: true
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            service: 'Azure AI Search',
            operation: 'Delete Index',
            error: error.message,
            code: error.code
        });
    }
});

// Test Azure Key Vault access (Key Vault Secrets User role)
app.get('/test-keyvault', async (req, res) => {
    try {
        // Create Secret Client
        const secretClient = new SecretClient(AZURE_KEYVAULT_URL, credential);
        
        const testResults = {
            keyVaultUrl: AZURE_KEYVAULT_URL,
            testTimestamp: new Date().toISOString(),
            operations: {}
        };

        // Test 1: List Secrets (Read permission)
        console.log('Testing: List secrets...');
        const secrets = [];
        for await (const secretProperties of secretClient.listPropertiesOfSecrets()) {
            secrets.push({
                name: secretProperties.name,
                enabled: secretProperties.enabled,
                createdOn: secretProperties.createdOn,
                updatedOn: secretProperties.updatedOn,
                version: secretProperties.version
            });
            // Limit to first 10 secrets for response size
            if (secrets.length >= 10) break;
        }
        testResults.operations.listSecrets = {
            success: true,
            count: secrets.length,
            secrets: secrets.slice(0, 5) // Show only first 5 in response
        };

        // Test 2: Create/Set Secret (Write permission)
        console.log('Testing: Set secret...');
        const testSecretName = `managed-identity-test-${Date.now()}`;
        const testSecretValue = `test-value-${Math.random().toString(36).substring(7)}`;
        
        const setSecretResult = await secretClient.setSecret(testSecretName, testSecretValue, {
            contentType: 'text/plain',
            tags: {
                createdBy: 'managed-identity-test',
                testType: 'automated',
                environment: 'test'
            }
        });
        
        testResults.operations.setSecret = {
            success: true,
            secretName: testSecretName,
            version: setSecretResult.version,
            createdOn: setSecretResult.properties.createdOn,
            enabled: setSecretResult.properties.enabled
        };

        // Test 3: Get Secret (Read permission)
        console.log('Testing: Get secret...');
        const getSecretResult = await secretClient.getSecret(testSecretName);
        const secretMatches = getSecretResult.value === testSecretValue;
        
        testResults.operations.getSecret = {
            success: true,
            secretName: testSecretName,
            version: getSecretResult.properties.version,
            valueMatches: secretMatches,
            contentType: getSecretResult.properties.contentType,
            tags: getSecretResult.properties.tags
        };

        // Test 4: Update Secret Properties (Write permission)
        console.log('Testing: Update secret properties...');
        const updatedProperties = await secretClient.updateSecretProperties(testSecretName, {
            enabled: true,
            tags: {
                ...getSecretResult.properties.tags,
                updated: 'true',
                updateTimestamp: new Date().toISOString()
            }
        });
        
        testResults.operations.updateSecretProperties = {
            success: true,
            secretName: testSecretName,
            version: updatedProperties.version,
            updatedOn: updatedProperties.updatedOn,
            tagsCount: Object.keys(updatedProperties.tags || {}).length
        };

        // Test 5: List Secret Versions (Read permission)
        console.log('Testing: List secret versions...');
        const versions = [];
        for await (const versionProperties of secretClient.listPropertiesOfSecretVersions(testSecretName)) {
            versions.push({
                version: versionProperties.version,
                createdOn: versionProperties.createdOn,
                enabled: versionProperties.enabled
            });
        }
        
        testResults.operations.listSecretVersions = {
            success: true,
            secretName: testSecretName,
            versionsCount: versions.length,
            versions: versions
        };

        // Test 6: Get Secret Version (Read permission)
        console.log('Testing: Get specific secret version...');
        const specificVersion = versions[0]?.version || setSecretResult.version;
        const versionedSecret = await secretClient.getSecret(testSecretName, { version: specificVersion });
        
        testResults.operations.getSecretVersion = {
            success: true,
            secretName: testSecretName,
            requestedVersion: specificVersion,
            actualVersion: versionedSecret.properties.version,
            valueMatches: versionedSecret.value === testSecretValue
        };

        // Cleanup: Delete Secret (Delete permission) - This creates a soft delete
        console.log('Testing: Delete secret (soft delete)...');
        const deleteOperation = await secretClient.beginDeleteSecret(testSecretName);
        const deletedSecret = await deleteOperation.pollUntilDone();
        
        testResults.operations.deleteSecret = {
            success: true,
            secretName: testSecretName,
            deletedOn: deletedSecret.deletedOn,
            recoveryId: deletedSecret.recoveryId,
            scheduledPurgeDate: deletedSecret.scheduledPurgeDate
        };

        // Optional: Purge Secret (Purge permission) - Only if purge protection is disabled
        try {
            console.log('Testing: Purge secret (permanent delete)...');
            await secretClient.purgeDeletedSecret(testSecretName);
            testResults.operations.purgeSecret = {
                success: true,
                secretName: testSecretName,
                permanentlyDeleted: true
            };
        } catch (purgeError) {
            testResults.operations.purgeSecret = {
                success: false,
                secretName: testSecretName,
                reason: 'Purge protection enabled or insufficient permissions',
                error: purgeError.message
            };
        }

        // Summary
        const successfulOperations = Object.values(testResults.operations)
            .filter(op => op.success).length;
        const totalOperations = Object.keys(testResults.operations).length;

        res.json({
            success: true,
            service: 'Azure Key Vault',
            role: 'Key Vault Secrets User',
            testSummary: {
                totalOperations,
                successfulOperations,
                failedOperations: totalOperations - successfulOperations,
                allPermissionsVerified: successfulOperations >= 6 // Core operations
            },
            result: testResults
        });

    } catch (error) {
        res.status(500).json({
            success: false,
            service: 'Azure Key Vault',
            error: error.message,
            code: error.code,
            keyVaultUrl: AZURE_KEYVAULT_URL,
            suggestion: 'Verify that the managed identity has "Key Vault Secrets User" role assigned and Key Vault network access is properly configured'
        });
    }
});

app.get('/test-pgsql', async (req, res) => {
    let client;
    const startTime = Date.now();
    const timings = {};
    
    try {
        console.log('🔍 Starting PostgreSQL connection test...');
        
        // Step 1: Test environment variables
        console.log('📝 Step 1: Checking environment variables...');
        const envStart = Date.now();
        
        const host = process.env.POSTGRES_HOST;
        const database = process.env.POSTGRES_DB; 
        const user = process.env.APP_SERVICE_BACKEND_NAME || 'mh-kx-stg-backend-app-wus3-ipto';
        
        console.log(`Host: ${host}`);
        console.log(`Database: ${database}`);
        console.log(`User: ${user}`);
        
        if (!host || !database) {
            throw new Error(`Missing environment variables: POSTGRES_HOST=${!!host}, POSTGRES_DB=${!!database}`);
        }
        
        timings.envCheck = Date.now() - envStart;

        // Step 2: Token acquisition with timeout
        console.log('🔑 Step 2: Acquiring access token...');
        const tokenStart = Date.now();
        
        const tokenResponse = await Promise.race([
            credential.getToken('https://ossrdbms-aad.database.windows.net/.default'),
            new Promise((_, reject) => 
                setTimeout(() => reject(new Error('Token acquisition timeout after 30s')), 30000)
            )
        ]);
        
        timings.tokenAcquisition = Date.now() - tokenStart;
        console.log(`✅ Token acquired in ${timings.tokenAcquisition}ms`);

        if (!tokenResponse || !tokenResponse.token) {
            throw new Error('Failed to obtain access token');
        }

        // Step 3: DNS resolution test
        console.log('🌐 Step 3: Testing DNS resolution...');
        const dnsStart = Date.now();
        
        const dns = require('dns');
        const { promisify } = require('util');
        const lookup = promisify(dns.lookup);
        
        let resolvedIP = 'unknown';
        try {
            const result = await lookup(host);
            resolvedIP = result.address;
            console.log(`DNS resolved ${host} to ${resolvedIP}`);
        } catch (dnsError) {
            console.warn(`DNS resolution failed: ${dnsError.message}`);
        }
        
        timings.dnsResolution = Date.now() - dnsStart;

        // Step 4: Connection attempt with detailed config
        console.log('🔗 Step 4: Attempting database connection...');
        const connectStart = Date.now();
        
        const config = {
            host: host,
            database: database,
            user: user,
            password: tokenResponse.token,
            port: 5432,
            ssl: { rejectUnauthorized: false },
            connectionTimeoutMillis: 30000, // 30 seconds
            query_timeout: 15000, // 15 seconds
            statement_timeout: 15000, // 15 seconds
            keepAlive: true,
            keepAliveInitialDelayMillis: 0
        };

        console.log(`🎯 Connecting to: ${config.host}:${config.port}/${config.database}`);
        console.log(`👤 User: ${config.user}`);
        console.log(`🔐 Token length: ${config.password.length} characters`);
        
        client = new Client(config);
        
        // Wrap connection with timeout
        await Promise.race([
            client.connect(),
            new Promise((_, reject) => 
                setTimeout(() => reject(new Error('Database connection timeout after 30s')), 30000)
            )
        ]);
        
        timings.connection = Date.now() - connectStart;
        console.log(`✅ Connected in ${timings.connection}ms`);

        // Step 5: Test query
        console.log('📊 Step 5: Running test query...');
        const queryStart = Date.now();
        
        const result = await Promise.race([
            client.query('SELECT version(), current_user, current_database(), inet_server_addr()'),
            new Promise((_, reject) => 
                setTimeout(() => reject(new Error('Query timeout after 15s')), 15000)
            )
        ]);
        
        timings.query = Date.now() - queryStart;
        timings.total = Date.now() - startTime;
        
        console.log(`✅ Query completed in ${timings.query}ms`);
        console.log(`🏁 Total time: ${timings.total}ms`);

        res.json({
            success: true,
            service: 'PostgreSQL Flexible Server',
            role: 'Database User (Managed Identity)',
            timings: {
                environmentCheck: `${timings.envCheck}ms`,
                tokenAcquisition: `${timings.tokenAcquisition}ms`,
                dnsResolution: `${timings.dnsResolution}ms`,
                connection: `${timings.connection}ms`,
                query: `${timings.query}ms`,
                total: `${timings.total}ms`
            },
            connection: {
                host: host,
                resolvedIP: resolvedIP,
                database: database,
                user: user,
                ssl: 'enabled'
            },
            result: {
                version: result.rows[0].version,
                currentUser: result.rows[0].current_user,
                currentDatabase: result.rows[0].current_database,
                serverAddress: result.rows[0].inet_server_addr
            }
        });

    } catch (error) {
        timings.total = Date.now() - startTime;
        console.error(`❌ PostgreSQL connection failed after ${timings.total}ms: ${error.message}`);
        
        res.status(500).json({
            success: false,
            service: 'PostgreSQL Flexible Server',
            error: error.message,
            code: error.code,
            timings: {
                failedAfter: `${timings.total}ms`,
                tokenAcquisition: timings.tokenAcquisition ? `${timings.tokenAcquisition}ms` : 'not attempted',
                dnsResolution: timings.dnsResolution ? `${timings.dnsResolution}ms` : 'not attempted',
                connection: timings.connection ? `${timings.connection}ms` : 'not attempted'
            },
            troubleshooting: [
                'Check if POSTGRES_HOST resolves to private IP',
                'Verify VNET integration is working',
                'Confirm private DNS zone configuration',
                'Check NSG rules and route tables'
            ]
        });
    } finally {
        if (client) {
            try {
                await client.end();
                console.log('🔒 Database connection closed');
            } catch (endError) {
                console.error('Error closing connection:', endError);
            }
        }
    }
});

// Test Azure Container Registry access (AcrPull role)
app.get('/test-acr', async (req, res) => {
    try {
        const registryUrl = AZURE_CONTAINER_REGISTRY_URL.startsWith('https://') 
            ? AZURE_CONTAINER_REGISTRY_URL 
            : `https://${AZURE_CONTAINER_REGISTRY_URL}`;

        const client = new ContainerRegistryClient(registryUrl, credential);

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