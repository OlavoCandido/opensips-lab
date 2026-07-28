#!/bin/bash
set -euo pipefail

# Verificação de pré-requisitos de software
echo "=== Pré-requisitos para OpenSIPS 3.6 ==="

# Sistema operacional
lsb_release -a 2>/dev/null || cat /etc/os-release

# PostgreSQL (recomendado para 3.x)
apt-get install -y postgresql postgresql-client

# Redis (para cache e sessões)
apt-get install -y redis-server

# Dependências de compilação
apt-get install -y build-essential bison flex \
  libncurses5-dev libssl-dev libpcre3-dev \
  libxml2-dev libmariadb-dev libmariadb-dev-compat \
  libpq-dev libmicrohttpd-dev libcurl4-openssl-dev \
  python3-dev libhiredis-dev librabbitmq-dev curl

# RTPEngine para relay de mídia (pacote nativo do Debian 12 — roda em userspace)
apt-get install -y rtpengine-daemon

# Verificar versões instaladas
echo "---"
echo "PostgreSQL: $(pg_config --version 2>/dev/null || echo 'não instalado')"
echo "---"
echo "Redis:      $(redis-server --version 2>/dev/null || echo 'não instalado')"
echo "---"
echo "OpenSSL:    $(openssl version)"
echo "---"
echo "RTPEngine:  $(rtpengine --version 2>&1 || echo 'não instalado')"
