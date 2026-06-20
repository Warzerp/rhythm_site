from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from database import get_db, parse_pg_error
from auth_utils import get_current_user
import psycopg2

router = APIRouter(prefix="/ordenes", tags=["Ordenes"])


class CompraRequest(BaseModel):
    ticket_id: int
    cantidad: int


@router.post("/comprar")
def comprar_tickets(
    data: CompraRequest,
    current_user: dict = Depends(get_current_user),
):
    """
    Compra tickets para el usuario autenticado.
    El usuario_id se extrae del JWT — no se acepta del body para prevenir IDOR.
    """
    usuario_id = current_user["sub"]

    with get_db() as conn:
        with conn.cursor() as cur:
            try:
                cur.execute(
                    "CALL sp_comprar_tickets(%s, %s, %s)",
                    (usuario_id, data.ticket_id, data.cantidad),
                )
                return {"message": "Compra realizada exitosamente"}
            except psycopg2.Error as e:
                raise HTTPException(status_code=400, detail=parse_pg_error(e))


@router.get("/historial/{usuario_id}")
def historial_compras(
    usuario_id: int,
    current_user: dict = Depends(get_current_user),
):
    """
    Retorna el historial de compras.
    Solo el propio usuario puede ver su historial (verificado con JWT).
    """
    if current_user["sub"] != usuario_id:
        raise HTTPException(
            status_code=403,
            detail="No tienes permiso para ver el historial de este usuario",
        )

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
