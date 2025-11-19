-- ============================================
-- BANCO DE DADOS RAVEN'S LIST
-- Sistema completo de vendas de ingressos
-- ============================================

CREATE DATABASE IF NOT EXISTS raven_list;
USE raven_list;

-- ============================================
-- TABELA DE USUÁRIOS
-- ============================================
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    telefone VARCHAR(20),
    cpf VARCHAR(14) UNIQUE,
    data_nascimento DATE,
    tipo_usuario ENUM('cliente', 'admin') DEFAULT 'cliente',
    status ENUM('ativo', 'inativo', 'bloqueado') DEFAULT 'ativo',
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultima_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_tipo (tipo_usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABELA DE EVENTOS
-- ============================================
CREATE TABLE eventos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    descricao TEXT,
    data_evento DATETIME NOT NULL,
    local VARCHAR(200) NOT NULL,
    endereco_completo VARCHAR(500),
    cidade VARCHAR(100),
    estado VARCHAR(2),
    capacidade_total INT NOT NULL DEFAULT 100,
    ingressos_vendidos INT DEFAULT 0,
    ingressos_disponiveis INT,
    preco_inteira DECIMAL(10,2) NOT NULL,
    preco_meia DECIMAL(10,2),
    categoria VARCHAR(50),
    classificacao_etaria INT DEFAULT 18,
    imagem VARCHAR(255),
    banner VARCHAR(255),
    status_evento ENUM('ativo', 'esgotado', 'cancelado', 'finalizado') DEFAULT 'ativo',
    destaque BOOLEAN DEFAULT FALSE,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_data (data_evento),
    INDEX idx_status (status_evento),
    INDEX idx_categoria (categoria)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABELA DE LOTES DE INGRESSOS
-- ============================================
CREATE TABLE lotes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    evento_id INT NOT NULL,
    nome_lote VARCHAR(100) NOT NULL,
    numero_lote INT NOT NULL,
    quantidade_total INT NOT NULL,
    quantidade_vendida INT DEFAULT 0,
    quantidade_disponivel INT,
    preco_inteira DECIMAL(10,2) NOT NULL,
    preco_meia DECIMAL(10,2) NOT NULL,
    data_inicio DATETIME NOT NULL,
    data_fim DATETIME NOT NULL,
    status_lote ENUM('ativo', 'esgotado', 'encerrado') DEFAULT 'ativo',
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (evento_id) REFERENCES eventos(id) ON DELETE CASCADE,
    INDEX idx_evento (evento_id),
    INDEX idx_status (status_lote)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABELA DE INGRESSOS (VENDAS)
-- ============================================
CREATE TABLE ingressos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo_ingresso VARCHAR(50) UNIQUE NOT NULL,
    usuario_id INT NOT NULL,
    evento_id INT NOT NULL,
    lote_id INT,
    tipo_ingresso ENUM('inteira', 'meia') DEFAULT 'inteira',
    quantidade INT DEFAULT 1,
    valor_unitario DECIMAL(10,2) NOT NULL,
    valor_total DECIMAL(10,2) NOT NULL,
    taxa_servico DECIMAL(10,2) DEFAULT 0.00,
    valor_final DECIMAL(10,2) NOT NULL,
    status_ingresso ENUM('pendente', 'confirmado', 'cancelado', 'usado') DEFAULT 'pendente',
    forma_pagamento ENUM('pix', 'cartao_credito', 'cartao_debito', 'boleto') NOT NULL,
    data_compra TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_pagamento TIMESTAMP NULL,
    data_cancelamento TIMESTAMP NULL,
    data_uso TIMESTAMP NULL,
    qr_code TEXT,
    observacoes TEXT,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (evento_id) REFERENCES eventos(id) ON DELETE CASCADE,
    FOREIGN KEY (lote_id) REFERENCES lotes(id) ON DELETE SET NULL,
    INDEX idx_codigo (codigo_ingresso),
    INDEX idx_usuario (usuario_id),
    INDEX idx_evento (evento_id),
    INDEX idx_status (status_ingresso),
    INDEX idx_data_compra (data_compra)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABELA DE PAGAMENTOS
-- ============================================
CREATE TABLE pagamentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ingresso_id INT NOT NULL,
    usuario_id INT NOT NULL,
    valor_pago DECIMAL(10,2) NOT NULL,
    forma_pagamento ENUM('pix', 'cartao_credito', 'cartao_debito', 'boleto') NOT NULL,
    status_pagamento ENUM('pendente', 'aprovado', 'recusado', 'cancelado', 'estornado') DEFAULT 'pendente',
    transacao_id VARCHAR(100) UNIQUE,
    codigo_autorizacao VARCHAR(100),
    bandeira_cartao VARCHAR(50),
    ultimos_digitos VARCHAR(4),
    parcelas INT DEFAULT 1,
    data_vencimento DATE,
    data_pagamento TIMESTAMP NULL,
    ip_compra VARCHAR(45),
    observacoes TEXT,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ingresso_id) REFERENCES ingressos(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    INDEX idx_transacao (transacao_id),
    INDEX idx_status (status_pagamento),
    INDEX idx_data (data_pagamento)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABELA DE ESTATÍSTICAS DE VENDAS
-- ============================================
CREATE TABLE estatisticas_vendas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    evento_id INT NOT NULL,
    data_referencia DATE NOT NULL,
    total_vendas INT DEFAULT 0,
    total_receita DECIMAL(10,2) DEFAULT 0.00,
    vendas_inteira INT DEFAULT 0,
    vendas_meia INT DEFAULT 0,
    vendas_pix INT DEFAULT 0,
    vendas_cartao INT DEFAULT 0,
    vendas_canceladas INT DEFAULT 0,
    taxa_ocupacao DECIMAL(5,2) DEFAULT 0.00,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (evento_id) REFERENCES eventos(id) ON DELETE CASCADE,
    UNIQUE KEY uk_evento_data (evento_id, data_referencia),
    INDEX idx_data (data_referencia)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABELA DE LOG DE AÇÕES
-- ============================================
CREATE TABLE log_acoes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT,
    tipo_acao ENUM('compra', 'cancelamento', 'login', 'cadastro', 'edicao', 'exclusao') NOT NULL,
    descricao TEXT,
    tabela_afetada VARCHAR(50),
    registro_id INT,
    ip_origem VARCHAR(45),
    user_agent TEXT,
    data_acao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_usuario (usuario_id),
    INDEX idx_tipo (tipo_acao),
    INDEX idx_data (data_acao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- INSERIR OS 3 EVENTOS
-- ============================================
INSERT INTO eventos (
    titulo, 
    descricao, 
    data_evento, 
    local, 
    endereco_completo,
    cidade,
    estado,
    capacidade_total,
    ingressos_vendidos,
    ingressos_disponiveis,
    preco_inteira,
    preco_meia,
    categoria,
    classificacao_etaria,
    status_evento,
    destaque
) VALUES 
(
    'Bio Dementia',
    'Uma experiência sensorial única com performances de arte experimental, instalações interativas e sets de música industrial. O underground gótico em sua forma mais pura.',
    '2025-12-07 21:00:00',
    'Warehouse Underground',
    'Rua Industrial, 404 - Distrito',
    'São Paulo',
    'SP',
    450,
    287,
    163,
    85.00,
    42.50,
    'Arte Experimental',
    18,
    'ativo',
    TRUE
),
(
    'Noir Fest',
    'Festival boutique de música darkwave e post-punk com bandas nacionais e internacionais. Ambiente intimista para verdadeiros apreciadores da cena dark.',
    '2025-12-20 19:00:00',
    'Teatro das Trevas',
    'Av. Sombria, 777 - Centro Histórico',
    'Curitiba',
    'PR',
    350,
    312,
    38,
    120.00,
    60.00,
    'Festival Musical',
    16,
    'ativo',
    TRUE
),
(
    'Vampire''s Night',
    'O maior evento gótico do Brasil! Uma noite épica com 3 palcos simultâneos, performances teatrais, concurso de fantasias, zona VIP e experiências imersivas. Dress code: Gothic Victorian.',
    '2026-01-31 20:00:00',
    'Parque Gótico Industrial',
    'Complexo Cultural, s/n - Zona Portuária',
    'Rio de Janeiro',
    'RJ',
    2500,
    1847,
    653,
    180.00,
    90.00,
    'Mega Evento',
    18,
    'ativo',
    TRUE
);

-- ============================================
-- INSERIR LOTES PARA BIO DEMENTIA (450 pessoas)
-- ============================================
INSERT INTO lotes (evento_id, nome_lote, numero_lote, quantidade_total, quantidade_vendida, quantidade_disponivel, preco_inteira, preco_meia, data_inicio, data_fim, status_lote) VALUES
(1, '1º Lote - Early Bird', 1, 100, 100, 0, 65.00, 32.50, '2025-10-01 00:00:00', '2025-10-31 23:59:59', 'esgotado'),
(1, '2º Lote - Promocional', 2, 150, 150, 0, 75.00, 37.50, '2025-11-01 00:00:00', '2025-11-20 23:59:59', 'esgotado'),
(1, '3º Lote - Regular', 3, 150, 37, 113, 85.00, 42.50, '2025-11-21 00:00:00', '2025-12-07 20:00:00', 'ativo'),
(1, '4º Lote - Última Hora', 4, 50, 0, 50, 100.00, 50.00, '2025-12-07 00:00:00', '2025-12-07 20:00:00', 'ativo');

-- ============================================
-- INSERIR LOTES PARA NOIR FEST (350 pessoas)
-- ============================================
INSERT INTO lotes (evento_id, nome_lote, numero_lote, quantidade_total, quantidade_vendida, quantidade_disponivel, preco_inteira, preco_meia, data_inicio, data_fim, status_lote) VALUES
(2, '1º Lote - Pré-Venda', 1, 80, 80, 0, 90.00, 45.00, '2025-09-15 00:00:00', '2025-10-15 23:59:59', 'esgotado'),
(2, '2º Lote - Antecipado', 2, 120, 120, 0, 105.00, 52.50, '2025-10-16 00:00:00', '2025-11-30 23:59:59', 'esgotado'),
(2, '3º Lote - Normal', 3, 120, 112, 8, 120.00, 60.00, '2025-12-01 00:00:00', '2025-12-20 18:00:00', 'ativo'),
(2, '4º Lote - Portaria', 4, 30, 0, 30, 140.00, 70.00, '2025-12-20 18:00:00', '2025-12-20 23:00:00', 'ativo');

-- ============================================
-- INSERIR LOTES PARA VAMPIRE'S NIGHT (2500 pessoas)
-- ============================================
INSERT INTO lotes (evento_id, nome_lote, numero_lote, quantidade_total, quantidade_vendida, quantidade_disponivel, preco_inteira, preco_meia, data_inicio, data_fim, status_lote) VALUES
(3, '1º Lote - Super Early Bird', 1, 300, 300, 0, 120.00, 60.00, '2025-08-01 00:00:00', '2025-09-30 23:59:59', 'esgotado'),
(3, '2º Lote - Early Bird', 2, 500, 500, 0, 140.00, 70.00, '2025-10-01 00:00:00', '2025-11-30 23:59:59', 'esgotado'),
(3, '3º Lote - Promocional', 3, 600, 600, 0, 160.00, 80.00, '2025-12-01 00:00:00', '2025-12-31 23:59:59', 'esgotado'),
(3, '4º Lote - Regular', 4, 800, 447, 353, 180.00, 90.00, '2026-01-01 00:00:00', '2026-01-31 19:00:00', 'ativo'),
(3, '5º Lote - Última Chamada', 5, 300, 0, 300, 220.00, 110.00, '2026-01-31 00:00:00', '2026-01-31 19:00:00', 'ativo');

-- ============================================
-- INSERIR USUÁRIOS DE EXEMPLO
-- ============================================
INSERT INTO usuarios (nome, email, senha, telefone, cpf, data_nascimento, tipo_usuario, status) VALUES
('Administrador', 'admin@ravenslist.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '(11) 98888-8888', '000.000.000-00', '1990-01-01', 'admin', 'ativo'),
('Morgana Blackwood', 'morgana.black@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '(11) 99876-5432', '123.456.789-01', '1995-10-31', 'cliente', 'ativo'),
('Raven Darknight', 'raven.dark@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '(21) 98765-4321', '234.567.890-12', '1992-06-13', 'cliente', 'ativo'),
('Lilith Shadows', 'lilith.shadows@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '(41) 97654-3210', '345.678.901-23', '1997-12-25', 'cliente', 'ativo'),
('Viktor Nosferatu', 'viktor.nosferatu@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '(11) 96543-2109', '456.789.012-34', '1988-03-15', 'cliente', 'ativo'),
('Selene Moonlight', 'selene.moon@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '(21) 95432-1098', '567.890.123-45', '1994-09-21', 'cliente', 'ativo');

-- ============================================
-- INSERIR VENDAS DE INGRESSOS - BIO DEMENTIA
-- ============================================
INSERT INTO ingressos (codigo_ingresso, usuario_id, evento_id, lote_id, tipo_ingresso, quantidade, valor_unitario, valor_total, taxa_servico, valor_final, status_ingresso, forma_pagamento, data_compra, data_pagamento) VALUES
('BIO001-000001', 2, 1, 1, 'inteira', 2, 65.00, 130.00, 13.00, 143.00, 'confirmado', 'pix', '2025-10-05 14:23:00', '2025-10-05 14:25:00'),
('BIO001-000002', 3, 1, 1, 'meia', 1, 32.50, 32.50, 3.25, 35.75, 'confirmado', 'cartao_credito', '2025-10-12 19:45:00', '2025-10-12 19:45:00'),
('BIO001-000003', 4, 1, 2, 'inteira', 3, 75.00, 225.00, 22.50, 247.50, 'confirmado', 'pix', '2025-11-08 16:30:00', '2025-11-08 16:32:00'),
('BIO001-000004', 5, 1, 2, 'inteira', 2, 75.00, 150.00, 15.00, 165.00, 'confirmado', 'cartao_credito', '2025-11-15 20:10:00', '2025-11-15 20:10:00'),
('BIO001-000005', 2, 1, 3, 'meia', 2, 42.50, 85.00, 8.50, 93.50, 'confirmado', 'pix', '2025-11-25 10:15:00', '2025-11-25 10:17:00');

-- ============================================
-- INSERIR VENDAS DE INGRESSOS - NOIR FEST
-- ============================================
INSERT INTO ingressos (codigo_ingresso, usuario_id, evento_id, lote_id, tipo_ingresso, quantidade, valor_unitario, valor_total, taxa_servico, valor_final, status_ingresso, forma_pagamento, data_compra, data_pagamento) VALUES
('NOI002-000001', 3, 2, 1, 'inteira', 1, 90.00, 90.00, 9.00, 99.00, 'confirmado', 'pix', '2025-09-20 11:30:00', '2025-09-20 11:32:00'),
('NOI002-000002', 4, 2, 2, 'inteira', 2, 105.00, 210.00, 21.00, 231.00, 'confirmado', 'cartao_credito', '2025-10-25 15:20:00', '2025-10-25 15:20:00'),
('NOI002-000003', 5, 2, 2, 'meia', 1, 52.50, 52.50, 5.25, 57.75, 'confirmado', 'pix', '2025-11-05 18:45:00', '2025-11-05 18:47:00'),
('NOI002-000004', 2, 2, 3, 'inteira', 2, 120.00, 240.00, 24.00, 264.00, 'confirmado', 'cartao_credito', '2025-12-02 13:10:00', '2025-12-02 13:10:00'),
('NOI002-000005', 3, 2, 3, 'meia', 1, 60.00, 60.00, 6.00, 66.00, 'confirmado', 'pix', '2025-12-10 09:25:00', '2025-12-10 09:27:00');

-- ============================================
-- INSERIR VENDAS DE INGRESSOS - VAMPIRE'S NIGHT
-- ============================================
INSERT INTO ingressos (codigo_ingresso, usuario_id, evento_id, lote_id, tipo_ingresso, quantidade, valor_unitario, valor_total, taxa_servico, valor_final, status_ingresso, forma_pagamento, data_compra, data_pagamento) VALUES
('VAM003-000001', 2, 3, 1, 'inteira', 4, 120.00, 480.00, 48.00, 528.00, 'confirmado', 'pix', '2025-08-15 16:30:00', '2025-08-15 16:32:00'),
('VAM003-000002', 3, 3, 2, 'inteira', 3, 140.00, 420.00, 42.00, 462.00, 'confirmado', 'cartao_credito', '2025-10-20 14:15:00', '2025-10-20 14:15:00'),
('VAM003-000003', 4, 3, 2, 'meia', 2, 70.00, 140.00, 14.00, 154.00, 'confirmado', 'pix', '2025-11-10 19:40:00', '2025-11-10 19:42:00'),
('VAM003-000004', 5, 3, 3, 'inteira', 5, 160.00, 800.00, 80.00, 880.00, 'confirmado', 'cartao_credito', '2025-12-15 11:20:00', '2025-12-15 11:20:00'),
('VAM003-000005', 2, 3, 4, 'inteira', 2, 180.00, 360.00, 36.00, 396.00, 'confirmado', 'pix', '2026-01-05 15:50:00', '2026-01-05 15:52:00'),
('VAM003-000006', 3, 3, 4, 'meia', 3, 90.00, 270.00, 27.00, 297.00, 'confirmado', 'cartao_credito', '2026-01-12 20:10:00', '2026-01-12 20:10:00');

-- ============================================
-- INSERIR PAGAMENTOS CORRESPONDENTES
-- ============================================
INSERT INTO pagamentos (ingresso_id, usuario_id, valor_pago, forma_pagamento, status_pagamento, transacao_id, codigo_autorizacao, bandeira_cartao, ultimos_digitos, parcelas, data_pagamento, ip_compra) VALUES
-- Bio Dementia
(1, 2, 143.00, 'pix', 'aprovado', 'PIX-20251005-142500-001', 'PIX-AUTO-001', NULL, NULL, 1, '2025-10-05 14:25:00', '192.168.1.10'),
(2, 3, 35.75, 'cartao_credito', 'aprovado', 'CC-20251012-194500-002', 'AUTH-CC-002', 'Visa', '4532', 1, '2025-10-12 19:45:00', '192.168.1.11'),
(3, 4, 247.50, 'pix', 'aprovado', 'PIX-20251108-163200-003', 'PIX-AUTO-003', NULL, NULL, 1, '2025-11-08 16:32:00', '192.168.1.12'),
(4, 5, 165.00, 'cartao_credito', 'aprovado', 'CC-20251115-201000-004', 'AUTH-CC-004', 'Mastercard', '5678', 2, '2025-11-15 20:10:00', '192.168.1.13'),
(5, 2, 93.50, 'pix', 'aprovado', 'PIX-20251125-101700-005', 'PIX-AUTO-005', NULL, NULL, 1, '2025-11-25 10:17:00', '192.168.1.10'),

-- Noir Fest
(6, 3, 99.00, 'pix', 'aprovado', 'PIX-20250920-113200-006', 'PIX-AUTO-006', NULL, NULL, 1, '2025-09-20 11:32:00', '192.168.1.11'),
(7, 4, 231.00, 'cartao_credito', 'aprovado', 'CC-20251025-152000-007', 'AUTH-CC-007', 'Elo', '6789', 3, '2025-10-25 15:20:00', '192.168.1.12'),
(8, 5, 57.75, 'pix', 'aprovado', 'PIX-20251105-184700-008', 'PIX-AUTO-008', NULL, NULL, 1, '2025-11-05 18:47:00', '192.168.1.13'),
(9, 2, 264.00, 'cartao_credito', 'aprovado', 'CC-20251202-131000-009', 'AUTH-CC-009', 'Visa', '1234', 2, '2025-12-02 13:10:00', '192.168.1.10'),
(10, 3, 66.00, 'pix', 'aprovado', 'PIX-20251210-092700-010', 'PIX-AUTO-010', NULL, NULL, 1, '2025-12-10 09:27:00', '192.168.1.11'),

-- Vampire's Night
(11, 2, 528.00, 'pix', 'aprovado', 'PIX-20250815-163200-011', 'PIX-AUTO-011', NULL, NULL, 1, '2025-08-15 16:32:00', '192.168.1.10'),
(12, 3, 462.00, 'cartao_credito', 'aprovado', 'CC-20251020-141500-012', 'AUTH-CC-012', 'Mastercard', '8901', 4, '2025-10-20 14:15:00', '192.168.1.11'),
(13, 4, 154.00, 'pix', 'aprovado', 'PIX-20251110-194200-013', 'PIX-AUTO-013', NULL, NULL, 1, '2025-11-10 19:42:00', '192.168.1.12'),
(14, 5, 880.00, 'cartao_credito', 'aprovado', 'CC-20251215-112000-014', 'AUTH-CC-014', 'Visa', '2345', 5, '2025-12-15 11:20:00', '192.168.1.13'),
(15, 2, 396.00, 'pix', 'aprovado', 'PIX-20260105-155200-015', 'PIX-AUTO-015', NULL, NULL, 1, '2026-01-05 15:52:00', '192.168.1.10'),
(16, 3, 297.00, 'cartao_credito', 'aprovado', 'CC-20260112-201000-016', 'AUTH-CC-016', 'Elo', '3456', 3, '2026-01-12 20:10:00', '192.168.1.11');

-- ============================================
-- VIEWS ÚTEIS PARA RELATÓRIOS
-- ============================================

-- View de vendas por evento
CREATE VIEW vw_vendas_por_evento AS
SELECT 
    e.id AS evento_id,
    e.titulo,
    e.data_evento,
    e.local,
    e.capacidade_total,
    e.ingressos_vendidos,
    e.ingressos_disponiveis,
    COUNT(DISTINCT i.id) AS total_vendas,
    SUM(i.quantidade) AS total_ingressos,
    SUM(i.valor_final) AS receita_total,
    ROUND((e.ingressos_vendidos / e.capacidade_total * 100), 2) AS taxa_ocupacao
FROM eventos e
LEFT JOIN ingressos i ON e.id = i.evento_id 
    AND i.status_ingresso IN ('confirmado', 'usado')
GROUP BY e.id;

-- View de vendas por lote
CREATE VIEW vw_vendas_por_lote AS
SELECT 
    l.id AS lote_id,
    e.titulo AS evento,
    l.nome_lote,
    l.numero_lote,
    l.quantidade_total,
    l.quantidade_vendida,
    l.quantidade_disponivel,
    l.preco_inteira,
    l.preco_meia,
    l.status_lote,
    COUNT(i.id) AS total_transacoes,
    SUM(i.valor_final) AS receita_lote,
    ROUND((l.quantidade_vendida / l.quantidade_total * 100), 2) AS percentual_vendido
FROM lotes l
INNER JOIN eventos e ON l.evento_id = e.id
LEFT JOIN ingressos i ON l.id = i.lote_id AND i.status_ingresso = 'confirmado'
GROUP BY l.id;

-- View de histórico de compras do usuário
CREATE VIEW vw_historico_compras AS
SELECT 
    u.id AS usuario_id,
    u.nome AS usuario_nome,
    u.email,
    i.codigo_ingresso,
    e.titulo AS evento_titulo,
    e.data_evento,
    l.nome_lote,
    i.quantidade,
    i.tipo_ingresso,
    i.valor_final,
    i.status_ingresso,
    i.forma_pagamento,
    i.data_compra,
    p.status_pagamento
FROM usuarios u
INNER JOIN ingressos i ON u.id = i.usuario_id
INNER JOIN eventos e ON i.evento_id = e.id
LEFT JOIN lotes l ON i.lote_id = l.id
LEFT JOIN pagamentos p ON i.id = p.ingresso_id
ORDER BY i.data_compra DESC;

-- View de estatísticas gerais
CREATE VIEW vw_estatisticas_gerais AS
SELECT 
    COUNT(DISTINCT u.id) AS total_usuarios,
    COUNT(DISTINCT e.id) AS total_eventos,
    COUNT(DISTINCT i.id) AS total_vendas,
    SUM(i.quantidade) AS total_ingressos_vendidos,
    SUM(i.valor_final) AS receita_total,
    ROUND(AVG(i.valor_final), 2) AS ticket_medio,
    SUM(CASE WHEN i.forma_pagamento = 'pix' THEN 1 ELSE 0 END) AS vendas_pix,
    SUM(CASE WHEN i.forma_pagamento IN ('cartao_credito', 'cartao_debito') THEN 1 ELSE 0 END) AS vendas_cartao
FROM usuarios u
CROSS JOIN eventos e
LEFT JOIN ingressos i ON i.status_ingresso IN ('confirmado', 'usado');

-- View de ranking de eventos mais vendidos
CREATE VIEW vw_ranking_eventos AS
SELECT 
    e.id,
    e.titulo,
    e.data_evento,
    e.capacidade_total,
    e.ingressos_vendidos,
    COUNT(i.id) AS total_transacoes,
    SUM(i.valor_final) AS receita,
    ROUND((e.ingressos_vendidos / e.capacidade_total * 100), 2) AS taxa_ocupacao
FROM eventos e
LEFT JOIN ingressos i ON e.id = i.evento_id AND i.status_ingresso = 'confirmado'
GROUP BY e.id
ORDER BY receita DESC;

-- ============================================
-- TRIGGERS PARA AUTOMAÇÃO
-- ============================================

-- Trigger para atualizar ingressos disponíveis ao vender
DELIMITER //
CREATE TRIGGER tr_atualizar_ingressos_disponiveis
AFTER INSERT ON ingressos
FOR EACH ROW
BEGIN
    IF NEW.status_ingresso = 'confirmado' THEN
        -- Atualizar evento
        UPDATE eventos 
        SET 
            ingressos_vendidos = ingressos_vendidos + NEW.quantidade,
            ingressos_disponiveis = capacidade_total - (ingressos_vendidos + NEW.quantidade)
        WHERE id = NEW.evento_id;
        
        -- Atualizar lote
        IF NEW.lote_id IS NOT NULL THEN
            UPDATE lotes
            SET 
                quantidade_vendida = quantidade_vendida + NEW.quantidade,
                quantidade_disponivel = quantidade_total - (quantidade_vendida + NEW.quantidade)
            WHERE id = NEW.lote_id;
            
            -- Atualizar status do lote se esgotado
            UPDATE lotes
            SET status_lote = 'esgotado'
            WHERE id = NEW.lote_id AND quantidade_disponivel <= 0;
        END IF;
        
        -- Atualizar status do evento se esgotado
        UPDATE eventos 
        SET status_evento = 'esgotado'
        WHERE id = NEW.evento_id 
        AND ingressos_disponiveis <= 0;
    END IF;
END//

-- Trigger para devolver ingressos ao cancelar
CREATE TRIGGER tr_devolver_ingressos_cancelados
AFTER UPDATE ON ingressos
FOR EACH ROW
BEGIN
    IF OLD.status_ingresso = 'confirmado' AND NEW.status_ingresso = 'cancelado' THEN
        -- Devolver no evento
        UPDATE eventos 
        SET 
            ingressos_vendidos = ingressos_vendidos - NEW.quantidade,
            ingressos_disponiveis = capacidade_total - (ingressos_vendidos - NEW.quantidade)
        WHERE id = NEW.evento_id;
        
        -- Devolver no lote
        IF NEW.lote_id IS NOT NULL THEN
            UPDATE lotes
            SET 
                quantidade_vendida = quantidade_vendida - NEW.quantidade,
                quantidade_disponivel = quantidade_total - (quantidade_vendida - NEW.quantidade),
                status_lote = 'ativo'
            WHERE id = NEW.lote_id;
        END IF;
        
        -- Reativar evento se estava esgotado
        UPDATE eventos 
        SET status_evento = 'ativo'
        WHERE id = NEW.evento_id 
        AND status_evento = 'esgotado'
        AND ingressos_disponiveis > 0;
    END IF;
END//

-- Trigger para registrar log de compra
CREATE TRIGGER tr_log_compra_ingresso
AFTER INSERT ON ingressos
FOR EACH ROW
BEGIN
    INSERT INTO log_acoes (
        usuario_id,
        tipo_acao,
        descricao,
        tabela_afetada,
        registro_id
    ) VALUES (
        NEW.usuario_id,
        'compra',
        CONCAT('Compra de ', NEW.quantidade, ' ingresso(s) - Código: ', NEW.codigo_ingresso),
        'ingressos',
        NEW.id
    );
END//

-- Trigger para registrar log de cancelamento
CREATE TRIGGER tr_log_cancelamento_ingresso
AFTER UPDATE ON ingressos
FOR EACH ROW
BEGIN
    IF OLD.status_ingresso = 'confirmado' AND NEW.status_ingresso = 'cancelado' THEN
        INSERT INTO log_acoes (
            usuario_id,
            tipo_acao,
            descricao,
            tabela_afetada,
            registro_id
        ) VALUES (
            NEW.usuario_id,
            'cancelamento',
            CONCAT('Cancelamento de ', NEW.quantidade, ' ingresso(s) - Código: ', NEW.codigo_ingresso),
            'ingressos',
            NEW.id
        );
    END IF;
END//

DELIMITER ;

-- ============================================
-- PROCEDURES ÚTEIS
-- ============================================

-- Procedure para gerar código único de ingresso
DELIMITER //
CREATE PROCEDURE sp_gerar_codigo_ingresso(
    IN p_evento_id INT,
    OUT p_codigo VARCHAR(50)
)
BEGIN
    DECLARE v_prefixo VARCHAR(10);
    DECLARE v_numero INT;
    
    -- Gerar prefixo baseado no evento
    SELECT 
        CASE 
            WHEN id = 1 THEN 'BIO'
            WHEN id = 2 THEN 'NOI'
            WHEN id = 3 THEN 'VAM'
            ELSE 'RVN'
        END
    INTO v_prefixo
    FROM eventos WHERE id = p_evento_id;
    
    -- Obter próximo número
    SELECT COALESCE(MAX(CAST(SUBSTRING(codigo_ingresso, -6) AS UNSIGNED)), 0) + 1 
    INTO v_numero
    FROM ingressos 
    WHERE evento_id = p_evento_id;
    
    -- Montar código
    SET p_codigo = CONCAT(v_prefixo, LPAD(p_evento_id, 3, '0'), '-', LPAD(v_numero, 6, '0'));
END//

-- Procedure para relatório de vendas por período
CREATE PROCEDURE sp_relatorio_vendas_periodo(
    IN p_data_inicio DATE,
    IN p_data_fim DATE
)
BEGIN
    SELECT 
        e.titulo AS evento,
        DATE(i.data_compra) AS data,
        COUNT(i.id) AS total_vendas,
        SUM(i.quantidade) AS total_ingressos,
        SUM(CASE WHEN i.tipo_ingresso = 'inteira' THEN i.quantidade ELSE 0 END) AS qtd_inteira,
        SUM(CASE WHEN i.tipo_ingresso = 'meia' THEN i.quantidade ELSE 0 END) AS qtd_meia,
        SUM(i.valor_final) AS receita,
        ROUND(AVG(i.valor_final), 2) AS ticket_medio
    FROM ingressos i
    INNER JOIN eventos e ON i.evento_id = e.id
    WHERE DATE(i.data_compra) BETWEEN p_data_inicio AND p_data_fim
    AND i.status_ingresso IN ('confirmado', 'usado')
    GROUP BY e.id, DATE(i.data_compra)
    ORDER BY data DESC, receita DESC;
END//

-- Procedure para relatório de vendas por lote
CREATE PROCEDURE sp_relatorio_vendas_lote(
    IN p_evento_id INT
)
BEGIN
    SELECT 
        l.numero_lote,
        l.nome_lote,
        l.quantidade_total,
        l.quantidade_vendida,
        l.quantidade_disponivel,
        CONCAT('R$ ', FORMAT(l.preco_inteira, 2)) AS preco_inteira,
        CONCAT('R$ ', FORMAT(l.preco_meia, 2)) AS preco_meia,
        l.status_lote,
        COUNT(i.id) AS total_transacoes,
        CONCAT('R$ ', FORMAT(SUM(i.valor_final), 2)) AS receita_total,
        ROUND((l.quantidade_vendida / l.quantidade_total * 100), 2) AS percentual_vendido
    FROM lotes l
    LEFT JOIN ingressos i ON l.id = i.lote_id AND i.status_ingresso = 'confirmado'
    WHERE l.evento_id = p_evento_id
    GROUP BY l.id
    ORDER BY l.numero_lote;
END//

-- Procedure para dashboard administrativo
CREATE PROCEDURE sp_dashboard_admin()
BEGIN
    -- Resumo geral
    SELECT 
        'Resumo Geral' AS secao,
        COUNT(DISTINCT e.id) AS total_eventos,
        SUM(e.capacidade_total) AS capacidade_total,
        SUM(e.ingressos_vendidos) AS ingressos_vendidos,
        SUM(e.ingressos_disponiveis) AS ingressos_disponiveis,
        CONCAT('R$ ', FORMAT(SUM(i.valor_final), 2)) AS receita_total,
        COUNT(DISTINCT u.id) AS total_clientes
    FROM eventos e
    LEFT JOIN ingressos i ON e.id = i.evento_id AND i.status_ingresso = 'confirmado'
    LEFT JOIN usuarios u ON i.usuario_id = u.id;
    
    -- Eventos individuais
    SELECT 
        e.titulo AS evento,
        e.data_evento,
        e.capacidade_total,
        e.ingressos_vendidos,
        e.ingressos_disponiveis,
        ROUND((e.ingressos_vendidos / e.capacidade_total * 100), 2) AS ocupacao_percentual,
        CONCAT('R$ ', FORMAT(SUM(i.valor_final), 2)) AS receita,
        e.status_evento
    FROM eventos e
    LEFT JOIN ingressos i ON e.id = i.evento_id AND i.status_ingresso = 'confirmado'
    GROUP BY e.id
    ORDER BY e.data_evento;
END//

DELIMITER ;

-- ============================================
-- INSERIR ESTATÍSTICAS INICIAIS
-- ============================================
INSERT INTO estatisticas_vendas (evento_id, data_referencia, total_vendas, total_receita, vendas_inteira, vendas_meia, vendas_pix, vendas_cartao, taxa_ocupacao)
SELECT 
    e.id,
    CURDATE(),
    COUNT(i.id),
    COALESCE(SUM(i.valor_final), 0),
    SUM(CASE WHEN i.tipo_ingresso = 'inteira' THEN i.quantidade ELSE 0 END),
    SUM(CASE WHEN i.tipo_ingresso = 'meia' THEN i.quantidade ELSE 0 END),
    SUM(CASE WHEN i.forma_pagamento = 'pix' THEN 1 ELSE 0 END),
    SUM(CASE WHEN i.forma_pagamento IN ('cartao_credito', 'cartao_debito') THEN 1 ELSE 0 END),
    ROUND((e.ingressos_vendidos / e.capacidade_total * 100), 2)
FROM eventos e
LEFT JOIN ingressos i ON e.id = i.evento_id AND i.status_ingresso = 'confirmado'
GROUP BY e.id;

-- ============================================
-- INFORMAÇÕES FINAIS
-- ============================================
SELECT '✅ Banco de dados Raven\'s List criado com sucesso!' AS status;
SELECT '📊 ESTATÍSTICAS DO BANCO' AS info;
SELECT CONCAT('Total de tabelas: ', COUNT(*)) AS total FROM information_schema.tables WHERE table_schema = 'raven_list' AND table_type = 'BASE TABLE';
SELECT CONCAT('Total de views: ', COUNT(*)) AS total FROM information_schema.views WHERE table_schema = 'raven_list';

-- Mostrar resumo dos eventos
SELECT 
    '🎭 RESUMO DOS EVENTOS' AS info,
    titulo,
    capacidade_total,
    ingressos_vendidos,
    ingressos_disponiveis,
    CONCAT(ROUND((ingressos_vendidos / capacidade_total * 100), 2), '%') AS ocupacao
FROM eventos
ORDER BY data_evento;-- ============================================
-- BANCO DE DADOS RAVEN'S LIST
-- Sistema completo de vendas de ingressos
-- ============================================

CREATE DATABASE IF NOT EXISTS raven_list;
USE raven_list;

-- ============================================
-- TABELA DE USUÁRIOS
-- ============================================
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    telefone VARCHAR(20),
    cpf VARCHAR(14) UNIQUE,
    data_nascimento DATE,
    tipo_usuario ENUM('cliente', 'admin') DEFAULT 'cliente',
    status ENUM('ativo', 'inativo', 'bloqueado') DEFAULT 'ativo',
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultima_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_tipo (tipo_usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABELA DE EVENTOS
-- ============================================
CREATE TABLE eventos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    descricao TEXT,
    data_evento DATETIME NOT NULL,
    local VARCHAR(200) NOT NULL,
    endereco_completo VARCHAR(500),
    cidade VARCHAR(100),
    estado VARCHAR(2),
    capacidade_total INT NOT NULL DEFAULT 100,
    ingressos_vendidos INT DEFAULT 0,
    ingressos_disponiveis INT,
    preco_inteira DECIMAL(10,2) NOT NULL,
    preco_meia DECIMAL(10,2),
    categoria VARCHAR(50),
    classificacao_etaria INT DEFAULT 18,
    imagem VARCHAR(255),
    banner VARCHAR(255),
    status_evento ENUM('ativo', 'esgotado', 'cancelado', 'finalizado') DEFAULT 'ativo',
    destaque BOOLEAN DEFAULT FALSE,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_data (data_evento),
    INDEX idx_status (status_evento),
    INDEX idx_categoria (categoria)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABELA DE INGRESSOS (VENDAS)
-- ============================================
CREATE TABLE ingressos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo_ingresso VARCHAR(50) UNIQUE NOT NULL,
    usuario_id INT NOT NULL,
    evento_id INT NOT NULL,
    tipo_ingresso ENUM('inteira', 'meia') DEFAULT 'inteira',
    quantidade INT DEFAULT 1,
    valor_unitario DECIMAL(10,2) NOT NULL,
    valor_total DECIMAL(10,2) NOT NULL,
    taxa_servico DECIMAL(10,2) DEFAULT 0.00,
    valor_final DECIMAL(10,2) NOT NULL,
    status_ingresso ENUM('pendente', 'confirmado', 'cancelado', 'usado') DEFAULT 'pendente',
    forma_pagamento ENUM('pix', 'cartao_credito', 'cartao_debito', 'boleto') NOT NULL,
    data_compra TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_pagamento TIMESTAMP NULL,
    data_cancelamento TIMESTAMP NULL,
    data_uso TIMESTAMP NULL,
    qr_code TEXT,
    observacoes TEXT,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (evento_id) REFERENCES eventos(id) ON DELETE CASCADE,
    INDEX idx_codigo (codigo_ingresso),
    INDEX idx_usuario (usuario_id),
    INDEX idx_evento (evento_id),
    INDEX idx_status (status_ingresso),
    INDEX idx_data_compra (data_compra)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABELA DE PAGAMENTOS
-- ============================================
CREATE TABLE pagamentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ingresso_id INT NOT NULL,
    usuario_id INT NOT NULL,
    valor_pago DECIMAL(10,2) NOT NULL,
    forma_pagamento ENUM('pix', 'cartao_credito', 'cartao_debito', 'boleto') NOT NULL,
    status_pagamento ENUM('pendente', 'aprovado', 'recusado', 'cancelado', 'estornado') DEFAULT 'pendente',
    transacao_id VARCHAR(100) UNIQUE,
    codigo_autorizacao VARCHAR(100),
    bandeira_cartao VARCHAR(50),
    ultimos_digitos VARCHAR(4),
    parcelas INT DEFAULT 1,
    data_vencimento DATE,
    data_pagamento TIMESTAMP NULL,
    ip_compra VARCHAR(45),
    observacoes TEXT,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ingresso_id) REFERENCES ingressos(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    INDEX idx_transacao (transacao_id),
    INDEX idx_status (status_pagamento),
    INDEX idx_data (data_pagamento)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABELA DE ESTATÍSTICAS DE VENDAS
-- ============================================
CREATE TABLE estatisticas_vendas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    evento_id INT NOT NULL,
    data_referencia DATE NOT NULL,
    total_vendas INT DEFAULT 0,
    total_receita DECIMAL(10,2) DEFAULT 0.00,
    vendas_inteira INT DEFAULT 0,
    vendas_meia INT DEFAULT 0,
    vendas_pix INT DEFAULT 0,
    vendas_cartao INT DEFAULT 0,
    vendas_canceladas INT DEFAULT 0,
    taxa_ocupacao DECIMAL(5,2) DEFAULT 0.00,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (evento_id) REFERENCES eventos(id) ON DELETE CASCADE,
    UNIQUE KEY uk_evento_data (evento_id, data_referencia),
    INDEX idx_data (data_referencia)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABELA DE LOG DE AÇÕES
-- ============================================
CREATE TABLE log_acoes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT,
    tipo_acao ENUM('compra', 'cancelamento', 'login', 'cadastro', 'edicao', 'exclusao') NOT NULL,
    descricao TEXT,
    tabela_afetada VARCHAR(50),
    registro_id INT,
    ip_origem VARCHAR(45),
    user_agent TEXT,
    data_acao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_usuario (usuario_id),
    INDEX idx_tipo (tipo_acao),
    INDEX idx_data (data_acao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- INSERIR OS 3 EVENTOS PADRÃO
-- ============================================
INSERT INTO eventos (
    titulo, 
    descricao, 
    data_evento, 
    local, 
    endereco_completo,
    cidade,
    estado,
    capacidade_total,
    ingressos_disponiveis,
    preco_inteira,
    preco_meia,
    categoria,
    classificacao_etaria,
    status_evento,
    destaque
) VALUES 
(
    'Noite dos Vampiros',
    'Uma noite imersiva no universo vampírico com DJs góticos internacionais, performances teatrais e decoração macabra. Dress code: apenas preto e vermelho.',
    '2025-11-25 22:00:00',
    'Catacumbas Club',
    'Rua das Sombras, 666 - Centro',
    'São Paulo',
    'SP',
    500,
    500,
    80.00,
    40.00,
    'Festa Gótica',
    18,
    'ativo',
    TRUE
),
(
    'Festival das Almas',
    'Celebração gótica com bandas de darkwave, metal sinfônico e performances de dança macabra. Uma experiência inesquecível entre lápides e neblina.',
    '2025-12-13 20:00:00',
    'Cemitério do Rock',
    'Av. dos Mártires, 1313 - Zona Sul',
    'Rio de Janeiro',
    'RJ',
    800,
    800,
    120.00,
    60.00,
    'Festival',
    16,
    'ativo',
    TRUE
),
(
    'Baile das Sombras',
    'Réveillon gótico em mansão vitoriana com música dark, bar temático e queima de fogos em vermelho e preto. Entrada apenas com traje gótico completo.',
    '2025-12-31 23:00:00',
    'Mansão Obscura',
    'Rua Vitoriana, 13 - Batel',
    'Curitiba',
    'PR',
    300,
    300,
    250.00,
    125.00,
    'Réveillon',
    18,
    'ativo',
    TRUE
);

-- ============================================
-- CRIAR USUÁRIO ADMIN PADRÃO
-- Senha: admin123 (hash bcrypt)
-- ============================================
INSERT INTO usuarios (
    nome,
    email,
    senha,
    tipo_usuario,
    status
) VALUES (
    'Administrador',
    'admin@ravenslist.com',
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    'admin',
    'ativo'
);

-- ============================================
-- VIEWS ÚTEIS PARA RELATÓRIOS
-- ============================================

-- View de vendas por evento
CREATE VIEW vw_vendas_por_evento AS
SELECT 
    e.id AS evento_id,
    e.titulo,
    e.data_evento,
    e.local,
    e.capacidade_total,
    COUNT(i.id) AS total_ingressos_vendidos,
    SUM(i.quantidade) AS total_quantidade,
    SUM(i.valor_final) AS receita_total,
    (SUM(i.quantidade) / e.capacidade_total * 100) AS taxa_ocupacao
FROM eventos e
LEFT JOIN ingressos i ON e.id = i.evento_id 
    AND i.status_ingresso IN ('confirmado', 'usado')
GROUP BY e.id;

-- View de histórico de compras do usuário
CREATE VIEW vw_historico_compras AS
SELECT 
    u.id AS usuario_id,
    u.nome AS usuario_nome,
    u.email,
    i.codigo_ingresso,
    e.titulo AS evento_titulo,
    e.data_evento,
    i.quantidade,
    i.tipo_ingresso,
    i.valor_final,
    i.status_ingresso,
    i.forma_pagamento,
    i.data_compra
FROM usuarios u
INNER JOIN ingressos i ON u.id = i.usuario_id
INNER JOIN eventos e ON i.evento_id = e.id
ORDER BY i.data_compra DESC;

-- View de estatísticas gerais
CREATE VIEW vw_estatisticas_gerais AS
SELECT 
    COUNT(DISTINCT u.id) AS total_usuarios,
    COUNT(DISTINCT e.id) AS total_eventos,
    COUNT(i.id) AS total_vendas,
    SUM(i.valor_final) AS receita_total,
    AVG(i.valor_final) AS ticket_medio
FROM usuarios u
CROSS JOIN eventos e
LEFT JOIN ingressos i ON i.status_ingresso IN ('confirmado', 'usado');

-- ============================================
-- TRIGGERS PARA AUTOMAÇÃO
-- ============================================

-- Trigger para atualizar ingressos disponíveis ao vender
DELIMITER //
CREATE TRIGGER tr_atualizar_ingressos_disponiveis
AFTER INSERT ON ingressos
FOR EACH ROW
BEGIN
    IF NEW.status_ingresso = 'confirmado' THEN
        UPDATE eventos 
        SET 
            ingressos_vendidos = ingressos_vendidos + NEW.quantidade,
            ingressos_disponiveis = capacidade_total - (ingressos_vendidos + NEW.quantidade)
        WHERE id = NEW.evento_id;
        
        -- Atualizar status se esgotado
        UPDATE eventos 
        SET status_evento = 'esgotado'
        WHERE id = NEW.evento_id 
        AND ingressos_disponiveis <= 0;
    END IF;
END//

-- Trigger para devolver ingressos ao cancelar
CREATE TRIGGER tr_devolver_ingressos_cancelados
AFTER UPDATE ON ingressos
FOR EACH ROW
BEGIN
    IF OLD.status_ingresso = 'confirmado' AND NEW.status_ingresso = 'cancelado' THEN
        UPDATE eventos 
        SET 
            ingressos_vendidos = ingressos_vendidos - NEW.quantidade,
            ingressos_disponiveis = capacidade_total - (ingressos_vendidos - NEW.quantidade)
        WHERE id = NEW.evento_id;
        
        -- Reativar evento se estava esgotado
        UPDATE eventos 
        SET status_evento = 'ativo'
        WHERE id = NEW.evento_id 
        AND status_evento = 'esgotado'
        AND ingressos_disponiveis > 0;
    END IF;
END//

-- Trigger para registrar log de compra
CREATE TRIGGER tr_log_compra_ingresso
AFTER INSERT ON ingressos
FOR EACH ROW
BEGIN
    INSERT INTO log_acoes (
        usuario_id,
        tipo_acao,
        descricao,
        tabela_afetada,
        registro_id
    ) VALUES (
        NEW.usuario_id,
        'compra',
        CONCAT('Compra de ', NEW.quantidade, ' ingresso(s) para evento ID: ', NEW.evento_id),
        'ingressos',
        NEW.id
    );
END//

DELIMITER ;

-- ============================================
-- PROCEDURES ÚTEIS
-- ============================================

-- Procedure para gerar código único de ingresso
DELIMITER //
CREATE PROCEDURE sp_gerar_codigo_ingresso(
    IN p_evento_id INT,
    OUT p_codigo VARCHAR(50)
)
BEGIN
    DECLARE v_prefixo VARCHAR(10);
    DECLARE v_numero INT;
    
    SELECT CONCAT('RVN', LPAD(id, 3, '0')) INTO v_prefixo
    FROM eventos WHERE id = p_evento_id;
    
    SELECT COALESCE(MAX(CAST(SUBSTRING(codigo_ingresso, -6) AS UNSIGNED)), 0) + 1 
    INTO v_numero
    FROM ingressos 
    WHERE evento_id = p_evento_id;
    
    SET p_codigo = CONCAT(v_prefixo, '-', LPAD(v_numero, 6, '0'));
END//

-- Procedure para relatório de vendas
CREATE PROCEDURE sp_relatorio_vendas(
    IN p_data_inicio DATE,
    IN p_data_fim DATE
)
BEGIN
    SELECT 
        e.titulo AS evento,
        DATE(i.data_compra) AS data,
        COUNT(i.id) AS total_vendas,
        SUM(i.quantidade) AS total_ingressos,
        SUM(i.valor_final) AS receita,
        AVG(i.valor_final) AS ticket_medio
    FROM ingressos i
    INNER JOIN eventos e ON i.evento_id = e.id
    WHERE DATE(i.data_compra) BETWEEN p_data_inicio AND p_data_fim
    AND i.status_ingresso IN ('confirmado', 'usado')
    GROUP BY e.id, DATE(i.data_compra)
    ORDER BY data DESC, receita DESC;
END//

DELIMITER ;

-- ============================================
-- COMENTÁRIOS E DOCUMENTAÇÃO
-- ============================================

-- Informações sobre o banco de dados
SELECT 'Banco de dados Raven\'s List criado com sucesso!' AS mensagem;
SELECT 'Total de tabelas criadas: 7' AS info;
SELECT 'Total de views criadas: 3' AS info;
SELECT 'Total de triggers criados: 3' AS info;
SELECT 'Total de procedures criadas: 2' AS info;