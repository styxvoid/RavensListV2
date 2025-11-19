// ============================================
// API.JS - CAMADA DE COMUNICAÇÃO COM O BACKEND PHP
// ============================================

class API {
    /**
     * Função auxiliar para fazer requisições POST com JSON.
     * @param {string} endpoint - O caminho para o script PHP (ex: 'php/Cadastro.php').
     * @param {object} data - O objeto de dados a ser enviado (será transformado em JSON).
     * @returns {Promise<object>} - A resposta do servidor decodificada.
     */
    async post(endpoint, data) {
        try {
            const response = await fetch(endpoint, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(data)
            });

            // Lidar com erros HTTP (ex: 404, 500)
            if (!response.ok) {
                // Tentar retornar o erro do servidor se for um JSON
                const errorBody = await response.json().catch(() => ({})); 
                throw new Error(errorBody.message || `Erro de rede: status ${response.status}`);
            }

            // A resposta deve ser JSON
            return await response.json();

        } catch (error) {
            console.error('Erro na requisição API:', error.message);
            // Retornar um objeto de erro padronizado para o frontend
            return { success: false, message: error.message || 'Erro de conexão com o servidor.' };
        }
    }

    /**
     * Envia dados de cadastro para o backend.
     * @param {string} nome
     * @param {string} email
     * @param {string} senha
     */
    async cadastrar(nome, email, senha) {
        const data = { nome, email, senha };
        return this.post('php/Cadastro.php', data);
    }

    /**
     * Envia dados de login para o backend.
     * @param {string} email
     * @param {string} senha
     */
    async login(email, senha) {
        const data = { email, senha };
        // Assume-se que há um script php/Login.php
        // IMPORTANTE: O script Login.php deve retornar o objeto do usuário (incluindo o email)
        // em caso de sucesso (ex: {success: true, message: "...", usuario: {id: 1, email: "..."}})
        return this.post('php/Login.php', data);
    }

    // Você pode adicionar mais métodos aqui conforme necessário (ex: buscarEventos, editarEvento)
    // async buscarEventos() { ... }
}

// Instância global da API para ser usada em outros scripts (auth.js, crudEventos.js)
const api = new API();