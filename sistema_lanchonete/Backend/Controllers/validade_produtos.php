<?php
require './../../Backend/Conexao/conexao.php';
try {
    $stmt = $pdo->query("SELECT * FROM Validade_Produtos");
    $validade_produtos = $stmt->fetchAll();
    echo json_encode($validade_produtos);
} catch (PDOException $e) {
    echo json_encode(['error' => $e->getMessage()]);
}
?>
