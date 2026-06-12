# LIFERAY AI CHAT WITH CONTENT

AI chatbot stack for Liferay DXP using a Retrieval-Augmented Generation (RAG) architecture.

This project was inspired from :
https://github.com/orgs/qls-ai-chatbot/repositories

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

## Available Commands

The [project.sh](project.sh) script provides the following commands:

- `./project.sh start`: Starts the runtime stack using [runtime/scripts/start.sh](runtime/scripts/start.sh).
- `./project.sh stop`: Stops the runtime stack using [runtime/scripts/stop.sh](runtime/scripts/stop.sh).
- `./project.sh clean`: Removes generated artifacts (`build`, `bundles`, `node_modules`, `dist`, `bin`).
- `./project.sh build`: Builds JS client extensions, then runs [liferay-workspace/scripts/build.sh](liferay-workspace/scripts/build.sh).
- `./project.sh refresh`: Runs the preparation sequence (`clean`, `build`, `deploy`).
- `./project.sh help`: Displays the command help.


