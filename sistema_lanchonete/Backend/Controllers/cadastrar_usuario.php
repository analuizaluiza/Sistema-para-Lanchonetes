<?php
require './../../Backend/Conexao/conexao.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    if (!isset($_POST['nome']) || !isset($_POST['sobrenome']) || !isset($_POST['email']) || !isset($_POST['senha'])) {
        echo json_encode(['status' => 'error', 'message' => 'Nome, sobrenome, email ou senha não fornecidos.']);
        exit;
    }
    $nome = $_POST['nome'];
    $sobrenome = $_POST['sobrenome'];
    $email = $_POST['email'];
    $senha = $_POST['senha'];

    $senha_hash = password_hash($senha, PASSWORD_DEFAULT);

    $stmt = $pdo->prepare('INSERT INTO usuario (nome, sobrenome, email, senha) VALUES (?, ?, ?, ?)');
    $stmt->execute([$nome, $sobrenome, $email, $senha_hash]);

    if ($stmt->rowCount() > 0) {
        echo json_encode(['status' => 'success', 'message' => 'Usuário cadastrado com sucesso!']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Erro ao cadastrar usuário.']);
    }

} else {
    echo json_encode(['status' => 'error', 'message' => 'Método de requisição inválido.']);
}
?>
