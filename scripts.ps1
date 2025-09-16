param (
    [string]$Action
)

switch ($Action) {
    "up" {
        docker compose up -d
    }
    "down" {
        docker compose down -v
    }
    "reload-prom" {
        Invoke-RestMethod -Method Post -Uri http://localhost:9090/-/reload
    }
    "simulate-down" {
        docker compose stop cadvisor
    }
    "simulate-restore" {
        docker compose start cadvisor
    }
    Default {
        Write-Host "Uso: ./scripts.ps1 {up|down|reload-prom|simulate-down|simulate-restore}"
    }
}
