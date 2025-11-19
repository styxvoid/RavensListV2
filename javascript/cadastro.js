// ============================================
// CADASTRO COM INTEGRAÇÃO PHP (ou LocalStorage)
// ============================================

// Funções auxiliares para mostrar mensagens
function showError(message) {
    const errorMsg = document.getElementById('errorMessage');
    const successMsg = document.getElementById('successMessage');

    // Limpar sucesso anterior
    successMsg.classList.remove('show'); 

    errorMsg.textContent = '❌ ' + message;
    errorMsg.classList.add('show');
    
    // Remover após 5 segundos
    setTimeout(() => {
        errorMsg.classList.remove('show');
    }, 5000);
}

function showSuccess(message) {
    const successMsg = document.getElementById('successMessage');
    const errorMsg = document.getElementById('errorMessage');

    // Limpar erro anterior
    errorMsg.classList.remove('show');

    successMsg.textContent = '✅ ' + message;
    successMsg.classList.add('show');
}


document.getElementById('formCadastro').addEventListener('submit', async function(e) {
    e.preventDefault();
    
    // Capturar valores
    const nome = document.getElementById('nome').value.trim();
    const email = document.getElementById('email').value.trim();
    const senha = document.getElementById('senha').value;
    const confirmarSenha = document.getElementById('confirmarSenha').value;
    
    // Validações
    if (nome.length < 3) {
        showError('Nome deve ter pelo menos 3 caracteres');
        return;
    }
    
    if (senha.length < 6) {
        showError('A senha deve ter no mínimo 6 caracteres');
        return;
    }
    
    if (senha !== confirmarSenha) {
        showError('As senhas não coincidem. Tente novamente.');
        return;
    }
    
    // Desabilitar botão durante o processo
    const submitBtn = this.querySelector('button[type="submit"]');
    submitBtn.disabled = true;
    submitBtn.textContent = 'Cadastrando...';
    
    try {
        // OPÇÃO 1: Com PHP (se você tiver o backend configurado e o arquivo js/api.js)
        if (typeof api !== 'undefined' && typeof api.cadastrar === 'function') {
            const resultado = await api.cadastrar(nome, email, senha);
            
            if (resultado.success) {
                showSuccess(resultado.message);
                
                // Salvar dados do usuário
                localStorage.setItem('isLoggedIn', 'true');
                localStorage.setItem('userType', 'cliente');
                localStorage.setItem('usuario', JSON.stringify({
                    id: resultado.usuario_id,
                    nome: nome,
                    email: email
                }));
                
                // Redirecionar após 2 segundos
                setTimeout(() => {
                    window.location.href = 'index.html';
                }, 2000);
            } else {
                showError(resultado.message);
                submitBtn.disabled = false;
                submitBtn.textContent = 'Cadastrar';
            }
        } else {
            // OPÇÃO 2: Sem PHP (apenas localStorage para testes e prototipagem)
            
            // Verificar se email já existe
            const usuarios = JSON.parse(localStorage.getItem('usuarios') || '[]');
            const emailExiste = usuarios.some(u => u.email === email);
            
            if (emailExiste) {
                showError('Este email já está cadastrado!');
                submitBtn.disabled = false;
                submitBtn.textContent = 'Cadastrar';
                return;
            }
            
            // Adicionar novo usuário
            const novoUsuario = {
                id: Date.now(),
                nome: nome,
                email: email,
                senha: senha // AVISO: Em produção, NUNCA armazene senhas sem hash!
            };
            
            usuarios.push(novoUsuario);
            localStorage.setItem('usuarios', JSON.stringify(usuarios));
            
            // Fazer login automático
            localStorage.setItem('isLoggedIn', 'true');
            localStorage.setItem('userType', 'cliente');
            localStorage.setItem('usuario', JSON.stringify({
                id: novoUsuario.id,
                nome: nome,
                email: email
            }));
            
            showSuccess('Cadastro realizado com sucesso! Redirecionando...');
            
            // Redirecionar após 2 segundos
            setTimeout(() => {
                window.location.href = 'index.html';
            }, 2000);
        }
    } catch (error) {
        console.error('Erro no cadastro:', error);
        showError('Erro ao realizar cadastro. Tente novamente.');
        submitBtn.disabled = false;
        submitBtn.textContent = 'Cadastrar';
    }
});