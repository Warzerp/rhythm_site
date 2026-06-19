from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from database import get_db, parse_pg_error
import psycopg2

router = APIRouter(prefix="/tickets", tags=["Tickets"])


class CrearTicketRequest(BaseModel):
    precio: float
    tipo_ticket_id: int
    cantidad: int
    evento_id: int


class ActualizarTicketRequest(BaseModel):
    precio: float
    cantidad: int


@router.get("/evento/{evento_id}")
def tickets_por_evento(evento_id: int):
    """Lista los tickets disponibles para un evento usando la vista vw_tickets_evento."""
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT * FROM vw_tickets_evento WHERE evento_id = %s ORDER BY precio ASC",
                (evento_id,),
            )
            return [dict(row) for row in cur.fetchall()]


@router.post("/", status_code=201)
def crear_ticket(data: CrearTicketRequest):
    """Crea un ticket para un evento usando sp_crear_ticket (con validaciones de negocio)."""
    with get_db() as conn:
        with conn.cursor() as cur:
            try:
                cur.execute(
                    "CALL sp_crear_ticket(%s, %s, %s, %s)",
                    (data.precio, data.tipo_ticket_id, data.cantidad, data.evento_id),
                )
                return {"message": "Ticket creado exitosamente"}
            except psycopg2.Error as e:
                raise HTTPException(status_code=400, detail=parse_pg_error(e))


@router.put("/{ticket_id}")
def actualizar_ticket(ticket_id: int, data: ActualizarTicketRequest):
    """Actualiza precio y cantidad de un ticket usando sp_actualizar_ticket."""
    with get_db() as conn:
        with conn.cursor() as cur:
            try:
                cur.execute(
                    "CALL sp_actualizar_ticket(%s, %s, %s)",
                    (ticket_id, data.precio, data.cantidad),
                )
                return {"message": f"Ticket {ticket_id} actualizado exitosamente"}
            except psycopg2.Error as e:
                raise HTTPException(status_code=400, detail=parse_pg_error(e))


@router.delete("/{ticket_id}", status_code=200)
def eliminar_ticket(ticket_id: int):
    """Elimina un ticket usando sp_eliminar_ticket (valida que no tenga órdenes)."""
    with get_db() as conn:
        with conn.cursor() as cur:
            try:
                cur.execute("CALL sp_eliminar_ticket(%s)", (ticket_id,))
                return {"message": f"Ticket {ticket_id} eliminado exitosamente"}
            except psycopg2.Error as e:
                raise HTTPException(status_code=400, detail=parse_pg_error(e))
