<?php
require './../../Backend/Conexao/conexao.php';

header('Content-Type: application/json');

try {
    if (isset($_GET['id'])) {
        $id = $_GET['id'];
        $stmt = $pdo->prepare('SELECT id_produto, nome, valor, data_fabricacao, data_validade, estoque_minimo, estoque_maximo FROM produtos WHERE id_produto = ?');
        $stmt->execute([$id]);
        $produto = $stmt->fetch(PDO::FETCH_ASSOC);
        echo json_encode($produto);
    } else {
        $stmt = $pdo->query('SELECT id_produto, nome, valor, data_fabricacao, data_validade, estoque_minimo, estoque_maximo FROM produtos');
        $produtos = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode($produtos);
    }
} catch (Exception $e) {
    echo json_encode(['error' => $e->getMessage()]);
}
?>
