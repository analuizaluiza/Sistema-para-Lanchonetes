<?php
require './../../Backend/Conexao/conexao.php';

$error_message = '';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    if (!isset($_POST['email']) || !isset($_POST['senha'])) {
        $error_message = 'Por favor, insira o email e a senha.';
    } else {
        $email = $_POST['email'];
        $senha = $_POST['senha'];

        $sql = "SELECT * FROM Usuario WHERE Email = :email";
        $stmt = $pdo->prepare($sql);
        $stmt->bindParam(':email', $email);
        $stmt->execute();
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($user) {
            if (password_verify($senha, $user['Senha'])) {
                session_start();
                $_SESSION['usuario_id'] = $user['ID_Usuario']; 
                echo json_encode(['status' => 'success']);
                exit();
            } else {
                $error_message = "Senha incorreta.";
            }
        } else {
            $error_message = "Usuário não encontrado.";
        }
    }
}

if (!empty($error_message)) {
    echo json_encode(['status' => 'error', 'message' => $error_message]);
    exit();
}
?>
