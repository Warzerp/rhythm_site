from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from datetime import date
from database import get_db, parse_pg_error
import psycopg2

router = APIRouter(prefix="/usuarios", tags=["Usuarios"])


class RegistroRequest(BaseModel):
    nombre: str
    apellido: str
    nick: str
    contrasena: str
    fecha_nacimiento: date
    correo: str
    telefono: str


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


@router.post("/registro", status_code=201)
def registrar_usuario(data: RegistroRequest):
    with get_db() as conn:
        with conn.cursor() as cur:
            try:
                cur.execute(
                    "CALL sp_crear_usuario(%s, %s, %s, %s, %s, 1, %s, %s)",
                    (
                        data.nombre, data.apellido, data.nick, data.contrasena,
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
def login(data: LoginRequest):
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT id, nick, nombre, apellido
                FROM usuarios
                WHERE nick = %s AND contrasena = %s AND activo = TRUE
                """,
                (data.nick, data.contrasena),
            )
            user = cur.fetchone()
            if not user:
                raise HTTPException(status_code=401, detail="Nick o contraseña incorrectos")
            return {"message": "Login exitoso", "usuario": dict(user)}


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
def actualizar_usuario(usuario_id: int, data: ActualizarRequest):
    """Actualiza los datos de un usuario llamando a sp_actualizar_usuario."""
    with get_db() as conn:
        with conn.cursor() as cur:
            try:
                cur.execute(
                    "CALL sp_actualizar_usuario(%s, %s, %s, %s, %s, %s, %s, %s)",
                    (
                        usuario_id, data.nombre, data.apellido, data.nick,
                        data.contrasena, data.fecha_nacimiento, data.correo, data.telefono,
                    ),
                )
                return {"message": "Usuario actualizado exitosamente"}
            except psycopg2.Error as e:
                raise HTTPException(status_code=400, detail=parse_pg_error(e))


@router.delete("/{usuario_id}", status_code=200)
def eliminar_usuario(usuario_id: int):
    """Realiza un soft-delete del usuario (activo = FALSE) usando sp_eliminar_usuario."""
    with get_db() as conn:
        with conn.cursor() as cur:
            try:
                cur.execute("CALL sp_eliminar_usuario(%s)", (usuario_id,))
                return {"message": f"Usuario {usuario_id} desactivado exitosamente"}
            except psycopg2.Error as e:
                raise HTTPException(status_code=400, detail=parse_pg_error(e))
