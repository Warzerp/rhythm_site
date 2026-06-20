document.addEventListener("DOMContentLoaded", async () => {
    const user = Session.getUser();
    if (!user) {
        window.location.href = "auth.html";
        return;
    }
    
    // Set profile info
    document.getElementById("profile-fullname").innerText = `${user.nombre} ${user.apellido}`;
    document.getElementById("profile-nick").innerText = `@${user.nick}`;
    
    const initials = (user.nombre[0] + user.apellido[0]).toUpperCase();
    document.getElementById("avatar-icon").innerText = initials;
    
    await loadPurchaseHistory(user.id);
});

async function loadPurchaseHistory(userId) {
    const tbody = document.getElementById("history-table-body");
    
    try {
        const response = await authFetch(`${API_BASE}/ordenes/historial/${userId}`);
        if (!response.ok) throw new Error("Error obteniendo historial");
        
        const history = await response.json();
        
        if (history.length === 0) {
            tbody.innerHTML = `
                <tr>
                    <td colspan="8" style="text-align: center; color: var(--text-muted); padding: 3rem;">
                        No has realizado ninguna compra todavía. ¡Explora los eventos para adquirir entradas!
                    </td>
                </tr>
            `;
            return;
        }
        
        tbody.innerHTML = history.map(item => `
            <tr>
                <td>#${escapeHTML(String(item.orden_id))}</td>
                <td style="font-weight: 500;">${escapeHTML(item.nombre_evento)}</td>
                <td><span class="card-badge" style="position: static; font-size: 0.75rem;">${escapeHTML(item.tipo_ticket)}</span></td>
                <td>$${escapeHTML(String(item.precio_unitario))}</td>
                <td>${escapeHTML(String(item.cantidad))}</td>
                <td style="font-weight: 600; color: var(--accent);">$${escapeHTML(String(item.total_pagado))}</td>
                <td>${new Date(item.fecha_compra).toLocaleDateString()}</td>
                <td>
                    <span class="status-badge status-paid">
                        ${escapeHTML(item.estado_pago.toUpperCase())}
                    </span>
                </td>
            </tr>
        `).join('');
        
    } catch (err) {
        tbody.innerHTML = `
            <tr>
                <td colspan="8" style="text-align: center; color: #ff4d4d; padding: 2rem;">
                    Error al cargar el historial de compras.
                </td>
            </tr>
        `;
        console.error(err);
    }
}
