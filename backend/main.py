import os
import logging
from fastapi import FastAPI, Request, Response, status
from fastapi.middleware.cors import CORSMiddleware
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from database import get_db

logger = logging.getLogger(__name__)

# ─── Rate Limiter ─────────────────────────────────────────────────────────────
# Limita peticiones por IP. Los límites específicos se aplican en cada endpoint.
limiter = Limiter(key_func=get_remote_address, default_limits=["200/minute"])
# ─────────────────────────────────────────────────────────────────────────────

app = FastAPI(
    title="Rhythm Site API",
    description="API para la plataforma de eventos musicales Rhythm Site",
    version="1.0.0",
    # Desactiva docs en producción cambiando a None
    docs_url="/docs",
    redoc_url="/redoc",
)

# Registrar el limiter y su manejador de errores
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# ─── CORS: Restringir orígenes permitidos ────────────────────────────────────
# En producción, define ALLOWED_ORIGINS en .env, p.ej.:
# ALLOWED_ORIGINS=https://tudominio.com,https://www.tudominio.com
_raw_origins = os.getenv("ALLOWED_ORIGINS", "http://localhost,http://127.0.0.1")
ALLOWED_ORIGINS = [o.strip() for o in _raw_origins.split(",") if o.strip()]

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,   # ← solo orígenes explícitos, nunca "*"
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["Content-Type", "Authorization"],
)
# ─────────────────────────────────────────────────────────────────────────────

from routers import eventos, usuarios, tickets, ordenes

app.include_router(eventos.router, prefix="/api")
app.include_router(usuarios.router, prefix="/api")
app.include_router(tickets.router, prefix="/api")
app.include_router(ordenes.router, prefix="/api")


@app.get("/", tags=["Root"])
def root():
    return {"app": "Rhythm Site API", "version": "1.0.0", "docs": "/docs"}


@app.get("/health", tags=["Health"])
def health_check(response: Response):
    health = {
        "status": "healthy",
        "services": {
            "backend": "ok",
            "database": "disconnected"
        }
    }
    try:
        with get_db() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT 1;")
                cur.fetchone()
        health["services"]["database"] = "ok"
    except Exception as e:
        # ─── Seguridad: loggear internamente, nunca exponer detalles al cliente
        logger.error("Database health check failed: %s", e)
        health["status"] = "unhealthy"
        health["services"]["database"] = "unavailable"   # mensaje genérico
        response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE
    return health
