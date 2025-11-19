-- ============================================
-- CRIAR USUÁRIO ADMIN
-- Execute este script para garantir que o admin existe
-- ============================================

USE raven_list;

-- Verificar se o admin já existe
SELECT COUNT(*) as admin_existe FROM usuarios WHERE email = 'admin@ravenslist.com';

-- Se não existir, criar o admin
-- Senha: admin123 (hash bcrypt)
INSERT INTO usuarios (nome, email, senha, tipo_usuario, status, data_cadastro)
SELECT 'Admin Raven', 'admin@ravenslist.com', '$2y$10$qG6tZaC4dPVQvWf9rTF2.ePoeaALl5h6atD2Z1Tkw5.aTpp6bWrV.', 'admin', 'ativo', NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM usuarios WHERE email = 'admin@ravenslist.com'
);

-- Atualizar senha caso o admin já exista
UPDATE usuarios
SET senha = '$2y$10$qG6tZaC4dPVQvWf9rTF2.ePoeaALl5h6atD2Z1Tkw5.aTpp6bWrV.',
    tipo_usuario = 'admin',
    status = 'ativo'
WHERE email = 'admin@ravenslist.com';

-- Verificar resultado
SELECT id, nome, email, tipo_usuario, status, data_cadastro 
FROM usuarios 
WHERE email = 'admin@ravenslist.com';

SELECT '✅ Usuário admin criado/atualizado com sucesso!' AS resultado;
SELECT '📧 Email: admin@ravenslist.com' AS credencial_email;
SELECT '🔑 Senha: admin123' AS credencial_senha;