# InfraSIEM

Infraestrutura SIEM usada no curso de Monitoramento e Análise de Ameaças.

Este repositório contém um stack leve (Prometheus, Alertmanager, Grafana, Loki, Promtail, cAdvisor, node-exporter, MailHog) para testes e demonstração.

---

## Sumário

- [Pré-requisitos](#pré-requisitos)
- [Subir o stack (rápido)](#subir-o-stack-rápido)
- [Verificar serviços (Windows)](#verificar-serviços-windows)
- [Configurar webhook (Alertmanager)](#configurar-webhook-alertmanager)
- [Dashboards do Grafana](#dashboards-do-grafana)
- [Scripts de gerenciamento](#scripts-de-gerenciamento)
- [Testar alertas e webhook](#testar-alertas-e-webhook)
- [Troubleshooting rápido](#troubleshooting-rápido)

---

## Pré-requisitos

- Docker Desktop (Windows) com Compose V2
- PowerShell (Windows) ou Bash (Linux/macOS)

## Subir o stack (rápido)

No Windows PowerShell:

```powershell
Set-Location -LiteralPath "C:\Users\<seu_usuario>\OneDrive\Área de Trabalho\InfraSIEM"
.\scripts.ps1 -Action install
```

No Linux/macOS (bash):

```bash
./scripts.sh install
```

## Verificar serviços (Windows)

Após subir, verifique rapidamente cada serviço nas suas UIs/APIs:

- Prometheus (porta 9090)
	- http://localhost:9090/-/healthy
	- http://localhost:9090/-/ready
	- Targets: http://localhost:9090/targets
- Grafana (porta 3000)
	- http://localhost:3000 (usuário padrão: `admin` / `admin`)
- Loki (porta 3100)
	- http://localhost:3100/ready
- Alertmanager (porta 9093)
	- http://localhost:9093/-/healthy
	- http://localhost:9093/-/ready
	- Active alerts: http://localhost:9093/api/v2/alerts

Comandos PowerShell uteis:

```powershell
# listar containers relacionados
docker ps --filter "name=prometheus" --filter "name=alertmanager" --filter "name=grafana"

# ver alvos do Prometheus (último scrape / erros)
Invoke-RestMethod -Uri http://localhost:9090/api/v1/targets | ConvertTo-Json -Depth 4

# ver alerts do Prometheus
Invoke-RestMethod -Uri http://localhost:9090/api/v1/alerts | ConvertTo-Json -Depth 4

# ver alerts no Alertmanager
Invoke-RestMethod -Uri http://localhost:9093/api/v2/alerts | ConvertTo-Json -Depth 4
```

## Configurar webhook (Alertmanager)

O Alertmanager possui um receiver `webhook_receiver` já configurado em `alertmanager/alertmanager.yml` apontando para um webhook de exemplo (webhook.site). Se quiser receber as notificações no seu endpoint, edite `alertmanager/alertmanager.yml` e substitua a URL:

```yaml
receivers:
	- name: "webhook_receiver"
		webhook_configs:
			- url: "https://seu-webhook.exemplo/alerts"
				send_resolved: true
```

`send_resolved: true` faz com que o Alertmanager envie também uma notificação quando o alerta é resolvido (serviço voltou).

## Dashboards do Grafana

As dashboards estão em `grafana/dashboards/` e serão provisionadas automaticamente pelo Grafana (veja `grafana/provisioning/`). As dashboards usam variáveis `job` e `instance` para filtrar a métrica `up`.

## Scripts de gerenciamento

Use `scripts.ps1` (Windows PowerShell) ou `scripts.sh` para gerenciar o stack:

- `install`: puxa imagens e sobe o stack
- `uninstall`: para e remove containers, redes e volumes nomeados do stack
- `reinstall`: `uninstall` seguido de `install`
- `up` / `down`: `docker compose up -d` / `docker compose down -v`

Exemplo (PowerShell):

```powershell
.\scripts.ps1 -Action install
.\scripts.ps1 -Action down
.\scripts.ps1 -Action uninstall
```

Exemplo (bash):

```bash
./scripts.sh install
```

## Testar alertas e webhook

Fluxo curto:

1. O Prometheus faz `scrape` dos serviços e produz a métrica `up`.
2. Regras em `prometheus/alerts.yml` disparam alertas quando `up == 0` por `for:` configurado.
3. O Alertmanager recebe os alertas e os roteia para `webhook_receiver` (entre outros).

Exemplo: enviar alerta manual para o Alertmanager (PowerShell):

```powershell
$payload = @'
[{"labels":{"alertname":"InstanceDown","instance":"example-site:80","job":"site-example"},"annotations":{"summary":"Teste: alvo indisponível"},"startsAt":"'+ (Get-Date).ToString("o") +'"}]

Invoke-RestMethod -Method Post -ContentType 'application/json' -Body $payload -Uri http://localhost:9093/api/v1/alerts
```

Abra o inbox do webhook (ex.: webhook.site) para ver as requisições de `firing` e `resolved` (caso `send_resolved: true` esteja ativado).

## Troubleshooting rápido

- Se o Alertmanager mostrar erro ao enviar para o webhook, verifique `docker logs alertmanager` e a métrica `/metrics` para `notifications_failed_total`.
- Se Prometheus não carregar as regras, confirme o `rule_files` em `prometheus/prometheus.yml` e recarregue com `POST http://localhost:9090/-/reload`.
- Se o `docker compose` reclamar de YAML inválido (ex.: `services.networks must be a mapping`) verifique a indentação do `docker-compose.windows.yml` (já corrigido neste repositório).

---

Se quiser, posso acrescentar uma seção com exemplos de testes automatizados (scripts que param/levantam serviços e medem latência de notificação). Abra um pedido e eu implemento.
