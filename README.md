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

## Webhook de alertas

O Alertmanager foi configurado para encaminhar alertas específicos para um receiver do tipo webhook chamado `webhook_receiver` quando o alerta contiver a label `webhook_target: "site-example"`.

Edite `alertmanager/alertmanager.yml` e substitua o campo `url` do `webhook_receiver` pelo endpoint do seu webhook real (ex.: `https://meu-webhook.exemplo/alerts`).

## Dashboards do Grafana

Foi adicionada uma dashboard de exemplo em `grafana/dashboards/site_overview.json`. Ela será provisionada automaticamente pelo Grafana quando o container iniciar (provisioning em `grafana/provisioning/dashboards/dashboards.yml`).

A dashboard contém variáveis `job` e `instance` para filtrar os destinos e mostrar a métrica `up`.

## Scripts de gerenciamento

Use `scripts.ps1` (Windows PowerShell) ou `scripts.sh` (Linux/macOS) para gerenciar o stack:

- `install`: puxa imagens e sobe o stack
- `uninstall`: para e remove containers, redes e volumes nomeados do stack
- `reinstall`: faz `uninstall` seguido de `install`
- `up` / `down`: `docker compose up -d` / `docker compose down -v`

Exemplo (PowerShell):

```powershell
.\scripts.ps1 -Action install
```

Exemplo (bash):

```bash
./scripts.sh install
```

## Testando alertas e webhook

Como os alertas funcionam aqui:
- O Prometheus faz `scrape` dos serviços configurados em `prometheus/prometheus.yml` e registra a métrica `up`.
- Regras em `prometheus/alerts.yml` disparam alertas (por exemplo `InstanceDown`) quando `up == 0` por um período configurado.
- O Alertmanager recebe esses alertas e os roteia de acordo com `alertmanager/alertmanager.yml`. Há um receiver `webhook_receiver` que envia um POST para o endpoint que você configurar (por exemplo, seu webhook externo em webhook.site). Atualize `alertmanager/alertmanager.yml` com sua URL do webhook caso necessário.

Passo-a-passo para testar o fluxo (no Windows PowerShell):

1) Suba o stack (usa o compose do Docker Desktop automaticamente):

```powershell
.\scripts.ps1 -Action install
```

3) Envie um alerta de teste para o Alertmanager API (substitua timestamps se quiser):

```powershell
$payload = @'
[{"labels":{"alertname":"InstanceDown","instance":"example-site:80","job":"site-example"},"annotations":{"summary":"Teste: alvo indisponível"},"startsAt":"'+ (Get-Date).ToString("o") +'"}]
'@

Invoke-RestMethod -Method Post -ContentType 'application/json' -Body $payload -Uri http://localhost:9093/api/v1/alerts
```

2) Envie um alerta de teste para o Alertmanager API (substitua timestamps se quiser) e depois verifique o inbox do seu webhook externo (ex.: webhook.site) para confirmar a recepção.

```powershell
$payload = @'
[{"labels":{"alertname":"InstanceDown","instance":"example-site:80","job":"site-example"},"annotations":{"summary":"Teste: alvo indisponível"},"startsAt":"'+ (Get-Date).ToString("o") +'"}]
'@

Invoke-RestMethod -Method Post -ContentType 'application/json' -Body $payload -Uri http://localhost:9093/api/v1/alerts
```


# cAdvisor (porta padrão: 8080)
curl http://localhost:8080/metrics | head -n 10
