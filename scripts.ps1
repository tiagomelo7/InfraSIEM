param (
    [string]$Action
)

# Choose compose file: prefer windows file when present
if (Test-Path -Path "./docker-compose.windows.yml") {
    $ComposeFile = "./docker-compose.windows.yml"
} elseif (Test-Path -Path "./docker-compose.linux.yml") {
    $ComposeFile = "./docker-compose.linux.yml"
} else {
    $ComposeFile = "./docker-compose.yml"
}

switch ($Action) {
    "up" {
        docker compose -f $ComposeFile up -d
    }
    "down" {
        docker compose -f $ComposeFile down -v
    }
    "install" {
        Write-Host "Installing stack: pulling images and starting containers..."
        docker compose -f $ComposeFile pull
        docker compose -f $ComposeFile up -d
    }
    "uninstall" {
    Write-Host "Stopping and removing containers, networks and volumes..."
    docker compose -f $ComposeFile down -v --remove-orphans
        # Remove named volumes used by this stack
        # Try removing stack-prefixed volumes first; ignore errors and fall back to plain names
        & docker volume rm InfraSIEM_grafana-data InfraSIEM_prometheus-data InfraSIEM_loki-data -f 2>$null
        if ($LASTEXITCODE -ne 0) {
            & docker volume rm grafana-data prometheus-data loki-data -f 2>$null
        }
    }
    "reinstall" {
        & $MyInvocation.MyCommand.Path -Action uninstall
        & $MyInvocation.MyCommand.Path -Action install
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
        Write-Host "Uso: .\scripts.ps1 -Action {install|uninstall|reinstall|up|down|reload-prom|simulate-down|simulate-restore}"
    }
}
