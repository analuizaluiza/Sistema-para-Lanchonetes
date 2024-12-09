<?php
require './../../Backend/Conexao/conexao.php';

try {
    $stmt = $pdo->query("SELECT * FROM Vendas_Detalhes");
    $vendas = $stmt->fetchAll();
    echo json_encode($vendas);
} catch (PDOException $e) {
    echo json_encode(['error' => $e->getMessage()]);
}
?>
