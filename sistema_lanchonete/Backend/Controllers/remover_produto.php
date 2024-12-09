<?php
require './../../Backend/Conexao/conexao.php';

$response = []; 

if ($_SERVER["REQUEST_METHOD"] == "POST") {
  
    if (!isset($_POST['produto_id'])) {
        $response['error'] = 'ID do produto não especificado.';
        echo json_encode($response);
        exit;
    }

   
    $produtoId = filter_var($_POST['produto_id'], FILTER_SANITIZE_NUMBER_INT);

    try {
        
        $pdo->beginTransaction();

       
        $stmtItensCompras = $pdo->prepare("DELETE FROM itens_compras WHERE id_produto = ?");
        $stmtItensCompras->execute([$produtoId]);

        $stmtItensCompras = $pdo->prepare("DELETE FROM itens_vendas WHERE id_produto = ?");
        $stmtItensCompras->execute([$produtoId]);

      
        $stmtEstoque = $pdo->prepare("DELETE FROM estoque WHERE id_produto = ?");
        $stmtEstoque->execute([$produtoId]);

      
        $stmtProduto = $pdo->prepare("DELETE FROM produtos WHERE id_produto = ?");
        $stmtProduto->execute([$produtoId]);

    
        if ($stmtProduto->rowCount() > 0) {
            $response['success'] = 'Produto removido com sucesso.';
        } else {
            $response['error'] = 'Nenhum produto foi removido.';
        }

       
        $pdo->commit();
    } catch (PDOException $e) {
     
        $pdo->rollBack();
        $response['error'] = 'Erro ao remover o produto: ' . $e->getMessage();
    }
} else {
    $response['error'] = 'Método não permitido. Apenas POST é aceito.';
}


echo json_encode($response);
?>
