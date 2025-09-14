#!/usr/bin/env bash
set -e

case "$1" in
  up)
    docker compose up -d
    ;;
  down)
    docker compose down -v
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
