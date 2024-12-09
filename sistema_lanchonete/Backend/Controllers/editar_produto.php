<?php

if ($_SERVER["REQUEST_METHOD"] == "POST") {
   
    require './../../Backend/Conexao/conexao.php';

 
    $productId = $_POST['id'];
    $nome = $_POST['nome'];
    $valor = $_POST['valor'];
    $dataFabricacao = $_POST['data_fabricacao'];
    $dataValidade = $_POST['data_validade'];
    $estoqueMinimo = $_POST['estoque_minimo'];
    $estoqueMaximo = $_POST['estoque_maximo'];

    
    $updateProdutoSQL = "UPDATE produtos SET nome = ?, valor = ?, data_fabricacao = ?, data_validade = ?, estoque_minimo = ?, estoque_maximo = ? WHERE id_produto = ?";

   
    $updateEstoqueSQL = "UPDATE estoque SET valor = ? WHERE id_produto = ?";

    try {
       
        $pdo->beginTransaction();

      
        $stmtProduto = $pdo->prepare($updateProdutoSQL);

        
        $stmtProduto->execute([$nome, $valor, $dataFabricacao, $dataValidade, $estoqueMinimo, $estoqueMaximo, $productId]);

       
        $stmtEstoque = $pdo->prepare($updateEstoqueSQL);

       
        $stmtEstoque->execute([$valor, $productId]);

      
        $pdo->commit();

       
        echo json_encode(['success' => 'Produto e estoque atualizados com sucesso!']);
    } catch (PDOException $e) {
      
        $pdo->rollback();

      
        echo json_encode(['error' => 'Erro ao atualizar produto e estoque: ' . $e->getMessage()]);
    }
} else {
   
    echo json_encode(['error' => 'Método de requisição não permitido']);
}
?>
