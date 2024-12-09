-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 28/06/2024 às 13:41
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
-- Banco de dados: `lanchonete`
--

DELIMITER $$
--
-- Procedimentos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `RegistrarCompra` (IN `p_data_compra` DATE, IN `p_id_fornecedor` VARCHAR(14), IN `p_produtos` JSON)   BEGIN
    DECLARE v_id_compra INT;
    DECLARE v_valor_produto DECIMAL(7, 2);
    DECLARE v_total DECIMAL(9, 2) DEFAULT 0;
    DECLARE v_estoque_maximo INT;
    DECLARE v_id_produto INT;
    DECLARE v_quantidade INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        
        ROLLBACK;
        DELETE FROM Compras WHERE ID_Compra = v_id_compra;
        RESIGNAL;
    END;

    START TRANSACTION;

    
    INSERT INTO Compras (Data_Compra, ID_Fornecedor)
    VALUES (p_data_compra, p_id_fornecedor);

    
    SET v_id_compra = LAST_INSERT_ID();

    
    SET @i = 0;
    WHILE @i < JSON_LENGTH(p_produtos) DO
        SET v_id_produto = JSON_UNQUOTE(JSON_EXTRACT(p_produtos, CONCAT('$[', @i, '].id_produto')));
        SET v_quantidade = JSON_UNQUOTE(JSON_EXTRACT(p_produtos, CONCAT('$[', @i, '].quantidade')));

        
        SELECT Valor INTO v_valor_produto
        FROM Produtos
        WHERE ID_Produto = v_id_produto;

        
        SELECT Estoque_Maximo INTO v_estoque_maximo
        FROM Produtos
        WHERE ID_Produto = v_id_produto;

        
        IF (SELECT Quantidade FROM Estoque WHERE ID_Produto = v_id_produto) + v_quantidade > v_estoque_maximo THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quantidade maxima de estoque atingida para o produto.';
        ELSE
            
            INSERT INTO Itens_Compras (ID_Produto, ID_Compra, Quantidade)
            VALUES (v_id_produto, v_id_compra, v_quantidade);

            
            SET v_total = v_total + (v_quantidade * v_valor_produto);
        END IF;

        
        SET @i = @i + 1;
    END WHILE;

    
    IF v_total > 0 THEN
        UPDATE Compras
        SET Total = v_total
        WHERE ID_Compra = v_id_compra;
    ELSE
        
        DELETE FROM Compras WHERE ID_Compra = v_id_compra;
    END IF;

    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `RegistrarVenda` (IN `p_id_usuario` INT, IN `p_data_venda` DATE, IN `p_itens` JSON)   BEGIN
    DECLARE v_id_venda INT;
    DECLARE i INT DEFAULT 0;
    DECLARE j INT;
    DECLARE v_id_produto INT;
    DECLARE v_quantidade INT;
    DECLARE v_valor_produto DECIMAL(7, 2);
    DECLARE v_total DECIMAL(9, 2) DEFAULT 0;
    DECLARE v_estoque_atual INT;
    DECLARE v_estoque_minimo INT;
    DECLARE v_json_path VARCHAR(255);
    DECLARE v_json_value VARCHAR(255);
    DECLARE v_message VARCHAR(255);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        
        ROLLBACK;
        DELETE FROM Vendas WHERE ID_Venda = v_id_venda;
        RESIGNAL;
    END;

    START TRANSACTION;

    
    INSERT INTO Vendas (ID_Usuario, Data_Venda) VALUES (p_id_usuario, p_data_venda);
    SET v_id_venda = LAST_INSERT_ID();

    SET j = JSON_LENGTH(p_itens) - 1;

    
    WHILE i <= j DO
        SET v_json_path = CONCAT('$[', i, '].ID_Produto');
        SET v_json_value = JSON_UNQUOTE(JSON_EXTRACT(p_itens, v_json_path));
        SET v_id_produto = CAST(v_json_value AS UNSIGNED);

        SET v_json_path = CONCAT('$[', i, '].Quantidade');
        SET v_json_value = JSON_UNQUOTE(JSON_EXTRACT(p_itens, v_json_path));
        SET v_quantidade = CAST(v_json_value AS UNSIGNED);

        
        SELECT Quantidade INTO v_estoque_atual
        FROM Estoque
        WHERE ID_Produto = v_id_produto;

        SELECT Estoque_Minimo INTO v_estoque_minimo
        FROM Produtos
        WHERE ID_Produto = v_id_produto;

        
        SELECT Valor INTO v_valor_produto
        FROM Produtos
        WHERE ID_Produto = v_id_produto;

        
        SET v_total = v_total + (v_valor_produto * v_quantidade);

        
        IF v_estoque_atual - v_quantidade < v_estoque_minimo THEN
            SET v_message = CONCAT('Quantidade minima de estoque do produto sera ultrapassada.');
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_message;
        ELSE
            
            INSERT INTO Itens_Vendas (ID_Produto, ID_Venda, Quantidade)
            VALUES (v_id_produto, v_id_venda, v_quantidade);
        END IF;

        SET i = i + 1;
    END WHILE;

    
    IF v_total > 0 THEN
        UPDATE Vendas
        SET Total = v_total
        WHERE ID_Venda = v_id_venda;
    ELSE
        
        DELETE FROM Vendas WHERE ID_Venda = v_id_venda;
    END IF;

    COMMIT;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura para tabela `compras`
--

CREATE TABLE `compras` (
  `ID_Compra` int(11) NOT NULL,
  `Data_Compra` date NOT NULL,
  `Total` decimal(9,2) DEFAULT 0.00,
  `ID_Fornecedor` varchar(14) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `compras`
--

INSERT INTO `compras` (`ID_Compra`, `Data_Compra`, `Total`, `ID_Fornecedor`) VALUES
(1, '2024-06-09', 450.00, '12345678901234'),
(3, '2024-06-09', 250.00, '12345678901234'),
(4, '2024-06-09', 75.00, '12345678901234'),
(9, '2024-06-11', 15.00, '12345678901234'),
(10, '2024-06-16', 20.00, '12345678901234'),
(11, '2024-06-17', 20.00, '12345678901234'),
(12, '2024-05-26', 30.00, '12345678901234'),
(13, '2024-06-06', 80.00, '12345678901234'),
(14, '2024-05-30', 10.00, '12345678901234'),
(15, '2024-06-28', 5.00, '12345678901234'),
(16, '2024-05-29', 5.00, '12345678901234'),
(17, '2024-06-01', 10.00, '12345678901234'),
(23, '2024-06-26', 270.00, '12345678901234'),
(24, '2024-06-26', 175.00, '12345678901234'),
(25, '2024-06-26', 37.50, '12345678901234'),
(26, '2024-06-26', 40.00, '12345678901234'),
(27, '2024-06-27', 60.00, '12345678901234'),
(28, '2024-06-27', 75.00, '12345678901234'),
(29, '2024-06-27', 64.00, '12345678901234'),
(30, '2024-06-27', 90.00, '12345678901234'),
(31, '2024-06-27', 40.00, '12345678901234'),
(32, '2024-06-27', 80.00, '12345678901234'),
(33, '2024-06-27', 80.00, '12345678901234'),
(37, '2024-06-27', 225.00, '12345678901234'),
(38, '2024-06-27', 40.00, '12345678901234'),
(39, '2024-06-27', 3.00, '12345678901234'),
(40, '2024-06-28', 5.00, '12345678901234');

-- --------------------------------------------------------

--
-- Estrutura stand-in para view `compras_detalhes`
-- (Veja abaixo para a visão atual)
--
CREATE TABLE `compras_detalhes` (
`ID_Compra` int(11)
,`Nome_Fornecedor` varchar(50)
,`Data_Compra` date
,`Total` decimal(9,2)
,`Produtos` mediumtext
,`Quantidades` mediumtext
);

-- --------------------------------------------------------

--
-- Estrutura para tabela `estoque`
--

CREATE TABLE `estoque` (
  `ID_Produto` int(11) NOT NULL,
  `Nome` varchar(40) NOT NULL,
  `Quantidade` int(4) DEFAULT NULL,
  `Valor` decimal(5,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `estoque`
--

INSERT INTO `estoque` (`ID_Produto`, `Nome`, `Quantidade`, `Valor`) VALUES
(9, 'Hamburguer', 14, 8.00),
(10, 'Refrigerante', 30, 5.00),
(11, 'Bombom', 50, 2.00),
(12, 'Batata Frita', 5, 15.00),
(13, 'Picolé', 15, 3.00),
(21, 'Coxinha', 6, 5.00),
(22, 'Pão de queijo', 14, 4.00),
(23, 'Água', 32, 2.50),
(24, 'Bolo', 8, 8.00),
(25, 'milshake', 6, 15.00),
(26, 'Empada', 8, 5.00),
(27, 'pastel', 8, 10.00),
(28, 'Sanduíche Natural', 7, 10.00),
(29, 'Sorvete', 45, 5.00),
(30, 'Paçoca', 77, 0.60);

-- --------------------------------------------------------

--
-- Estrutura para tabela `fornecedor`
--

CREATE TABLE `fornecedor` (
  `CNPJ` varchar(14) NOT NULL,
  `Nome` varchar(50) NOT NULL,
  `Endereco` varchar(100) NOT NULL,
  `Telefone` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `fornecedor`
--

INSERT INTO `fornecedor` (`CNPJ`, `Nome`, `Endereco`, `Telefone`) VALUES
('12345678901234', 'Fornecedor Exemplo', 'Rua Exemplo, 123', '1234-5678');

-- --------------------------------------------------------

--
-- Estrutura para tabela `itens_compras`
--

CREATE TABLE `itens_compras` (
  `ID_Produto` int(11) NOT NULL,
  `ID_Compra` int(11) NOT NULL,
  `Quantidade` int(11) NOT NULL CHECK (`Quantidade` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `itens_compras`
--

INSERT INTO `itens_compras` (`ID_Produto`, `ID_Compra`, `Quantidade`) VALUES
(9, 23, 15),
(10, 23, 30),
(11, 24, 50),
(12, 24, 5),
(13, 25, 15),
(21, 26, 8),
(22, 27, 15),
(23, 28, 30),
(23, 40, 2),
(24, 29, 8),
(25, 30, 6),
(26, 31, 8),
(27, 32, 8),
(28, 33, 8),
(29, 37, 45),
(30, 38, 80);

--
-- Acionadores `itens_compras`
--
DELIMITER $$
CREATE TRIGGER `AtualizaEstoqueAposCompra` AFTER INSERT ON `itens_compras` FOR EACH ROW BEGIN
    DECLARE produto_ja_no_estoque INT;
    DECLARE quantidade_atual INT;
    
    SELECT COUNT(*) INTO produto_ja_no_estoque 
    FROM Estoque 
    WHERE ID_Produto = NEW.ID_Produto;
    
    IF produto_ja_no_estoque > 0 THEN
        
        UPDATE Estoque 
        SET Quantidade = Quantidade + NEW.Quantidade 
        WHERE ID_Produto = NEW.ID_Produto;
    ELSE
        
        INSERT INTO Estoque (ID_Produto, Nome, Quantidade, Valor)
        SELECT p.ID_Produto, p.Nome, NEW.Quantidade, p.Valor
        FROM Produtos p
        WHERE p.ID_Produto = NEW.ID_Produto;
    END IF;
    
    
    SELECT Quantidade INTO quantidade_atual
    FROM Estoque
    WHERE ID_Produto = NEW.ID_Produto;
    IF quantidade_atual > (SELECT Estoque_Maximo FROM Produtos WHERE ID_Produto = NEW.ID_Produto) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantidade maxima de estoque atingida para o produto.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `atualizar_total_compras` AFTER INSERT ON `itens_compras` FOR EACH ROW BEGIN
UPDATE Compras
SET Total = (SELECT SUM(IC.Quantidade * P.Valor)
FROM Itens_Compras IC
JOIN Produtos P ON IC.ID_Produto = P.ID_Produto
WHERE IC.ID_Compra = NEW.ID_Compra)
WHERE ID_Compra = NEW.ID_Compra;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura para tabela `itens_vendas`
--

CREATE TABLE `itens_vendas` (
  `ID_Produto` int(11) NOT NULL,
  `ID_Venda` int(11) NOT NULL,
  `Quantidade` int(11) NOT NULL CHECK (`Quantidade` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `itens_vendas`
--

INSERT INTO `itens_vendas` (`ID_Produto`, `ID_Venda`, `Quantidade`) VALUES
(9, 89, 1),
(21, 92, 2),
(22, 92, 1),
(28, 91, 1),
(30, 90, 3);

--
-- Acionadores `itens_vendas`
--
DELIMITER $$
CREATE TRIGGER `AtualizaEstoqueAposVenda` AFTER INSERT ON `itens_vendas` FOR EACH ROW BEGIN
    DECLARE quantidade_atual INT;
    
    
    UPDATE Estoque 
    SET Quantidade = Quantidade - NEW.Quantidade 
    WHERE ID_Produto = NEW.ID_Produto;
    
    
    SELECT Quantidade INTO quantidade_atual
    FROM Estoque
    WHERE ID_Produto = NEW.ID_Produto;
    
    IF quantidade_atual < (SELECT Estoque_Minimo FROM Produtos WHERE ID_Produto = NEW.ID_Produto) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantidade minima de estoque atingida para o produto.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `atualizar_total_vendas` AFTER INSERT ON `itens_vendas` FOR EACH ROW BEGIN
UPDATE Vendas
SET Total = (SELECT SUM(IV.Quantidade * P.Valor)
FROM Itens_Vendas IV
JOIN Produtos P ON IV.ID_Produto = P.ID_Produto
WHERE IV.ID_Venda = NEW.ID_Venda)
WHERE ID_Venda = NEW.ID_Venda;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura para tabela `produtos`
--

CREATE TABLE `produtos` (
  `ID_Produto` int(11) NOT NULL,
  `Nome` varchar(40) NOT NULL,
  `Valor` decimal(7,2) NOT NULL CHECK (`Valor` > 0),
  `Data_Fabricacao` date DEFAULT NULL,
  `Data_Validade` date NOT NULL,
  `Estoque_Minimo` int(11) DEFAULT NULL,
  `Estoque_Maximo` int(11) DEFAULT NULL,
  `imagens` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `produtos`
--

INSERT INTO `produtos` (`ID_Produto`, `Nome`, `Valor`, `Data_Fabricacao`, `Data_Validade`, `Estoque_Minimo`, `Estoque_Maximo`, `imagens`) VALUES
(9, 'Hamburguer', 8.00, '2024-06-25', '2024-06-30', 5, 28, './../../Raiz/Imagens\\hamburguer.jpg'),
(10, 'Refrigerante', 5.00, '2024-06-13', '2025-10-11', 12, 80, './../../Raiz/Imagens\\refrigerante.jpg'),
(11, 'Bombom', 2.00, '2024-06-12', '2024-12-12', 10, 80, './../../Raiz/Imagens\\bombom.png'),
(12, 'Batata Frita', 15.00, '2024-06-26', '2024-06-29', 3, 10, './../../Raiz/Imagens\\batatafritaaa.jpg'),
(13, 'Picolé', 3.00, '2024-06-18', '2024-08-28', 10, 80, './../../Raiz/Imagens\\picole.jpg'),
(21, 'Coxinha', 5.00, '2024-06-26', '2024-06-29', 5, 15, './../../Raiz/imagens/coxinha.jpg'),
(22, 'Pão de queijo', 4.00, '2024-06-27', '2024-06-28', 10, 30, './../../Raiz/imagens/pãodequeijo.jpg'),
(23, 'Água', 2.50, '2024-06-27', '2025-01-04', 15, 80, './../../Raiz/imagens/agua.jpg'),
(24, 'Bolo', 8.00, '2024-06-27', '2024-06-29', 5, 15, './../../Raiz/imagens/bolo.png'),
(25, 'milshake', 15.00, '2024-06-27', '2024-06-27', 5, 10, './../../Raiz/imagens/milkshake.jpg'),
(26, 'Empada', 5.00, '2024-06-27', '2024-06-28', 5, 20, './../../Raiz/imagens/empada.jpg'),
(27, 'pastel', 10.00, '2024-06-27', '2024-06-28', 5, 12, './../../Raiz/imagens/pastel.jpg'),
(28, 'Sanduíche Natural', 10.00, '2024-06-27', '2024-06-28', 5, 10, './../../Raiz/imagens/sanduichenatural.jpg'),
(29, 'Sorvete', 5.00, '2024-06-27', '2024-08-27', 10, 50, './../../Raiz/imagens/sorvete.jpg'),
(30, 'Paçoca', 0.60, '2024-06-27', '2025-06-27', 15, 100, './../../Raiz/imagens/paçoca.jpg');

-- --------------------------------------------------------

--
-- Estrutura para tabela `usuario`
--

CREATE TABLE `usuario` (
  `ID_Usuario` int(11) NOT NULL,
  `Nome` varchar(30) NOT NULL,
  `Sobrenome` varchar(30) NOT NULL,
  `Email` varchar(50) NOT NULL,
  `Senha` varchar(60) DEFAULT NULL
) ;

--
-- Despejando dados para a tabela `usuario`
--

INSERT INTO `usuario` (`ID_Usuario`, `Nome`, `Sobrenome`, `Email`, `Senha`) VALUES
(7, 'yasmim', 'sales', 'yasmim@email.com', '$2y$10$3Z1GbCS84bmr7dk5h442xejrNftUHfMBJ2E9pT7hb47Ivr8ZBn/vG'),
(8, 'maria', 'clara', 'maria@email.com', '$2y$10$lO3TsAvFxOeP2GIBAQzD0usICJ8vQ9O/pvcChWvP6/L1xZ2J9rjTO'),
(11, 'joana', 'silva', 'joana@email.com', '$2y$10$YbLwH7.eHAP1ZDE1sK18..cSBCXa.DYTLxygIWRIFIl3nroOqLl5K'),
(12, 'pablo', 'rocha', 'pablo@email.com', '$2y$10$DbewOrqjLXxTeqDmy9IPv.YYREguUEEeldu3lw/79j8mt8vDMhkDe'),
(14, 'ana', 'luiza', 'analuiza@email.com', '$2y$10$8gbxl19xBzIZwjoKx9OIS.MC5X21ZL0zRYYlnebk71yYXCiQdjA/S'),
(15, 'marcos', 'silva', 'marcos@email.com', '$2y$10$DmWDt.J3jygEJrIPsUmJxeTiKJkXAZI6PB3k10xAmMQK/IKJBrIdW'),
(16, 'Guilherme', 'Alves', 'guilherme@email.com', '$2y$10$IjHiLKNyeyNcSkZgniuyAu0oXkKQ3uz0EvzSxx1h.461/5YXdKyh6');

-- --------------------------------------------------------

--
-- Estrutura stand-in para view `validade_produtos`
-- (Veja abaixo para a visão atual)
--
CREATE TABLE `validade_produtos` (
`ID_Produto` int(11)
,`Nome` varchar(40)
,`Data_Fabricacao` date
,`Data_Validade` date
,`Dias_Restantes` int(7)
);

-- --------------------------------------------------------

--
-- Estrutura para tabela `vendas`
--

CREATE TABLE `vendas` (
  `ID_Venda` int(11) NOT NULL,
  `ID_Usuario` int(11) NOT NULL,
  `Data_Venda` date NOT NULL,
  `Total` decimal(9,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `vendas`
--

INSERT INTO `vendas` (`ID_Venda`, `ID_Usuario`, `Data_Venda`, `Total`) VALUES
(89, 7, '2024-06-27', 8.00),
(90, 14, '2024-06-27', 1.50),
(91, 16, '2024-06-27', 10.00),
(92, 14, '2024-06-28', 14.00);

-- --------------------------------------------------------

--
-- Estrutura stand-in para view `vendas_detalhes`
-- (Veja abaixo para a visão atual)
--
CREATE TABLE `vendas_detalhes` (
`ID_Venda` int(11)
,`Nome_Usuario` varchar(30)
,`Sobrenome_Usuario` varchar(30)
,`Data_Venda` date
,`Total` decimal(9,2)
,`Produtos` mediumtext
,`Quantidades` mediumtext
);

-- --------------------------------------------------------

--
-- Estrutura para view `compras_detalhes`
--
DROP TABLE IF EXISTS `compras_detalhes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `compras_detalhes`  AS SELECT `c`.`ID_Compra` AS `ID_Compra`, `f`.`Nome` AS `Nome_Fornecedor`, `c`.`Data_Compra` AS `Data_Compra`, `c`.`Total` AS `Total`, group_concat(`p`.`Nome` order by `p`.`Nome` ASC separator ', ') AS `Produtos`, group_concat(`ic`.`Quantidade` order by `p`.`Nome` ASC separator ', ') AS `Quantidades` FROM (((`compras` `c` join `fornecedor` `f` on(`c`.`ID_Fornecedor` = `f`.`CNPJ`)) join `itens_compras` `ic` on(`c`.`ID_Compra` = `ic`.`ID_Compra`)) join `produtos` `p` on(`ic`.`ID_Produto` = `p`.`ID_Produto`)) GROUP BY `c`.`ID_Compra`, `f`.`Nome`, `c`.`Data_Compra`, `c`.`Total` ;

-- --------------------------------------------------------

--
-- Estrutura para view `validade_produtos`
--
DROP TABLE IF EXISTS `validade_produtos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `validade_produtos`  AS SELECT `produtos`.`ID_Produto` AS `ID_Produto`, `produtos`.`Nome` AS `Nome`, `produtos`.`Data_Fabricacao` AS `Data_Fabricacao`, `produtos`.`Data_Validade` AS `Data_Validade`, to_days(`produtos`.`Data_Validade`) - to_days(curdate()) AS `Dias_Restantes` FROM `produtos` WHERE `produtos`.`Data_Validade` <= curdate() OR to_days(`produtos`.`Data_Validade`) - to_days(curdate()) <= 30 ;

-- --------------------------------------------------------

--
-- Estrutura para view `vendas_detalhes`
--
DROP TABLE IF EXISTS `vendas_detalhes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vendas_detalhes`  AS SELECT `v`.`ID_Venda` AS `ID_Venda`, `u`.`Nome` AS `Nome_Usuario`, `u`.`Sobrenome` AS `Sobrenome_Usuario`, `v`.`Data_Venda` AS `Data_Venda`, `v`.`Total` AS `Total`, group_concat(`p`.`Nome` order by `p`.`Nome` ASC separator ', ') AS `Produtos`, group_concat(`iv`.`Quantidade` order by `p`.`Nome` ASC separator ', ') AS `Quantidades` FROM (((`vendas` `v` join `usuario` `u` on(`v`.`ID_Usuario` = `u`.`ID_Usuario`)) join `itens_vendas` `iv` on(`v`.`ID_Venda` = `iv`.`ID_Venda`)) join `produtos` `p` on(`iv`.`ID_Produto` = `p`.`ID_Produto`)) GROUP BY `v`.`ID_Venda`, `u`.`Nome`, `u`.`Sobrenome`, `v`.`Data_Venda`, `v`.`Total` ;

--
-- Índices para tabelas despejadas
--

--
-- Índices de tabela `compras`
--
ALTER TABLE `compras`
  ADD PRIMARY KEY (`ID_Compra`),
  ADD KEY `ID_Fornecedor` (`ID_Fornecedor`),
  ADD KEY `idx_data_compra` (`Data_Compra`);

--
-- Índices de tabela `estoque`
--
ALTER TABLE `estoque`
  ADD PRIMARY KEY (`ID_Produto`);

--
-- Índices de tabela `fornecedor`
--
ALTER TABLE `fornecedor`
  ADD PRIMARY KEY (`CNPJ`),
  ADD KEY `idx_nome_fornecedor` (`Nome`);

--
-- Índices de tabela `itens_compras`
--
ALTER TABLE `itens_compras`
  ADD PRIMARY KEY (`ID_Produto`,`ID_Compra`),
  ADD KEY `ID_Compra` (`ID_Compra`);

--
-- Índices de tabela `itens_vendas`
--
ALTER TABLE `itens_vendas`
  ADD PRIMARY KEY (`ID_Produto`,`ID_Venda`),
  ADD KEY `ID_Venda` (`ID_Venda`);

--
-- Índices de tabela `produtos`
--
ALTER TABLE `produtos`
  ADD PRIMARY KEY (`ID_Produto`),
  ADD UNIQUE KEY `Nome` (`Nome`),
  ADD KEY `idx_nome_produto` (`Nome`);

--
-- Índices de tabela `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`ID_Usuario`),
  ADD UNIQUE KEY `Email` (`Email`),
  ADD KEY `idx_email_usuario` (`Email`);

--
-- Índices de tabela `vendas`
--
ALTER TABLE `vendas`
  ADD PRIMARY KEY (`ID_Venda`),
  ADD KEY `ID_Usuario` (`ID_Usuario`),
  ADD KEY `idx_data_venda` (`Data_Venda`);

--
-- AUTO_INCREMENT para tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `compras`
--
ALTER TABLE `compras`
  MODIFY `ID_Compra` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT de tabela `produtos`
--
ALTER TABLE `produtos`
  MODIFY `ID_Produto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT de tabela `usuario`
--
ALTER TABLE `usuario`
  MODIFY `ID_Usuario` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `vendas`
--
ALTER TABLE `vendas`
  MODIFY `ID_Venda` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=93;

--
-- Restrições para tabelas despejadas
--

--
-- Restrições para tabelas `compras`
--
ALTER TABLE `compras`
  ADD CONSTRAINT `compras_ibfk_1` FOREIGN KEY (`ID_Fornecedor`) REFERENCES `fornecedor` (`CNPJ`);

--
-- Restrições para tabelas `estoque`
--
ALTER TABLE `estoque`
  ADD CONSTRAINT `estoque_ibfk_1` FOREIGN KEY (`ID_Produto`) REFERENCES `produtos` (`ID_Produto`);

--
-- Restrições para tabelas `itens_compras`
--
ALTER TABLE `itens_compras`
  ADD CONSTRAINT `itens_compras_ibfk_1` FOREIGN KEY (`ID_Produto`) REFERENCES `produtos` (`ID_Produto`),
  ADD CONSTRAINT `itens_compras_ibfk_2` FOREIGN KEY (`ID_Compra`) REFERENCES `compras` (`ID_Compra`);

--
-- Restrições para tabelas `itens_vendas`
--
ALTER TABLE `itens_vendas`
  ADD CONSTRAINT `itens_vendas_ibfk_1` FOREIGN KEY (`ID_Produto`) REFERENCES `produtos` (`ID_Produto`),
  ADD CONSTRAINT `itens_vendas_ibfk_2` FOREIGN KEY (`ID_Venda`) REFERENCES `vendas` (`ID_Venda`);

--
-- Restrições para tabelas `vendas`
--
ALTER TABLE `vendas`
  ADD CONSTRAINT `vendas_ibfk_1` FOREIGN KEY (`ID_Usuario`) REFERENCES `usuario` (`ID_Usuario`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
