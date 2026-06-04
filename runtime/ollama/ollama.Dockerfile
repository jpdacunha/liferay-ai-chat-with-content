FROM ollama/ollama:latest

RUN mkdir -p /home/ollama
COPY ./ollama/models/install-models.sh /home/ollama/install-models.sh
RUN chmod +x /home/ollama/*.sh
