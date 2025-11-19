// Gerenciamento de Autenticação
class Auth {
    constructor() {
        this.usuario = this.getUsuarioLogado();
    }

    // Salvar usuário no localStorage
    salvarUsuario(usuario) {
        localStorage.setItem('usuario', JSON.stringify(usuario));
        this.usuario = usuario;
    }

    // Pegar usuário logado
    getUsuarioLogado() {
        const usuario = localStorage.getItem('usuario');
        return usuario ? JSON.parse(usuario) : null;
    }

    // Verificar se está logado
    estaLogado() {
        return this.usuario !== null;
    }

    // Logout
    logout() {
        localStorage.removeItem('usuario');
        this.usuario = null;
        window.location.href = 'index.html'; 
    }

    // Redirecionar se não estiver logado
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
// LÓGICA DE REDIRECIONAMENTO CONDICIONAL
// ============================================

/**
 * Redireciona o usuário para 'eventos.html' se for admin, ou 'index.html' caso contrário.
 * @param {string} email - O email do usuário logado/cadastrado.
 */
function redirecionarUsuario(email) {
    const ADMIN_EMAIL = 'admin@ravenslist.com';
    
    // Converte para minúsculas para comparação segura
    if (email && email.toLowerCase() === ADMIN_EMAIL) {
        // Redireciona o administrador para a página de eventos/CRUD
        window.location.href = 'eventos.html';
    } else {
        // Redireciona usuários normais para a página inicial
        window.location.href = 'index.html';
    }
}

// ============================================
// LÓGICA DE ATUALIZAÇÃO DA BARRA DE NAVEGAÇÃO
// (Para a funcionalidade de "Bem-vindo, [Nome]")
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
    
    // Aborta se os elementos não existirem na página (Ex: páginas sem Navbar completa)
    if (!unloggedDiv || !loggedDiv || !welcomeSpan) {
        return; 
    }

    if (auth.estaLogado()) {
        const usuario = auth.getUsuarioLogado();
        // Acesso seguro ao email do usuário logado
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
    
    // --- 1. MANIPULADOR DE CADASTRO ---
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
                
                // Redireciona usando a lógica condicional
                redirecionarUsuario(email);

            } else {
                alert('❌ ' + resultado.message);
            }
        });
    }

    // --- 2. MANIPULADOR DE LOGIN ---
    const formLogin = document.getElementById('formLogin');
    if (formLogin) {
        formLogin.addEventListener('submit', async (e) => {
            e.preventDefault();
            
            const email = document.getElementById('email').value;
            const senha = document.getElementById('senha').value;
            
            const resultado = await api.login(email, senha);
            
            if (resultado.success) {
                // Salvar usuário logado, que contém o email necessário para o redirecionamento
                auth.salvarUsuario(resultado.usuario);
                
                alert('🦇 ' + resultado.message);
                
                // Redireciona usando a lógica condicional
                redirecionarUsuario(resultado.usuario.email); 

            } else {
                alert('❌ ' + resultado.message);
            }
        });
    }

    // --- 3. INICIALIZAÇÃO DA BARRA DE NAVEGAÇÃO E LOGOUT ---
    updateNavButtons();

    const logoutBtn = document.getElementById('logout-button');
    if (logoutBtn) {
        logoutBtn.addEventListener('click', () => {
            auth.logout();
        });
    }
});