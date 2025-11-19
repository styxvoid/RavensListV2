<?php
header('Content-Type: application/json');
require_once 'config.php';

// Receber dados do JavaScript
$data = json_decode(file_get_contents('php://input'), true);

// Validação inicial dos campos
if (empty($data['email']) || empty($data['senha'])) {
    echo json_encode([
        'success' => false,
        'message' => 'Email e senha são obrigatórios!'
    ]);
    exit;
}

$email = trim($data['email']);
$senha = $data['senha'];

try {
    // Buscar o usuário pelo email
    $stmt = $pdo->prepare("SELECT id, nome, email, senha, tipo_usuario FROM usuarios WHERE email = ?");
    $stmt->execute([$email]);
    $usuario = $stmt->fetch(PDO::FETCH_ASSOC);

    // Verificar se o usuário existe e se a senha está correta
    if ($usuario && password_verify($senha, $usuario['senha'])) {
        
        // Login bem-sucedido!
        unset($usuario['senha']); // Remove a senha hasheada por segurança

        echo json_encode([
            'success' => true,
            'message' => 'Login efetuado com sucesso!',
            'usuario' => $usuario
        ]);
    } else {
        // Credenciais inválidas
        echo json_encode([
            'success' => false,
            'message' => 'Credenciais inválidas. Verifique seu email e senha.'
        ]);
    }
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Erro interno do servidor: ' . $e->getMessage()
    ]);
}
?>