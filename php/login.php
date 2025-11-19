<?php
// Define que a resposta será em formato JSON
header('Content-Type: application/json');

// Inclua o arquivo de configuração e conexão com o banco de dados (assumindo que seja 'config.php')
require_once 'config.php';

// Receber dados do JavaScript (esperamos email e senha)
$data = json_decode(file_get_contents('php://input'), true);

// 1. Validação inicial dos campos
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
    // 2. Buscar o usuário pelo email
    $stmt = $pdo->prepare("SELECT id, nome, email, senha, tipo_usuario FROM usuarios WHERE email = ?");
    $stmt->execute([$email]);
    $usuario = $stmt->fetch(PDO::FETCH_ASSOC);

    // 3. Verificar se o usuário existe e se a senha está correta
    if ($usuario && password_verify($senha, $usuario['senha'])) {
        
        // Login bem-sucedido!
        
        // Remove a senha hasheada do objeto antes de enviar para o frontend por segurança
        unset($usuario['senha']); 

        // Retorna a resposta de sucesso com os dados do usuário (crucial para o auth.js)
        echo json_encode([
            'success' => true,
            'message' => 'Login efetuado com sucesso!',
            'usuario' => $usuario // Contém email e tipo_usuario
        ]);
    } else {
        // Credenciais inválidas
        echo json_encode([
            'success' => false,
            'message' => 'Credenciais inválidas. Verifique seu email e senha.'
        ]);
    }
} catch (PDOException $e) {
    // Erro de banco de dados
    http_response_code(500); // Define o código de erro HTTP
    echo json_encode([
        'success' => false,
        'message' => 'Erro interno do servidor: ' . $e->getMessage()
    ]);
}
?>