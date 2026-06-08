#!/usr/bin/env python3
"""
Rhythm Site - SQL DDL Pipeline
Ejecuta los archivos SQL en orden secuencial para crear la base de datos y sus tablas.
"""
import psycopg2
import sys
import os
import argparse

# ============================================
# CONFIGURACIÓN - EDITAR SOLO AQUÍ
# ============================================

# Orden de ejecución de los scripts SQL
SQL_FILES = [
    ("01_create_database.sql",        "Creación de base de datos",     "postgres"),
    ("02_tablas_no_gestionables.sql", "Tablas no gestionables",        "rhythm_site"),
    ("03_tablas_contacto.sql",        "Tablas de contacto",            "rhythm_site"),
    ("04_usuarios_artistas.sql",      "Usuarios y artistas",           "rhythm_site"),
    ("05_organizadores_venues.sql",   "Organizadores y venues",        "rhythm_site"),
    ("06_eventos.sql",                "Eventos",                       "rhythm_site"),
    ("07_tickets_ordenes.sql",        "Tickets y órdenes",             "rhythm_site"),
]

# ============================================
# NO EDITAR A PARTIR DE AQUÍ
# ============================================

def parse_arguments():
    parser = argparse.ArgumentParser(description="Rhythm Site — Pipeline de scripts SQL")
    parser.add_argument("--sql-dir",  required=True,             help="Directorio que contiene los archivos SQL (ej: ../ddl)")
    parser.add_argument("--user",     required=True,             help="Usuario de PostgreSQL")
    parser.add_argument("--password", required=True,             help="Contraseña de PostgreSQL")
    parser.add_argument("--host",     default="localhost",       help="Host de PostgreSQL (default: localhost)")
    parser.add_argument("--port",     default=5432, type=int,   help="Puerto de PostgreSQL (default: 5432)")
    return parser.parse_args()


def connect_postgres(host, port, user, password, dbname="postgres"):
    try:
        conn = psycopg2.connect(host=host, port=port, user=user, password=password, dbname=dbname)
        print(f"    Conectado a PostgreSQL — base de datos: {dbname}")
        return conn
    except Exception as e:
        print(f"    Error al conectar a PostgreSQL: {e}")
        sys.exit(1)


def parse_sql_file(filepath):
    """Lee un archivo SQL y lo divide en sentencias individuales."""
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            sql = f.read()
    except UnicodeDecodeError:
        print(f"    Advertencia: usando codificación latin-1 para {filepath}")
        with open(filepath, "r", encoding="latin-1") as f:
            sql = f.read()

    statements = []
    buffer = ""

    for line in sql.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("--"):
            continue
        buffer += " " + stripped
        if stripped.endswith(";"):
            statements.append(buffer.strip())
            buffer = ""

    return statements


def execute_statements(conn, statements):
    with conn.cursor() as cur:
        for i, statement in enumerate(statements, 1):
            try:
                print(f"      [{i}/{len(statements)}] Ejecutando...")
                cur.execute(statement)
            except Exception as e:
                print(f"      Error en sentencia {i}: {e}")
                raise


def run_script(filepath, description, dbname, host, port, user, password):
    print(f"\n----- {description} -----")
    print(f"  Archivo : {os.path.basename(filepath)}")
    print(f"  Base de datos: {dbname}")

    if not os.path.exists(filepath):
        print(f"  ADVERTENCIA: Archivo no encontrado, omitiendo → {filepath}")
        return

    statements = parse_sql_file(filepath)
    if not statements:
        print("  Sin sentencias que ejecutar.")
        return

    try:
        conn = connect_postgres(host, port, user, password, dbname)
        conn.autocommit = True
        print(f"  Ejecutando {len(statements)} sentencia(s)...")
        execute_statements(conn, statements)
        print(f"  ✓ Completado: {description}")
    except psycopg2.OperationalError as e:
        print(f"  Error de conexión: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"  Error inesperado: {e}")
        sys.exit(1)
    finally:
        try:
            conn.close()
        except Exception:
            pass


def main():
    args = parse_arguments()
    sql_dir = os.path.abspath(args.sql_dir)

    print("=" * 60)
    print("  Rhythm Site — Pipeline DDL")
    print("=" * 60)
    print(f"  Directorio SQL : {sql_dir}")
    print(f"  Host           : {args.host}:{args.port}")
    print(f"  Usuario        : {args.user}")

    if not os.path.isdir(sql_dir):
        print(f"\n  Error: Directorio no encontrado → {sql_dir}")
        sys.exit(1)

    for filename, description, dbname in SQL_FILES:
        filepath = os.path.join(sql_dir, filename)
        run_script(filepath, description, dbname, args.host, args.port, args.user, args.password)

    print()
    print("=" * 60)
    print("  Pipeline completado exitosamente.")
    print("=" * 60)


if __name__ == "__main__":
    main()
