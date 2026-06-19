document.addEventListener("DOMContentLoaded", async () => {
    const params = new URLSearchParams(window.location.search);
    const eventId = params.get("id");
    
    if (!eventId) {
        window.location.href = "index.html";
        return;
    }
    
    await loadEventDetails(eventId);
    await loadEventTickets(eventId);
});

async function loadEventDetails(id) {
    try {
        const response = await fetch(`${API_BASE}/eventos/${id}`);
        if (!response.ok) throw new Error("Error obteniendo detalles del evento");
        
        const event = await response.json();
        
        document.title = `${event.nombre_evento} — Rhythm Site`;
        document.getElementById("event-title").innerText = event.nombre_evento;
        document.getElementById("event-type-badge").innerText = event.tipo_evento;
        document.getElementById("event-description").innerText = event.descripcion || "Este evento no cuenta con una descripción detallada en este momento.";
        
        document.getElementById("event-meta").innerHTML = `
            <span>📅 Fecha: ${new Date(event.fecha_inicio).toLocaleDateString()}</span>
            <span>📍 Lugar: ${event.nombre_venue} (${event.ciudad}, ${event.departamento})</span>
            <span>🏢 Organizador: ${event.nombre_organizador}</span>
        `;
        
        const artistsContainer = document.getElementById("artists-container");
        if (event.artistas.length === 0) {
            artistsContainer.innerHTML = "<p style='color: var(--text-muted);'>No se han asignado artistas para este evento.</p>";
        } else {
            artistsContainer.innerHTML = event.artistas.map(art => `
                <div class="artist-chip">
                    <div class="artist-img">🎙️</div>
                    <span style="font-weight: 500;">${art.nombre_artistico}</span>
                </div>
            `).join('');
        }
        
    } catch (err) {
        showToast("Error al cargar los detalles del evento", "error");
        console.error(err);
    }
}

async function loadEventTickets(id) {
    const container = document.getElementById("tickets-container");
    
    try {
        const response = await fetch(`${API_BASE}/tickets/evento/${id}`);
        if (!response.ok) throw new Error("Error obteniendo tickets");
        
        const tickets = await response.json();
        
        if (tickets.length === 0) {
            container.innerHTML = "<div style='text-align: center; color: var(--text-muted); padding: 1.5rem;'>No hay tickets disponibles para este evento.</div>";
            return;
        }
        
        container.innerHTML = tickets.map(ticket => `
            <div class="ticket-row">
                <div class="ticket-info">
                    <h4>${ticket.tipo_ticket}</h4>
                    <span style="font-size: 0.8rem; color: var(--text-muted);">Stock disponible: ${ticket.stock_disponible}</span>
                </div>
                <div class="ticket-price">$${ticket.precio}</div>
                <div style="display: flex; flex-direction: column; align-items: flex-end; gap: 0.5rem;">
                    <div class="qty-picker">
                        <button class="qty-btn" onclick="updateQty(${ticket.ticket_id}, -1)">-</button>
                        <span class="qty-val" id="qty-${ticket.ticket_id}">1</span>
                        <button class="qty-btn" onclick="updateQty(${ticket.ticket_id}, 1, ${ticket.stock_disponible})">+</button>
                    </div>
                    <button class="btn btn-accent" style="padding: 0.4rem 0.8rem; font-size: 0.8rem;" onclick="buyTicket(${ticket.ticket_id})">Comprar</button>
                </div>
            </div>
        `).join('');
        
    } catch (err) {
        container.innerHTML = "<div style='text-align: center; color: #ff4d4d; padding: 1.5rem;'>Error al conectar con el inventario.</div>";
        console.error(err);
    }
}

function updateQty(ticketId, change, maxStock = 100) {
    const qtySpan = document.getElementById(`qty-${ticketId}`);
    if (!qtySpan) return;
    
    let current = parseInt(qtySpan.innerText);
    current += change;
    
    if (current < 1) current = 1;
    if (current > maxStock) {
        current = maxStock;
        showToast("No puedes exceder el stock disponible", "error");
    }
    
    qtySpan.innerText = current;
}

async function buyTicket(ticketId) {
    const user = Session.getUser();
    if (!user) {
        showToast("Debes iniciar sesión para comprar tickets", "error");
        setTimeout(() => {
            window.location.href = "auth.html";
        }, 1500);
        return;
    }
    
    const qty = parseInt(document.getElementById(`qty-${ticketId}`).innerText);
    
    try {
        const response = await fetch(`${API_BASE}/ordenes/comprar`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                usuario_id: user.id,
                ticket_id: ticketId,
                cantidad: qty
            })
        });
        
        const data = await response.json();
        
        if (!response.ok) {
            showToast(data.detail || "Error al completar la compra", "error");
            return;
        }
        
        showToast("¡Compra realizada con éxito!", "success");
        
        // Reload ticket availability
        const params = new URLSearchParams(window.location.search);
        await loadEventTickets(params.get("id"));
        
    } catch (err) {
        showToast("Hubo un fallo de red. Intenta nuevamente.", "error");
        console.error(err);
    }
}
