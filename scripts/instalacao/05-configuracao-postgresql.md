-- ============================================================
-- Configuração do PostgreSQL para OpenSIPS 3.6 (Debian 12 / PG 15)
-- ============================================================

-- 1) Criar usuário e banco (como superusuário via socket local)
sudo -u postgres psql <<'EOF'
CREATE USER opensips WITH PASSWORD 'SENHA_SEGURA_AQUI';
CREATE DATABASE opensips OWNER opensips;
GRANT ALL PRIVILEGES ON DATABASE opensips TO opensips;
EOF

-- 2) Permissão de schema (OBRIGATÓRIO no PG 15+)
--    Sem isto, o opensips-cli não consegue criar as tabelas no schema public.
sudo -u postgres psql -d opensips <<'EOF'
GRANT ALL ON SCHEMA public TO opensips;
ALTER SCHEMA public OWNER TO opensips;
EOF

-- 3) pg_hba.conf: o Debian já traz por padrão a linha abaixo, que cobre o opensips.
--    Confirme com: grep -E '^host' /etc/postgresql/15/main/pg_hba.conf
--    Esperado:  host  all  all  127.0.0.1/32  scram-sha-256
--    (não precisa editar nada se essa linha existir)

-- 4) Verificar conexão (via TCP, pede a senha)
psql -U opensips -h 127.0.0.1 -d opensips -c "\l"

-- 5) Extensões
--    pg_stat_statements exige SUPERUSER para criar -> roda como postgres:
sudo -u postgres psql -d opensips -c "CREATE EXTENSION IF NOT EXISTS pg_stat_statements;"
--    btree_gin o usuário opensips consegue criar sozinho (via TCP, pede senha):
psql -U opensips -h 127.0.0.1 -d opensips -c "CREATE EXTENSION IF NOT EXISTS btree_gin;"

-- 6) Ativar pg_stat_statements de fato (preload) — precisa de RESTART, não reload
echo "shared_preload_libraries = 'pg_stat_statements'" | sudo tee -a /etc/postgresql/15/main/postgresql.conf
sudo systemctl restart postgresql

-- 7) Validar que o pg_stat_statements está ativo (deve retornar linhas, sem erro)
sudo -u postgres psql -d opensips -c "SELECT count(*) FROM pg_stat_statements;"

-- ============================================================
-- Otimizações postgresql.conf para OpenSIPS (aplicar manualmente
-- editando /etc/postgresql/15/main/postgresql.conf e reiniciando):
--   shared_buffers = 256MB
--   max_connections = 100
--   work_mem = 16MB
--   checkpoint_completion_target = 0.9
--   effective_cache_size = 1GB
-- ============================================================
