<?php
session_start();
require_once 'config.php';

// Receber dados do JavaScript
$data = json_decode(file_get_contents('php://input'), true);

// Validar dados
if (empty($data['email']) || empty($data['senha'])) {
    echo json_encode([
        'success' => false,
        'message' => 'Email e senha são obrigatórios!'
    ]);
    exit;
}

$email = trim($data['email']);
$senha = $data['senha'];

// Buscar usuário no banco
try {
    $stmt = $pdo->prepare("SELECT id, nome, email, senha FROM usuarios WHERE email = ?");
    $stmt->execute([$email]);
    $usuario = $stmt->fetch();
    
    // Verificar se usuário existe e senha está correta
    if ($usuario && password_verify($senha, $usuario['senha'])) {
        // Criar sessão
        $_SESSION['usuario_id'] = $usuario['id'];
        $_SESSION['usuario_nome'] = $usuario['nome'];
        $_SESSION['usuario_email'] = $usuario['email'];
        
        echo json_encode([
            'success' => true,
            'message' => 'Login realizado com sucesso!',
            'usuario' => [
                'id' => $usuario['id'],
                'nome' => $usuario['nome'],
                'email' => $usuario['email']
            ]
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Email ou senha incorretos!'
        ]);
    }
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Erro ao fazer login: ' . $e->getMessage()
    ]);
}
?>