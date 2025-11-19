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
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION, // Lança exceções em caso de erro
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,     // Retorna resultados como array associativo
    PDO::ATTR_EMULATE_PREPARES   => false,                // Desabilita emulação de prepared statements
];

$dsn = "mysql:host=$host;dbname=$db_name;charset=utf8mb4";
$pdo = null;

try {
    // Tenta estabelecer a conexão
    $pdo = new PDO($dsn, $username, $password, $options);
} catch (\PDOException $e) {
    // Se houver um erro, exibe uma mensagem JSON de falha (ideal para APIs)
    http_response_code(500); // Internal Server Error
    echo json_encode([
        'success' => false,
        'message' => 'Erro de conexão com o banco de dados: ' . $e->getMessage()
    ]);
    exit; // Termina a execução do script
}

// O objeto $pdo agora está disponível para ser usado por outros scripts PHP
?>