📊 Infraestrutura de Observabilidade (SIEM com Docker Compose)
🔧 Ferramentas utilizadas

Docker Compose → Orquestra todos os containers em uma única rede para comunicação entre serviços e host.

Prometheus → Coleta e armazena métricas de containers e do host.

Alertmanager → Gerencia alertas gerados pelo Prometheus e envia notificações (Telegram, e-mail, webhook etc.).

Node Exporter → Exporta métricas do host (CPU, RAM, disco, rede).

cAdvisor → Exporta métricas de uso de recursos por containers (CPU, RAM, I/O).

Grafana → Interface de visualização de métricas e logs (dashboards interativos).

Loki → Sistema de armazenamento e consulta de logs (semelhante ao Prometheus, mas para logs).

Promtail → Agente que coleta logs do host/containers e envia ao Loki.

▶️ Comandos básicos
Subir a stack
docker-compose up -d

Ver status dos containers
docker ps

Acompanhar logs de um serviço
docker logs -f nome_do_servico

Derrubar todos os serviços
docker-compose down

🌐 Portas de acesso
# Prometheus:    http://localhost:9090
# Alertmanager:  http://localhost:9093
# Grafana:       http://localhost:3000
# Loki:          http://localhost:3100
# cAdvisor:      http://localhost:8080
# Node Exporter: http://localhost:9100

📌 Situação atual

Infraestrutura de coleta de métricas e logs já instalada e em execução.

Prometheus coleta métricas de containers e host.

Grafana disponível para visualização.

Loki instalado, aguardando ajustes para ingestão/consulta de logs.

Próxima etapa: simulação de evento de erro e configuração de Alertmanager para envio de notificações.
