#!/bin/bash
# =========================================
# Rhythm Site — Ejecutar pipeline DDL
# =========================================
# Uso: bash execute_command.sh
# Desde: pipelines/01-create-database/

# Primer Script
python .\01-sql-ddl-script-auto.py --sql-dir ../ddl --user postgres --password "" --host localhost --port 5432

# Segundo Script
python .\02-insert-data\02-sql-dml-insert-auto.py --data-dir ../data --user postgres --password "*" --host localhost --port 5432
