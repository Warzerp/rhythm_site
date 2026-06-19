from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from database import get_db, parse_pg_error
import psycopg2

router = APIRouter(tags=["Ordenes"])


class CompraRequest(BaseModel):
    usuario_id: int
    ticket_id: int
    cantidad: int


@router.post("/comprar")
def comprar_tickets(data: CompraRequest):
    with get_db() as conn:
        with conn.cursor() as cur:
            try:
                cur.execute(
                    "CALL sp_comprar_tickets(%s, %s, %s)",
                    (data.usuario_id, data.ticket_id, data.cantidad),
                )
                return {"message": "Compra realizada exitosamente"}
            except psycopg2.Error as e:
                raise HTTPException(status_code=400, detail=parse_pg_error(e))


@router.get("/historial/{usuario_id}")
def historial_compras(usuario_id: int):
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT * FROM vw_historial_compras_usuario
                WHERE usuario_id = %s
                ORDER BY fecha_compra DESC
                """,
                (usuario_id,),
            )
            return [dict(row) for row in cur.fetchall()]
