<?php
require_once 'config.php';

// Receber dados do JavaScript
$data = json_decode(file_get_contents('php://input'), true);

// Validar dados
if (empty($data['nome']) || empty($data['email']) || empty($data['senha'])) {
    echo json_encode([
        'success' => false,
        'message' => 'Todos os campos são obrigatórios!'
    ]);
    exit;
}

$nome = trim($data['nome']);
$email = trim($data['email']);
$senha = $data['senha'];

// Validar email
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode([
        'success' => false,
        'message' => 'Email inválido!'
    ]);
    exit;
}

// Verificar se email já existe
$stmt = $pdo->prepare("SELECT id FROM usuarios WHERE email = ?");
$stmt->execute([$email]);

if ($stmt->rowCount() > 0) {
    echo json_encode([
        'success' => false,
        'message' => 'Este email já está cadastrado!'
    ]);
    exit;
}

// Hash da senha (NUNCA salvar senha em texto puro!)
$senhaHash = password_hash($senha, PASSWORD_DEFAULT);

// Inserir no banco
try {
    $stmt = $pdo->prepare("INSERT INTO usuarios (nome, email, senha) VALUES (?, ?, ?)");
    $stmt->execute([$nome, $email, $senhaHash]);
    
    echo json_encode([
        'success' => true,
        'message' => 'Cadastro realizado com sucesso!',
        'usuario_id' => $pdo->lastInsertId()
    ]);
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Erro ao cadastrar: ' . $e->getMessage()
    ]);
}
?>