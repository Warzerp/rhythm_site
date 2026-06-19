import requests
import json
import random

BASE_URL = "http://127.0.0.1:8000/api"

def test_api_flow():
    print("--- STARTING API FLOW INTEGRATION TEST ---")
    
    # Generate random credentials to avoid conflicts
    rand_id = random.randint(1000, 9999)
    nick = f"test_{rand_id}"
    email = f"test_{rand_id}@rhythm.com"
    phone = f"300{rand_id:04d}"
    
    # 1. Register User
    print("\n1. Testing User Registration...")
    reg_data = {
        "nombre": "Integration",
        "apellido": "Tester",
        "nick": nick,
        "contrasena": "pass123",
        "fecha_nacimiento": "2000-01-01",
        "correo": email,
        "telefono": phone
    }
    
    response = requests.post(f"{BASE_URL}/usuarios/registro", json=reg_data)
    print("Response Status:", response.status_code)
    assert response.status_code == 201, f"Failed registration: {response.text}"
    user_info = response.json()["usuario"]
    user_id = user_info["id"]
    print(f"User registered successfully! ID: {user_id}, Nick: {user_info['nick']}")
    
    # 2. Login User
    print("\n2. Testing User Login...")
    login_data = {
        "nick": nick,
        "contrasena": "pass123"
    }
    response = requests.post(f"{BASE_URL}/usuarios/login", json=login_data)
    print("Response Status:", response.status_code)
    assert response.status_code == 200, f"Failed login: {response.text}"
    print("Logged in successfully!")
    
    # 3. List Events
    print("\n3. Testing Get Events...")
    response = requests.get(f"{BASE_URL}/eventos/")
    print("Response Status:", response.status_code)
    assert response.status_code == 200, f"Failed getting events: {response.text}"
    events = response.json()
    assert len(events) > 0, "No events available to test"
    
    # Let's pick the first event
    target_event = events[0]
    event_id = target_event["evento_id"]
    print(f"Selected Event: '{target_event['nombre_evento']}' (ID: {event_id})")
    
    # 4. Get Tickets for Event
    print(f"\n4. Testing Get Tickets for Event {event_id}...")
    response = requests.get(f"{BASE_URL}/tickets/evento/{event_id}")
    print("Response Status:", response.status_code)
    assert response.status_code == 200, f"Failed getting tickets: {response.text}"
    tickets = response.json()
    assert len(tickets) > 0, f"No tickets available for event {event_id}"
    
    # Pick the first ticket category
    target_ticket = tickets[0]
    ticket_id = target_ticket["ticket_id"]
    ticket_type = target_ticket["tipo_ticket"]
    stock_before = target_ticket["stock_disponible"]
    print(f"Selected Ticket Type: '{ticket_type}' (ID: {ticket_id}, Stock: {stock_before})")
    
    # 5. Buy 2 Tickets
    buy_qty = 2
    print(f"\n5. Testing Purchase of {buy_qty} tickets...")
    buy_data = {
        "usuario_id": user_id,
        "ticket_id": ticket_id,
        "cantidad": buy_qty
    }
    response = requests.post(f"{BASE_URL}/comprar", json=buy_data)
    print("Response Status:", response.status_code)
    assert response.status_code == 200, f"Failed purchase: {response.text}"
    print("Purchase completed successfully!")
    
    # Verify stock decrement
    response = requests.get(f"{BASE_URL}/tickets/evento/{event_id}")
    updated_tickets = response.json()
    updated_ticket = next(t for t in updated_tickets if t["ticket_id"] == ticket_id)
    stock_after = updated_ticket["stock_disponible"]
    print(f"Stock after purchase: {stock_after} (Expected: {stock_before - buy_qty})")
    assert stock_after == stock_before - buy_qty, "Stock was not decremented correctly!"
    
    # 6. Fetch User History
    print(f"\n6. Testing User Purchase History for User {user_id}...")
    response = requests.get(f"{BASE_URL}/historial/{user_id}")
    print("Response Status:", response.status_code)
    assert response.status_code == 200, f"Failed getting history: {response.text}"
    history = response.json()
    assert len(history) == 1, f"Expected 1 history record, got {len(history)}"
    
    history_record = history[0]
    print(f"History Record:")
    print(f"  Event Name: {history_record['nombre_evento']}")
    print(f"  Ticket Type: {history_record['tipo_ticket']}")
    print(f"  Quantity: {history_record['cantidad']}")
    print(f"  Total Paid: ${history_record['total_pagado']}")
    print(f"  Payment Status: {history_record['estado_pago']}")
    
    assert history_record["nombre_evento"] == target_event["nombre_evento"], "Event name mismatch"
    assert history_record["tipo_ticket"] == ticket_type, "Ticket type mismatch"
    assert history_record["cantidad"] == buy_qty, "Quantity mismatch"
    
    print("\n--- ALL API INTEGRATION TESTS PASSED SUCCESSFULLY! ---")

if __name__ == "__main__":
    try:
        test_api_flow()
    except Exception as e:
        print("\n--- TEST FAILED ---")
        import traceback
        traceback.print_exc()
