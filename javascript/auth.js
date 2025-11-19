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
// FORMULÁRIO DE CADASTRO
// ============================================
document.addEventListener('DOMContentLoaded', () => {
    const formCadastro = document.getElementById('formCadastro');
    
    if (formCadastro) {
        formCadastro.addEventListener('submit', async (e) => {
            e.preventDefault();
            
            const nome = document.getElementById('nome').value;
            const email = document.getElementById('email').value;
            const senha = document.getElementById('senha').value;
            const confirmarSenha = document.getElementById('confirmarSenha').value;
            
            // Validações
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
                alert('🦇 ' + resultado.message);
                window.location.href = 'login.html';
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
                window.location.href = 'index.html';
            } else {
                alert('❌ ' + resultado.message);
            }
        });
    }
});