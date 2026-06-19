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
        
        grid.innerHTML = eventos.map(event => `
            <article class="card">
                <div class="card-img-placeholder">
                    <span class="card-badge">${event.tipo_evento}</span>
                </div>
                <div class="card-content">
                    <h3 class="card-title">${event.nombre_evento}</h3>
                    <div class="card-meta">
                        <span>📅 ${new Date(event.fecha_inicio).toLocaleDateString()}</span>
                        <span>📍 ${event.ciudad}, ${event.departamento}</span>
                    </div>
                    <p class="card-desc">${event.descripcion || "Disfruta de este increíble show en vivo con tus artistas favoritos."}</p>
                    <div style="margin-top: auto; display: flex; justify-content: space-between; align-items: center;">
                        <span style="font-size: 0.8rem; color: var(--text-muted); font-weight: 500;">Organizado por: ${event.nombre_organizador}</span>
                        <a href="evento.html?id=${event.evento_id}" class="btn btn-secondary" style="font-size: 0.85rem; padding: 0.5rem 1rem;">Ver Entradas</a>
                    </div>
                </div>
            </article>
        `).join('');
        
        loader.style.display = "none";
        grid.style.display = "grid";
        
    } catch (err) {
        loader.innerText = "Hubo un problema al conectar con el servidor.";
        console.error(err);
    }
});
