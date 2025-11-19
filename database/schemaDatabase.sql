-- ============================================
-- SCRIPT PARA POPULAR O BANCO COM DADOS DE TESTE
-- Execute este script APÓS criar o schema completo
-- ============================================

USE raven_list;

-- ============================================
-- 1. INSERIR USUÁRIOS DE TESTE
-- ============================================

-- Admin (senha: admin123)
INSERT INTO usuarios (id, nome, email, senha, tipo_usuario, data_cadastro) VALUES
(1, 'Admin Raven', 'admin@ravenslist.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', NOW());

-- Clientes de teste (senha: cliente123)
INSERT INTO usuarios (nome, email, senha, tipo_usuario, data_cadastro) VALUES
('João Silva', 'joao@teste.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'cliente', NOW()),
('Maria Santos', 'maria@teste.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'cliente', NOW()),
('Pedro Oliveira', 'pedro@teste.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'cliente', NOW()),
('Ana Costa', 'ana@teste.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'cliente', NOW());

-- ============================================
-- 2. ATUALIZAR EVENTOS EXISTENTES
-- ============================================

UPDATE eventos SET
    cidade = 'Curitiba',
    estado = 'PR',
    ingressos_disponiveis = capacidade_total - ingressos_vendidos
WHERE cidade IS NULL OR cidade = '';

-- ============================================
-- 3. INSERIR LOTES PARA OS EVENTOS
-- ============================================

-- Lotes para Bio Dementia (evento_id = 1)
INSERT INTO lotes (evento_id, nome_lote, numero_lote, quantidade_total, quantidade_vendida, quantidade_disponivel, preco_inteira, preco_meia, data_inicio, data_fim, status_lote) VALUES
(1, '1º Lote - Early Bird', 1, 100, 75, 25, 80.00, 40.00, '2025-09-01 00:00:00', '2025-10-15 23:59:59', 'ativo'),
(1, '2º Lote - Normal', 2, 150, 50, 100, 120.00, 60.00, '2025-10-16 00:00:00', '2025-11-30 23:59:59', 'ativo'),
(1, '3º Lote - Última Hora', 3, 150, 0, 150, 150.00, 75.00, '2025-12-01 00:00:00', '2025-12-07 20:00:00', 'ativo');

-- Lotes para Noir Fest (evento_id = 2)
INSERT INTO lotes (evento_id, nome_lote, numero_lote, quantidade_total, quantidade_vendida, quantidade_disponivel, preco_inteira, preco_meia, data_inicio, data_fim, status_lote) VALUES
(2, '1º Lote - Pré-Venda', 1, 100, 80, 20, 70.00, 35.00, '2025-09-15 00:00:00', '2025-10-31 23:59:59', 'ativo'),
(2, '2º Lote - Final', 2, 200, 20, 180, 80.00, 40.00, '2025-11-01 00:00:00', '2025-11-25 18:00:00', 'ativo');

-- Lotes para Vampire's Night (evento_id = 3)
INSERT INTO lotes (evento_id, nome_lote, numero_lote, quantidade_total, quantidade_vendida, quantidade_disponivel, preco_inteira, preco_meia, data_inicio, data_fim, status_lote) VALUES
(3, '1º Lote - Super Early', 1, 150, 30, 120, 60.00, 30.00, '2025-10-01 00:00:00', '2025-11-15 23:59:59', 'ativo'),
(3, '2º Lote - Antecipado', 2, 200, 0, 200, 90.00, 45.00, '2025-11-16 00:00:00', '2025-12-31 23:59:59', 'ativo'),
(3, '3º Lote - Portaria', 3, 150, 0, 150, 120.00, 60.00, '2026-01-01 00:00:00', '2026-01-15 20:00:00', 'ativo');

-- ============================================
-- 4. INSERIR INGRESSOS VENDIDOS DE EXEMPLO
-- ============================================

-- Ingressos para Bio Dementia
INSERT INTO ingressos (codigo_ingresso, usuario_id, evento_id, lote_id, tipo_ingresso, quantidade, valor_unitario, valor_total, taxa_servico, valor_final, status_ingresso, forma_pagamento, data_compra, data_pagamento) VALUES
('RVN001-000001', 2, 1, 1, 'inteira', 2, 80.00, 160.00, 16.00, 176.00, 'confirmado', 'pix', '2025-09-10 14:30:00', '2025-09-10 14:32:00'),
('RVN001-000002', 3, 1, 1, 'meia', 1, 40.00, 40.00, 4.00, 44.00, 'confirmado', 'cartao_credito', '2025-09-15 18:20:00', '2025-09-15 18:20:00'),
('RVN001-000003', 4, 1, 2, 'inteira', 3, 120.00, 360.00, 36.00, 396.00, 'confirmado', 'pix', '2025-10-20 11:45:00', '2025-10-20 11:47:00'),
('RVN001-000004', 5, 1, 2, 'meia', 2, 60.00, 120.00, 12.00, 132.00, 'confirmado', 'cartao_debito', '2025-10-25 16:00:00', '2025-10-25 16:00:00');

-- Ingressos para Noir Fest
INSERT INTO ingressos (codigo_ingresso, usuario_id, evento_id, lote_id, tipo_ingresso, quantidade, valor_unitario, valor_total, taxa_servico, valor_final, status_ingresso, forma_pagamento, data_compra, data_pagamento) VALUES
('RVN002-000001', 2, 2, 4, 'inteira', 1, 70.00, 70.00, 7.00, 77.00, 'confirmado', 'pix', '2025-09-20 10:15:00', '2025-09-20 10:17:00'),
('RVN002-000002', 3, 2, 4, 'meia', 1, 35.00, 35.00, 3.50, 38.50, 'confirmado', 'pix', '2025-09-22 15:30:00', '2025-09-22 15:32:00'),
('RVN002-000003', 4, 2, 5, 'inteira', 2, 80.00, 160.00, 16.00, 176.00, 'confirmado', 'cartao_credito', '2025-11-05 19:00:00', '2025-11-05 19:00:00');

-- Ingressos para Vampire's Night
INSERT INTO ingressos (codigo_ingresso, usuario_id, evento_id, lote_id, tipo_ingresso, quantidade, valor_unitario, valor_total, taxa_servico, valor_final, status_ingresso, forma_pagamento, data_compra, data_pagamento) VALUES
('RVN003-000001', 2, 3, 6, 'inteira', 1, 60.00, 60.00, 6.00, 66.00, 'confirmado', 'pix', '2025-10-15 12:00:00', '2025-10-15 12:02:00'),
('RVN003-000002', 5, 3, 6, 'meia', 2, 30.00, 60.00, 6.00, 66.00, 'confirmado', 'cartao_debito', '2025-10-18 14:30:00', '2025-10-18 14:30:00');

-- ============================================
-- 5. INSERIR PAGAMENTOS CORRESPONDENTES
-- ============================================

INSERT INTO pagamentos (ingresso_id, usuario_id, valor_pago, forma_pagamento, status_pagamento, codigo_transacao, codigo_autorizacao, parcelas) VALUES
(1, 2, 176.00, 'pix', 'aprovado', 'PIX-20250910-143200-001', 'PIX-AUTO-001', 1),
(2, 3, 44.00, 'cartao_credito', 'aprovado', 'CC-20250915-182000-002', 'AUTH-CC-002', 1),
(3, 4, 396.00, 'pix', 'aprovado', 'PIX-20251020-114700-003', 'PIX-AUTO-003', 1),
(4, 5, 132.00, 'cartao_debito', 'aprovado', 'DB-20251025-160000-004', 'AUTH-DB-004', 1),
(5, 2, 77.00, 'pix', 'aprovado', 'PIX-20250920-101700-005', 'PIX-AUTO-005', 1),
(6, 3, 38.50, 'pix', 'aprovado', 'PIX-20250922-153200-006', 'PIX-AUTO-006', 1),
(7, 4, 176.00, 'cartao_credito', 'aprovado', 'CC-20251105-190000-007', 'AUTH-CC-007', 1),
(8, 2, 66.00, 'pix', 'aprovado', 'PIX-20251015-120200-008', 'PIX-AUTO-008', 1),
(9, 5, 66.00, 'cartao_debito', 'aprovado', 'DB-20251018-143000-009', 'AUTH-DB-009', 1);

-- ============================================
-- 6. ATUALIZAR ESTATÍSTICAS DOS EVENTOS
-- ============================================

-- Atualizar contadores do evento 1 (Bio Dementia)
UPDATE eventos SET 
    ingressos_vendidos = 125,
    ingressos_disponiveis = 275
WHERE id = 1;

-- Atualizar contadores do evento 2 (Noir Fest)
UPDATE eventos SET 
    ingressos_vendidos = 100,
    ingressos_disponiveis = 200
WHERE id = 2;

-- Atualizar contadores do evento 3 (Vampire's Night)
UPDATE eventos SET 
    ingressos_vendidos = 30,
    ingressos_disponiveis = 470
WHERE id = 3;

-- ============================================
-- VERIFICAÇÃO FINAL
-- ============================================

SELECT '✅ Banco de dados populado com sucesso!' AS status;

-- Verificar usuários
SELECT COUNT(*) AS total_usuarios FROM usuarios;

-- Verificar eventos
SELECT id, titulo, ingressos_vendidos, ingressos_disponiveis, status_evento FROM eventos;

-- Verificar lotes
SELECT evento_id, nome_lote, quantidade_vendida, quantidade_disponivel, status_lote FROM lotes ORDER BY evento_id, numero_lote;

-- Verificar ingressos
SELECT COUNT(*) AS total_ingressos, SUM(valor_final) AS receita_total FROM ingressos WHERE status_ingresso = 'confirmado';