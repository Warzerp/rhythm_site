# 📋 CHANGELOG — Rhythm Site
> Registro cronológico de todos los cambios realizados al proyecto.
> Formato: `[TIPO] Descripción breve — Archivo(s)`

---

## [v0.5.0] — 2026-06-20 · Seguridad a Nivel de Base de Datos

### 🗄️ DB-01 — Restricciones de Integridad (CHECK + UNIQUE)

| Constraint | Tabla | Regla |
|---|---|---|
| `chk_usuarios_contrasena_hasheada` | `usuarios` | `LENGTH(contrasena) >= 60` — **impide texto plano en BD** |
| `chk_usuarios_nick_formato` | `usuarios` | `nick` solo acepta `[a-zA-Z0-9_.-]` (3-50 chars) |
| `chk_ticket_precio_positivo` | `ticket` | `precio >= 0` |
| `chk_ticket_cantidad_no_negativa` | `ticket` | `cantidad >= 0` |
| `chk_ordenes_cantidad_positiva` | `ordenes` | `cantidad >= 1` |
| `chk_ordenes_estado_pago_valido` | `ordenes` | solo `pagado/pendiente/rechazado/reembolsado` |
| `chk_eventos_estado_valido` | `eventos` | solo `activo/cancelado/finalizado/borrador` |
| `uq_usuarios_nick` | `usuarios` | nick único en toda la tabla |
| `uq_ticket_tipo_evento` | `ticket` | un tipo de ticket por evento |

### 🗄️ DB-02 — Seguridad a Nivel de Columna

- `rol_usuario` y `rol_organizador` pierden `SELECT` sobre `contrasena` y `activo` directamente en la tabla `usuarios`
- La columna `contrasena` solo es accesible a través de `fn_verificar_credenciales` (SECURITY DEFINER)

### 🗄️ DB-03 — Row Level Security (RLS)

- **`ordenes`**: `ENABLE ROW LEVEL SECURITY` + `FORCE`
  - `rls_ordenes_select` — un usuario ve solo sus propias órdenes
  - `rls_ordenes_insert` — solo puede insertar órdenes a su propio nombre
  - `rls_ordenes_delete` — solo puede borrar sus propias órdenes
  - `rls_ordenes_admin` y `rls_ordenes_organizador` — acceso total para roles con más permisos

- **`usuarios`**: `ENABLE ROW LEVEL SECURITY` + `FORCE`
  - `rls_usuarios_select` — lectura libre (campos sensibles ya protegidos por columna)
  - `rls_usuarios_update` — solo puede actualizar su propia fila (`nick = current_user`)
  - `rls_usuarios_admin` — acceso total para `rol_admin`

### 🗄️ DB-04 — Rastreo de Intentos de Login

- **[ADD] Tabla `login_intentos`** — registra `nick`, `ip_origen`, `exitoso`, `fecha_intento`, `detalles`
- **[ADD] `fn_registrar_intento_login(nick, ip, exitoso, detalles)`** — `SECURITY DEFINER`, inserta el registro de auditoría
- **[ADD] `fn_intentos_fallidos_recientes(nick, minutos)`** — consulta cuántos fallos hubo en los últimos N minutos
- Integrado en `backend/routers/usuarios.py`: el login registra el resultado en BD con la IP real del cliente

### 🗄️ DB-05 — Funciones SECURITY DEFINER

- **[ADD] `fn_verificar_credenciales(nick, ip)`** — devuelve datos + hash de forma controlada; revocada de `PUBLIC`, solo accesible a `rol_usuario` y `rol_admin`
- El patrón `SECURITY DEFINER` ejecuta la función con los permisos del propietario, no del invocador, evitando escalación de privilegios

### 🗄️ DB-06 — Configuración de Seguridad de BD

- `idle_in_transaction_session_timeout = 30min` — cierra sesiones inactivas
- `REVOKE EXECUTE ON FUNCTION pg_read_file / pg_ls_dir FROM PUBLIC` — impide lectura del sistema de archivos
- Tablas de auditoría (`auditoria_*`) con `REVOKE ALL FROM PUBLIC` — solo `rol_admin` las puede leer

### 🗄️ DB-07 — Índices de Seguridad y Rendimiento

- `idx_usuarios_nick_activo` — índice **parcial** (`WHERE activo = TRUE`), acelera login y es más pequeño
- `idx_login_intentos_nick` — para detectar rápido ataques de fuerza bruta por nick
- `idx_auditoria_*_fecha` — para consultas cronológicas de auditoría

### 🗄️ DB-08 — Vista Segura de Auditoría

- **[ADD] `vw_auditoria_mis_eventos`** — los organizadores pueden ver auditoría solo de sus propios eventos; admin tiene acceso completo

### 📄 Archivos modificados en v0.5.0

| Archivo | Cambio |
|---------|--------|
| `scripts/ddl/13_seguridad_bd.sql` | **Nuevo** — todo el script de seguridad avanzada (280 líneas) |
| `scripts/pipelines/01-create-database/01-sql-ddl-script-auto.py` | Agrega `13_seguridad_bd.sql` al pipeline DDL |
| `backend/routers/usuarios.py` | Login registra intentos en BD con `fn_registrar_intento_login` |
| `backend/.env.example` | Agrega sección JWT (`JWT_SECRET_KEY`, `JWT_EXPIRE_MINUTES`) |

---

## [v0.4.0] — 2026-06-20 · Seguridad Avanzada: Hashing, JWT y Rate Limiting

### 🔐 SEC-01 — Contraseñas hasheadas con bcrypt

- **[ADD] Módulo `auth_utils.py`** — `backend/auth_utils.py` *(nuevo)*
  - `hash_password(plain)` — genera hash bcrypt usando passlib.
  - `verify_password(plain, hashed)` — compara texto plano con hash.
  - `create_access_token(data)` — genera JWT firmado HS256 con expiración configurable.
  - `decode_token(token)` — valida el JWT y lanza 401 si es inválido o expirado.
  - `get_current_user(token)` — dependencia FastAPI inyectable en cualquier ruta protegida.

- **[FIX] Registro** — `backend/routers/usuarios.py`
  - La contraseña ahora se hashea con `hash_password()` **antes** de llamar al stored procedure.
  - El hash bcrypt (no el texto plano) es lo que llega a la base de datos.

- **[FIX] Login** — `backend/routers/usuarios.py`
  - Ya no compara contraseñas en la query SQL (`WHERE contrasena = %s`).
  - Ahora: busca el usuario por nick → extrae el hash → `verify_password()` en Python.
  - Devuelve un JWT (`access_token`) en lugar de solo los datos del usuario.

- **[FIX] Actualización de perfil** — `backend/routers/usuarios.py`
  - La nueva contraseña también se rehashea antes de enviarse al SP.

### 🔐 SEC-02 — Autenticación JWT + protección IDOR

- **[FIX] PUT/DELETE /usuarios/{id}** — `backend/routers/usuarios.py`
  - Ahora requieren `Authorization: Bearer <token>`.
  - Verifican que el ID del token coincida con el recurso → **elimina IDOR**.

- **[FIX] POST /ordenes/comprar** — `backend/routers/ordenes.py`
  - Requiere JWT. El `usuario_id` ya **no se acepta del body** — se extrae del token.
  - Elimina la posibilidad de comprar con el ID de otra persona.

- **[FIX] GET /ordenes/historial/{id}** — `backend/routers/ordenes.py`
  - Requiere JWT y verifica que el `usuario_id` del token coincida con el de la URL.

- **[FIX] authFetch() en frontend** — `frontend/js/api.js`
  - Nueva función `authFetch(url, options)` que inyecta automáticamente el header `Authorization: Bearer <token>`.
  - Si el backend responde 401, limpia la sesión y redirige al login.

- **[FIX] Guardar token en login** — `frontend/js/auth.js`
  - Al hacer login exitoso, `Session.setToken(data.access_token)` guarda el JWT.

- **[FIX] Compra y Historial usan authFetch** — `frontend/js/evento.js`, `perfil.js`
  - Migradas a `authFetch()` para enviar el token automáticamente.

### 🔐 SEC-03 — Rate Limiting anti DDoS / Fuerza Bruta

- **[ADD] slowapi integrado** — `backend/main.py`
  - `Limiter(key_func=get_remote_address, default_limits=["200/minute"])` — límite global por IP.
  - El manejador de errores devuelve HTTP 429 con mensaje claro.

- **[ADD] Límite estricto en login** — `backend/routers/usuarios.py`
  - `@limiter.limit("10/minute")` — máximo 10 intentos de login por minuto por IP.
  - Protege contra ataques de fuerza bruta.

### 📦 Dependencias

- **[ADD] Nuevas dependencias** — `backend/requirements.txt`
  - `passlib[bcrypt]>=1.7.4` — hashing de contraseñas
  - `bcrypt==4.2.1` — fijado para compatibilidad con passlib 1.7.4
  - `python-jose[cryptography]>=3.5.0` — JWT
  - `slowapi>=0.1.10` — rate limiting
  - `python-dotenv>=1.2.0` — carga de variables de entorno

- **[ADD] JWT_SECRET_KEY al `.env`** — `backend/.env`
  - Clave secreta generada criptográficamente con `secrets.token_hex(32)`.
  - `JWT_EXPIRE_MINUTES=60` — tokens expiran en 1 hora.

### 📄 Archivos modificados en v0.4.0

| Archivo | Cambio |
|---------|--------|
| `backend/auth_utils.py` | **Nuevo** — hash bcrypt + JWT + dependencia `get_current_user` |
| `backend/main.py` | Integración de slowapi rate limiter global (200 req/min) |
| `backend/routers/usuarios.py` | Hashing en registro/actualización; JWT en login; protección IDOR en PUT/DELETE |
| `backend/routers/ordenes.py` | JWT requerido; usuario_id extraído del token (no del body) |
| `backend/requirements.txt` | Nuevas dependencias de seguridad |
| `backend/.env` | JWT_SECRET_KEY + JWT_EXPIRE_MINUTES añadidos |
| `frontend/js/api.js` | `Session` con soporte JWT; nueva función `authFetch()` |
| `frontend/js/auth.js` | Guarda `access_token` al hacer login |
| `frontend/js/evento.js` | Compra usa `authFetch` (sin usuario_id en body) |
| `frontend/js/perfil.js` | Historial usa `authFetch` |

---

## [v0.3.0] — 2026-06-20 · Auditoría de Seguridad

### 🔐 Seguridad — Backend

- **[FIX] Credencial hardcodeada eliminada** — `backend/database.py`
  - Se removió el valor por defecto `"040922"` de `DB_PASSWORD`.
  - Se añadió validación al arranque: si `DB_PASSWORD` no está definida en el entorno, el servidor lanza `RuntimeError` inmediatamente.
  - La contraseña ahora vive únicamente en `.env` (excluido por `.gitignore`).

- **[FIX] CORS wildcard reemplazado** — `backend/main.py`
  - `allow_origins=["*"]` → `allow_origins=ALLOWED_ORIGINS` (cargado desde variable de entorno `ALLOWED_ORIGINS`).
  - Por defecto: `http://localhost,http://127.0.0.1` para desarrollo local.
  - Métodos y headers explícitamente restringidos (ya no `"*"`).

- **[FIX] Health check no filtra errores internos** — `backend/main.py`
  - El error de conexión a la BD ya no se expone al cliente.
  - Ahora se loggea internamente con `logger.error(...)` y el cliente recibe solo `"unavailable"`.

- **[NEW] Archivo `.env` creado** — `backend/.env` *(no versionado)*
  - Contiene `DB_PASSWORD`, `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_DATABASE`, `ALLOWED_ORIGINS`.

- **[NEW] Plantilla `.env.example` creada** — `backend/.env.example`
  - Referencia documentada de todas las variables de entorno necesarias.

### 🔐 Seguridad — Frontend

- **[FIX] XSS (Cross-Site Scripting) corregido en todos los archivos JS** — `frontend/js/api.js`, `home.js`, `evento.js`, `perfil.js`
  - Se añadió la función utilitaria global `escapeHTML(str)` en `api.js`.
  - Todos los campos de la API que se insertan vía `innerHTML` ahora pasan por `escapeHTML()`.
  - Campos numéricos en `onclick` de botones de tickets ahora usan `parseInt()` para prevenir inyección en atributos.
  - URLs con IDs de evento ahora usan `encodeURIComponent()`.

### 📄 Archivos modificados en v0.3.0

| Archivo | Cambio |
|---------|--------|
| `backend/database.py` | Credencial hardcodeada → validación de entorno |
| `backend/main.py` | CORS wildcard → orígenes explícitos; health check seguro |
| `backend/.env` | **Nuevo** — credenciales locales (no versionado) |
| `backend/.env.example` | **Nuevo** — plantilla de variables de entorno |
| `frontend/js/api.js` | **Nuevo** — función `escapeHTML()` global anti-XSS |
| `frontend/js/home.js` | Sanitizado XSS en renderizado de tarjetas de eventos |
| `frontend/js/evento.js` | Sanitizado XSS en detalle de evento, artistas y tickets |
| `frontend/js/perfil.js` | Sanitizado XSS en historial de compras |

### ⚠️ Vulnerabilidades documentadas pendientes de implementar

| ID | Riesgo | Descripción | Requiere |
|----|--------|-------------|---------|
| SEC-01 | 🔴 Alto | Contraseñas almacenadas en texto plano | `bcrypt`/`passlib` en SP y login |
| SEC-02 | 🔴 Alto | Sin autenticación JWT (IDOR posible) | `python-jose`, middleware de auth |
| SEC-03 | 🟡 Medio | Sin Rate Limiting (brute force en login) | Librería `slowapi` |

---

## [v0.2.0] — 2026-06-19 · Integración Completa Backend + BD

### 🛠️ Backend — Completar CRUD

- **[FIX] Router de Órdenes sin prefijo de URL** — `backend/routers/ordenes.py`
  - `APIRouter(tags=["Ordenes"])` → `APIRouter(prefix="/ordenes", tags=["Ordenes"])`
  - Sin el prefijo, los endpoints colisionaban con la raíz `/api/`.

- **[ADD] CRUD completo de Usuarios** — `backend/routers/usuarios.py`
  - `GET /api/usuarios/{id}` — consulta `vw_usuarios_publicos`
  - `PUT /api/usuarios/{id}` — llama `CALL sp_actualizar_usuario(...)`
  - `DELETE /api/usuarios/{id}` — soft-delete via `CALL sp_eliminar_usuario(...)`

- **[ADD] CRUD completo de Eventos** — `backend/routers/eventos.py`
  - `POST /api/eventos/` — llama `CALL sp_crear_evento(...)`
  - `PUT /api/eventos/{id}` — llama `CALL sp_actualizar_evento(...)`
  - `DELETE /api/eventos/{id}` — llama `CALL sp_eliminar_evento(...)`
  - `GET /api/eventos/{id}/resumen` — **nuevo endpoint** que expone `mv_resumen_ventas_evento`

- **[ADD] CRUD completo de Tickets** — `backend/routers/tickets.py`
  - `POST /api/tickets/` — llama `CALL sp_crear_ticket(...)`
  - `PUT /api/tickets/{id}` — llama `CALL sp_actualizar_ticket(...)`
  - `DELETE /api/tickets/{id}` — llama `CALL sp_eliminar_ticket(...)`

### 🗄️ Base de Datos — Completar Seguridad

- **[FIX] Falta GRANT en vista materializada** — `scripts/ddl/12_roles_permisos.sql`
  - `mv_resumen_ventas_evento` no tenía permisos explícitos para `rol_organizador`.
  - Agregado: `GRANT SELECT ON public.mv_resumen_ventas_evento TO rol_organizador;`

- **[ADD] Usuarios de login de BD creados** — `scripts/ddl/12_roles_permisos.sql`
  - Roles existían pero sin usuarios con `LOGIN` asignados (inutilizables en práctica).
  - Creados: `app_usuario`, `app_organizador`, `app_admin` con contraseñas y `GRANT` a sus roles.

### 🌐 Frontend — Actualización de URLs

- **[FIX] URL de compra incorrecta** — `frontend/js/evento.js`
  - `/api/comprar` → `/api/ordenes/comprar`

- **[FIX] URL de historial incorrecta** — `frontend/js/perfil.js`
  - `/api/historial/{id}` → `/api/ordenes/historial/{id}`

### 📄 Archivos modificados en v0.2.0

| Archivo | Cambio |
|---------|--------|
| `backend/routers/ordenes.py` | Agregado `prefix="/ordenes"` |
| `backend/routers/usuarios.py` | Agregados `GET`, `PUT`, `DELETE` |
| `backend/routers/eventos.py` | Agregados `POST`, `PUT`, `DELETE`, `GET resumen` |
| `backend/routers/tickets.py` | Agregados `POST`, `PUT`, `DELETE` |
| `scripts/ddl/12_roles_permisos.sql` | GRANT vista materializada + usuarios login |
| `frontend/js/evento.js` | URL `/comprar` → `/ordenes/comprar` |
| `frontend/js/perfil.js` | URL `/historial/` → `/ordenes/historial/` |

---

## [v0.1.0] — 2026-06-16 · Sincronización con Backup pgAdmin

### 🗄️ Base de Datos — DDL y Scripts de Datos

- **[SYNC] Scripts DDL alineados con backup de producción** — `scripts/ddl/`
  - Verificación y corrección de todos los scripts 01–12 contra el backup de pgAdmin.
  - Asegurado el orden de dependencias entre tablas.

- **[SYNC] Scripts DML verificados** — `scripts/data/`
  - 29 archivos de inserción de datos validados.
  - Orden correcto entre `20_venues` y `21_direcciones_venues` confirmado (FK: `venues.direcciones_id → direcciones_venues.id`).

### 🔧 Pipeline de Instalación

- **[FIX] Pipeline DDL incluye todos los 12 scripts** — `scripts/pipelines/01-ddl/`
  - Soporte para bloques `$$` en PL/pgSQL.
  - Reconexión automática entre base `postgres` y `rhythm_site`.

- **[DOCS] Documentación de instalación** — `TUTORIAL INSTALAR BD.docx`
  - Guía paso a paso para instalar la BD desde cero.

---

## [v0.0.1] — 2026-06-07 · Setup inicial del repositorio

- **[INIT] Estructura de ramas** — `develop`, `qa`, `main` configuradas
- **[INIT] `.gitignore`** — Excluye binarios, `venv/`, `__pycache__/`, `.env`, `.env.*`
- **[INIT] Estructura del proyecto** — `backend/`, `frontend/`, `scripts/ddl/`, `scripts/data/`, `scripts/pipelines/`

---

## API Surface actual (v0.3.0)

```
GET    /api/eventos/                 → Lista eventos públicos
POST   /api/eventos/                 → Crear evento
GET    /api/eventos/{id}             → Detalle evento + artistas
PUT    /api/eventos/{id}             → Actualizar evento
DELETE /api/eventos/{id}             → Eliminar evento
GET    /api/eventos/{id}/resumen     → Resumen ventas (vista materializada)

GET    /api/tickets/evento/{id}      → Tickets disponibles de un evento
POST   /api/tickets/                 → Crear ticket
PUT    /api/tickets/{id}             → Actualizar ticket
DELETE /api/tickets/{id}             → Eliminar ticket

POST   /api/usuarios/registro        → Registro de nuevo usuario
POST   /api/usuarios/login           → Iniciar sesión
GET    /api/usuarios/{id}            → Ver perfil público
PUT    /api/usuarios/{id}            → Actualizar perfil
DELETE /api/usuarios/{id}            → Desactivar cuenta (soft-delete)

POST   /api/ordenes/comprar          → Comprar tickets
GET    /api/ordenes/historial/{id}   → Historial de compras del usuario

GET    /health                       → Estado del sistema
```
