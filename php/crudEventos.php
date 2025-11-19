<?php
// ============================================
// CRUD DE EVENTOS - BACKEND PHP CORRIGIDO
// ============================================

require_once 'config.php';

// Obter ação
$acao = $_GET['acao'] ?? $_POST['acao'] ?? '';

// ============================================
// BUSCAR DADOS DE UM EVENTO
// ============================================
if ($acao === 'buscar') {
    $evento_id = $_GET['id'] ?? 0;
    
    try {
        $stmt = $pdo->prepare("SELECT * FROM eventos WHERE id = ?");
        $stmt->execute([$evento_id]);
        $evento = $stmt->fetch();
        
        if ($evento) {
            echo json_encode([
                'success' => true,
                'evento' => $evento
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'Evento não encontrado'
            ]);
        }
    } catch (PDOException $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erro ao buscar evento: ' . $e->getMessage()
        ]);
    }
}

// ============================================
// LISTAR LOTES DE UM EVENTO
// ============================================
else if ($acao === 'listar_lotes') {
    $evento_id = $_GET['evento_id'] ?? 0;
    
    try {
        $stmt = $pdo->prepare("
            SELECT * FROM lotes 
            WHERE evento_id = ? 
            ORDER BY numero_lote ASC
        ");
        $stmt->execute([$evento_id]);
        $lotes = $stmt->fetchAll();
        
        echo json_encode([
            'success' => true,
            'lotes' => $lotes
        ]);
    } catch (PDOException $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erro ao listar lotes: ' . $e->getMessage()
        ]);
    }
}

// ============================================
// LISTAR INGRESSOS VENDIDOS
// ============================================
else if ($acao === 'listar_ingressos') {
    $evento_id = $_GET['evento_id'] ?? 0;
    
    try {
        $stmt = $pdo->prepare("
            SELECT 
                i.*,
                u.nome AS usuario_nome,
                u.email AS usuario_email,
                l.nome_lote
            FROM ingressos i
            INNER JOIN usuarios u ON i.usuario_id = u.id
            LEFT JOIN lotes l ON i.lote_id = l.id
            WHERE i.evento_id = ?
            ORDER BY i.data_compra DESC
        ");
        $stmt->execute([$evento_id]);
        $ingressos = $stmt->fetchAll();
        
        echo json_encode([
            'success' => true,
            'ingressos' => $ingressos
        ]);
    } catch (PDOException $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erro ao listar ingressos: ' . $e->getMessage()
        ]);
    }
}

// ============================================
// ADICIONAR NOVO LOTE
// ============================================
else if ($acao === 'adicionar_lote') {
    $evento_id = $_POST['evento_id'] ?? 0;
    $nome_lote = $_POST['nome_lote'] ?? '';
    $quantidade_total = $_POST['quantidade_total'] ?? 0;
    $preco_inteira = $_POST['preco_inteira'] ?? 0;
    $preco_meia = $_POST['preco_meia'] ?? 0;
    $data_inicio = $_POST['data_inicio'] ?? '';
    $data_fim = $_POST['data_fim'] ?? '';
    
    // Validações
    if (empty($nome_lote) || $quantidade_total <= 0 || $preco_inteira <= 0) {
        echo json_encode([
            'success' => false,
            'message' => 'Preencha todos os campos obrigatórios'
        ]);
        exit;
    }
    
    try {
        // Obter próximo número de lote
        $stmt = $pdo->prepare("
            SELECT COALESCE(MAX(numero_lote), 0) + 1 AS proximo_numero
            FROM lotes WHERE evento_id = ?
        ");
        $stmt->execute([$evento_id]);
        $resultado = $stmt->fetch();
        $numero_lote = $resultado['proximo_numero'];
        
        // Inserir lote
        $stmt = $pdo->prepare("
            INSERT INTO lotes (
                evento_id, nome_lote, numero_lote, quantidade_total, 
                quantidade_disponivel, preco_inteira, preco_meia, 
                data_inicio, data_fim
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ");
        
        $stmt->execute([
            $evento_id, $nome_lote, $numero_lote, $quantidade_total,
            $quantidade_total, $preco_inteira, $preco_meia,
            $data_inicio, $data_fim
        ]);
        
        // Atualizar capacidade do evento
        $stmt = $pdo->prepare("
            UPDATE eventos 
            SET ingressos_disponiveis = ingressos_disponiveis + ?
            WHERE id = ?
        ");
        $stmt->execute([$quantidade_total, $evento_id]);
        
        echo json_encode([
            'success' => true,
            'message' => 'Lote adicionado com sucesso!',
            'lote_id' => $pdo->lastInsertId()
        ]);
    } catch (PDOException $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erro ao adicionar lote: ' . $e->getMessage()
        ]);
    }
}

// ============================================
// EXCLUIR LOTE
// ============================================
else if ($acao === 'excluir_lote') {
    $lote_id = $_POST['lote_id'] ?? 0;
    
    try {
        // Verificar se há ingressos vendidos neste lote
        $stmt = $pdo->prepare("
            SELECT COUNT(*) as total FROM ingressos 
            WHERE lote_id = ? AND status_ingresso = 'confirmado'
        ");
        $stmt->execute([$lote_id]);
        $resultado = $stmt->fetch();
        
        if ($resultado['total'] > 0) {
            echo json_encode([
                'success' => false,
                'message' => 'Não é possível excluir lote com ingressos vendidos'
            ]);
            exit;
        }
        
        // Obter dados do lote antes de excluir
        $stmt = $pdo->prepare("SELECT * FROM lotes WHERE id = ?");
        $stmt->execute([$lote_id]);
        $lote = $stmt->fetch();
        
        if (!$lote) {
            echo json_encode([
                'success' => false,
                'message' => 'Lote não encontrado'
            ]);
            exit;
        }
        
        // Excluir lote
        $stmt = $pdo->prepare("DELETE FROM lotes WHERE id = ?");
        $stmt->execute([$lote_id]);
        
        // Atualizar capacidade do evento
        $stmt = $pdo->prepare("
            UPDATE eventos 
            SET ingressos_disponiveis = ingressos_disponiveis - ?
            WHERE id = ?
        ");
        $stmt->execute([$lote['quantidade_disponivel'], $lote['evento_id']]);
        
        echo json_encode([
            'success' => true,
            'message' => 'Lote excluído com sucesso!'
        ]);
    } catch (PDOException $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erro ao excluir lote: ' . $e->getMessage()
        ]);
    }
}

// ============================================
// CANCELAR INGRESSO
// ============================================
else if ($acao === 'cancelar_ingresso') {
    $ingresso_id = $_POST['ingresso_id'] ?? 0;
    
    try {
        // Buscar dados do ingresso
        $stmt = $pdo->prepare("SELECT * FROM ingressos WHERE id = ?");
        $stmt->execute([$ingresso_id]);
        $ingresso = $stmt->fetch();
        
        if (!$ingresso) {
            echo json_encode([
                'success' => false,
                'message' => 'Ingresso não encontrado'
            ]);
            exit;
        }
        
        // Atualizar status do ingresso
        $stmt = $pdo->prepare("
            UPDATE ingressos 
            SET status_ingresso = 'cancelado', data_cancelamento = NOW()
            WHERE id = ?
        ");
        $stmt->execute([$ingresso_id]);
        
        echo json_encode([
            'success' => true,
            'message' => 'Ingresso cancelado com sucesso!'
        ]);
    } catch (PDOException $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erro ao cancelar ingresso: ' . $e->getMessage()
        ]);
    }
}

// ============================================
// MARCAR INGRESSO COMO USADO
// ============================================
else if ($acao === 'marcar_usado') {
    $ingresso_id = $_POST['ingresso_id'] ?? 0;
    
    try {
        $stmt = $pdo->prepare("
            UPDATE ingressos 
            SET status_ingresso = 'usado', data_uso = NOW()
            WHERE id = ?
        ");
        $stmt->execute([$ingresso_id]);
        
        echo json_encode([
            'success' => true,
            'message' => 'Ingresso marcado como usado!'
        ]);
    } catch (PDOException $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erro ao marcar ingresso: ' . $e->getMessage()
        ]);
    }
}

// ============================================
// BUSCAR ESTATÍSTICAS DE VENDAS DETALHADAS
// ============================================
else if ($acao === 'estatisticas_vendas') {
    $evento_id = $_GET['evento_id'] ?? 0;
    
    try {
        // Total de ingressos por tipo
        $stmt = $pdo->prepare("
            SELECT 
                SUM(CASE WHEN tipo_ingresso = 'inteira' THEN quantidade ELSE 0 END) as total_inteira,
                SUM(CASE WHEN tipo_ingresso = 'meia' THEN quantidade ELSE 0 END) as total_meia,
                COUNT(*) as total_vendas
            FROM ingressos 
            WHERE evento_id = ? AND status_ingresso IN ('confirmado', 'usado')
        ");
        $stmt->execute([$evento_id]);
        $tipos = $stmt->fetch();
        
        $total_ingressos = $tipos['total_inteira'] + $tipos['total_meia'];
        
        // Calcular percentuais
        $percent_inteira = $total_ingressos > 0 ? round(($tipos['total_inteira'] / $total_ingressos) * 100, 1) : 0;
        $percent_meia = $total_ingressos > 0 ? round(($tipos['total_meia'] / $total_ingressos) * 100, 1) : 0;
        
        // Vendas por forma de pagamento
        $stmt = $pdo->prepare("
            SELECT 
                forma_pagamento,
                COUNT(*) as total
            FROM ingressos 
            WHERE evento_id = ? AND status_ingresso IN ('confirmado', 'usado')
            GROUP BY forma_pagamento
        ");
        $stmt->execute([$evento_id]);
        $pagamentos = $stmt->fetchAll();
        
        $vendas_pix = 0;
        $vendas_credito = 0;
        $vendas_debito = 0;
        $vendas_boleto = 0;
        
        foreach ($pagamentos as $pag) {
            switch($pag['forma_pagamento']) {
                case 'pix':
                    $vendas_pix = $pag['total'];
                    break;
                case 'cartao_credito':
                    $vendas_credito = $pag['total'];
                    break;
                case 'cartao_debito':
                    $vendas_debito = $pag['total'];
                    break;
                case 'boleto':
                    $vendas_boleto = $pag['total'];
                    break;
            }
        }
        
        echo json_encode([
            'success' => true,
            'estatisticas' => [
                'total_inteira' => $tipos['total_inteira'],
                'total_meia' => $tipos['total_meia'],
                'percent_inteira' => $percent_inteira,
                'percent_meia' => $percent_meia,
                'vendas_pix' => $vendas_pix,
                'vendas_credito' => $vendas_credito,
                'vendas_debito' => $vendas_debito,
                'vendas_boleto' => $vendas_boleto
            ]
        ]);
    } catch (PDOException $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erro ao buscar estatísticas: ' . $e->getMessage()
        ]);
    }
}

// ============================================
// AÇÃO INVÁLIDA
// ============================================
else {
    echo json_encode([
        'success' => false,
        'message' => 'Ação inválida'
    ]);
}
?>