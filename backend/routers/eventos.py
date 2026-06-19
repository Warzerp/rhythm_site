from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional
from datetime import date
from database import get_db, parse_pg_error
import psycopg2

router = APIRouter(prefix="/eventos", tags=["Eventos"])


class CrearEventoRequest(BaseModel):
    nombre: str
    descripcion: Optional[str] = None
    fecha_inicio: date
    fecha_fin: date
    estado: str
    es_publico: bool
    organizador_id: int
    tipo_evento_id: int
    venue_id: int
    artista_ids: Optional[List[int]] = None


class ActualizarEventoRequest(BaseModel):
    nombre: str
    descripcion: Optional[str] = None
    fecha_inicio: date
    fecha_fin: date
    estado: str
    es_publico: bool
    organizador_id: int
    tipo_evento_id: int
    venue_id: int


@router.get("/")
def listar_eventos():
    """Lista todos los eventos públicos usando la vista vw_eventos_detallados."""
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT * FROM vw_eventos_detallados
                WHERE es_publico = TRUE
                ORDER BY fecha_inicio DESC
            """)
            return [dict(row) for row in cur.fetchall()]


@router.post("/", status_code=201)
def crear_evento(data: CrearEventoRequest):
    """Crea un evento con sus artistas llamando a sp_crear_evento."""
    with get_db() as conn:
        with conn.cursor() as cur:
            try:
                cur.execute(
                    "CALL sp_crear_evento(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
                    (
                        data.nombre, data.descripcion, data.fecha_inicio, data.fecha_fin,
                        data.estado, data.es_publico, data.organizador_id,
                        data.tipo_evento_id, data.venue_id, data.artista_ids,
                    ),
                )
                return {"message": "Evento creado exitosamente"}
            except psycopg2.Error as e:
                raise HTTPException(status_code=400, detail=parse_pg_error(e))


@router.get("/{evento_id}")
def obtener_evento(evento_id: int):
    """Obtiene detalle de un evento con sus artistas asociados."""
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


@router.get("/{evento_id}/resumen")
def resumen_ventas_evento(evento_id: int):
    """Retorna el resumen de ventas de un evento desde la vista materializada mv_resumen_ventas_evento."""
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT * FROM mv_resumen_ventas_evento WHERE evento_id = %s",
                (evento_id,),
            )
            resumen = cur.fetchone()
            if not resumen:
                raise HTTPException(status_code=404, detail="Resumen de ventas no encontrado para este evento")
            return dict(resumen)


@router.put("/{evento_id}")
def actualizar_evento(evento_id: int, data: ActualizarEventoRequest):
    """Actualiza un evento existente usando sp_actualizar_evento."""
    with get_db() as conn:
        with conn.cursor() as cur:
            try:
                cur.execute(
                    "CALL sp_actualizar_evento(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
                    (
                        evento_id, data.nombre, data.descripcion, data.fecha_inicio,
                        data.fecha_fin, data.estado, data.es_publico, data.organizador_id,
                        data.tipo_evento_id, data.venue_id,
                    ),
                )
                return {"message": f"Evento {evento_id} actualizado exitosamente"}
            except psycopg2.Error as e:
                raise HTTPException(status_code=400, detail=parse_pg_error(e))


@router.delete("/{evento_id}", status_code=200)
def eliminar_evento(evento_id: int):
    """Elimina un evento (y sus artistas asociados) usando sp_eliminar_evento."""
    with get_db() as conn:
        with conn.cursor() as cur:
            try:
                cur.execute("CALL sp_eliminar_evento(%s)", (evento_id,))
                return {"message": f"Evento {evento_id} eliminado exitosamente"}
            except psycopg2.Error as e:
                raise HTTPException(status_code=400, detail=parse_pg_error(e))
