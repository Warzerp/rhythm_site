from fastapi import APIRouter, HTTPException
from database import get_db

router = APIRouter(prefix="/eventos", tags=["Eventos"])


@router.get("/")
def listar_eventos():
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT * FROM vw_eventos_detallados
                WHERE es_publico = TRUE
                ORDER BY fecha_inicio DESC
            """)
            return [dict(row) for row in cur.fetchall()]


@router.get("/{evento_id}")
def obtener_evento(evento_id: int):
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT * FROM vw_eventos_detallados WHERE evento_id = %s",
                (evento_id,),
            )
            evento = cur.fetchone()
            if not evento:
                raise HTTPException(status_code=404, detail="Evento no encontrado")

            cur.execute(
                """
                SELECT a.id, a.nombre_artistico
                FROM evento_artistas ea
                JOIN artistas a ON ea.artista_id = a.id
                WHERE ea.evento_id = %s
                """,
                (evento_id,),
            )
            artistas = [dict(a) for a in cur.fetchall()]

            result = dict(evento)
            result["artistas"] = artistas
            return result
