function switchTab(tab) {
    const tabLogin = document.getElementById("tab-login");
    const tabReg = document.getElementById("tab-register");
    const formLogin = document.getElementById("form-login");
    const formReg = document.getElementById("form-register");
    
    if (tab === 'login') {
        tabLogin.className = "auth-tab active";
        tabReg.className = "auth-tab";
        formLogin.style.display = "block";
        formReg.style.display = "none";
    } else {
        tabLogin.className = "auth-tab";
        tabReg.className = "auth-tab active";
        formLogin.style.display = "none";
        formReg.style.display = "block";
    }
}

async function handleLogin(e) {
    e.preventDefault();
    const nick = document.getElementById("login-nick").value;
    const contrasena = document.getElementById("login-pass").value;
    
    try {
        const response = await fetch(`${API_BASE}/usuarios/login`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ nick, contrasena })
        });
        
        const data = await response.json();
        if (!response.ok) {
            showToast(data.detail || "Error en el inicio de sesión", "error");
            return;
        }
        
        Session.setUser(data.usuario);
        showToast("Inicio de sesión exitoso. ¡Bienvenido!", "success");
        setTimeout(() => {
            window.location.href = "index.html";
        }, 1200);
        
    } catch (err) {
        showToast("No se pudo establecer conexión con el servidor", "error");
        console.error(err);
    }
}

async function handleRegister(e) {
    e.preventDefault();
    const nombre = document.getElementById("reg-nombre").value;
    const apellido = document.getElementById("reg-apellido").value;
    const nick = document.getElementById("reg-nick").value;
    const contrasena = document.getElementById("reg-pass").value;
    const fecha_nacimiento = document.getElementById("reg-nacimiento").value;
    const correo = document.getElementById("reg-correo").value;
    const telefono = document.getElementById("reg-telefono").value;
    
    try {
        const response = await fetch(`${API_BASE}/usuarios/registro`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                nombre, apellido, nick, contrasena, fecha_nacimiento, correo, telefono
            })
        });
        
        const data = await response.json();
        if (!response.ok) {
            showToast(data.detail || "Error en el registro", "error");
            return;
        }
        
        showToast("Registro exitoso. Ya puedes iniciar sesión.", "success");
        switchTab('login');
        document.getElementById("login-nick").value = nick;
        document.getElementById("login-pass").value = "";
        
    } catch (err) {
        showToast("No se pudo establecer conexión con el servidor", "error");
        console.error(err);
    }
}
