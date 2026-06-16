#!/bin/bash
# =========================================
# Rhythm Site — Ejecutar pipeline DML (Insert Data)
# =========================================
# Uso: bash execute_command.sh
# Desde: pipelines/02-insert-data/

# Segundo Script
python .\02-insert-data\02-sql-dml-insert-auto.py --data-dir ../data --user postgres --password "*" --host localhost --port 5432 --database rhythm_site
