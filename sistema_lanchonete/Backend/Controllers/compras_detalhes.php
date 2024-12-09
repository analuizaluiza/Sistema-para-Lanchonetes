<?php
require './../../Backend/Conexao/conexao.php';

try {
    $stmt = $pdo->query("SELECT * FROM Compras_Detalhes");
    $compras = $stmt->fetchAll();
    echo json_encode($compras);
} catch (PDOException $e) {
    echo json_encode(['error' => $e->getMessage()]);
}
?>