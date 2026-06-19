import os
import psycopg2
from psycopg2.extras import RealDictCursor
from contextlib import contextmanager
from dotenv import load_dotenv

# Cargar variables de entorno desde .env si existe
load_dotenv()

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": int(os.getenv("DB_PORT", "5432")),
    "user": os.getenv("DB_USER", "postgres"),
    "password": os.getenv("DB_PASSWORD", "040922"),
    "database": os.getenv("DB_DATABASE", "rhythm_site")
}

@contextmanager
def get_db():
    conn = psycopg2.connect(**DB_CONFIG, cursor_factory=RealDictCursor)
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()

def parse_pg_error(e: Exception) -> str:
    """Extrae el mensaje limpio de un error de psycopg2."""
    if hasattr(e, "diag") and e.diag.message_primary:
        return e.diag.message_primary
    msg = str(e).split("\n")[0]
    if msg.startswith("ERROR:  "):
        msg = msg[8:]
    return msg
