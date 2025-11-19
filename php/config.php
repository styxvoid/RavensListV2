<?php
// ============================================
// CONFIGURAÇÕES DO BANCO DE DADOS (XAMPP/MySQL)
// ============================================

// Defina as credenciais do seu banco de dados
$host     = 'localhost';
$db_name  = 'raven_list';
$username = 'root'; // Usuário padrão do XAMPP
$password = '';     // Senha padrão do XAMPP (deixe vazio se não definiu uma)

$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
];

$dsn = "mysql:host=$host;dbname=$db_name;charset=utf8mb4";
$pdo = null;

try {
    $pdo = new PDO($dsn, $username, $password, $options);
} catch (\PDOException $e) {
    http_response_code(500);
    header('Content-Type: application/json');
    echo json_encode([
        'success' => false,
        'message' => 'Erro de conexão com o banco de dados: ' . $e->getMessage()
    ]);
    exit;
}

// Headers para permitir requisições AJAX
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
?>