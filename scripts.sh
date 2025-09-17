#!/usr/bin/env bash
set -e

case "$1" in
  up)
    docker compose up -d
    ;;
  down)
    docker compose down -v
    ;;
  install)
    echo "Installing stack: pulling images and starting containers..."
    docker compose pull
    docker compose up -d
    ;;
  uninstall)
    echo "Stopping and removing containers, networks and volumes..."
    docker compose down -v --remove-orphans
    # Remove named volumes used by this stack (try a couple of common names)
    docker volume rm InfraSIEM_grafana-data InfraSIEM_prometheus-data InfraSIEM_loki-data -f || true
    docker volume rm grafana-data prometheus-data loki-data -f || true
    ;;
  reinstall)
    $0 uninstall
    $0 install
    ;;
  reload-prom)
    curl -X POST http://localhost:9090/-/reload
    ;;
  simulate-down)
    docker compose stop cadvisor
    ;;
  simulate-restore)
    docker compose start cadvisor
    ;;
  *)
    echo "Uso: $0 {up|down|reload-prom|simulate-down|simulate-restore}"
    ;;
esac
