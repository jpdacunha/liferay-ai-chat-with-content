# LIFERAY AI CHAT WITH CONTENT

AI chatbot stack for Liferay DXP using a Retrieval-Augmented Generation (RAG) architecture.

This project was inspired from :
https://github.com/orgs/qls-ai-chatbot/repositories

## Stack technologique

| Domaine | Technologies |
| --- | --- |
| Plateforme | Liferay DXP 2026.q2.0; Liferay Workspace (Gradle); Client Extensions Liferay (frontend + backend) |
| Backend | Java; Spring Boot 2.7.18; Spring Web + Spring WebFlux; Spring Security OAuth2 Resource Server; LangChain4j 0.35.0 (incluant intégration Ollama) |
| Frontend | React 18; React Scripts 5 (Create React App); Sass; Clay UI (@clayui/*); react-chatbotify |
| IA / RAG | Ollama (inférence LLM, modèle: llama3.2 pour chat et streaming); LangChain4j (orchestration IA côté backend); txtai (recherche sémantique / embeddings, modèle: sentence-transformers/all-mpnet-base-v2); Elasticsearch (indexation et recherche) |
| Infrastructure et outillage | Docker + Docker Compose; MySQL 8; Kibana 8.19.15; scripts shell d'orchestration (project.sh, runtime/scripts/*.sh) |

## Quick Start

### 1) Before You Start

1. Install prerequisites:
	 - Docker Engine with Docker Compose
	 - NVIDIA GPU support for Docker (GPU is required by the startup script)
	 - `sudo` access for Docker commands used in project scripts
2. Clone the repository and move to the root folder.

3. Create the runtime environment file from the template (from the repository root):

	```bash
	cp runtime/.env.template runtime/.env
	```
4. Update `.env` with values that match your machine.

	Runtime variables used by `runtime/docker-compose.yml`:

	| Variable | Default | Purpose |
	| --- | --- | --- |
	| `ELASTICSEARCH_HOST_PORT` | `9200` | Elasticsearch HTTP port on host |
	| `ELASTICSEARCH_TRANSPORT_HOST_PORT` | `9300` | Elasticsearch transport port on host |
	| `KIBANA_HOST_PORT` | `5601` | Kibana UI port on host |
	| `MYSQL_HOST_PORT` | `3306` | MySQL port on host |
	| `MYSQL_ROOT_PASSWORD` | `password` | MySQL root password |
	| `MYSQL_USER` | `liferay` | MySQL application user |
	| `MYSQL_PASSWORD` | `liferay` | MySQL application user password |
	| `MYSQL_DATABASE` | `lfr74AICWDlportal` | MySQL database name |
	| `LIFERAY_HOST_PORT` | `8080` | Liferay HTTP port on host |
	| `LIFERAY_DEBUG_HOST_PORT` | `11311` | Liferay remote debug port |
	| `TXTAI_HOST_PORT` | `8001` | txtai API port on host |
	| `TXTAI_TAG` | `latest` | txtai Docker image tag |
	| `OLLAMA_HOST_PORT` | `11434` | Ollama API port on host |
	| `CHATBOT_BACKEND_HOST_PORT` | `58081` | Spring backend API port on host |
	| `AI_CHATBOT_BACKEND_SPRING_PROFILES_ACTIVE` | `localdocker` | Backend Spring profile |

	Additional variable present in the template:

	- `LIFERAY_LICENSE_FILE_PATH`: path to your local license file (kept for local setup convenience).

### 2) Prepare artifacts (without starting containers):

	```bash
	./project.sh refresh
	```

### 3) Start the runtime stack:

	```bash
	./project.sh start
	```

## Docker Services Architecture

### Service Dependency & Flow Matrix

| Producer Service | Consumer Service | Port/Protocol | Purpose | Why |
|---|---|---|---|---|
| **Database (MySQL)** | Liferay DXP | 3306 (TCP) | Persistent data storage | Stores portal configuration, users, content, and workspace data |
| **Database (MySQL)** | - | - | - | Prerequisite for Elasticsearch health check |
| **Elasticsearch** | Liferay DXP | 9200 (HTTP) | Content indexing & search | Enables full-text search and search experience features |
| **Elasticsearch** | Kibana | 9200 (HTTP) | Log visualization & monitoring | Provides dashboard for cluster health and log analysis |
| **Liferay DXP** | Chatbot Backend | 8080 (HTTP) | Search Experiences API | Retrieves indexed content for RAG processing via `/o/search/v1.0/search` endpoint |
| **Liferay DXP** | Chatbot Frontend | 8080 (HTTP) | OAuth2 & UI Integration | Authentication, authorization, and portal page context |
| **Liferay DXP** | Kibana | - | - | Prerequisite dependency for Ollama service startup |
| **Ollama (LLM)** | Chatbot Backend | 11434 (HTTP) | Language model inference | Generates AI responses using LangChain4j integration |
| **txtai** | Chatbot Backend | 8000 (HTTP) | Vector search/semantic search | Optional: Semantic similarity search and embeddings (standby for enhanced RAG) |
| **Chatbot Backend** | Chatbot Frontend | 58081 (HTTP) | Chat API | Provides `/chat` and `/stream-chat` endpoints for UI interaction |
| **Chatbot Frontend** | Web Browser/Client | 8080 (HTTP) | UI Component | Custom element rendered within Liferay portal pages |

### Service Startup Order & Health Checks

```
1. Database (MySQL)
   ↓
2. Elasticsearch (depends on Database health)
   ↓
3. Kibana (depends on Elasticsearch health)
   ↓
4. Liferay DXP (depends on Database & Elasticsearch health)
   ↓
5. Ollama (depends on Kibana health, models loaded async)
   ↓
6. txtai (independent, no explicit dependencies)
   ↓
7. Chatbot Backend (depends on Liferay health)
   ↓
8. Chatbot Frontend (browser-based, communicates via HTTP)
```

### Request Flow: User Chat Interaction

```
User Browser
    ↓
Chatbot Frontend (React component in Liferay page)
    ↓ HTTP POST /chat
Chatbot Backend (Spring Boot)
    ├─→ Retrieve OAuth token from request
    ├─→ HTTP POST /o/search/v1.0/search (with JWT Bearer token)
    │   ↓
    │   Liferay DXP (Search Experiences)
    │   ↓
    │   Elasticsearch (search index)
    │
    ├─→ HTTP POST to Ollama:11434/api/chat
    │   ↓
    │   Ollama (LLM model inference)
    │
    └─→ Construct RAG response
        ↓
Chatbot Frontend (renders AI response + source links)
    ↓
User Browser (displays chat)
```

## Available Commands

The [project.sh](project.sh) script provides the following commands:

- `./project.sh start`: Starts the runtime stack using [runtime/scripts/start.sh](runtime/scripts/start.sh).
- `./project.sh stop`: Stops the runtime stack using [runtime/scripts/stop.sh](runtime/scripts/stop.sh).
- `./project.sh clean`: Removes generated artifacts (`build`, `bundles`, `node_modules`, `dist`, `bin`).
- `./project.sh build`: Builds JS client extensions, then runs [liferay-workspace/scripts/build.sh](liferay-workspace/scripts/build.sh).
- `./project.sh refresh`: Runs the preparation sequence (`clean`, `build`, `deploy`).
- `./project.sh help`: Displays the command help.


