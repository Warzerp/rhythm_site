from fastapi import APIRouter
from database import get_db

router = APIRouter(prefix="/tickets", tags=["Tickets"])


@router.get("/evento/{evento_id}")
def tickets_por_evento(evento_id: int):
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT * FROM vw_tickets_evento WHERE evento_id = %s ORDER BY precio ASC",
                (evento_id,),
            )
            return [dict(row) for row in cur.fetchall()]
