from fastapi import FastAPI, Response, status
from fastapi.middleware.cors import CORSMiddleware
from routers import eventos, usuarios, tickets, ordenes
from database import get_db

app = FastAPI(
    title="Rhythm Site API",
    description="API para la plataforma de eventos musicales Rhythm Site",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

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
        health["status"] = "unhealthy"
        health["services"]["database"] = f"error: {str(e)}"
        response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE
    return health
