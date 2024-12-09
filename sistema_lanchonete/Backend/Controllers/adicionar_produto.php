<?php
require './../../Backend/Conexao/conexao.php';

$response = [];

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $nome = $_POST['nome'];
    $valor = $_POST['valor'];
    $data_fabricacao = $_POST['data_fabricacao'];
    $data_validade = $_POST['data_validade'];
    $estoque_minimo = $_POST['estoque_minimo'];
    $estoque_maximo = $_POST['estoque_maximo'];

    $imagem = ''; 

   
    if (isset($_FILES['imagens']) && $_FILES['imagens']['error'] === UPLOAD_ERR_OK) {
        $imagem_tmp = $_FILES['imagens']['tmp_name'];
        $imagem_nome = basename($_FILES['imagens']['name']); 
        $imagem_destino = './../../Raiz/imagens/' . $imagem_nome; 

        
        if (move_uploaded_file($imagem_tmp, $imagem_destino)) {
            $imagem = $imagem_destino; 
        } else {
            $response['error'] = 'Erro ao mover o arquivo de imagem.';
            echo json_encode($response);
            exit;
        }
    }

    try {
        $stmt = $pdo->prepare('INSERT INTO produtos (nome, valor, data_fabricacao, data_validade, estoque_minimo, estoque_maximo, imagens) VALUES (?, ?, ?, ?, ?, ?, ?)');
        $stmt->execute([$nome, $valor, $data_fabricacao, $data_validade, $estoque_minimo, $estoque_maximo, $imagem]);
        $response['success'] = 'Produto adicionado com sucesso!';
    } catch (PDOException $e) {
        $response['error'] = 'Erro ao adicionar o produto: ' . $e->getMessage();
    }
} else {
    $response['error'] = 'Método não permitido. Apenas POST é aceito.';
}

echo json_encode($response);
?>