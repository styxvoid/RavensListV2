// Gerenciamento de Autenticação
class Auth {
    constructor() {
        this.usuario = this.getUsuarioLogado();
    }

    salvarUsuario(usuario) {
        localStorage.setItem('usuario', JSON.stringify(usuario));
        this.usuario = usuario;
    }

    getUsuarioLogado() {
        const usuario = localStorage.getItem('usuario');
        return usuario ? JSON.parse(usuario) : null;
    }

    estaLogado() {
        return this.usuario !== null;
    }

    logout() {
        localStorage.removeItem('usuario');
        this.usuario = null;
        window.location.href = 'index.html'; 
    }

    protegerPagina() {
        if (!this.estaLogado()) {
            alert('Você precisa fazer login para acessar esta página!');
            window.location.href = 'login.html';
        }
    }
}

// Instância global
const auth = new Auth();

// ============================================
// REDIRECIONAMENTO CONDICIONAL
// ============================================
function redirecionarUsuario(email) {
    const ADMIN_EMAIL = 'admin@ravenslist.com';
    
    if (email && email.toLowerCase() === ADMIN_EMAIL) {
        window.location.href = 'eventos.html';
    } else {
        window.location.href = 'index.html';
    }
}

// ============================================
// ATUALIZAÇÃO DA BARRA DE NAVEGAÇÃO
// ============================================
function extractUsername(email) {
    if (!email || typeof email !== 'string') return 'Visitante';
    const parts = email.split('@');
    const username = parts[0];
    return username.charAt(0).toUpperCase() + username.slice(1);
}

function updateNavButtons() {
    const unloggedDiv = document.getElementById('auth-buttons-unlogged');
    const loggedDiv = document.getElementById('auth-info-logged');
    const welcomeSpan = document.getElementById('welcome-message');
    
    if (!unloggedDiv || !loggedDiv || !welcomeSpan) {
        return; 
    }

    if (auth.estaLogado()) {
        const usuario = auth.getUsuarioLogado();
        const username = extractUsername(usuario.email); 

        welcomeSpan.textContent = `Olá, ${username}! 🦇`;
        
        unloggedDiv.style.display = 'none';
        loggedDiv.style.display = 'flex'; 
    } else {
        unloggedDiv.style.display = 'flex';
        loggedDiv.style.display = 'none';
    }
}

// ============================================
// INICIALIZAÇÃO E MANIPULADORES DE EVENTOS
// ============================================
document.addEventListener('DOMContentLoaded', () => {
    
    // --- MANIPULADOR DE CADASTRO ---
    const formCadastro = document.getElementById('formCadastro');
    if (formCadastro) {
        formCadastro.addEventListener('submit', async (e) => {
            e.preventDefault();
            
            const nome = document.getElementById('nome').value.trim();
            const email = document.getElementById('email').value.trim();
            const senha = document.getElementById('senha').value;
            const confirmarSenha = document.getElementById('confirmarSenha').value;
            
            if (senha !== confirmarSenha) {
                alert('🦇 As senhas não coincidem!');
                return;
            }
            if (senha.length < 6) {
                alert('🦇 A senha deve ter no mínimo 6 caracteres!');
                return;
            }
            
            const resultado = await api.cadastrar(nome, email, senha);
            
            if (resultado.success) {
                alert('🦇 ' + resultado.message + ' Redirecionando...');
                redirecionarUsuario(resultado.email);
            } else {
                alert('❌ ' + resultado.message);
            }
        });
    }

    // --- MANIPULADOR DE LOGIN ---
    const formLogin = document.getElementById('formLogin');
    if (formLogin) {
        formLogin.addEventListener('submit', async (e) => {
            e.preventDefault();
            
            const email = document.getElementById('email').value;
            const senha = document.getElementById('senha').value;
            
            const resultado = await api.login(email, senha);
            
            if (resultado.success) {
                auth.salvarUsuario(resultado.usuario);
                alert('🦇 ' + resultado.message);
                redirecionarUsuario(resultado.usuario.email);
            } else {
                alert('❌ ' + resultado.message);
            }
        });
    }

    // --- INICIALIZAÇÃO DA BARRA DE NAVEGAÇÃO ---
    updateNavButtons();

    const logoutBtn = document.getElementById('logout-button');
    if (logoutBtn) {
        logoutBtn.addEventListener('click', () => {
            auth.logout();
        });
    }
});