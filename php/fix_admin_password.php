<?php
// ============================================
// SCRIPT PARA CORRIGIR A SENHA DO ADMIN
// ============================================
require_once 'config.php';

$senha_admin = 'admin123';
$email_admin = 'admin@ravenslist.com';

// Hash correto para a senha "admin123"
$senha_hash = '$2y$10$qG6tZaC4dPVQvWf9rTF2.ePoeaALl5h6atD2Z1Tkw5.aTpp6bWrV.';

try {
    // Verifica se o admin existe
    $stmt = $pdo->prepare("SELECT id, nome, email FROM usuarios WHERE email = ?");
    $stmt->execute([$email_admin]);
    $admin = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($admin) {
        // Atualiza a senha do admin
        $stmt = $pdo->prepare("UPDATE usuarios SET senha = ?, tipo_usuario = 'admin', status = 'ativo' WHERE email = ?");
        $stmt->execute([$senha_hash, $email_admin]);

        echo "✅ Senha do admin atualizada com sucesso!\n";
        echo "📧 Email: admin@ravenslist.com\n";
        echo "🔑 Senha: admin123\n";
        echo "🔐 Novo hash: " . $senha_hash . "\n";
    } else {
        // Cria o admin se não existir
        $stmt = $pdo->prepare("INSERT INTO usuarios (nome, email, senha, tipo_usuario, status, data_cadastro) VALUES (?, ?, ?, 'admin', 'ativo', NOW())");
        $stmt->execute(['Admin Raven', $email_admin, $senha_hash]);

        echo "✅ Usuário admin criado com sucesso!\n";
        echo "📧 Email: admin@ravenslist.com\n";
        echo "🔑 Senha: admin123\n";
        echo "🔐 Hash: " . $senha_hash . "\n";
    }

    // Verifica se a senha está funcionando
    $stmt = $pdo->prepare("SELECT senha FROM usuarios WHERE email = ?");
    $stmt->execute([$email_admin]);
    $usuario = $stmt->fetch(PDO::FETCH_ASSOC);

    if (password_verify($senha_admin, $usuario['senha'])) {
        echo "\n✅ VERIFICAÇÃO: A senha está funcionando corretamente!\n";
    } else {
        echo "\n❌ ERRO: A senha não está funcionando!\n";
    }

} catch (PDOException $e) {
    echo "❌ Erro: " . $e->getMessage() . "\n";
}
?>
