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
 * @param {string} email - O email do usuário logado.
 */
function redirecionarUsuario(email) {
    const ADMIN_EMAIL = 'admin@ravenslist.com';
    
    if (email === ADMIN_EMAIL) {
        // Redireciona o administrador para a página de eventos/CRUD
        window.location.href = 'eventos.html';
    } else {
        // Redireciona usuários normais para a página inicial
        window.location.href = 'index.html';
    }
}


// ============================================
// FORMULÁRIO DE CADASTRO
// ============================================
document.addEventListener('DOMContentLoaded', () => {
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
            
            // Enviar para PHP
            const resultado = await api.cadastrar(nome, email, senha);
            
            if (resultado.success) {
                alert('🦇 ' + resultado.message + ' Fazendo login...');
                
                // NO CADASTRO: Se o backend não retornar o usuário, podemos simular o login
                // e redirecionar. Assumindo que o cadastro implica em login automático:
                
                // Redireciona usando a lógica condicional
                redirecionarUsuario(email);

            } else {
                alert('❌ ' + resultado.message);
            }
        });
    }
});

// ============================================
// FORMULÁRIO DE LOGIN
// ============================================
document.addEventListener('DOMContentLoaded', () => {
    const formLogin = document.getElementById('formLogin');
    
    if (formLogin) {
        formLogin.addEventListener('submit', async (e) => {
            e.preventDefault();
            
            const email = document.getElementById('email').value;
            const senha = document.getElementById('senha').value;
            
            // Enviar para PHP
            const resultado = await api.login(email, senha);
            
            if (resultado.success) {
                // Salvar usuário logado
                auth.salvarUsuario(resultado.usuario);
                
                alert('🦇 ' + resultado.message);
                
                // Redireciona usando a lógica condicional
                redirecionarUsuario(email);

            } else {
                alert('❌ ' + resultado.message);
            }
        });
    }
    // ... (restante do código DOMContentLoaded para a UI da Navbar)
});