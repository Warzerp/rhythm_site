#!/usr/bin/env python3
"""
Rhythm Site - SQL DML Insert Pipeline
Ejecuta los archivos SQL de datos en orden secuencial para poblar la base de datos.
"""
import psycopg2
import sys
import os
import argparse

# ============================================
# CONFIGURACIÓN - EDITAR SOLO AQUÍ
# ============================================

# Orden de ejecución de los scripts SQL de datos
# Respeta el orden de dependencias de llaves foráneas
DATA_FILES = [
    ("00_rol_cuentas.sql",            "Roles de Cuentas",             "rhythm_site"),
    ("00_clasificaciones.sql",        "Clasificaciones",              "rhythm_site"),
    ("00_tipo_tickets.sql",           "Tipos de Tickets",             "rhythm_site"),
    ("01_paises.sql",                 "Paises",                      "rhythm_site"),
    ("02_departamentos.sql",          "Departamentos",                "rhythm_site"),
    ("03_municipio.sql",              "Municipios",                   "rhythm_site"),
    ("04_ciudad.sql",                 "Ciudades",                     "rhythm_site"),
    ("05_tipo_evento.sql",            "Tipos de Evento",              "rhythm_site"),
    ("06_generos.sql",                "Generos Musicales",            "rhythm_site"),
    ("07_tipos_artista.sql",          "Tipos de Artista",             "rhythm_site"),
    ("08_correo_usuarios.sql",        "Correos de Usuarios",          "rhythm_site"),
    ("09_telefono_usuarios.sql",      "Telefonos de Usuarios",        "rhythm_site"),
    ("10_usuarios.sql",               "Usuarios",                     "rhythm_site"),
    ("11_correo_artistas.sql",        "Correos de Artistas",          "rhythm_site"),
    ("12_telefono_artistas.sql",      "Telefonos de Artistas",        "rhythm_site"),
    ("13_artistas.sql",               "Artistas",                     "rhythm_site"),
    ("14_artista_genero.sql",         "Artista-Genero",               "rhythm_site"),
    ("15_correo_organizadores.sql",   "Correos de Organizadores",     "rhythm_site"),
    ("16_telefono_organizadores.sql", "Telefonos de Organizadores",   "rhythm_site"),
    ("17_direcciones.sql",            "Direcciones",                  "rhythm_site"),
    ("18_direcciones_organizador.sql","Direcciones de Organizadores", "rhythm_site"),
    ("19_organizadores.sql",          "Organizadores",                "rhythm_site"),
    ("21_direcciones_venues.sql",     "Direcciones de Venues",        "rhythm_site"),
    ("20_venues.sql",                 "Venues",                       "rhythm_site"),
    ("22_eventos.sql",                "Eventos",                      "rhythm_site"),
    ("23_evento_artistas.sql",        "Evento-Artistas",              "rhythm_site"),
    ("24_ticket.sql",                 "Tickets",                      "rhythm_site"),
    ("25_ordenes.sql",                "Ordenes",                      "rhythm_site"),
]

# ============================================
# NO EDITAR A PARTIR DE AQUÍ
# ============================================

def parse_arguments():
    parser = argparse.ArgumentParser(description="Rhythm Site — Pipeline de insercion de datos")
    parser.add_argument("--data-dir",  required=True,           help="Directorio que contiene los archivos SQL de datos (ej: ../data)")
    parser.add_argument("--user",      required=True,           help="Usuario de PostgreSQL")
    parser.add_argument("--password",  required=True,           help="Contrasena de PostgreSQL")
    parser.add_argument("--host",      default="localhost",     help="Host de PostgreSQL (default: localhost)")
    parser.add_argument("--port",      default=5432, type=int, help="Puerto de PostgreSQL (default: 5432)")
    parser.add_argument("--database",  default="rhythm_site",  help="Base de datos destino (default: rhythm_site)")
    return parser.parse_args()


def connect_postgres(host, port, user, password, dbname="rhythm_site"):
    try:
        conn = psycopg2.connect(host=host, port=port, user=user, password=password, dbname=dbname)
        print(f"    Conectado a PostgreSQL — base de datos: {dbname}")
        return conn
    except Exception as e:
        print(f"    Error al conectar a PostgreSQL: {e}")
        sys.exit(1)


def parse_sql_file(filepath):
    """Lee un archivo SQL y lo divide en sentencias individuales, soportando bloques $$."""
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            sql = f.read()
    except UnicodeDecodeError:
        print(f"    Advertencia: usando codificacion latin-1 para {filepath}")
        with open(filepath, "r", encoding="latin-1") as f:
            sql = f.read()

    statements = []
    buffer = ""
    in_dollar_quote = False

    for line in sql.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("--"):
            continue
        
        # Eliminar comentarios de fin de línea
        if " --" in stripped:
            stripped = stripped[:stripped.index(" --")].rstrip()
            
        if not stripped:
            continue

        buffer += "\n" + stripped
        
        # Cambiar el estado de la cita de dólar si la línea tiene un número impar de $$
        dollar_count = stripped.count("$$")
        if dollar_count % 2 == 1:
            in_dollar_quote = not in_dollar_quote
            
        if stripped.endswith(";") and not in_dollar_quote:
            statements.append(buffer.strip())
            buffer = ""

    return [s for s in statements if s]


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
    print(f"  Archivo      : {os.path.basename(filepath)}")
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
        print(f"  [OK] Completado: {description}")
    except psycopg2.OperationalError as e:
        print(f"  Error de conexion: {e}")
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
    data_dir = os.path.abspath(args.data_dir)

    print("=" * 60)
    print("  Rhythm Site — Pipeline de Insercion de Datos")
    print("=" * 60)
    print(f"  Directorio data : {data_dir}")
    print(f"  Host            : {args.host}:{args.port}")
    print(f"  Usuario         : {args.user}")
    print(f"  Base de datos   : {args.database}")

    if not os.path.isdir(data_dir):
        print(f"\n  Error: Directorio no encontrado → {data_dir}")
        sys.exit(1)

    total_ok = 0
    for filename, description, dbname in DATA_FILES:
        filepath = os.path.join(data_dir, filename)
        run_script(filepath, description, dbname, args.host, args.port, args.user, args.password)
        total_ok += 1

    print()
    print("=" * 60)
    print(f"  Pipeline completado: {total_ok}/{len(DATA_FILES)} scripts ejecutados.")
    print("=" * 60)


if __name__ == "__main__":
    main()
