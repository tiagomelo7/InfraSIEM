# InfraSIEM
Infraestrutura SIEM para a disciplina de Monitoramento e Análise de Ameaças ministrada pelo professor Francisco Sales no projeto Dell Delivery Academy

## 🔎 Verificação dos serviços no localhost

Após subir os containers com `docker compose up -d`, é possível verificar se os serviços estão rodando corretamente utilizando os comandos abaixo:

## Windows

Caso estejam usando o S.O Windows e 
### Comandos básicos de checagem

```bash
# Prometheus (porta padrão: 9090)
curl http://localhost:9090/-/healthy
curl http://localhost:9090/-/ready

# Grafana (porta padrão: 3000)
curl http://localhost:3000/login

# Loki (porta padrão: 3100)
curl http://localhost:3100/ready

# Alertmanager (porta padrão: 9093)
curl http://localhost:9093/-/healthy
curl http://localhost:9093/-/ready

# Node Exporter (porta padrão: 9100)
curl http://localhost:9100/metrics | head -n 10

# cAdvisor (porta padrão: 8080)
curl http://localhost:8080/metrics | head -n 10
