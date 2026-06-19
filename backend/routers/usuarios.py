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
