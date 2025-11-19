# Correção do Login do Administrador

## Problema Identificado
O hash da senha do administrador no banco de dados estava incorreto, impedindo o login com as credenciais do admin.

## Credenciais do Admin
- **Email:** admin@ravenslist.com
- **Senha:** admin123

## Solução

### Opção 1: Executar o Script SQL (Recomendado)
Execute o arquivo SQL que corrige a senha do admin:

```bash
# No MySQL/phpMyAdmin, execute o arquivo:
database/criar_admin.sql
```

Este script irá:
- Verificar se o admin existe
- Criar ou atualizar o usuário admin com a senha correta
- Confirmar que a operação foi bem-sucedida

### Opção 2: Executar o Script PHP
Se preferir, você pode executar o script PHP diretamente:

```bash
php php/fix_admin_password.php
```

### Opção 3: Recriar o Banco de Dados
Se preferir começar do zero, reimporte o schema do banco:

```bash
# No MySQL/phpMyAdmin, importe o arquivo:
database/schemaDatabase.sql
```

## Verificação
Após executar qualquer uma das opções acima, tente fazer login com:
- **Email:** admin@ravenslist.com
- **Senha:** admin123

O login deve funcionar corretamente e redirecionar para a página de eventos.

## Detalhes Técnicos
- **Hash antigo (incorreto):** `$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi`
- **Hash novo (correto):** `$2y$10$qG6tZaC4dPVQvWf9rTF2.ePoeaALl5h6atD2Z1Tkw5.aTpp6bWrV.`

O hash antigo não correspondia à senha "admin123", causando falha na verificação com `password_verify()`.
