<?php
require './../../Backend/Conexao/conexao.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $user_id = $_POST['user_id'];
    $sale_date = $_POST['sale_date'];
    $products_json = $_POST['products'];

    try {
        $pdo->beginTransaction();

        $stmt = $pdo->prepare("CALL RegistrarVenda(:p_id_usuario, :p_data_venda, :p_itens)");

        $stmt->bindParam(':p_id_usuario', $user_id, PDO::PARAM_INT);
        $stmt->bindParam(':p_data_venda', $sale_date, PDO::PARAM_STR);
        $stmt->bindParam(':p_itens', $products_json, PDO::PARAM_STR);

        $stmt->execute();

        if ($stmt->rowCount() > 0) {
            if ($pdo->inTransaction()) {
                $pdo->commit();
            }
            echo "Venda registrada com sucesso!";
        } else {
            echo "Erro ao registrar venda: Não foi possível completar a operação.";

            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }
        }

        $stmt->closeCursor();
    } catch (PDOException $e) {
        echo "Erro ao registrar venda: " . $e->getMessage();

        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
    }
} else {
    echo "Erro: Método de requisição inválido.";
}

$pdo = null;
?>
