<?php
// Configurações do banco de dados
define('DB_HOST', 'localhost');
define('DB_NAME', 'raven_list');
define('DB_USER', 'root');
define('DB_PASS', '');

// Conexão com PDO (mais seguro que mysqli)
try {
    $pdo = new PDO(
        "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4",
        DB_USER,
        DB_PASS,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false
        ]
    );
} catch (PDOException $e) {
    die(json_encode([
        'success' => false,
        'message' => 'Erro de conexão: ' . $e->getMessage()
    ]));
}

// Headers para permitir requisições AJAX
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
?>