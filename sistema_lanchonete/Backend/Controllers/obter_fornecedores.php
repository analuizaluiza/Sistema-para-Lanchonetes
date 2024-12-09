<?php
require './../../Backend/Conexao/conexao.php';

try {
    $stmt = $pdo->query('SELECT CNPJ, nome FROM fornecedor');
    $fornecedores = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($fornecedores);
} catch (PDOException $e) {
    echo json_encode(['error' => $e->getMessage()]);
}
?>
