const API_BASE = "http://localhost:8000/api";

// ─── Seguridad: Escape de HTML para prevenir XSS ────────────────────────────
// SIEMPRE usa esta función antes de insertar datos de la API en innerHTML.
function escapeHTML(str) {
    if (str === null || str === undefined) return '';
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}
// ────────────────────────────────────────────────────────────────────────────

// Helper to show modern status toasts
function showToast(message, type = "success") {
    let toast = document.getElementById("toast-notification");
    if (!toast) {
        toast = document.createElement("div");
        toast.id = "toast-notification";
        toast.className = "toast";
        document.body.appendChild(toast);
    }
    
    toast.className = `toast show toast-${type}`;
    toast.innerText = message;
    
    setTimeout(() => {
        toast.className = "toast";
    }, 4000);
}

// User session management (con soporte para JWT)
const Session = {
    getUser() {
        const u = localStorage.getItem("rhythm_user");
        return u ? JSON.parse(u) : null;
    },
    setUser(user) {
        localStorage.setItem("rhythm_user", JSON.stringify(user));
    },
    // ─── JWT ─────────────────────────────────────────────────────────────────
    getToken() {
        return localStorage.getItem("rhythm_token") || null;
    },
    setToken(token) {
        localStorage.setItem("rhythm_token", token);
    },
    // ─────────────────────────────────────────────────────────────────────────
    clear() {
        localStorage.removeItem("rhythm_user");
        localStorage.removeItem("rhythm_token");
    },
    isLoggedIn() {
        return this.getToken() !== null && this.getUser() !== null;
    }
};

/**
 * authFetch — wrapper de fetch que inyecta automáticamente el JWT.
 * Úsalo en lugar de fetch() para rutas protegidas.
 *
 * Ejemplo:
 *   const res = await authFetch(`${API_BASE}/ordenes/comprar`, {
 *       method: "POST",
 *       body: JSON.stringify({ ticket_id: 1, cantidad: 2 })
 *   });
 */
async function authFetch(url, options = {}) {
    const token = Session.getToken();
    const headers = {
        "Content-Type": "application/json",
        ...(options.headers || {}),
        ...(token ? { "Authorization": `Bearer ${token}` } : {}),
    };
    const response = await fetch(url, { ...options, headers });

    // Si el backend responde 401, la sesión expiró — limpiar y redirigir
    if (response.status === 401) {
        Session.clear();
        showToast("Tu sesión ha expirado. Inicia sesión de nuevo.", "error");
        setTimeout(() => { window.location.href = "auth.html"; }, 1500);
    }

    return response;
}


// Auto-update common navigation links based on user status
function updateNav() {
    const navRight = document.getElementById("nav-actions");
    if (!navRight) return;
    
    const user = Session.getUser();
    if (user) {
        navRight.innerHTML = `
            <a href="perfil.html" style="margin-right: 1.5rem; font-weight: 500;">👤 ${user.nick}</a>
            <button class="btn btn-logout" onclick="logoutUser()">Salir</button>
        `;
    } else {
        navRight.innerHTML = `
            <a href="auth.html" class="btn btn-primary">Iniciar Sesión</a>
        `;
    }
}

function logoutUser() {
    Session.clear();
    showToast("Sesión cerrada correctamente", "success");
    setTimeout(() => {
        window.location.href = "index.html";
    }, 1000);
}

// Set up nav on DOM load
document.addEventListener("DOMContentLoaded", () => {
    updateNav();
});
