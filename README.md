# 🎵 Rhythm Site

Plataforma web para la gestión y venta de entradas a eventos musicales en Colombia. Permite a usuarios explorar eventos, comprar tickets y a organizadores administrar sus producciones.

---

## 📋 Tabla de Contenido

- [Tecnologías](#-tecnologías)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Clonar el Repositorio](#-clonar-el-repositorio)
- [Instalar la Base de Datos (Paso a Paso Exacto)](#-instalar-la-base-de-datos-paso-a-paso-exacto)
- [Ejecutar el Servidor Backend (FastAPI + Uvicorn)](#-ejecutar-el-servidor-backend-fastapi--uvicorn)
- [Ejecutar el Frontend](#-ejecutar-el-frontend)
- [Reinstalación Completa](#-reinstalación-completa)

---

## 🛠 Tecnologías

| Capa | Tecnología |
|------|-----------|
| Base de datos | PostgreSQL |
| Backend | FastAPI (Python 3.14 / 3.8+) |
| Frontend | HTML5 + CSS3 (Vanilla) + JavaScript (ES6) |
| Servidor Web | Uvicorn |

---

## 📁 Estructura del Proyecto

```
pruebas__sub/
├── requirements.txt                  # Librerías de todo el proyecto (FastAPI, psycopg2, etc.)
├── rhythm_site/                      # Carpeta principal de la base de datos
│   ├── scripts/
│   │   ├── ddl/                      # Estructura de base de datos (01 a 12)
│   │   ├── data/                     # Datos de prueba (01 a 25)
│   │   └── pipelines/                # Scripts automatizados de instalación
│   └── README.md                     # Este archivo
├── backend/                          # API REST en FastAPI
│   ├── main.py                       # Servidor de entrada
│   ├── database.py                   # Conexión psycopg2 a la BD
│   └── routers/                      # Módulos de endpoints (eventos, usuarios, etc.)
└── frontend/                         # Aplicación Web cliente (Estética premium oscura)
    ├── index.html                    # Inicio (Próximos eventos)
    ├── auth.html                     # Login y registro de usuarios
    ├── evento.html                   # Detalle del evento y compra de entradas
    ├── perfil.html                   # Historial del cliente (Consumido de vistas de la BD)
    ├── css/style.css                 # Diseño responsivo y glassmorphism
    └── js/                           # Lógica del cliente
```

---

## 📥 Clonar el Repositorio

### Prerrequisitos

- [Git](https://git-scm.com/) instalado
- [Python 3.8+](https://www.python.org/) instalado
- [PostgreSQL](https://www.postgresql.org/) instalado y corriendo en el puerto `5432` con usuario `postgres` y contraseña (por ejemplo, `040922` u otra).

### Clonar

```bash
git clone https://github.com/Warzerp/rhythm_site.git
cd rhythm_site
```

---

## 🗄 Instalar la Base de Datos (Paso a Paso Exacto)

Sigue estos comandos de terminal de forma secuencial y exacta:

### 1. Abre tu terminal de comandos en la carpeta `scripts/`
Si estás en la raíz del repositorio (`rhythm_site`), muévete a la carpeta `scripts`:
```powershell
cd scripts
```

### 2. Crea el entorno virtual de Python (`venv`)
Ejecuta el comando para crear el entorno virtual en esta ubicación:
```powershell
python -m venv venv
```

### 3. Activa el entorno virtual (`venv`)
 ejecuta:
*   **En Windows (Símbolo del sistema / cmd):**
    ```cmd
    venv\Scripts\activate
    


Una vez activo, verás `(venv)` al inicio de la línea de tu terminal.

### 4. Instalar las dependencias necesarias
Instala las librerías necesarias del proyecto especificando la ruta al archivo `requirements.txt` ubicado en la raíz del espacio de trabajo:
```cmd
pip install -r ..\..\requirements.txt
```

### 5. Ejecutar la creación de la base de datos (DDL)
Ejecuta el script de automatización DDL de Python. **Reemplaza `"*"` por tu contraseña real de PostgreSQL**:
```powershell
python .\pipelines\01-create-database\01-sql-ddl-script-auto.py --sql-dir .\ddl --user postgres --password "*" --host localhost --port 5432
```

### 6. Ejecutar la inserción de datos de prueba (DML)
Ejecuta el script de inserción de datos de Python. **Reemplaza `"*"` por tu contraseña real de PostgreSQL**:
```powershell
python .\pipelines\02-insert-data\02-sql-dml-insert-auto.py --data-dir .\data --user postgres --password "*" --host localhost --port 5432
```

---

## 🚀 Ejecutar el Servidor Backend (FastAPI + Uvicorn)

Una vez que la base de datos esté lista, inicia el servidor de la API:

### 1. Muévete a la carpeta del backend
Desde la misma terminal donde tienes el entorno virtual `(venv)` activado en la carpeta `scripts/`, sube de nivel y entra en `backend`:
```powershell
cd ../../backend
```

### 2. Inicia el servidor de Uvicorn
Ejecuta el comando para iniciar el servidor de desarrollo local:
```powershell
python -m uvicorn main:app --host 127.0.0.1 --port 8000 --reload
```

El backend estará disponible en `http://127.0.0.1:8000` y su documentación interactiva en `http://127.0.0.1:8000/docs`.

---

## 💻 Ejecutar el Frontend

Para evitar restricciones de CORS del navegador al abrir archivos HTML locales directos, sirve el frontend a través de un servidor web local simple:

### 1. Abre una nueva terminal en la carpeta `frontend/`
Muévete a la carpeta `frontend` del proyecto:
```cmd
cd pruebas__sub/frontend
```

### 2. Inicia el servidor de prueba de Python
Ejecuta un servidor web integrado en el puerto `8080`:
```powershell
python -m http.server 8080 --bind 127.0.0.1
```

### 3. Abre la aplicación en tu navegador
Ingresa a la siguiente dirección en tu navegador:
👉 **[http://127.0.0.1:8080/index.html](http://127.0.0.1:8080/index.html)**

Desde ahí podrás registrarte, iniciar sesión, ver la cartelera de eventos, comprar tickets con control de stock y ver tu historial.

---

## 🔄 Reinstalación Completa

Si necesitas limpiar la base de datos y recrear todo el esquema desde cero, ejecuta en `psql` (o pgAdmin) como superusuario `postgres`:

```sql
DROP DATABASE IF EXISTS rhythm_site;
DROP ROLE IF EXISTS rol_usuario;
DROP ROLE IF EXISTS rol_organizador;
DROP ROLE IF EXISTS rol_admin;
```

Luego repite los **pasos 5 y 6** de la sección [Instalar la Base de Datos](#-instalar-la-base-de-datos-paso-a-paso-exacto).
