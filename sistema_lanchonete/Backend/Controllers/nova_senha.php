<?php
require './../../Backend/Conexao/conexao.php';


ini_set('display_errors', 0);
ini_set('log_errors', 1);
ini_set('error_log', '/path/to/your/error.log'); 
error_reporting(E_ALL);


header('Content-Type: application/json');

$response = [];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!isset($_POST['email'], $_POST['nova-senha'])) {
        $response = ['status' => 'error', 'message' => 'Parâmetros incompletos.'];
        echo json_encode($response);
        exit;
    }

    $email = filter_var($_POST['email'], FILTER_SANITIZE_EMAIL);
    $novaSenha = $_POST['nova-senha'];

    try {
        $query = "SELECT * FROM usuario WHERE Email = :email";
        $stmt = $pdo->prepare($query);
        $stmt->bindParam(':email', $email);
        $stmt->execute();

        if ($stmt->rowCount() > 0) {
            $queryUpdate = "UPDATE usuario SET Senha = :senha WHERE Email = :email";
            $stmtUpdate = $pdo->prepare($queryUpdate);
            $stmtUpdate->bindParam(':senha', password_hash($novaSenha, PASSWORD_DEFAULT));
            $stmtUpdate->bindParam(':email', $email);
            $stmtUpdate->execute();

            if ($stmtUpdate->rowCount() > 0) {
                $response = ['status' => 'success', 'message' => 'Senha atualizada com sucesso!'];
            } else {
                $response = ['status' => 'error', 'message' => 'Erro ao atualizar a senha.'];
            }
        } else {
            $response = ['status' => 'error', 'message' => 'Usuário não encontrado.'];
        }
    } catch (PDOException $e) {
        error_log($e->getMessage()); 
        $response = ['status' => 'error', 'message' => 'Erro ao processar a solicitação.'];
    }
} else {
    $response = ['status' => 'error', 'message' => 'Método não permitido.'];
}

echo json_encode($response);
?>
