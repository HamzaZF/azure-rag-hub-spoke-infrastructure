# Kelix Test Containers

This directory contains comprehensive containerized test applications designed to validate the complete Kelix Azure hub-and-spoke architecture. The setup includes a Node.js backend API with Azure SDK integration and an Nginx frontend that work together to test all hub services using managed identities.

## 🏗️ Architecture

```
Frontend (Nginx) → Application Gateway → Backend (Node.js + Azure SDK)
      ↓                       ↓                        ↓
   Port 80                 Port 443              Port 3000
      ↓                       ↓                        ↓
Azure App Service      Public IP + SSL      Azure App Service (Private)
      ↓                       ↓                        ↓
   Docker Hub            WAF Protection        Managed Identity
                                                       ↓
                                              Hub Services:
                                              • Blob Storage
                                              • PostgreSQL
                                              • OpenAI
                                              • AI Search
                                              • Container Registry
```

## 📁 Directory Structure

```
test-containers/
├── backend/
│   ├── server.js          # Node.js Express server
│   ├── package.json       # Node.js dependencies
│   ├── Dockerfile         # Backend container configuration
│   └── .dockerignore      # Docker ignore patterns
├── frontend/
│   ├── index.html         # Main frontend application
│   ├── 404.html          # 404 error page
│   ├── 50x.html          # Server error page
│   ├── nginx.conf        # Nginx configuration
│   ├── Dockerfile        # Frontend container configuration
│   └── .dockerignore     # Docker ignore patterns
├── docker-compose.yml    # Local development setup
├── build.bat             # Windows build and push script
├── deploy.bat            # Windows Azure deployment script
├── validate.bat          # Windows validation script
├── config.env.example    # Configuration example
└── README.md             # This file
```

## 🚀 Quick Start

### Prerequisites

- **Windows 10/11** with PowerShell or Command Prompt
- **Docker Desktop** installed and running
- **Azure CLI** installed (for deployment)
- **Docker Hub account** (for image hosting)

### Local Development

1. **Start both services:**
   ```cmd
   docker-compose up --build
   ```

2. **Access the application:**
   - Frontend: http://localhost:8888
   - Backend API (direct): http://localhost:3333/api/random
   - Backend Health (direct): http://localhost:3333/health

### Docker Hub Deployment

1. **Configure your Docker Hub username:**
   ```cmd
   copy config.env.example config.env
   REM Edit config.env and set your DOCKER_USERNAME
   ```

2. **Build and push to Docker Hub:**
   ```cmd
   build.bat --username your-dockerhub-username --push
   ```

3. **Deploy to Azure App Services:**
   ```cmd
   deploy.bat --username your-dockerhub-username --resource-group your-rg --backend-app backend-app-name --frontend-app frontend-app-name
   ```

## 🔧 Backend API

### Core Endpoints

- `GET /health` - Health check endpoint
- `GET /ready` - Readiness check endpoint
- `GET /api/random` - Returns a random number (legacy test endpoint)
- `GET /api/info` - API information and service status

### Azure Service Test Endpoints

- `GET /api/blob/test` - Test Blob Storage connectivity and operations
- `GET /api/openai/test` - Test OpenAI service and deployments
- `GET /api/search/test` - Test AI Search service and indexing
- `GET /api/postgres/test` - Test PostgreSQL database connectivity
- `GET /api/acr/test` - Test Container Registry access

### Response Format

```json
{
  "number": 742851,
  "timestamp": "2024-01-15T10:30:45.123Z",
  "requestId": "abc123def",
  "message": "Random number generated: 742851"
}
```

### Environment Variables

#### Core Configuration
- `NODE_ENV` - Environment (development/production)
- `PORT` - Server port (default: 3000)
- `WEBSITES_PORT` - Azure App Service port (3000)

#### Azure Service Configuration (Managed Identity)
- `AZURE_STORAGE_ACCOUNT_NAME` - Blob Storage account name
- `AZURE_OPENAI_ENDPOINT` - OpenAI service endpoint
- `AZURE_SEARCH_ENDPOINT` - AI Search service endpoint
- `AZURE_SEARCH_INDEX_NAME` - Search index name
- `AZURE_CONTAINER_REGISTRY_URL` - ACR login server
- `POSTGRES_HOST` - PostgreSQL server FQDN
- `POSTGRES_USER` - PostgreSQL admin username
- `POSTGRES_PASSWORD` - PostgreSQL admin password

#### Optional Configuration
- `AZURE_OPENAI_DEPLOYMENT_NAME` - OpenAI deployment name for completions
- `AZURE_SEARCH_API_KEY` - Search API key (if not using managed identity)

## 🌐 Frontend Application

### Features

- **Comprehensive Testing UI** - Interactive interface for testing all Azure services
- **Service Status Monitoring** - Real-time status of all hub services
- **Managed Identity Testing** - Validates authentication to each service
- **Detailed Response Display** - Shows full JSON responses for debugging
- **Error Handling** - Comprehensive error display with service-specific messages
- **Service Health Dashboard** - Individual test buttons for each Azure service

### Configuration

- Local development: set `BACKEND_API_URL` env when running the frontend container, or type the URL in the page input; by default use `http://localhost:3333`.
- Production (Azure): set `BACKEND_API_URL` app setting on the frontend App Service to your Application Gateway URL (for example `https://<agw-hostname>`). The page reads it from `/config.js` at runtime.

## 🛠️ Build Scripts (Windows)

### build.bat

Builds Docker images and optionally pushes to Docker Hub.

```cmd
REM Build locally
build.bat

REM Build and push to Docker Hub
build.bat --username myusername --push

REM Build only backend
build.bat --backend-only

REM Build with custom tag
build.bat --tag v1.2.3

REM Build and push with cleanup
build.bat --username myusername --push --clean
```

### deploy.bat

Deploys containers to Azure App Services from Docker Hub.

```cmd
REM Deploy both apps
deploy.bat --username myusername --resource-group my-rg --backend-app backend-app --frontend-app frontend-app

REM Build and deploy in one step
deploy.bat --username myusername --resource-group my-rg --backend-app backend-app --frontend-app frontend-app --build

REM Deploy only frontend
deploy.bat --username myusername --resource-group my-rg --frontend-app frontend-app --frontend-only
```

### validate.bat

Validates the setup and checks for required files.

```cmd
REM Validate setup
validate.bat
```

## 🔒 Security Features

### Backend Security
- **Helmet.js** - Security headers and protections
- **CORS** - Configurable cross-origin resource sharing
- **Request ID** - Unique request tracking
- **Input validation** - Basic request validation
- **Non-root user** - Container runs as non-privileged user

### Frontend Security
- **CSP Headers** - Content Security Policy
- **Security Headers** - XSS protection, frame options, etc.
- **Rate Limiting** - Nginx-level request rate limiting
- **Non-root user** - Container runs as nginx user

## 🔍 Monitoring & Debugging

### Health Checks

Both containers include health check endpoints:

```bash
# Backend health
curl http://localhost:3000/health

# Frontend health (through nginx)
curl http://localhost:8080/health
```

### Logging

View container logs:

```bash
# Local development
docker-compose logs -f

# Azure App Service
az webapp log tail --name <app-name> --resource-group <rg-name>
```

### Troubleshooting

1. **Backend not responding:**
   - Check if container is running: `docker ps`
   - Check logs: `docker-compose logs backend`
   - Verify port 3000 is accessible

2. **Frontend can't reach backend:**
   - Ensure you are calling the Application Gateway URL from the frontend, not the private backend App Service
   - Verify CORS on the backend allows requests (currently `*`)
   - Confirm Application Gateway backend health probe is set to `/health` and is Healthy

3. **Azure deployment issues:**
   - Verify ACR login: `az acr login --name <acr-name>`
   - Check app service logs: `az webapp log tail`
   - Verify container registry access

## 🧪 Testing the Architecture

### Comprehensive Service Testing

1. **Open the frontend** in a web browser at your Application Gateway URL
2. **Basic API Tests:**
   - **Health Check** - Validates backend connectivity
   - **API Info** - Shows service status and available endpoints
   - **Random Number** - Legacy test endpoint
3. **Azure Hub Services Tests:**
   - **🗃️ Blob Storage** - Tests container listing and creation
   - **🤖 OpenAI** - Tests deployments and completions
   - **🔍 AI Search** - Tests index statistics and search queries
   - **🗄️ PostgreSQL** - Tests database connectivity and queries
   - **📦 Container Registry** - Tests repository access
4. **🚀 Test All Services** - Runs comprehensive test suite

### API Testing

```cmd
REM Test via Application Gateway (Production)
curl -X GET https://<agw-hostname>/health
curl -X GET https://<agw-hostname>/api/info
curl -X GET https://<agw-hostname>/api/blob/test
curl -X GET https://<agw-hostname>/api/openai/test
curl -X GET https://<agw-hostname>/api/search/test
curl -X GET https://<agw-hostname>/api/postgres/test
curl -X GET https://<agw-hostname>/api/acr/test

REM Local development testing
curl -X GET http://localhost:3333/health
curl -X GET http://localhost:3333/api/info
curl -X GET http://localhost:3333/api/blob/test
```

Or using PowerShell:

```powershell
# Test via Application Gateway (Production)
Invoke-RestMethod -Uri https://<agw-hostname>/api/info
Invoke-RestMethod -Uri https://<agw-hostname>/api/blob/test

# Local development testing  
Invoke-RestMethod -Uri http://localhost:3333/api/info
```

### Load Testing

Use PowerShell or tools like `ab` (if installed) to test under load:

```powershell
# PowerShell load test example
1..100 | ForEach-Object -Parallel { 
    Invoke-RestMethod -Uri http://localhost:3000/api/random 
} -ThrottleLimit 10
```

## 📝 Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DOCKER_USERNAME` | Docker Hub username | - |
| `RESOURCE_GROUP` | Azure Resource Group | - |
| `BACKEND_APP_NAME` | Backend App Service name | - |
| `FRONTEND_APP_NAME` | Frontend App Service name | - |
| `IMAGE_TAG` | Docker image tag | `latest` |
| `BACKEND_IMAGE_NAME` | Backend image name | `kelix-backend-test` |
| `FRONTEND_IMAGE_NAME` | Frontend image name | `kelix-frontend-test` |

### Customization

- **Backend port:** Modify `PORT` in docker-compose.yml or environment
- **Frontend styling:** Edit CSS in `frontend/index.html`
- **Nginx config:** Modify `frontend/nginx.conf`
- **API endpoints:** Add new routes in `backend/server.js`

## 🤝 Contributing

1. Make changes to the appropriate service
2. Test locally with `docker-compose up --build`
3. Build and test images with `./build.sh`
4. Deploy and test in Azure environment

## 📄 License

This project is part of the Kelix architecture testing suite.
