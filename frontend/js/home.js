document.addEventListener("DOMContentLoaded", async () => {
    const loader = document.getElementById("events-loader");
    const grid = document.getElementById("events-grid");
    
    try {
        const response = await fetch(`${API_BASE}/eventos`);
        if (!response.ok) throw new Error("Error cargando eventos");
        
        const eventos = await response.json();
        
        if (eventos.length === 0) {
            loader.innerText = "No hay eventos programados en este momento.";
            return;
        }
        
        grid.innerHTML = eventos.map((event, idx) => {
            // Asigna una de las 3 imágenes premium dinámicamente según el ID del evento
            const imageIndex = (event.evento_id % 3) + 1;
            const imgPath = `img/event${imageIndex}.png`;
            
            return `
            <article class="card">
                <div class="card-img-container">
                    <img src="${imgPath}" alt="${escapeHTML(event.nombre_evento)}" class="card-img">
                    <span class="card-badge">${escapeHTML(event.tipo_evento)}</span>
                </div>
                <div class="card-content">
                    <h3 class="card-title">${escapeHTML(event.nombre_evento)}</h3>
                    <div class="card-meta">
                        <span>📅 ${new Date(event.fecha_inicio).toLocaleDateString('es-ES', { day: 'numeric', month: 'short', year: 'numeric' })}</span>
                        <span>📍 ${escapeHTML(event.ciudad)}</span>
                    </div>
                    <p class="card-desc">${escapeHTML(event.descripcion) || "Disfruta de este increíble show en vivo con tus artistas favoritos."}</p>
                    <div style="margin-top: auto; display: flex; justify-content: space-between; align-items: center; border-top: 1px solid var(--border-glass); padding-top: 1rem;">
                        <span style="font-size: 0.8rem; color: var(--text-muted); font-weight: 500;">By: ${escapeHTML(event.nombre_organizador)}</span>
                        <a href="evento.html?id=${encodeURIComponent(event.evento_id)}" class="btn btn-primary" style="font-size: 0.85rem; padding: 0.5rem 1.2rem; border-radius: var(--radius-sm);">Detalles</a>
                    </div>
                </div>
            </article>
            `;
        }).join('');
        
        loader.style.display = "none";
        grid.style.display = "grid";
        
    } catch (err) {
        loader.innerText = "Hubo un problema al conectar con el servidor.";
        console.error(err);
    }
});
