-- ============================================
-- BANCO DE DADOS RAVEN'S LIST
-- Sistema completo de vendas de ingressos
-- VERSÃO ROBUSTA E CORRIGIDA (T-SQL)
-- ============================================

-- 1. MUDAR O CONTEXTO E TENTAR DROPAR O DB
USE master;
GO

IF EXISTS (SELECT name FROM master.sys.databases WHERE name = N'raven_list')
BEGIN
    -- Configura o banco de dados para modo Single User para forçar a desconexão de qualquer usuário
    ALTER DATABASE raven_list SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE raven_list;
END
GO

-- 2. CRIAÇÃO DO BANCO DE DADOS
CREATE DATABASE raven_list;
GO

-- 3. UTILIZAÇÃO DO BANCO
USE raven_list;
GO

-- ============================================
-- PREPARAÇÃO: DROPAR OBJETOS EXISTENTES PARA REPETIÇÃO
-- ============================================

-- Dropar PROCEDURES
IF OBJECT_ID('sp_dashboard_admin', 'P') IS NOT NULL DROP PROCEDURE sp_dashboard_admin;
IF OBJECT_ID('sp_relatorio_vendas_lote', 'P') IS NOT NULL DROP PROCEDURE sp_relatorio_vendas_lote;
IF OBJECT_ID('sp_relatorio_vendas_periodo', 'P') IS NOT NULL DROP PROCEDURE sp_relatorio_vendas_periodo;
IF OBJECT_ID('sp_gerar_codigo_ingresso', 'P') IS NOT NULL DROP PROCEDURE sp_gerar_codigo_ingresso;
GO

-- Dropar VIEWS
IF OBJECT_ID('vw_ranking_eventos', 'V') IS NOT NULL DROP VIEW vw_ranking_eventos;
IF OBJECT_ID('vw_estatisticas_gerais', 'V') IS NOT NULL DROP VIEW vw_estatisticas_gerais;
IF OBJECT_ID('vw_historico_compras', 'V') IS NOT NULL DROP VIEW vw_historico_compras;
IF OBJECT_ID('vw_vendas_por_lote', 'V') IS NOT NULL DROP VIEW vw_vendas_por_lote;
IF OBJECT_ID('vw_vendas_por_evento', 'V') IS NOT NULL DROP VIEW vw_vendas_por_evento;
GO

-- Dropar TRIGGERS
IF OBJECT_ID('tr_log_cancelamento_ingresso', 'TR') IS NOT NULL DROP TRIGGER tr_log_cancelamento_ingresso;
IF OBJECT_ID('tr_log_compra_ingresso', 'TR') IS NOT NULL DROP TRIGGER tr_log_compra_ingresso;
IF OBJECT_ID('tr_devolver_ingressos_cancelados', 'TR') IS NOT NULL DROP TRIGGER tr_devolver_ingressos_cancelados;
IF OBJECT_ID('tr_atualizar_ingressos_disponiveis', 'TR') IS NOT NULL DROP TRIGGER tr_atualizar_ingressos_disponiveis;
IF OBJECT_ID('tr_estatisticas_vendas_atualizado_em', 'TR') IS NOT NULL DROP TRIGGER tr_estatisticas_vendas_atualizado_em;
IF OBJECT_ID('tr_pagamentos_atualizado_em', 'TR') IS NOT NULL DROP TRIGGER tr_pagamentos_atualizado_em;
IF OBJECT_ID('tr_eventos_atualizado_em', 'TR') IS NOT NULL DROP TRIGGER tr_eventos_atualizado_em;
IF OBJECT_ID('tr_usuarios_ultima_atualizacao', 'TR') IS NOT NULL DROP TRIGGER tr_usuarios_ultima_atualizacao;
GO

-- Dropar TABELAS em ordem de dependência (do filho para o pai)
IF OBJECT_ID('log_acoes', 'U') IS NOT NULL DROP TABLE log_acoes;
IF OBJECT_ID('estatisticas_vendas', 'U') IS NOT NULL DROP TABLE estatisticas_vendas;
IF OBJECT_ID('pagamentos', 'U') IS NOT NULL DROP TABLE pagamentos;
IF OBJECT_ID('ingressos', 'U') IS NOT NULL DROP TABLE ingressos;
IF OBJECT_ID('lotes', 'U') IS NOT NULL DROP TABLE lotes;
IF OBJECT_ID('eventos', 'U') IS NOT NULL DROP TABLE eventos;
IF OBJECT_ID('usuarios', 'U') IS NOT NULL DROP TABLE usuarios;
GO

-- ============================================
-- TABELA DE USUÁRIOS
-- ============================================
CREATE TABLE usuarios (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    telefone VARCHAR(20),
    cpf VARCHAR(14) UNIQUE,
    data_nascimento DATE,
    tipo_usuario VARCHAR(10) DEFAULT 'cliente' CHECK (tipo_usuario IN ('cliente', 'admin')),
    status VARCHAR(10) DEFAULT 'ativo' CHECK (status IN ('ativo', 'inativo', 'bloqueado')),
    data_cadastro DATETIME DEFAULT GETDATE(),
    ultima_atualizacao DATETIME DEFAULT GETDATE(),
    INDEX idx_email UNIQUE (email),
    INDEX idx_tipo (tipo_usuario)
);
GO

-- Trigger para atualizar a coluna 'ultima_atualizacao' na tabela 'usuarios'
CREATE TRIGGER tr_usuarios_ultima_atualizacao
ON usuarios
AFTER UPDATE
AS
BEGIN
    UPDATE usuarios
    SET ultima_atualizacao = GETDATE()
    FROM inserted i
    WHERE usuarios.id = i.id;
END;
GO

-- ============================================
-- TABELA DE EVENTOS
-- ============================================
CREATE TABLE eventos (
    id INT IDENTITY(1,1) PRIMARY KEY,
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
    status_evento VARCHAR(10) DEFAULT 'ativo' CHECK (status_evento IN ('ativo', 'esgotado', 'cancelado', 'finalizado')),
    destaque BIT DEFAULT 0,
    criado_em DATETIME DEFAULT GETDATE(),
    atualizado_em DATETIME DEFAULT GETDATE(),
    INDEX idx_data (data_evento),
    INDEX idx_status (status_evento),
    INDEX idx_categoria (categoria)
);
GO

-- Trigger para atualizar a coluna 'atualizado_em' na tabela 'eventos'
CREATE TRIGGER tr_eventos_atualizado_em
ON eventos
AFTER UPDATE
AS
BEGIN
    UPDATE eventos
    SET atualizado_em = GETDATE()
    FROM inserted i
    WHERE eventos.id = i.id;
END;
GO

-- ============================================
-- TABELA DE LOTES DE INGRESSOS
-- ============================================
CREATE TABLE lotes (
    id INT IDENTITY(1,1) PRIMARY KEY,
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
    status_lote VARCHAR(10) DEFAULT 'ativo' CHECK (status_lote IN ('ativo', 'esgotado', 'encerrado')),
    criado_em DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (evento_id) REFERENCES eventos(id) ON DELETE NO ACTION, -- Mantido NO ACTION para evitar ciclos
    INDEX idx_evento (evento_id),
    INDEX idx_status (status_lote)
);
GO

-- ============================================
-- TABELA DE INGRESSOS (VENDAS)
-- ============================================
CREATE TABLE ingressos (
    id INT IDENTITY(1,1) PRIMARY KEY,
    codigo_ingresso VARCHAR(50) UNIQUE NOT NULL,
    usuario_id INT NOT NULL,
    evento_id INT NOT NULL,
    lote_id INT,
    tipo_ingresso VARCHAR(10) DEFAULT 'inteira' CHECK (tipo_ingresso IN ('inteira', 'meia')),
    quantidade INT DEFAULT 1,
    valor_unitario DECIMAL(10,2) NOT NULL,
    valor_total DECIMAL(10,2) NOT NULL,
    taxa_servico DECIMAL(10,2) DEFAULT 0.00,
    valor_final DECIMAL(10,2) NOT NULL,
    status_ingresso VARCHAR(10) DEFAULT 'pendente' CHECK (status_ingresso IN ('pendente', 'confirmado', 'cancelado', 'usado')),
    forma_pagamento VARCHAR(20) NOT NULL CHECK (forma_pagamento IN ('pix', 'cartao_credito', 'cartao_debito', 'boleto')),
    data_compra DATETIME DEFAULT GETDATE(),
    data_pagamento DATETIME NULL,
    data_cancelamento DATETIME NULL,
    data_uso DATETIME NULL,
    qr_code TEXT,
    observacoes TEXT,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE, -- Manter CASCADE aqui
    FOREIGN KEY (evento_id) REFERENCES eventos(id) ON DELETE CASCADE,
    FOREIGN KEY (lote_id) REFERENCES lotes(id) ON DELETE SET NULL,
    INDEX idx_codigo UNIQUE (codigo_ingresso),
    INDEX idx_usuario (usuario_id),
    INDEX idx_evento (evento_id),
    INDEX idx_status (status_ingresso),
    INDEX idx_data_compra (data_compra)
);
GO

-- ============================================
-- TABELA DE PAGAMENTOS
-- ============================================
CREATE TABLE pagamentos (
    id INT IDENTITY(1,1) PRIMARY KEY,
    ingresso_id INT NOT NULL,
    usuario_id INT NOT NULL,
    valor_pago DECIMAL(10,2) NOT NULL,
    forma_pagamento VARCHAR(20) NOT NULL CHECK (forma_pagamento IN ('pix', 'cartao_credito', 'cartao_debito', 'boleto')),
    status_pagamento VARCHAR(10) DEFAULT 'pendente' CHECK (status_pagamento IN ('pendente', 'aprovado', 'recusado', 'cancelado', 'estornado')),
    transacao_id VARCHAR(100) UNIQUE,
    codigo_autorizacao VARCHAR(100),
    bandeira_cartao VARCHAR(50),
    ultimos_digitos VARCHAR(4),
    parcelas INT DEFAULT 1,
    data_vencimento DATE,
    data_pagamento DATETIME NULL,
    ip_compra VARCHAR(45),
    observacoes TEXT,
    criado_em DATETIME DEFAULT GETDATE(),
    atualizado_em DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ingresso_id) REFERENCES ingressos(id) ON DELETE CASCADE, -- CASCADE: se ingresso for apagado, o pagamento também é.
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE NO ACTION, -- CORREÇÃO: NO ACTION para quebrar o ciclo de cascata.
    INDEX idx_transacao UNIQUE (transacao_id),
    INDEX idx_status (status_pagamento),
    INDEX idx_data (data_pagamento)
);
GO

-- Trigger para atualizar a coluna 'atualizado_em' na tabela 'pagamentos'
CREATE TRIGGER tr_pagamentos_atualizado_em
ON pagamentos
AFTER UPDATE
AS
BEGIN
    UPDATE pagamentos
    SET atualizado_em = GETDATE()
    FROM inserted i
    WHERE pagamentos.id = i.id;
END;
GO

-- ============================================
-- TABELA DE ESTATÍSTICAS DE VENDAS
-- ============================================
CREATE TABLE estatisticas_vendas (
    id INT IDENTITY(1,1) PRIMARY KEY,
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
    criado_em DATETIME DEFAULT GETDATE(),
    atualizado_em DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (evento_id) REFERENCES eventos(id) ON DELETE CASCADE,
    CONSTRAINT uk_evento_data UNIQUE (evento_id, data_referencia),
    INDEX idx_data (data_referencia)
);
GO

-- Trigger para atualizar a coluna 'atualizado_em' na tabela 'estatisticas_vendas'
CREATE TRIGGER tr_estatisticas_vendas_atualizado_em
ON estatisticas_vendas
AFTER UPDATE
AS
BEGIN
    UPDATE estatisticas_vendas
    SET atualizado_em = GETDATE()
    FROM inserted i
    WHERE estatisticas_vendas.id = i.id;
END;
GO

-- ============================================
-- TABELA DE LOG DE AÇÕES
-- ============================================
CREATE TABLE log_acoes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    usuario_id INT,
    tipo_acao VARCHAR(20) NOT NULL CHECK (tipo_acao IN ('compra', 'cancelamento', 'login', 'cadastro', 'edicao', 'exclusao')),
    descricao TEXT,
    tabela_afetada VARCHAR(50),
    registro_id INT,
    ip_origem VARCHAR(45),
    user_agent TEXT,
    data_acao DATETIME DEFAULT GETDATE(),
    INDEX idx_usuario (usuario_id),
    INDEX idx_tipo (tipo_acao),
    INDEX idx_data (data_acao)
);
GO

-- ============================================
-- INSERIR OS 3 EVENTOS
-- ============================================
SET IDENTITY_INSERT eventos ON;
GO
INSERT INTO eventos (
    id, titulo, 
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
    1, 'Bio Dementia',
    'Uma experiência sensorial única com performances de arte experimental, instalações interativas e sets de música industrial. O underground gótico em sua forma mais pura.',
    '2025-12-07 21:00:00',
    'Warehouse Underground',
    'Bloodrock Bar',
    'Curitiba',
    'PR',
    450,
    287,
    163,
    85.00,
    42.50,
    'Arte Experimental',
    18,
    'ativo',
    1
),
(
    2, 'Noir Fest',
    'Festival boutique de música darkwave e post-punk com bandas nacionais e internacionais. Ambiente intimista para verdadeiros apreciadores da cena dark.',
    '2025-12-20 19:00:00',
    'Teatro das Trevas',
    'Jokers Pub',
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
    1
),
(
    3, 'Vampire''s Night',
    'O maior evento gótico do Brasil! Uma noite épica com 3 palcos simultâneos, performances teatrais, concurso de fantasias, zona VIP e experiências imersivas. Dress code: Gothic Victorian.',
    '2026-01-31 20:00:00',
    'Parque Gótico Industrial',
    'Tork n Roll',
    'Curitiba',
    'PR',
    2500,
    1847,
    653,
    180.00,
    90.00,
    'Mega Evento',
    18,
    'ativo',
    1
);
GO
SET IDENTITY_INSERT eventos OFF;
GO

-- ============================================
-- INSERIR LOTES
-- ============================================
SET IDENTITY_INSERT lotes ON;
GO

INSERT INTO lotes (id, evento_id, nome_lote, numero_lote, quantidade_total, quantidade_vendida, quantidade_disponivel, preco_inteira, preco_meia, data_inicio, data_fim, status_lote, criado_em) VALUES
(1, 1, '1º Lote - Early Bird', 1, 100, 100, 0, 65.00, 32.50, '2025-10-01 00:00:00', '2025-10-31 23:59:59', 'esgotado', '2025-10-01 00:00:00'),
(2, 1, '2º Lote - Promocional', 2, 150, 150, 0, 75.00, 37.50, '2025-11-01 00:00:00', '2025-11-20 23:59:59', 'esgotado', '2025-11-01 00:00:00'),
(3, 1, '3º Lote - Regular', 3, 150, 37, 113, 85.00, 42.50, '2025-11-21 00:00:00', '2025-12-07 20:00:00', 'ativo', '2025-11-21 00:00:00'),
(4, 1, '4º Lote - Última Hora', 4, 50, 0, 50, 100.00, 50.00, '2025-12-07 00:00:00', '2025-12-07 20:00:00', 'ativo', '2025-12-07 00:00:00'),
(5, 2, '1º Lote - Pré-Venda', 1, 80, 80, 0, 90.00, 45.00, '2025-09-15 00:00:00', '2025-10-15 23:59:59', 'esgotado', '2025-09-15 00:00:00'),
(6, 2, '2º Lote - Antecipado', 2, 120, 120, 0, 105.00, 52.50, '2025-10-16 00:00:00', '2025-11-30 23:59:59', 'esgotado', '2025-10-16 00:00:00'),
(7, 2, '3º Lote - Normal', 3, 120, 112, 8, 120.00, 60.00, '2025-12-01 00:00:00', '2025-12-20 18:00:00', 'ativo', '2025-12-01 00:00:00'),
(8, 2, '4º Lote - Portaria', 4, 30, 0, 30, 140.00, 70.00, '2025-12-20 18:00:00', '2025-12-20 23:00:00', 'ativo', '2025-12-20 18:00:00'),
(9, 3, '1º Lote - Super Early Bird', 1, 300, 300, 0, 120.00, 60.00, '2025-08-01 00:00:00', '2025-09-30 23:59:59', 'esgotado', '2025-08-01 00:00:00'),
(10, 3, '2º Lote - Early Bird', 2, 500, 500, 0, 140.00, 70.00, '2025-10-01 00:00:00', '2025-11-30 23:59:59', 'esgotado', '2025-10-01 00:00:00'),
(11, 3, '3º Lote - Promocional', 3, 600, 600, 0, 160.00, 80.00, '2025-12-01 00:00:00', '2025-12-31 23:59:59', 'esgotado', '2025-12-01 00:00:00'),
(12, 3, '4º Lote - Regular', 4, 800, 447, 353, 180.00, 90.00, '2026-01-01 00:00:00', '2026-01-31 19:00:00', 'ativo', '2026-01-01 00:00:00'),
(13, 3, '5º Lote - Última Chamada', 5, 300, 0, 300, 220.00, 110.00, '2026-01-31 00:00:00', '2026-01-31 19:00:00', 'ativo', '2026-01-31 00:00:00');
GO
SET IDENTITY_INSERT lotes OFF;
GO

-- ============================================
-- INSERIR USUÁRIOS DE EXEMPLO
-- ============================================
SET IDENTITY_INSERT usuarios ON;
GO

INSERT INTO usuarios (id, nome, email, senha, telefone, cpf, data_nascimento, tipo_usuario, status) VALUES
(1, 'Administrador', 'admin@ravenslist.com', 'admin123', '(11) 98888-8888', '000.000.000-00', '1990-01-01', 'admin', 'ativo'),
(2, 'Morgana Blackwood', 'morgana.black@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '(11) 99876-5432', '123.456.789-01', '1995-10-31', 'cliente', 'ativo'),
(3, 'Raven Darknight', 'raven.dark@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '(21) 98765-4321', '234.567.890-12', '1992-06-13', 'cliente', 'ativo'),
(4, 'Lilith Shadows', 'lilith.shadows@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '(41) 97654-3210', '345.678.901-23', '1997-12-25', 'cliente', 'ativo'),
(5, 'Viktor Nosferatu', 'viktor.nosferatu@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '(11) 96543-2109', '456.789.012-34', '1988-03-15', 'cliente', 'ativo'),
(6, 'Selene Moonlight', 'selene.moon@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '(21) 95432-1098', '567.890.123-45', '1994-09-21', 'cliente', 'ativo');
GO
SET IDENTITY_INSERT usuarios OFF;
GO

-- ============================================
-- INSERIR VENDAS DE INGRESSOS
-- ============================================
SET IDENTITY_INSERT ingressos ON;
GO

INSERT INTO ingressos (id, codigo_ingresso, usuario_id, evento_id, lote_id, tipo_ingresso, quantidade, valor_unitario, valor_total, taxa_servico, valor_final, status_ingresso, forma_pagamento, data_compra, data_pagamento) VALUES
(1, 'BIO001-000001', 2, 1, 1, 'inteira', 2, 65.00, 130.00, 13.00, 143.00, 'confirmado', 'pix', '2025-10-05 14:23:00', '2025-10-05 14:25:00'),
(2, 'BIO001-000002', 3, 1, 1, 'meia', 1, 32.50, 32.50, 3.25, 35.75, 'confirmado', 'cartao_credito', '2025-10-12 19:45:00', '2025-10-12 19:45:00'),
(3, 'BIO001-000003', 4, 1, 2, 'inteira', 3, 75.00, 225.00, 22.50, 247.50, 'confirmado', 'pix', '2025-11-08 16:30:00', '2025-11-08 16:32:00'),
(4, 'BIO001-000004', 5, 1, 2, 'inteira', 2, 75.00, 150.00, 15.00, 165.00, 'confirmado', 'cartao_credito', '2025-11-15 20:10:00', '2025-11-15 20:10:00'),
(5, 'BIO001-000005', 2, 1, 3, 'meia', 2, 42.50, 85.00, 8.50, 93.50, 'confirmado', 'pix', '2025-11-25 10:15:00', '2025-11-25 10:17:00'),
(6, 'NOI002-000001', 3, 2, 5, 'inteira', 1, 90.00, 90.00, 9.00, 99.00, 'confirmado', 'pix', '2025-09-20 11:30:00', '2025-09-20 11:32:00'),
(7, 'NOI002-000002', 4, 2, 6, 'inteira', 2, 105.00, 210.00, 21.00, 231.00, 'confirmado', 'cartao_credito', '2025-10-25 15:20:00', '2025-10-25 15:20:00'),
(8, 'NOI002-000003', 5, 2, 6, 'meia', 1, 52.50, 52.50, 5.25, 57.75, 'confirmado', 'pix', '2025-11-05 18:45:00', '2025-11-05 18:47:00'),
(9, 'NOI002-000004', 2, 2, 7, 'inteira', 2, 120.00, 240.00, 24.00, 264.00, 'confirmado', 'cartao_credito', '2025-12-02 13:10:00', '2025-12-02 13:10:00'),
(10, 'NOI002-000005', 3, 2, 7, 'meia', 1, 60.00, 60.00, 6.00, 66.00, 'confirmado', 'pix', '2025-12-10 09:25:00', '2025-12-10 09:27:00'),
(11, 'VAM003-000001', 2, 3, 9, 'inteira', 4, 120.00, 480.00, 48.00, 528.00, 'confirmado', 'pix', '2025-08-15 16:30:00', '2025-08-15 16:32:00'),
(12, 'VAM003-000002', 3, 3, 10, 'inteira', 3, 140.00, 420.00, 42.00, 462.00, 'confirmado', 'cartao_credito', '2025-10-20 14:15:00', '2025-10-20 14:15:00'),
(13, 'VAM003-000003', 4, 3, 10, 'meia', 2, 70.00, 140.00, 14.00, 154.00, 'confirmado', 'pix', '2025-11-10 19:40:00', '2025-11-10 19:42:00'),
(14, 'VAM003-000004', 5, 3, 11, 'inteira', 5, 160.00, 800.00, 80.00, 880.00, 'confirmado', 'cartao_credito', '2025-12-15 11:20:00', '2025-12-15 11:20:00'),
(15, 'VAM003-000005', 2, 3, 12, 'inteira', 2, 180.00, 360.00, 36.00, 396.00, 'confirmado', 'pix', '2026-01-05 15:50:00', '2026-01-05 15:52:00'),
(16, 'VAM003-000006', 3, 3, 12, 'meia', 3, 90.00, 270.00, 27.00, 297.00, 'confirmado', 'cartao_credito', '2026-01-12 20:10:00', '2026-01-12 20:10:00');
GO
SET IDENTITY_INSERT ingressos OFF;
GO

-- ============================================
-- INSERIR PAGAMENTOS CORRESPONDENTES
-- ============================================
SET IDENTITY_INSERT pagamentos ON;
GO

INSERT INTO pagamentos (id, ingresso_id, usuario_id, valor_pago, forma_pagamento, status_pagamento, transacao_id, codigo_autorizacao, bandeira_cartao, ultimos_digitos, parcelas, data_pagamento, ip_compra) VALUES
(1, 1, 2, 143.00, 'pix', 'aprovado', 'PIX-20251005-142500-001', 'PIX-AUTO-001', NULL, NULL, 1, '2025-10-05 14:25:00', '192.168.1.10'),
(2, 2, 3, 35.75, 'cartao_credito', 'aprovado', 'CC-20251012-194500-002', 'AUTH-CC-002', 'Visa', '4532', 1, '2025-10-12 19:45:00', '192.168.1.11'),
(3, 3, 4, 247.50, 'pix', 'aprovado', 'PIX-20251108-163200-003', 'PIX-AUTO-003', NULL, NULL, 1, '2025-11-08 16:32:00', '192.168.1.12'),
(4, 4, 5, 165.00, 'cartao_credito', 'aprovado', 'CC-20251115-201000-004', 'AUTH-CC-004', 'Mastercard', '5678', 2, '2025-11-15 20:10:00', '192.168.1.13'),
(5, 5, 2, 93.50, 'pix', 'aprovado', 'PIX-20251125-101700-005', 'PIX-AUTO-005', NULL, NULL, 1, '2025-11-25 10:17:00', '192.168.1.10'),
(6, 6, 3, 99.00, 'pix', 'aprovado', 'PIX-20250920-113200-006', 'PIX-AUTO-006', NULL, NULL, 1, '2025-09-20 11:32:00', '192.168.1.11'),
(7, 7, 4, 231.00, 'cartao_credito', 'aprovado', 'CC-20251025-152000-007', 'AUTH-CC-007', 'Elo', '6789', 3, '2025-10-25 15:20:00', '192.168.1.12'),
(8, 8, 5, 57.75, 'pix', 'aprovado', 'PIX-20251105-184700-008', 'PIX-AUTO-008', NULL, NULL, 1, '2025-11-05 18:47:00', '192.168.1.13'),
(9, 9, 2, 264.00, 'cartao_credito', 'aprovado', 'CC-20251202-131000-009', 'AUTH-CC-009', 'Visa', '1234', 2, '2025-12-02 13:10:00', '192.168.1.10'),
(10, 10, 3, 66.00, 'pix', 'aprovado', 'PIX-20251210-092700-010', 'PIX-AUTO-010', NULL, NULL, 1, '2025-12-10 09:27:00', '192.168.1.11'),
(11, 11, 2, 528.00, 'pix', 'aprovado', 'PIX-20250815-163200-011', 'PIX-AUTO-011', NULL, NULL, 1, '2025-08-15 16:32:00', '192.168.1.10'),
(12, 12, 3, 462.00, 'cartao_credito', 'aprovado', 'CC-20251020-141500-012', 'AUTH-CC-012', 'Mastercard', '8901', 4, '2025-10-20 14:15:00', '192.168.1.11'),
(13, 13, 4, 154.00, 'pix', 'aprovado', 'PIX-20251110-194200-013', 'PIX-AUTO-013', NULL, NULL, 1, '2025-11-10 19:42:00', '192.168.1.12'),
(14, 14, 5, 880.00, 'cartao_credito', 'aprovado', 'CC-20251215-112000-014', 'AUTH-CC-014', 'Visa', '2345', 5, '2025-12-15 11:20:00', '192.168.1.13'),
(15, 15, 2, 396.00, 'pix', 'aprovado', 'PIX-20260105-155200-015', 'PIX-AUTO-015', NULL, NULL, 1, '2026-01-05 15:52:00', '192.168.1.10'),
(16, 16, 3, 297.00, 'cartao_credito', 'aprovado', 'CC-20260112-201000-016', 'AUTH-CC-016', 'Mastercard', '9012', 3, '2026-01-12 20:10:00', '192.168.1.11'); -- ID 16 corrigido.
GO
SET IDENTITY_INSERT pagamentos OFF;
GO
SET IDENTITY_INSERT ingressos OFF;
GO

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
    ROUND((CAST(e.ingressos_vendidos AS DECIMAL(10,2)) / e.capacidade_total * 100), 2) AS taxa_ocupacao
FROM eventos e
LEFT JOIN ingressos i ON e.id = i.evento_id 
    AND i.status_ingresso IN ('confirmado', 'usado')
GROUP BY e.id, e.titulo, e.data_evento, e.local, e.capacidade_total, e.ingressos_vendidos, e.ingressos_disponiveis;
GO

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
    ROUND((CAST(l.quantidade_vendida AS DECIMAL(10,2)) / l.quantidade_total * 100), 2) AS percentual_vendido
FROM lotes l
INNER JOIN eventos e ON l.evento_id = e.id
LEFT JOIN ingressos i ON l.id = i.lote_id AND i.status_ingresso = 'confirmado'
GROUP BY l.id, e.titulo, l.nome_lote, l.numero_lote, l.quantidade_total, l.quantidade_vendida, l.quantidade_disponivel, l.preco_inteira, l.preco_meia, l.status_lote;
GO

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
    p.status_pagamento -- Acesso à tabela pagamentos agora está OK
FROM usuarios u
INNER JOIN ingressos i ON u.id = i.usuario_id
INNER JOIN eventos e ON i.evento_id = e.id
LEFT JOIN lotes l ON i.lote_id = l.id
LEFT JOIN pagamentos p ON i.id = p.ingresso_id;
GO

-- View de estatísticas gerais
CREATE VIEW vw_estatisticas_gerais AS
SELECT 
    (SELECT COUNT(DISTINCT id) FROM usuarios) AS total_usuarios,
    (SELECT COUNT(DISTINCT id) FROM eventos) AS total_eventos,
    COUNT(i.id) AS total_vendas,
    SUM(i.quantidade) AS total_ingressos_vendidos,
    SUM(i.valor_final) AS receita_total,
    ROUND(AVG(i.valor_final), 2) AS ticket_medio,
    SUM(CASE WHEN i.forma_pagamento = 'pix' THEN 1 ELSE 0 END) AS vendas_pix,
    SUM(CASE WHEN i.forma_pagamento IN ('cartao_credito', 'cartao_debito') THEN 1 ELSE 0 END) AS vendas_cartao
FROM ingressos i
WHERE i.status_ingresso IN ('confirmado', 'usado');
GO

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
    ROUND((CAST(e.ingressos_vendidos AS DECIMAL(10,2)) / e.capacidade_total * 100), 2) AS taxa_ocupacao
FROM eventos e
LEFT JOIN ingressos i ON e.id = i.evento_id AND i.status_ingresso = 'confirmado'
GROUP BY e.id, e.titulo, e.data_evento, e.capacidade_total, e.ingressos_vendidos
ORDER BY receita DESC OFFSET 0 ROWS; 
GO

-- ============================================
-- TRIGGERS PARA AUTOMAÇÃO
-- (Estas triggers não foram alteradas e devem funcionar corretamente)
-- ============================================

-- Trigger para atualizar ingressos disponíveis ao vender (INSERT)
CREATE TRIGGER tr_atualizar_ingressos_disponiveis
ON ingressos
AFTER INSERT
AS
BEGIN
    -- Atualizar Evento
    UPDATE e
    SET 
        ingressos_vendidos = e.ingressos_vendidos + i.quantidade,
        ingressos_disponiveis = e.capacidade_total - (e.ingressos_vendidos + i.quantidade)
    FROM eventos e
    INNER JOIN inserted i ON e.id = i.evento_id
    WHERE i.status_ingresso = 'confirmado';

    -- Atualizar Lote
    UPDATE l
    SET 
        quantidade_vendida = l.quantidade_vendida + i.quantidade,
        quantidade_disponivel = l.quantidade_total - (l.quantidade_vendida + i.quantidade)
    FROM lotes l
    INNER JOIN inserted i ON l.id = i.lote_id
    WHERE i.lote_id IS NOT NULL AND i.status_ingresso = 'confirmado';
    
    -- Atualizar status do lote se esgotado
    UPDATE l
    SET status_lote = 'esgotado'
    FROM lotes l
    INNER JOIN inserted i ON l.id = i.lote_id
    WHERE l.quantidade_disponivel <= 0 AND i.status_ingresso = 'confirmado';

    -- Atualizar status do evento se esgotado
    UPDATE e
    SET status_evento = 'esgotado'
    FROM eventos e
    INNER JOIN inserted i ON e.id = i.evento_id
    WHERE e.ingressos_disponiveis <= 0 AND e.status_evento = 'ativo' AND i.status_ingresso = 'confirmado';
END;
GO

-- Trigger para devolver ingressos ao cancelar (UPDATE)
CREATE TRIGGER tr_devolver_ingressos_cancelados
ON ingressos
AFTER UPDATE
AS
BEGIN
    IF UPDATE(status_ingresso)
    BEGIN
        IF EXISTS (SELECT 1 FROM deleted d INNER JOIN inserted i ON d.id = i.id WHERE d.status_ingresso = 'confirmado' AND i.status_ingresso = 'cancelado')
        BEGIN
            -- Devolver no evento
            UPDATE e
            SET 
                ingressos_vendidos = e.ingressos_vendidos - i.quantidade,
                ingressos_disponiveis = e.capacidade_total - (e.ingressos_vendidos - i.quantidade)
            FROM eventos e
            INNER JOIN inserted i ON e.id = i.evento_id;
            
            -- Devolver no lote
            UPDATE l
            SET 
                quantidade_vendida = l.quantidade_vendida - i.quantidade,
                quantidade_disponivel = l.quantidade_total - (l.quantidade_vendida - i.quantidade),
                status_lote = 'ativo'
            FROM lotes l
            INNER JOIN inserted i ON l.id = i.lote_id
            WHERE i.lote_id IS NOT NULL;

            -- Reativar evento se estava esgotado
            UPDATE e 
            SET status_evento = 'ativo'
            FROM eventos e
            INNER JOIN inserted i ON e.id = i.evento_id
            WHERE e.status_evento = 'esgotado'
            AND e.ingressos_disponiveis > 0;
        END
    END
END;
GO

-- Trigger para registrar log de compra
CREATE TRIGGER tr_log_compra_ingresso
ON ingressos
AFTER INSERT
AS
BEGIN
    INSERT INTO log_acoes (
        usuario_id,
        tipo_acao,
        descricao,
        tabela_afetada,
        registro_id
    )
    SELECT
        i.usuario_id,
        'compra',
        'Compra de ' + CAST(i.quantidade AS VARCHAR) + ' ingresso(s) - Código: ' + i.codigo_ingresso,
        'ingressos',
        i.id
    FROM inserted i;
END;
GO

-- Trigger para registrar log de cancelamento
CREATE TRIGGER tr_log_cancelamento_ingresso
ON ingressos
AFTER UPDATE
AS
BEGIN
    IF UPDATE(status_ingresso)
    BEGIN
        INSERT INTO log_acoes (
            usuario_id,
            tipo_acao,
            descricao,
            tabela_afetada,
            registro_id
        )
        SELECT 
            i.usuario_id,
            'cancelamento',
            'Cancelamento de ' + CAST(i.quantidade AS VARCHAR) + ' ingresso(s) - Código: ' + i.codigo_ingresso,
            'ingressos',
            i.id
        FROM inserted i
        INNER JOIN deleted d ON i.id = d.id
        WHERE d.status_ingresso = 'confirmado' AND i.status_ingresso = 'cancelado';
    END
END;
GO

-- ============================================
-- PROCEDURES ÚTEIS
-- ============================================

-- Procedure para gerar código único de ingresso
CREATE PROCEDURE sp_gerar_codigo_ingresso
    @p_evento_id INT,
    @p_codigo VARCHAR(50) OUTPUT
AS
BEGIN
    DECLARE @v_prefixo VARCHAR(10);
    DECLARE @v_numero INT;
    
    -- Gerar prefixo baseado no evento
    SELECT 
        @v_prefixo = CASE 
            WHEN id = 1 THEN 'BIO'
            WHEN id = 2 THEN 'NOI'
            WHEN id = 3 THEN 'VAM'
            ELSE 'RVN'
        END
    FROM eventos WHERE id = @p_evento_id;
    
    -- Obter próximo número
    SELECT @v_numero = COALESCE(MAX(CAST(SUBSTRING(codigo_ingresso, CHARINDEX('-', codigo_ingresso) + 1, 6) AS INT)), 0) + 1 
    FROM ingressos 
    WHERE evento_id = @p_evento_id;
    
    -- Montar código
    SET @p_codigo = @v_prefixo + RIGHT('000' + CAST(@p_evento_id AS VARCHAR), 3) + '-' + RIGHT('000000' + CAST(@v_numero AS VARCHAR), 6);
END;
GO

-- Procedure para relatório de vendas por período
CREATE PROCEDURE sp_relatorio_vendas_periodo
    @p_data_inicio DATE,
    @p_data_fim DATE
AS
BEGIN
    SELECT 
        e.titulo AS evento,
        CAST(i.data_compra AS DATE) AS data,
        COUNT(i.id) AS total_vendas,
        SUM(i.quantidade) AS total_ingressos,
        SUM(CASE WHEN i.tipo_ingresso = 'inteira' THEN i.quantidade ELSE 0 END) AS qtd_inteira,
        SUM(CASE WHEN i.tipo_ingresso = 'meia' THEN i.quantidade ELSE 0 END) AS qtd_meia,
        SUM(i.valor_final) AS receita,
        ROUND(AVG(i.valor_final), 2) AS ticket_medio
    FROM ingressos i
    INNER JOIN eventos e ON i.evento_id = e.id
    WHERE CAST(i.data_compra AS DATE) BETWEEN @p_data_inicio AND @p_data_fim
    AND i.status_ingresso IN ('confirmado', 'usado')
    GROUP BY e.id, e.titulo, CAST(i.data_compra AS DATE)
    ORDER BY data DESC, receita DESC;
END;
GO

-- Procedure para relatório de vendas por lote
CREATE PROCEDURE sp_relatorio_vendas_lote
    @p_evento_id INT
AS
BEGIN
    SELECT 
        l.numero_lote,
        l.nome_lote,
        l.quantidade_total,
        l.quantidade_vendida,
        l.quantidade_disponivel,
        'R$ ' + FORMAT(l.preco_inteira, 'N2') AS preco_inteira, 
        'R$ ' + FORMAT(l.preco_meia, 'N2') AS preco_meia,
        l.status_lote,
        COUNT(i.id) AS total_transacoes,
        'R$ ' + FORMAT(SUM(i.valor_final), 'N2') AS receita_total,
        ROUND((CAST(l.quantidade_vendida AS DECIMAL(10,2)) / l.quantidade_total * 100), 2) AS percentual_vendido
    FROM lotes l
    LEFT JOIN ingressos i ON l.id = i.lote_id AND i.status_ingresso = 'confirmado'
    WHERE l.evento_id = @p_evento_id
    GROUP BY l.id, l.numero_lote, l.nome_lote, l.quantidade_total, l.quantidade_vendida, l.quantidade_disponivel, l.preco_inteira, l.preco_meia, l.status_lote
    ORDER BY l.numero_lote;
END;
GO

-- Procedure para dashboard administrativo
CREATE PROCEDURE sp_dashboard_admin
AS
BEGIN
    -- Resumo geral
    SELECT 
        'Resumo Geral' AS secao,
        COUNT(DISTINCT e.id) AS total_eventos,
        SUM(e.capacidade_total) AS capacidade_total,
        SUM(e.ingressos_vendidos) AS ingressos_vendidos,
        SUM(e.ingressos_disponiveis) AS ingressos_disponiveis,
        'R$ ' + FORMAT(COALESCE(SUM(i.valor_final), 0), 'N2') AS receita_total,
        (SELECT COUNT(DISTINCT id) FROM usuarios WHERE tipo_usuario = 'cliente') AS total_clientes
    FROM eventos e
    LEFT JOIN ingressos i ON e.id = i.evento_id AND i.status_ingresso = 'confirmado';

    -- Eventos individuais
    SELECT 
        e.titulo AS evento,
        e.data_evento,
        e.capacidade_total,
        e.ingressos_vendidos,
        e.ingressos_disponiveis,
        ROUND((CAST(e.ingressos_vendidos AS DECIMAL(10,2)) / e.capacidade_total * 100), 2) AS ocupacao_percentual,
        'R$ ' + FORMAT(COALESCE(SUM(i.valor_final), 0), 'N2') AS receita,
        e.status_evento
    FROM eventos e
    LEFT JOIN ingressos i ON e.id = i.evento_id AND i.status_ingresso = 'confirmado'
    GROUP BY e.id, e.titulo, e.data_evento, e.capacidade_total, e.ingressos_vendidos, e.ingressos_disponiveis, e.status_evento
    ORDER BY e.data_evento;
END;
GO

-- ============================================
-- INSERIR ESTATÍSTICAS INICIAIS
-- ============================================
INSERT INTO estatisticas_vendas (evento_id, data_referencia, total_vendas, total_receita, vendas_inteira, vendas_meia, vendas_pix, vendas_cartao, taxa_ocupacao)
SELECT 
    e.id,
    CAST(GETDATE() AS DATE),
    COUNT(i.id),
    COALESCE(SUM(i.valor_final), 0),
    SUM(CASE WHEN i.tipo_ingresso = 'inteira' THEN i.quantidade ELSE 0 END),
    SUM(CASE WHEN i.tipo_ingresso = 'meia' THEN i.quantidade ELSE 0 END),
    SUM(CASE WHEN i.forma_pagamento = 'pix' THEN 1 ELSE 0 END),
    SUM(CASE WHEN i.forma_pagamento IN ('cartao_credito', 'cartao_debito') THEN 1 ELSE 0 END),
    ROUND((CAST(e.ingressos_vendidos AS DECIMAL(10,2)) / e.capacidade_total * 100), 2)
FROM eventos e
LEFT JOIN ingressos i ON e.id = i.evento_id AND i.status_ingresso = 'confirmado'
GROUP BY e.id, e.ingressos_vendidos, e.capacidade_total;
GO

-- ============================================
-- INFORMAÇÕES FINAIS
-- ============================================
SELECT '✅ Banco de dados Raven''s List criado e populado com sucesso!' AS status;

SELECT '📊 ESTATÍSTICAS DO BANCO' AS info;
SELECT 'Total de tabelas: ' + CAST(COUNT(*) AS VARCHAR) AS total FROM sys.tables WHERE type_desc = 'USER_TABLE' AND schema_name(schema_id) = 'dbo';
SELECT 'Total de views: ' + CAST(COUNT(*) AS VARCHAR) AS total FROM sys.views WHERE schema_name(schema_id) = 'dbo';
GO

-- Mostrar resumo dos eventos
SELECT 
    '🎭 RESUMO DOS EVENTOS' AS info,
    titulo,
    capacidade_total,
    ingressos_vendidos,
    ingressos_disponiveis,
    FORMAT((CAST(ingressos_vendidos AS DECIMAL(10,2)) / capacidade_total * 100), 'N2') + '%' AS ocupacao
FROM eventos
ORDER BY data_evento;
GO