from fastapi import APIRouter, HTTPException, Depends, Request
from pydantic import BaseModel, field_validator
from datetime import date
from database import get_db, parse_pg_error
from auth_utils import hash_password, verify_password, create_access_token, get_current_user
from main import limiter
import psycopg2
import re

router = APIRouter(prefix="/usuarios", tags=["Usuarios"])


# ─── Modelos ──────────────────────────────────────────────────────────────────

class RegistroRequest(BaseModel):
    nombre: str
    apellido: str
    nick: str
    contrasena: str
    fecha_nacimiento: date
    correo: str
    telefono: str

    @field_validator("contrasena")
    @classmethod
    def contrasena_segura(cls, v: str) -> str:
        """Mínimo 6 caracteres."""
        if len(v) < 6:
            raise ValueError("La contraseña debe tener al menos 6 caracteres")
        return v

    @field_validator("correo")
    @classmethod
    def correo_valido(cls, v: str) -> str:
        if not re.match(r"^[^@\s]+@[^@\s]+\.[^@\s]+$", v):
            raise ValueError("Correo electrónico inválido")
        return v


class ActualizarRequest(BaseModel):
    nombre: str
    apellido: str
    nick: str
    contrasena: str
    fecha_nacimiento: date
    correo: str
    telefono: str


class LoginRequest(BaseModel):
    nick: str
    contrasena: str


# ─── Endpoints ────────────────────────────────────────────────────────────────

@router.post("/registro", status_code=201)
def registrar_usuario(data: RegistroRequest):
    """Registra un nuevo usuario. La contraseña se almacena hasheada con bcrypt."""
    hashed = hash_password(data.contrasena)   # ← nunca se guarda en texto plano

    with get_db() as conn:
        with conn.cursor() as cur:
            try:
                cur.execute(
                    "CALL sp_crear_usuario(%s, %s, %s, %s, %s, 1, %s, %s)",
                    (
                        data.nombre, data.apellido, data.nick, hashed,
                        data.fecha_nacimiento, data.correo, data.telefono,
                    ),
                )
                cur.execute(
                    "SELECT id, nick, nombre, apellido FROM usuarios WHERE nick = %s",
                    (data.nick,),
                )
                user = cur.fetchone()
                return {"message": "Usuario registrado exitosamente", "usuario": dict(user)}
            except psycopg2.Error as e:
                raise HTTPException(status_code=400, detail=parse_pg_error(e))


@router.post("/login")
@limiter.limit("10/minute")   # ← máximo 10 intentos por minuto por IP
def login(data: LoginRequest, request: Request):
    """
    Autentica al usuario y devuelve un JWT.
    Registra cada intento en login_intentos para auditoría en BD.
    Authorization: Bearer <token>
    """
    ip_origen = request.client.host if request.client else "0.0.0.0"

    with get_db() as conn:
        with conn.cursor() as cur:
            # 1. Buscar por nick
            cur.execute(
                """
                SELECT id, nick, nombre, apellido, contrasena
                FROM usuarios
                WHERE nick = %s AND activo = TRUE
                """,
                (data.nick,),
            )
            user = cur.fetchone()

            # 2. Verificar contraseña (timing-safe — separado de la query)
            es_valido = user is not None and verify_password(data.contrasena, user["contrasena"])

            # 3. Registrar el intento en la BD (independientemente del resultado)
            try:
                motivo = "login exitoso" if es_valido else (
                    "nick no existe" if not user else "contraseña incorrecta"
                )
                cur.execute(
                    "SELECT fn_registrar_intento_login(%s, %s, %s, %s)",
                    (data.nick, ip_origen, es_valido, motivo),
                )
            except Exception:
                pass  # nunca bloquear el login por un error de auditoría

    if not es_valido:
        raise HTTPException(
            status_code=401,
            detail="Nick o contraseña incorrectos",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # 4. Emitir JWT
    token = create_access_token({"sub": user["id"], "nick": user["nick"]})
    public_user = {k: v for k, v in dict(user).items() if k != "contrasena"}
    return {
        "access_token": token,
        "token_type": "bearer",
        "usuario": public_user,
    }


@router.get("/{usuario_id}")
def obtener_usuario(usuario_id: int):
    """Obtiene la información pública de un usuario (usa vw_usuarios_publicos)."""
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT * FROM vw_usuarios_publicos WHERE id = %s",
                (usuario_id,),
            )
            user = cur.fetchone()
            if not user:
                raise HTTPException(status_code=404, detail="Usuario no encontrado o inactivo")
            return dict(user)


@router.put("/{usuario_id}")
def actualizar_usuario(
    usuario_id: int,
    data: ActualizarRequest,
    current_user: dict = Depends(get_current_user),
):
    """
    Actualiza los datos de un usuario.
    Solo el propio usuario puede actualizar su perfil (verificado por JWT).
    """
    if current_user["sub"] != usuario_id:
        raise HTTPException(
            status_code=403,
            detail="No tienes permiso para modificar este usuario",
        )

    hashed = hash_password(data.contrasena)  # rehashear al actualizar contraseña

    with get_db() as conn:
        with conn.cursor() as cur:
            try:
                cur.execute(
                    "CALL sp_actualizar_usuario(%s, %s, %s, %s, %s, %s, %s, %s)",
                    (
                        usuario_id, data.nombre, data.apellido, data.nick,
                        hashed, data.fecha_nacimiento, data.correo, data.telefono,
                    ),
                )
                return {"message": "Usuario actualizado exitosamente"}
            except psycopg2.Error as e:
                raise HTTPException(status_code=400, detail=parse_pg_error(e))


@router.delete("/{usuario_id}", status_code=200)
def eliminar_usuario(
    usuario_id: int,
    current_user: dict = Depends(get_current_user),
):
    """
    Realiza un soft-delete del usuario (activo = FALSE).
    Solo el propio usuario puede desactivar su cuenta.
    """
    if current_user["sub"] != usuario_id:
        raise HTTPException(
            status_code=403,
            detail="No tienes permiso para eliminar este usuario",
        )

    with get_db() as conn:
        with conn.cursor() as cur:
            try:
                cur.execute("CALL sp_eliminar_usuario(%s)", (usuario_id,))
                return {"message": f"Usuario {usuario_id} desactivado exitosamente"}
            except psycopg2.Error as e:
                raise HTTPException(status_code=400, detail=parse_pg_error(e))
