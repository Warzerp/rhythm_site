const API_BASE = "http://localhost:8000/api";

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

// User session management
const Session = {
    getUser() {
        const u = localStorage.getItem("rhythm_user");
        return u ? JSON.parse(u) : null;
    },
    setUser(user) {
        localStorage.setItem("rhythm_user", JSON.stringify(user));
    },
    clear() {
        localStorage.removeItem("rhythm_user");
    },
    isLoggedIn() {
        return this.getUser() !== null;
    }
};

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
