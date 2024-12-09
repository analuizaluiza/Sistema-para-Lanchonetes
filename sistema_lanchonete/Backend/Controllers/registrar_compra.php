<?php
require './../../Backend/Conexao/conexao.php';

header('Content-Type: application/json');

$response = [];

try {
    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        
        if (isset($_POST['purchase_date'], $_POST['fornecedor'], $_POST['products'])) {
            
            $dataCompra = $_POST['purchase_date'];
            $idFornecedor = $_POST['fornecedor'];
            $produtos = json_decode($_POST['products'], true); 

           
            error_log("Dados recebidos: " . print_r($_POST, true));

            try {
               
                error_log("Iniciando transação...");
                $pdo->beginTransaction();

                
                $stmt = $pdo->prepare("CALL RegistrarCompra(:data_compra, :id_fornecedor, :produtos)");

                
                $jsonProdutos = json_encode($produtos);

               
                $stmt->bindParam(':data_compra', $dataCompra, PDO::PARAM_STR);
                $stmt->bindParam(':id_fornecedor', $idFornecedor, PDO::PARAM_STR);
                $stmt->bindParam(':produtos', $jsonProdutos, PDO::PARAM_STR);
                $stmt->execute();

                
                if ($pdo->inTransaction()) {
                    error_log("Commit da transação...");
                    $pdo->commit();
                }

               
                $response = ['status' => 'success', 'message' => 'Compra registrada com sucesso!'];
            } catch (PDOException $e) {
                
                if ($pdo->inTransaction()) {
                    error_log("Rollback da transação...");
                    $pdo->rollback();
                }

               
                $response = ['status' => 'error', 'message' => 'Erro ao registrar compra: ' . $e->getMessage()];

                
                error_log("Erro ao registrar compra: " . $e->getMessage());
            }
        } else {
            
            $response = ['status' => 'error', 'message' => 'Erro: Campos obrigatórios não foram preenchidos.'];
        }
    } else {
        
        $response = ['status' => 'error', 'message' => 'Erro: Método de requisição inválido.'];
    }
} catch (PDOException $e) {
    $response = ['status' => 'error', 'message' => 'Erro ao iniciar transação: ' . $e->getMessage()];
    error_log("Erro ao iniciar transação: " . $e->getMessage());
}

echo json_encode($response);
?>