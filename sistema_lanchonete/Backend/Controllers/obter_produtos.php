<?php
require './../../Backend/Conexao/conexao.php';

try {
    $sql = "
        SELECT e.id_produto, e.nome, e.valor, e.quantidade, p.imagens 
        FROM estoque e 
        INNER JOIN produtos p ON e.id_produto = p.id_produto
    ";

    $stmt = $pdo->query($sql);
    $produtos = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    error_log(print_r($produtos, true));
    
    echo json_encode($produtos);
} catch (PDOException $e) {
    echo json_encode(['error' => 'Erro ao obter produtos: ' . $e->getMessage()]);
}
?>
