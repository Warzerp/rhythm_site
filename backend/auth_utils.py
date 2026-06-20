"""
auth_utils.py — Utilidades de seguridad para Rhythm Site
Cubre:
  - Hashing de contraseñas con bcrypt (passlib)
  - Creación y verificación de JWT tokens (python-jose)
  - Dependencia FastAPI: get_current_user
"""

import os
from datetime import datetime, timedelta, timezone
from typing import Optional

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from passlib.context import CryptContext

# ─── Configuración de contraseñas ────────────────────────────────────────────
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def hash_password(plain: str) -> str:
    """Devuelve el hash bcrypt de la contraseña."""
    return pwd_context.hash(plain)


def verify_password(plain: str, hashed: str) -> bool:
    """Compara una contraseña en texto plano con su hash bcrypt."""
    return pwd_context.verify(plain, hashed)


# ─── Configuración de JWT ─────────────────────────────────────────────────────
# Genera un secreto con: python -c "import secrets; print(secrets.token_hex(32))"
# y colócalo en .env como JWT_SECRET_KEY
SECRET_KEY: str = os.getenv("JWT_SECRET_KEY", "CAMBIA_ESTE_SECRETO_EN_PRODUCCION")
ALGORITHM: str = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES: int = int(os.getenv("JWT_EXPIRE_MINUTES", "60"))

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/usuarios/login")


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """Crea un JWT firmado con el payload dado."""
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + (
        expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


def decode_token(token: str) -> dict:
    """Decodifica y valida un JWT. Lanza HTTPException 401 si es inválido."""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Token inválido o expirado",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: Optional[int] = payload.get("sub")
        if user_id is None:
            raise credentials_exception
        return payload
    except JWTError:
        raise credentials_exception


def get_current_user(token: str = Depends(oauth2_scheme)) -> dict:
    """
    Dependencia FastAPI para rutas protegidas.
    Extrae y valida el JWT del header Authorization: Bearer <token>.

    Uso en un router:
        @router.get("/protegida")
        def ruta_protegida(current_user = Depends(get_current_user)):
            return {"usuario_id": current_user["sub"]}
    """
    return decode_token(token)
