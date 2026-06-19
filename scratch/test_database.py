import psycopg2
import sys

def test_database():
    try:
        conn = psycopg2.connect(
            host="localhost",
            port=5432,
            user="postgres",
            password="040922",
            database="rhythm_site"
        )
        conn.autocommit = True
        cur = conn.cursor()
        print("Connected to database successfully.")

        # ==========================================
        # 1. Test sp_crear_usuario + Audit Log
        # ==========================================
        print("\n--- Testing sp_crear_usuario + Audit Log ---")
        cur.execute("""
            CALL sp_crear_usuario(
                'TestNombre', 'TestApellido', 'testnick', 'testpass', 
                '1999-12-31', 1, 'testuser@rhythm.com', '55512345'
            )
        """)
        cur.execute("SELECT id, nick FROM usuarios WHERE nick = 'testnick'")
        user_row = cur.fetchone()
        user_id = user_row[0]
        print(f"Created User ID: {user_id}, Nick: {user_row[1]}")

        # Verify audit log for user INSERT
        cur.execute("""
            SELECT operacion, usuario_id FROM auditoria_usuarios 
            WHERE usuario_id = %s ORDER BY id DESC LIMIT 1
        """, (user_id,))
        audit_row = cur.fetchone()
        if audit_row and audit_row[0] == 'INSERT':
            print(f"VERIFIED: auditoria_usuarios registró INSERT para usuario_id={audit_row[1]}")
        else:
            print(f"FAILED: auditoria_usuarios no registró INSERT para el usuario. Got: {audit_row}")
            return

        # ==========================================
        # 2. Test sp_actualizar_usuario + Audit UPDATE
        # ==========================================
        print("\n--- Testing sp_actualizar_usuario + Audit UPDATE ---")
        cur.execute("""
            CALL sp_actualizar_usuario(
                %s, 'NombreActualizado', 'ApellidoActualizado', 'testnick',
                'newpassword', '1999-12-31', 'updated@rhythm.com', '99912345'
            )
        """, (user_id,))
        cur.execute("""
            SELECT operacion, detalles_old, detalles_new FROM auditoria_usuarios 
            WHERE usuario_id = %s AND operacion = 'UPDATE'
            ORDER BY id DESC LIMIT 1
        """, (user_id,))
        audit_row = cur.fetchone()
        if audit_row:
            print(f"VERIFIED: auditoria_usuarios registró UPDATE. Old != None: {audit_row[1] is not None}")
        else:
            print("FAILED: auditoria_usuarios no registró UPDATE.")
            return

        # ==========================================
        # 3. Test sp_crear_evento (CRUD Event)
        # ==========================================
        print("\n--- Testing sp_crear_evento ---")
        cur.execute("""
            CALL sp_crear_evento(
                'Festival Test', 'Descripción del festival test',
                '2025-12-01', '2025-12-02', 'programado', TRUE,
                1, 1, 1,
                ARRAY[1, 2]::INT[]
            )
        """)
        cur.execute("SELECT id FROM eventos WHERE nombre = 'Festival Test'")
        evt_row = cur.fetchone()
        if evt_row:
            event_id = evt_row[0]
            print(f"Created Event ID via sp_crear_evento: {event_id}")
        else:
            print("FAILED: evento no encontrado.")
            return

        # Verify artist associations
        cur.execute("SELECT COUNT(*) FROM evento_artistas WHERE evento_id = %s", (event_id,))
        ea_count = cur.fetchone()[0]
        print(f"VERIFIED: {ea_count} artistas asociados al evento {event_id}")

        # Verify event audit log
        cur.execute("""
            SELECT operacion FROM auditoria_eventos 
            WHERE evento_id = %s AND operacion = 'INSERT'
        """, (event_id,))
        audit_row = cur.fetchone()
        if audit_row:
            print(f"VERIFIED: auditoria_eventos registró INSERT para evento_id={event_id}")
        else:
            print("FAILED: auditoria_eventos no registró INSERT del evento.")
            return

        # ==========================================
        # 4. Test sp_actualizar_evento
        # ==========================================
        print("\n--- Testing sp_actualizar_evento ---")
        cur.execute("""
            CALL sp_actualizar_evento(
                %s, 'Festival Test Actualizado', 'Descripción actualizada',
                '2025-12-01', '2025-12-03', 'confirmado', TRUE,
                1, 1, 1
            )
        """, (event_id,))
        cur.execute("SELECT nombre, estado FROM eventos WHERE id = %s", (event_id,))
        row = cur.fetchone()
        if row and row[1] == 'confirmado':
            print(f"VERIFIED: Evento actualizado. Nombre: '{row[0]}', Estado: '{row[1]}'")
        else:
            print(f"FAILED: El evento no fue actualizado correctamente. Got: {row}")
            return

        # Verify update audit
        cur.execute("""
            SELECT operacion FROM auditoria_eventos 
            WHERE evento_id = %s AND operacion = 'UPDATE'
            ORDER BY id DESC LIMIT 1
        """, (event_id,))
        audit_row = cur.fetchone()
        if audit_row:
            print(f"VERIFIED: auditoria_eventos registró UPDATE para evento_id={event_id}")
        else:
            print("FAILED: auditoria_eventos no registró UPDATE del evento.")
            return

        # ==========================================
        # 5. Test sp_crear_ticket + Ticket Audit
        # ==========================================
        print("\n--- Testing sp_crear_ticket + Ticket Audit ---")
        cur.execute("CALL sp_crear_ticket(250.00, 1, 50, %s)", (event_id,))
        cur.execute("SELECT id, precio, cantidad FROM ticket WHERE evento_id = %s AND tipo_ticket_id = 1", (event_id,))
        ticket_row = cur.fetchone()
        if ticket_row:
            ticket_id = ticket_row[0]
            print(f"Created Ticket ID: {ticket_id}, Price: {ticket_row[1]}, Stock: {ticket_row[2]}")
        else:
            print("FAILED: ticket no encontrado.")
            return

        # Verify ticket audit log
        cur.execute("""
            SELECT operacion FROM auditoria_tickets 
            WHERE ticket_id = %s AND operacion = 'INSERT'
        """, (ticket_id,))
        audit_row = cur.fetchone()
        if audit_row:
            print(f"VERIFIED: auditoria_tickets registró INSERT para ticket_id={ticket_id}")
        else:
            print("FAILED: auditoria_tickets no registró INSERT del ticket.")
            return

        # ==========================================
        # 6. Test sp_comprar_tickets + Order Audit
        # ==========================================
        print("\n--- Testing sp_comprar_tickets + Order Audit ---")
        cur.execute("CALL sp_comprar_tickets(%s, %s, 5)", (user_id, ticket_id))
        print("Purchased 5 tickets successfully.")

        # Verify order audit
        cur.execute("""
            SELECT au.operacion, au.orden_id 
            FROM auditoria_ordenes au
            JOIN ordenes o ON au.orden_id = o.id
            WHERE o.usuario_id = %s AND o.ticket_id = %s AND au.operacion = 'INSERT'
            ORDER BY au.id DESC LIMIT 1
        """, (user_id, ticket_id))
        audit_row = cur.fetchone()
        if audit_row:
            print(f"VERIFIED: auditoria_ordenes registró INSERT para orden_id={audit_row[1]}")
        else:
            print("FAILED: auditoria_ordenes no registró INSERT de la orden.")
            return

        # ==========================================
        # 7. Test vw_historial_compras_usuario
        # ==========================================
        print("\n--- Testing vw_historial_compras_usuario ---")
        cur.execute("""
            SELECT orden_id, usuario_nick, nombre_evento, tipo_ticket, 
                   precio_unitario, cantidad, total_pagado, estado_pago
            FROM vw_historial_compras_usuario 
            WHERE usuario_id = %s
        """, (user_id,))
        rows = cur.fetchall()
        if rows:
            for row in rows:
                print(f"  Orden {row[0]} | Usuario: {row[1]} | Evento: {row[2]} | Tipo: {row[3]} | Precio: {row[4]} | Cant: {row[5]} | Total: {row[6]} | Estado: {row[7]}")
            print(f"VERIFIED: vw_historial_compras_usuario devolvió {len(rows)} orden(es).")
        else:
            print("FAILED: vw_historial_compras_usuario no devolvió resultados.")
            return

        # ==========================================
        # 8. Test sp_eliminar_evento (should fail - has tickets)
        # ==========================================
        print("\n--- Testing sp_eliminar_evento with tickets (expected fail) ---")
        try:
            cur.execute("CALL sp_eliminar_evento(%s)", (event_id,))
            print("FAILED: Eliminó evento con tickets (no debería).")
            return
        except Exception as e:
            print(f"VERIFIED: No se puede eliminar evento con tickets. Error: {e}")

        # ==========================================
        # 9. Test sp_eliminar_usuario (Soft Delete + Update Audit)
        # ==========================================
        print("\n--- Testing sp_eliminar_usuario (soft delete) + Audit ---")
        cur.execute("CALL sp_eliminar_usuario(%s)", (user_id,))
        cur.execute("SELECT activo FROM usuarios WHERE id = %s", (user_id,))
        activo = cur.fetchone()[0]
        if not activo:
            print(f"VERIFIED: Usuario {user_id} desactivado correctamente (soft delete).")
        else:
            print(f"FAILED: Usuario {user_id} todavía está activo.")
            return

        # Check update audit for soft delete
        cur.execute("""
            SELECT operacion FROM auditoria_usuarios 
            WHERE usuario_id = %s AND operacion = 'UPDATE'
            ORDER BY id DESC LIMIT 1
        """, (user_id,))
        audit_row = cur.fetchone()
        if audit_row:
            print(f"VERIFIED: auditoria_usuarios registró UPDATE (soft delete) para usuario_id={user_id}")
        else:
            print("FAILED: auditoria_usuarios no registró UPDATE del soft delete.")
            return

        print("\n==========================================")
        print("ALL EXTENDED VERIFICATIONS COMPLETED SUCCESSFULLY!")
        print("==========================================")

    except Exception as e:
        print(f"Database error: {e}")
        import traceback
        traceback.print_exc()
    finally:
        if 'conn' in locals() and conn:
            conn.close()

if __name__ == "__main__":
    test_database()
