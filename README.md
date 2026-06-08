# 🎵 Rhythm Site

Plataforma web para la gestión y venta de entradas a eventos musicales en Colombia. Permite a usuarios explorar eventos, comprar tickets y a organizadores administrar sus producciones.

---

## 📋 Tabla de Contenido

- [Tecnologías](#-tecnologías)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Clonar el Repositorio](#-clonar-el-repositorio)
- [Instalar la Base de Datos](#-instalar-la-base-de-datos)
- [Reinstalación Completa](#-reinstalación-completa)
- [Estrategia de Ramas](#-estrategia-de-ramas)

---

## 🛠 Tecnologías

| Capa | Tecnología |
|------|-----------|
| Base de datos | PostgreSQL |
| Scripts de migración | Python 3.8+ (`psycopg2-binary`, `tqdm`) |
| Control de versiones | Git / GitHub |

---

## 📁 Estructura del Proyecto

```
rhythm_site/
├── scripts/
│   ├── ddl/                          # Creación de tablas (ejecutar en orden)
│   │   ├── 01_create_database.sql
│   │   ├── 02_tablas_no_gestionables.sql
│   │   ├── 03_tablas_contacto.sql
│   │   ├── 04_usuarios_artistas.sql
│   │   ├── 05_organizadores_venues.sql
│   │   ├── 06_eventos.sql
│   │   └── 07_tickets_ordenes.sql
│   ├── data/                         # Datos de prueba
│   │   └── 08_inserts_datos.sql
│   └── pipelines/                    # Automatización de despliegue
│       ├── 01-create-database/
│       │   ├── 01-sql-ddl-script-auto.py
│       │   └── execute_command.sh
│       └── 02-insert-data/
│           ├── 02-sql-dml-insert-auto.py
│           └── execute_command.sh
└── README.md
```

---

## 📥 Clonar el Repositorio

### Prerrequisitos

- [Git](https://git-scm.com/) instalado
- [Python 3.8+](https://www.python.org/) instalado
- [PostgreSQL](https://www.postgresql.org/) instalado y corriendo

### Clonar

```bash
git clone git@github.com:Warzerp/rhythm_site.git
cd rhythm_site
```

> Si no tienes configurada una clave SSH, usa HTTPS:
> ```bash
> git clone https://github.com/Warzerp/rhythm_site.git
> ```

### Cambiar a la rama de desarrollo

```bash
git checkout develop
```

---

## 🗄 Instalar la Base de Datos

### Paso 1 — Crear el entorno virtual Python

Desde la raíz del repositorio entra a la carpeta `scripts/`:

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

Instala las dependencias:

```bash
pip install psycopg2-binary tqdm
```

### Paso 2 — Ejecutar el pipeline de creación

Desde la carpeta `scripts/`, ejecuta:

```bash
bash pipelines/01-create-database/execute_command.sh
```

Este script ejecuta automáticamente y en orden:

| Orden | Acción |
|-------|--------|
| 1° | Crea la base de datos `rhythm_site` y todas las tablas (DDL) |
| 2° | Inserta todos los datos de prueba (DML) |

> **Parámetros por defecto del pipeline:**
> - Host: `localhost`
> - Puerto: `5432`
> - Usuario: `postgres`
> - Contraseña: reemplaza `"*"` en el `.sh` por tu contraseña real de PostgreSQL

---

## 🔄 Reinstalación Completa

Si necesitas borrar la base de datos y empezar desde cero, ejecuta en `psql` como superusuario:

```sql
DROP DATABASE rhythm_site;
DROP ROLE rhythm_admin;
```

Luego vuelve al **Paso 2** del apartado anterior.

---

## 🌿 Estrategia de Ramas

El flujo de trabajo sigue el modelo **GitFlow simplificado**:

```
feature/Jhon_M  ──┐
feature/xxx     ──┤──► develop ──► qa ──► main
feature/yyy     ──┘
```

| Rama | Propósito |
|------|-----------|
| `main` | Producción — protegida, requiere Pull Request aprobado |
| `qa` | Control de calidad y pruebas de integración |
| `develop` | Integración continua del equipo |
| `feature/*` | Desarrollo individual por funcionalidad o miembro |

> ⚠️ **`main` está protegida.** No se permite `push` directo. Todo cambio debe pasar por Pull Request y ser aprobado por el dueño del repositorio.