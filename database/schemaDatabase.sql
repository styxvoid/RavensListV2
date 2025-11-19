-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 19/11/2025 às 20:56
-- Versão do servidor: 10.4.32-MariaDB
-- Versão do PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `raven_list`
--

DELIMITER $$
--
-- Procedimentos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_gerar_codigo_ingresso` (IN `p_evento_id` INT, OUT `p_codigo` VARCHAR(50))   BEGIN
    DECLARE v_prefixo VARCHAR(6);
    DECLARE v_numero INT;
    
    -- Gera o prefixo RVN + ID do evento (ex: RVN001)
    SELECT CONCAT('RVN', LPAD(id, 3, '0')) INTO v_prefixo
    FROM eventos WHERE id = p_evento_id;
    
    -- Encontra o último número de ingresso para aquele evento e adiciona 1
    SELECT COALESCE(MAX(CAST(SUBSTRING(codigo_ingresso, -6) AS UNSIGNED)), 0) + 1 
    INTO v_numero
    FROM ingressos 
    WHERE evento_id = p_evento_id;
    
    -- Monta o código final (ex: RVN001-000001)
    SET p_codigo = CONCAT(v_prefixo, '-', LPAD(v_numero, 6, '0'));
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_relatorio_vendas_periodo` (IN `p_data_inicio` DATE, IN `p_data_fim` DATE)   BEGIN
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
    ORDER BY data, evento;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura para tabela `estatisticas_vendas`
--

CREATE TABLE `estatisticas_vendas` (
  `id` int(11) NOT NULL,
  `evento_id` int(11) NOT NULL,
  `data_estatistica` date NOT NULL,
  `total_vendas` int(11) DEFAULT 0,
  `receita_total` decimal(10,2) DEFAULT 0.00,
  `ingressos_inteira` int(11) DEFAULT 0,
  `ingressos_meia` int(11) DEFAULT 0,
  `vendas_pix` int(11) DEFAULT 0,
  `vendas_cartao` int(11) DEFAULT 0,
  `percentual_ocupacao` decimal(5,2) DEFAULT 0.00,
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  `atualizado_em` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estrutura para tabela `eventos`
--

CREATE TABLE `eventos` (
  `id` int(11) NOT NULL,
  `titulo` varchar(200) NOT NULL,
  `descricao` text DEFAULT NULL,
  `data_evento` datetime NOT NULL,
  `local` varchar(200) NOT NULL,
  `endereco_completo` varchar(500) DEFAULT NULL,
  `cidade` varchar(100) DEFAULT NULL,
  `estado` varchar(2) DEFAULT NULL,
  `capacidade_total` int(11) NOT NULL DEFAULT 100,
  `ingressos_vendidos` int(11) DEFAULT 0,
  `ingressos_disponiveis` int(11) DEFAULT NULL,
  `preco_inteira` decimal(10,2) NOT NULL,
  `preco_meia` decimal(10,2) DEFAULT NULL,
  `categoria` varchar(50) DEFAULT NULL,
  `classificacao_etaria` int(11) DEFAULT 18,
  `imagem` varchar(255) DEFAULT NULL,
  `banner` varchar(255) DEFAULT NULL,
  `status_evento` enum('ativo','esgotado','cancelado','finalizado') DEFAULT 'ativo',
  `destaque` tinyint(1) DEFAULT 0,
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  `atualizado_em` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `eventos`
--

INSERT INTO `eventos` (`id`, `titulo`, `descricao`, `data_evento`, `local`, `endereco_completo`, `cidade`, `estado`, `capacidade_total`, `ingressos_vendidos`, `ingressos_disponiveis`, `preco_inteira`, `preco_meia`, `categoria`, `classificacao_etaria`, `imagem`, `banner`, `status_evento`, `destaque`, `criado_em`, `atualizado_em`) VALUES
(1, 'Bio Dementia', 'Prepare-se para mergulhar na escuridão e elegância. O Bio Dementia é a festa gótica mais tradicional e intensa de Curitiba, um evento essencial para quem vive a cultura Dark. Aqui, celebramos a estética e a música gótica em uma noite de profunda imersão no underground.', '2025-12-07 22:00:00', 'The Black Castle', NULL, 'Curitiba', 'PR', 400, 125, 275, 120.00, 60.00, 'Festa', 18, NULL, NULL, 'ativo', 1, '2025-09-01 03:00:00', '2025-11-19 19:55:26'),
(2, 'Noir Fest', 'Esta é uma noite temática no Jokers Pub que exige elegância, mistério e atitude. Celebramos a estética atemporal do Film Noir e a cultura Dark, em um evento onde o jazz encontra o rock e a pista de dança se torna um palco de intrigas e charme.', '2025-11-25 20:00:00', 'Teatro Guaíra', NULL, 'Curitiba', 'PR', 300, 100, 200, 80.00, 40.00, 'Show', 18, NULL, NULL, 'ativo', 1, '2025-09-10 03:00:00', '2025-11-19 19:55:26'),
(3, 'Vampires Night', 'O Vampires Night no Tork N Roll é a festa ideal para os amantes da cultura dark, rock, gótico e vampiresco, reunindo a comunidade em um dos maiores palcos de Curitiba. Vista-se de preto, capriche no traje de gala sombrio e venha celebrar a noite até o sol raiar.', '2026-01-15 14:00:00', 'Centro de Eventos', NULL, 'Curitiba', 'PR', 500, 30, 470, 30.00, 15.00, 'Feira', 18, NULL, NULL, 'ativo', 0, '2025-10-01 03:00:00', '2025-11-19 19:55:26');

-- --------------------------------------------------------

--
-- Estrutura para tabela `ingressos`
--

CREATE TABLE `ingressos` (
  `id` int(11) NOT NULL,
  `codigo_ingresso` varchar(50) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `evento_id` int(11) NOT NULL,
  `lote_id` int(11) DEFAULT NULL,
  `tipo_ingresso` enum('inteira','meia') NOT NULL,
  `quantidade` int(11) DEFAULT 1,
  `valor_unitario` decimal(10,2) NOT NULL,
  `valor_total` decimal(10,2) NOT NULL,
  `taxa_servico` decimal(10,2) DEFAULT 0.00,
  `valor_final` decimal(10,2) NOT NULL,
  `status_ingresso` enum('pendente','confirmado','cancelado','usado') DEFAULT 'pendente',
  `forma_pagamento` enum('pix','cartao_credito','cartao_debito','boleto') NOT NULL,
  `data_compra` timestamp NOT NULL DEFAULT current_timestamp(),
  `data_pagamento` datetime DEFAULT NULL,
  `data_cancelamento` datetime DEFAULT NULL,
  `data_uso` datetime DEFAULT NULL,
  `qr_code` text DEFAULT NULL,
  `observacoes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `ingressos`
--

INSERT INTO `ingressos` (`id`, `codigo_ingresso`, `usuario_id`, `evento_id`, `lote_id`, `tipo_ingresso`, `quantidade`, `valor_unitario`, `valor_total`, `taxa_servico`, `valor_final`, `status_ingresso`, `forma_pagamento`, `data_compra`, `data_pagamento`, `data_cancelamento`, `data_uso`, `qr_code`, `observacoes`) VALUES
(1, 'RVN001-000001', 2, 1, 1, 'inteira', 2, 80.00, 160.00, 16.00, 176.00, 'confirmado', 'pix', '2025-09-10 17:30:00', '2025-09-10 14:32:00', NULL, NULL, NULL, NULL),
(2, 'RVN001-000002', 3, 1, 1, 'meia', 1, 40.00, 40.00, 4.00, 44.00, 'confirmado', 'cartao_credito', '2025-09-15 21:20:00', '2025-09-15 18:20:00', NULL, NULL, NULL, NULL),
(3, 'RVN001-000003', 4, 1, 2, 'inteira', 3, 120.00, 360.00, 36.00, 396.00, 'confirmado', 'pix', '2025-10-20 14:45:00', '2025-10-20 11:47:00', NULL, NULL, NULL, NULL),
(4, 'RVN001-000004', 5, 1, 2, 'meia', 2, 60.00, 120.00, 12.00, 132.00, 'confirmado', 'cartao_debito', '2025-10-25 19:00:00', '2025-10-25 16:00:00', NULL, NULL, NULL, NULL),
(5, 'RVN002-000001', 2, 2, 4, 'inteira', 1, 70.00, 70.00, 7.00, 77.00, 'confirmado', 'pix', '2025-09-20 13:15:00', '2025-09-20 10:17:00', NULL, NULL, NULL, NULL),
(6, 'RVN002-000002', 3, 2, 4, 'meia', 1, 35.00, 35.00, 3.50, 38.50, 'confirmado', 'pix', '2025-09-22 18:30:00', '2025-09-22 15:32:00', NULL, NULL, NULL, NULL),
(7, 'RVN002-000003', 4, 2, 5, 'inteira', 2, 80.00, 160.00, 16.00, 176.00, 'confirmado', 'cartao_credito', '2025-11-05 22:00:00', '2025-11-05 19:00:00', NULL, NULL, NULL, NULL),
(8, 'RVN003-000001', 2, 3, 6, 'inteira', 1, 60.00, 60.00, 6.00, 66.00, 'confirmado', 'pix', '2025-10-15 15:00:00', '2025-10-15 12:02:00', NULL, NULL, NULL, NULL),
(9, 'RVN003-000002', 5, 3, 6, 'meia', 2, 30.00, 60.00, 6.00, 66.00, 'confirmado', 'cartao_debito', '2025-10-18 17:30:00', '2025-10-18 14:30:00', NULL, NULL, NULL, NULL);

--
-- Acionadores `ingressos`
--
DELIMITER $$
CREATE TRIGGER `tr_log_cancelamento_ingresso` AFTER UPDATE ON `ingressos` FOR EACH ROW BEGIN
    -- Verifica se o status mudou de 'confirmado' para 'cancelado'
    IF OLD.status_ingresso = 'confirmado' AND NEW.status_ingresso = 'cancelado' THEN
        -- Devolve no evento
        UPDATE eventos
        SET ingressos_vendidos = ingressos_vendidos - NEW.quantidade,
            ingressos_disponiveis = ingressos_disponiveis + NEW.quantidade
        WHERE id = NEW.evento_id;
        
        -- Devolve no lote
        UPDATE lotes
        SET quantidade_vendida = quantidade_vendida - NEW.quantidade,
            quantidade_disponivel = quantidade_disponivel + NEW.quantidade,
            status_lote = 'ativo' -- Reativa o lote se tinha esgotado
        WHERE id = NEW.lote_id;
        
        -- Log da ação
        INSERT INTO log_acoes (usuario_id, tipo_acao, descricao, tabela_afetada, registro_id)
        VALUES (NEW.usuario_id, 'cancelamento', CONCAT('Ingresso #', NEW.codigo_ingresso, ' cancelado.'), 'ingressos', NEW.id);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_log_compra_ingresso` AFTER UPDATE ON `ingressos` FOR EACH ROW BEGIN
    -- Verifica se o status mudou de 'pendente' para 'confirmado'
    IF OLD.status_ingresso = 'pendente' AND NEW.status_ingresso = 'confirmado' THEN
        -- Atualiza no evento
        UPDATE eventos
        SET ingressos_vendidos = ingressos_vendidos + NEW.quantidade,
            ingressos_disponiveis = capacidade_total - (ingressos_vendidos + NEW.quantidade)
        WHERE id = NEW.evento_id;
        
        -- Atualiza no lote
        UPDATE lotes
        SET quantidade_vendida = quantidade_vendida + NEW.quantidade,
            quantidade_disponivel = quantidade_disponivel - NEW.quantidade
        WHERE id = NEW.lote_id;
        
        -- Log da ação
        INSERT INTO log_acoes (usuario_id, tipo_acao, descricao, tabela_afetada, registro_id)
        VALUES (NEW.usuario_id, 'compra', CONCAT('Ingresso #', NEW.codigo_ingresso, ' confirmado.'), 'ingressos', NEW.id);
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura para tabela `log_acoes`
--

CREATE TABLE `log_acoes` (
  `id` int(11) NOT NULL,
  `usuario_id` int(11) DEFAULT NULL,
  `tipo_acao` enum('compra','cancelamento','login','cadastro','edicao','exclusao') NOT NULL,
  `descricao` text DEFAULT NULL,
  `tabela_afetada` varchar(50) DEFAULT NULL,
  `registro_id` int(11) DEFAULT NULL,
  `ip_origem` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `data_acao` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estrutura para tabela `lotes`
--

CREATE TABLE `lotes` (
  `id` int(11) NOT NULL,
  `evento_id` int(11) NOT NULL,
  `nome_lote` varchar(100) NOT NULL,
  `numero_lote` int(11) NOT NULL,
  `quantidade_total` int(11) NOT NULL,
  `quantidade_vendida` int(11) DEFAULT 0,
  `quantidade_disponivel` int(11) DEFAULT NULL,
  `preco_inteira` decimal(10,2) NOT NULL,
  `preco_meia` decimal(10,2) NOT NULL,
  `data_inicio` datetime NOT NULL,
  `data_fim` datetime NOT NULL,
  `status_lote` enum('ativo','esgotado','encerrado') DEFAULT 'ativo',
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `lotes`
--

INSERT INTO `lotes` (`id`, `evento_id`, `nome_lote`, `numero_lote`, `quantidade_total`, `quantidade_vendida`, `quantidade_disponivel`, `preco_inteira`, `preco_meia`, `data_inicio`, `data_fim`, `status_lote`, `criado_em`) VALUES
(1, 1, '1º Lote - Early Bird', 1, 100, 75, 25, 80.00, 40.00, '2025-09-01 00:00:00', '2025-10-15 23:59:59', 'ativo', '2025-11-19 19:55:26'),
(2, 1, '2º Lote - Normal', 2, 150, 50, 100, 120.00, 60.00, '2025-10-16 00:00:00', '2025-11-30 23:59:59', 'ativo', '2025-11-19 19:55:26'),
(3, 1, '3º Lote - Última Hora', 3, 150, 0, 150, 150.00, 75.00, '2025-12-01 00:00:00', '2025-12-07 20:00:00', 'ativo', '2025-11-19 19:55:26'),
(4, 2, '1º Lote - Pré-Venda', 1, 100, 80, 20, 70.00, 35.00, '2025-09-15 00:00:00', '2025-10-31 23:59:59', 'ativo', '2025-11-19 19:55:26'),
(5, 2, '2º Lote - Final', 2, 200, 20, 180, 80.00, 40.00, '2025-11-01 00:00:00', '2025-11-25 18:00:00', 'ativo', '2025-11-19 19:55:26'),
(6, 3, '1º Lote - Super Early', 1, 150, 30, 120, 60.00, 30.00, '2025-10-01 00:00:00', '2025-11-15 23:59:59', 'ativo', '2025-11-19 19:55:26'),
(7, 3, '2º Lote - Antecipado', 2, 200, 0, 200, 90.00, 45.00, '2025-11-16 00:00:00', '2025-12-31 23:59:59', 'ativo', '2025-11-19 19:55:26'),
(8, 3, '3º Lote - Portaria', 3, 150, 0, 150, 120.00, 60.00, '2026-01-01 00:00:00', '2026-01-15 20:00:00', 'ativo', '2025-11-19 19:55:26');

--
-- Acionadores `lotes`
--
DELIMITER $$
CREATE TRIGGER `tr_atualizar_ingressos_disponiveis` AFTER INSERT ON `lotes` FOR EACH ROW BEGIN
    UPDATE eventos 
    SET ingressos_disponiveis = COALESCE(ingressos_disponiveis, 0) + NEW.quantidade_total
    WHERE id = NEW.evento_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura para tabela `pagamentos`
--

CREATE TABLE `pagamentos` (
  `id` int(11) NOT NULL,
  `ingresso_id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `valor_pago` decimal(10,2) NOT NULL,
  `forma_pagamento` enum('pix','cartao_credito','cartao_debito','boleto') NOT NULL,
  `status_pagamento` enum('pendente','aprovado','recusado','estornado') DEFAULT 'pendente',
  `codigo_transacao` varchar(255) NOT NULL,
  `codigo_autorizacao` varchar(255) DEFAULT NULL,
  `bandeira_cartao` varchar(50) DEFAULT NULL,
  `ultimos_digitos` varchar(4) DEFAULT NULL,
  `parcelas` int(11) DEFAULT 1,
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  `atualizado_em` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `ip_origem` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `pagamentos`
--

INSERT INTO `pagamentos` (`id`, `ingresso_id`, `usuario_id`, `valor_pago`, `forma_pagamento`, `status_pagamento`, `codigo_transacao`, `codigo_autorizacao`, `bandeira_cartao`, `ultimos_digitos`, `parcelas`, `criado_em`, `atualizado_em`, `ip_origem`) VALUES
(1, 1, 2, 176.00, 'pix', 'aprovado', 'PIX-20250910-143200-001', 'PIX-AUTO-001', NULL, NULL, 1, '2025-11-19 19:55:26', '2025-11-19 19:55:26', NULL),
(2, 2, 3, 44.00, 'cartao_credito', 'aprovado', 'CC-20250915-182000-002', 'AUTH-CC-002', NULL, NULL, 1, '2025-11-19 19:55:26', '2025-11-19 19:55:26', NULL),
(3, 3, 4, 396.00, 'pix', 'aprovado', 'PIX-20251020-114700-003', 'PIX-AUTO-003', NULL, NULL, 1, '2025-11-19 19:55:26', '2025-11-19 19:55:26', NULL),
(4, 4, 5, 132.00, 'cartao_debito', 'aprovado', 'DB-20251025-160000-004', 'AUTH-DB-004', NULL, NULL, 1, '2025-11-19 19:55:26', '2025-11-19 19:55:26', NULL),
(5, 5, 2, 77.00, 'pix', 'aprovado', 'PIX-20250920-101700-005', 'PIX-AUTO-005', NULL, NULL, 1, '2025-11-19 19:55:26', '2025-11-19 19:55:26', NULL),
(6, 6, 3, 38.50, 'pix', 'aprovado', 'PIX-20250922-153200-006', 'PIX-AUTO-006', NULL, NULL, 1, '2025-11-19 19:55:26', '2025-11-19 19:55:26', NULL),
(7, 7, 4, 176.00, 'cartao_credito', 'aprovado', 'CC-20251105-190000-007', 'AUTH-CC-007', NULL, NULL, 1, '2025-11-19 19:55:26', '2025-11-19 19:55:26', NULL),
(8, 8, 2, 66.00, 'pix', 'aprovado', 'PIX-20251015-120200-008', 'PIX-AUTO-008', NULL, NULL, 1, '2025-11-19 19:55:26', '2025-11-19 19:55:26', NULL),
(9, 9, 5, 66.00, 'cartao_debito', 'aprovado', 'DB-20251018-143000-009', 'AUTH-DB-009', NULL, NULL, 1, '2025-11-19 19:55:26', '2025-11-19 19:55:26', NULL);

-- --------------------------------------------------------

--
-- Estrutura para tabela `usuarios`
--

CREATE TABLE `usuarios` (
  `id` int(11) NOT NULL,
  `nome` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `senha` varchar(255) NOT NULL,
  `telefone` varchar(20) DEFAULT NULL,
  `cpf` varchar(14) DEFAULT NULL,
  `data_nascimento` date DEFAULT NULL,
  `tipo_usuario` enum('cliente','admin') DEFAULT 'cliente',
  `status` enum('ativo','inativo','bloqueado') DEFAULT 'ativo',
  `data_cadastro` timestamp NOT NULL DEFAULT current_timestamp(),
  `ultima_atualizacao` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `usuarios`
--

INSERT INTO `usuarios` (`id`, `nome`, `email`, `senha`, `telefone`, `cpf`, `data_nascimento`, `tipo_usuario`, `status`, `data_cadastro`, `ultima_atualizacao`) VALUES
(1, 'Admin Raven', 'admin@ravenslist.com', '$2y$10$qG6tZaC4dPVQvWf9rTF2.ePoeaALl5h6atD2Z1Tkw5.aTpp6bWrV.', NULL, NULL, NULL, 'admin', 'ativo', '2025-11-19 19:55:26', '2025-11-19 19:55:26'),
(2, 'João Silva', 'joao@teste.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', NULL, NULL, NULL, 'cliente', 'ativo', '2025-11-19 19:55:26', '2025-11-19 19:55:26'),
(3, 'Maria Santos', 'maria@teste.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', NULL, NULL, NULL, 'cliente', 'ativo', '2025-11-19 19:55:26', '2025-11-19 19:55:26'),
(4, 'Pedro Oliveira', 'pedro@teste.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', NULL, NULL, NULL, 'cliente', 'ativo', '2025-11-19 19:55:26', '2025-11-19 19:55:26'),
(5, 'Ana Costa', 'ana@teste.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', NULL, NULL, NULL, 'cliente', 'ativo', '2025-11-19 19:55:26', '2025-11-19 19:55:26');

-- --------------------------------------------------------

--
-- Estrutura stand-in para view `vw_estatisticas_gerais`
-- (Veja abaixo para a visão atual)
--
CREATE TABLE `vw_estatisticas_gerais` (
`total_usuarios` bigint(21)
,`total_eventos` bigint(21)
,`total_vendas` bigint(21)
,`total_ingressos_vendidos` decimal(32,0)
,`receita_total` decimal(32,2)
,`ticket_medio` decimal(11,2)
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para view `vw_historico_compras`
-- (Veja abaixo para a visão atual)
--
CREATE TABLE `vw_historico_compras` (
`usuario_id` int(11)
,`nome_usuario` varchar(100)
,`email_usuario` varchar(100)
,`evento` varchar(200)
,`data_evento` datetime
,`nome_lote` varchar(100)
,`codigo_ingresso` varchar(50)
,`tipo_ingresso` enum('inteira','meia')
,`quantidade` int(11)
,`valor_final` decimal(10,2)
,`status_ingresso` enum('pendente','confirmado','cancelado','usado')
,`data_compra` timestamp
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para view `vw_vendas_por_evento`
-- (Veja abaixo para a visão atual)
--
CREATE TABLE `vw_vendas_por_evento` (
`evento_id` int(11)
,`titulo` varchar(200)
,`data_evento` datetime
,`total_ingressos_vendidos` decimal(32,0)
,`receita_total` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Estrutura para view `vw_estatisticas_gerais`
--
DROP TABLE IF EXISTS `vw_estatisticas_gerais`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_estatisticas_gerais`  AS SELECT (select count(distinct `usuarios`.`id`) from `usuarios`) AS `total_usuarios`, (select count(distinct `eventos`.`id`) from `eventos`) AS `total_eventos`, count(`i`.`id`) AS `total_vendas`, sum(`i`.`quantidade`) AS `total_ingressos_vendidos`, sum(`i`.`valor_final`) AS `receita_total`, round(avg(`i`.`valor_final`),2) AS `ticket_medio` FROM `ingressos` AS `i` WHERE `i`.`status_ingresso` in ('confirmado','usado') ;

-- --------------------------------------------------------

--
-- Estrutura para view `vw_historico_compras`
--
DROP TABLE IF EXISTS `vw_historico_compras`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_historico_compras`  AS SELECT `u`.`id` AS `usuario_id`, `u`.`nome` AS `nome_usuario`, `u`.`email` AS `email_usuario`, `e`.`titulo` AS `evento`, `e`.`data_evento` AS `data_evento`, `l`.`nome_lote` AS `nome_lote`, `i`.`codigo_ingresso` AS `codigo_ingresso`, `i`.`tipo_ingresso` AS `tipo_ingresso`, `i`.`quantidade` AS `quantidade`, `i`.`valor_final` AS `valor_final`, `i`.`status_ingresso` AS `status_ingresso`, `i`.`data_compra` AS `data_compra` FROM (((`usuarios` `u` join `ingressos` `i` on(`u`.`id` = `i`.`usuario_id`)) join `eventos` `e` on(`i`.`evento_id` = `e`.`id`)) left join `lotes` `l` on(`i`.`lote_id` = `l`.`id`)) ORDER BY `u`.`id` ASC, `i`.`data_compra` DESC ;

-- --------------------------------------------------------

--
-- Estrutura para view `vw_vendas_por_evento`
--
DROP TABLE IF EXISTS `vw_vendas_por_evento`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_vendas_por_evento`  AS SELECT `e`.`id` AS `evento_id`, `e`.`titulo` AS `titulo`, `e`.`data_evento` AS `data_evento`, coalesce(sum(`i`.`quantidade`),0) AS `total_ingressos_vendidos`, coalesce(sum(`i`.`valor_final`),0.00) AS `receita_total` FROM (`eventos` `e` left join `ingressos` `i` on(`e`.`id` = `i`.`evento_id` and `i`.`status_ingresso` in ('confirmado','usado'))) GROUP BY `e`.`id`, `e`.`titulo`, `e`.`data_evento` ;

--
-- Índices para tabelas despejadas
--

--
-- Índices de tabela `estatisticas_vendas`
--
ALTER TABLE `estatisticas_vendas`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `evento_id` (`evento_id`),
  ADD KEY `idx_evento_data` (`evento_id`,`data_estatistica`);

--
-- Índices de tabela `eventos`
--
ALTER TABLE `eventos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_data` (`data_evento`),
  ADD KEY `idx_status` (`status_evento`),
  ADD KEY `idx_categoria` (`categoria`);

--
-- Índices de tabela `ingressos`
--
ALTER TABLE `ingressos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `codigo_ingresso` (`codigo_ingresso`),
  ADD KEY `lote_id` (`lote_id`),
  ADD KEY `idx_codigo` (`codigo_ingresso`),
  ADD KEY `idx_usuario` (`usuario_id`),
  ADD KEY `idx_evento` (`evento_id`),
  ADD KEY `idx_status_ingresso` (`status_ingresso`);

--
-- Índices de tabela `log_acoes`
--
ALTER TABLE `log_acoes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_usuario` (`usuario_id`),
  ADD KEY `idx_acao_tabela` (`tipo_acao`,`tabela_afetada`);

--
-- Índices de tabela `lotes`
--
ALTER TABLE `lotes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_evento` (`evento_id`),
  ADD KEY `idx_status` (`status_lote`);

--
-- Índices de tabela `pagamentos`
--
ALTER TABLE `pagamentos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `codigo_transacao` (`codigo_transacao`),
  ADD KEY `ingresso_id` (`ingresso_id`),
  ADD KEY `usuario_id` (`usuario_id`),
  ADD KEY `idx_transacao` (`codigo_transacao`);

--
-- Índices de tabela `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `cpf` (`cpf`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `idx_tipo` (`tipo_usuario`);

--
-- AUTO_INCREMENT para tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `estatisticas_vendas`
--
ALTER TABLE `estatisticas_vendas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `eventos`
--
ALTER TABLE `eventos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de tabela `ingressos`
--
ALTER TABLE `ingressos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de tabela `log_acoes`
--
ALTER TABLE `log_acoes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `lotes`
--
ALTER TABLE `lotes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de tabela `pagamentos`
--
ALTER TABLE `pagamentos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de tabela `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Restrições para tabelas despejadas
--

--
-- Restrições para tabelas `estatisticas_vendas`
--
ALTER TABLE `estatisticas_vendas`
  ADD CONSTRAINT `estatisticas_vendas_ibfk_1` FOREIGN KEY (`evento_id`) REFERENCES `eventos` (`id`) ON DELETE CASCADE;

--
-- Restrições para tabelas `ingressos`
--
ALTER TABLE `ingressos`
  ADD CONSTRAINT `ingressos_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`),
  ADD CONSTRAINT `ingressos_ibfk_2` FOREIGN KEY (`evento_id`) REFERENCES `eventos` (`id`),
  ADD CONSTRAINT `ingressos_ibfk_3` FOREIGN KEY (`lote_id`) REFERENCES `lotes` (`id`) ON DELETE SET NULL;

--
-- Restrições para tabelas `log_acoes`
--
ALTER TABLE `log_acoes`
  ADD CONSTRAINT `log_acoes_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Restrições para tabelas `lotes`
--
ALTER TABLE `lotes`
  ADD CONSTRAINT `lotes_ibfk_1` FOREIGN KEY (`evento_id`) REFERENCES `eventos` (`id`) ON DELETE NO ACTION;

--
-- Restrições para tabelas `pagamentos`
--
ALTER TABLE `pagamentos`
  ADD CONSTRAINT `pagamentos_ibfk_1` FOREIGN KEY (`ingresso_id`) REFERENCES `ingressos` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `pagamentos_ibfk_2` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;