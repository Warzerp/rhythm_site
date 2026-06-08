# 🎵 Rhythm Site — Guía de Instalación de Base de Datos

## Requisitos previos

- **PostgreSQL** instalado y corriendo (psql disponible en PATH)
- **Python 3.8+** instalado
- Acceso a la consola / terminal

---

## 🔄 Reinstalación completa (si ya existe la BD)

Si necesitas borrar una instalación previa, ejecuta en `psql` como superusuario:

```sql
DROP DATABASE rhythm_site;
DROP ROLE rhythm_admin;
```

---

## 📦 Paso 1 — Preparar el entorno virtual Python

Desde la raíz del repositorio, navega a la carpeta `scripts`:

```bash
cd scripts
python -m venv venv
```

Activa el entorno virtual:

- **Windows:**
  ```bash
  venv\Scripts\activate
  ```
- **Linux / Mac:**
  ```bash
  source venv/bin/activate
  ```

Instala las dependencias necesarias:

```bash
pip install psycopg2-binary tqdm
```

---

## 🚀 Paso 2 — Crear la base de datos y cargar los datos

Desde la carpeta `scripts/`, ejecuta el script principal del pipeline DDL:

```bash
bash pipelines/01-create-database/execute_command.sh
```

Este comando ejecuta **automáticamente** en orden:

| Orden | Script | Descripción |
|-------|--------|-------------|
| 1° | `01-sql-ddl-script-auto.py` | Crea la base de datos `rhythm_site` y todas las tablas |
| 2° | `02-sql-dml-insert-auto.py` | Inserta todos los datos de prueba |

> **Nota:** El script lee los archivos SQL desde `scripts/ddl/` (tablas) y `scripts/data/` (inserts) en orden numérico automáticamente.

---

## 🔧 Parámetros del pipeline

Los scripts aceptan los siguientes parámetros por defecto:

| Parámetro | Valor por defecto |
|-----------|-------------------|
| `--user` | `postgres` |
| `--host` | `localhost` |
| `--port` | `5432` |
| `--database` | `postgres` (para crear) / `rhythm_site` (para insertar) |
| `--password` | Debes reemplazar `"*"` por tu contraseña real |

---

## 📁 Estructura de scripts

```
scripts/
├── ddl/
│   ├── 01_create_database.sql
│   ├── 02_tablas_no_gestionables.sql
│   ├── 03_tablas_contacto.sql
│   ├── 04_usuarios_artistas.sql
│   ├── 05_organizadores_venues.sql
│   ├── 06_eventos.sql
│   └── 07_tickets_ordenes.sql
├── data/
│   └── 08_inserts_datos.sql
└── pipelines/
    ├── 01-create-database/
    │   ├── 01-sql-ddl-script-auto.py
    │   └── execute_command.sh
    └── 02-insert-data/
        ├── 02-sql-dml-insert-auto.py
        └── execute_command.sh
```
