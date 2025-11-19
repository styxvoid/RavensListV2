<?php
// ============================================
// TESTE DE CONEXÃO E DADOS
// Use: http://localhost/raven-list/php/teste-conexao.php
// ============================================

header('Content-Type: application/json; charset=utf-8');

echo "<h1>🦇 Teste de Conexão - Raven's List</h1>";

// Teste 1: Verificar se config.php existe
echo "<h2>1. Verificando config.php</h2>";
if (file_exists('config.php')) {
    echo "✅ config.php encontrado<br>";
    require_once 'config.php';
} else {
    echo "❌ config.php NÃO encontrado<br>";
    die("Crie o arquivo config.php!");
}

// Teste 2: Verificar conexão
echo "<h2>2. Testando Conexão</h2>";
try {
    if (isset($pdo)) {
        echo "✅ Conexão PDO estabelecida<br>";
        echo "Database: " . DB_NAME . "<br>";
    } else {
        echo "❌ PDO não foi criado<br>";
        die();
    }
} catch (Exception $e) {
    echo "❌ Erro: " . $e->getMessage() . "<br>";
    die();
}

// Teste 3: Verificar tabelas
echo "<h2>3. Verificando Tabelas</h2>";
try {
    $stmt = $pdo->query("SHOW TABLES");
    $tabelas = $stmt->fetchAll(PDO::FETCH_COLUMN);
    
    echo "Total de tabelas: " . count($tabelas) . "<br>";
    echo "<ul>";
    foreach ($tabelas as $tabela) {
        echo "<li>✅ " . $tabela . "</li>";
    }
    echo "</ul>";
} catch (PDOException $e) {
    echo "❌ Erro ao listar tabelas: " . $e->getMessage() . "<br>";
}

// Teste 4: Verificar eventos
echo "<h2>4. Verificando Eventos</h2>";
try {
    $stmt = $pdo->query("SELECT * FROM eventos ORDER BY id");
    $eventos = $stmt->fetchAll();
    
    if (count($eventos) > 0) {
        echo "✅ Total de eventos: " . count($eventos) . "<br><br>";
        
        foreach ($eventos as $evento) {
            echo "<div style='background: #1a0000; border: 2px solid #8b0000; padding: 15px; margin: 10px 0; border-radius: 8px;'>";
            echo "<h3 style='color: #8b0000;'>" . $evento['titulo'] . "</h3>";
            echo "<p><strong>ID:</strong> " . $evento['id'] . "</p>";
            echo "<p><strong>Local:</strong> " . $evento['local'] . "</p>";
            echo "<p><strong>Capacidade:</strong> " . $evento['capacidade_total'] . "</p>";
            echo "<p><strong>Vendidos:</strong> " . $evento['ingressos_vendidos'] . "</p>";
            echo "<p><strong>Disponíveis:</strong> " . $evento['ingressos_disponiveis'] . "</p>";
            echo "<p><strong>Status:</strong> " . $evento['status_evento'] . "</p>";
            echo "</div>";
        }
    } else {
        echo "❌ Nenhum evento encontrado. Execute o schema.sql!<br>";
    }
} catch (PDOException $e) {
    echo "❌ Erro ao buscar eventos: " . $e->getMessage() . "<br>";
}

// Teste 5: Verificar lotes
echo "<h2>5. Verificando Lotes</h2>";
try {
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM lotes");
    $resultado = $stmt->fetch();
    echo "✅ Total de lotes: " . $resultado['total'] . "<br>";
    
    $stmt = $pdo->query("
        SELECT l.*, e.titulo as evento_titulo 
        FROM lotes l 
        INNER JOIN eventos e ON l.evento_id = e.id 
        ORDER BY e.id, l.numero_lote
    ");
    $lotes = $stmt->fetchAll();
    
    $eventoAtual = '';
    foreach ($lotes as $lote) {
        if ($eventoAtual != $lote['evento_titulo']) {
            $eventoAtual = $lote['evento_titulo'];
            echo "<h4 style='color: #8b0000; margin-top: 20px;'>→ " . $eventoAtual . "</h4>";
        }
        echo "<div style='margin-left: 20px; padding: 10px; background: rgba(139,0,0,0.1); margin: 5px 0;'>";
        echo "🎫 " . $lote['nome_lote'] . " - ";
        echo "Total: " . $lote['quantidade_total'] . " | ";
        echo "Vendidos: " . $lote['quantidade_vendida'] . " | ";
        echo "Disponíveis: " . $lote['quantidade_disponivel'] . " | ";
        echo "Status: " . $lote['status_lote'];
        echo "</div>";
    }
} catch (PDOException $e) {
    echo "❌ Erro ao buscar lotes: " . $e->getMessage() . "<br>";
}

// Teste 6: Verificar ingressos
echo "<h2>6. Verificando Ingressos Vendidos</h2>";
try {
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM ingressos WHERE status_ingresso = 'confirmado'");
    $resultado = $stmt->fetch();
    echo "✅ Total de ingressos confirmados: " . $resultado['total'] . "<br>";
    
    $stmt = $pdo->query("
        SELECT 
            e.titulo as evento,
            COUNT(i.id) as total_vendas,
            SUM(i.quantidade) as total_ingressos,
            SUM(i.valor_final) as receita_total
        FROM eventos e
        LEFT JOIN ingressos i ON e.id = i.evento_id AND i.status_ingresso = 'confirmado'
        GROUP BY e.id
    ");
    $vendas = $stmt->fetchAll();
    
    foreach ($vendas as $venda) {
        echo "<div style='margin: 10px 0; padding: 10px; background: rgba(0,139,0,0.1);'>";
        echo "🎭 <strong>" . $venda['evento'] . "</strong><br>";
        echo "Vendas: " . ($venda['total_vendas'] ?? 0) . " | ";
        echo "Ingressos: " . ($venda['total_ingressos'] ?? 0) . " | ";
        echo "Receita: R$ " . number_format($venda['receita_total'] ?? 0, 2, ',', '.');
        echo "</div>";
    }
} catch (PDOException $e) {
    echo "❌ Erro ao buscar ingressos: " . $e->getMessage() . "<br>";
}

// Teste 7: Testar API
echo "<h2>7. Testando API do CRUD</h2>";
echo "<p>Testando busca de evento ID 1:</p>";
try {
    $stmt = $pdo->prepare("SELECT * FROM eventos WHERE id = ?");
    $stmt->execute([1]);
    $evento = $stmt->fetch();
    
    if ($evento) {
        echo "<pre style='background: #000; color: #0f0; padding: 15px; border: 1px solid #8b0000;'>";
        echo json_encode($evento, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        echo "</pre>";
    } else {
        echo "❌ Evento ID 1 não encontrado<br>";
    }
} catch (PDOException $e) {
    echo "❌ Erro: " . $e->getMessage() . "<br>";
}

echo "<hr>";
echo "<h2>✅ Teste Concluído!</h2>";
echo "<p style='color: #8b0000; font-weight: bold;'>Se todos os testes passaram, o CRUD deve funcionar!</p>";
echo "<p><a href='../index.html' style='color: #8b0000;'>← Voltar para o site</a></p>";

// CSS para deixar bonito
echo "
<style>
    body {
        font-family: Georgia, serif;
        background: #0a0a0a;
        color: #fff;
        padding: 20px;
        max-width: 1200px;
        margin: 0 auto;
    }
    h1, h2, h3, h4 {
        color: #8b0000;
        text-shadow: 0 0 10px #8b0000;
    }
    a {
        color: #8b0000;
        text-decoration: none;
    }
    a:hover {
        text-shadow: 0 0 10px #8b0000;
    }
</style>
";
?>