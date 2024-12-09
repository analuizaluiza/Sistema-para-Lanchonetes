<?php
session_start();


if (!isset($_SESSION['usuario_id'])) {
    header("Location: ./../../Backend/Controllers/login.php");
    exit();
}


require './../../Backend/Conexao/conexao.php';


$usuario_id = $_SESSION['usuario_id'];


$query = "SELECT * FROM Usuario WHERE ID_Usuario = :usuario_id";
$stmt = $pdo->prepare($query);
$stmt->bindParam(':usuario_id', $usuario_id, PDO::PARAM_INT);
$stmt->execute();
$usuario = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$usuario) {
    die('Usuário não encontrado.');
}
?>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Perfil de Usuário - Lanchonete</title>
    <link href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="./../../Raiz/CSS/style.css" />
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:ital,wght@0,100..900;1,100..900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" />
</head>
<body>
<nav class="navbar navbar-expand-lg navbar-light bg-info">
        <span class="material-symbols-outlined text-white">fastfood</span>
        <p class="h2 font-weight-bold ml-2 mb-0 text-white">Lanchonete</p>
        <button class="navbar-toggler custom-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ml-auto">
                <li class="nav-item active">
                    <a class="nav-link" href="./../../Frontend/Views/index.html">
                        <span class="material-symbols-outlined">home</span> Início
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="./../../Frontend/Views/produtos.html">
                        <span class="material-symbols-outlined">lunch_dining</span> Produtos
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="./../../Frontend/Views/estoque.html">
                        <span class="material-symbols-outlined">inventory_2</span> Estoque
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="./../../Frontend/Views/vendas.html">
                        <span class="material-symbols-outlined">point_of_sale</span> Vendas
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="./../../Frontend/Views/compras.html">
                        <span class="material-symbols-outlined">shopping_cart</span> Compras
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="./../../Frontend/Views/relatorios.html">
                        <span class="material-symbols-outlined">lab_profile</span> Relatórios
                    </a>
                </li>
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                        <span class="material-symbols-outlined">account_circle</span> 
                    </a>
                    <div class="dropdown-menu dropdown-menu-right" aria-labelledby="navbarDropdown">
                        <a class="dropdown-item" href="./../../Backend/Controllers/perfil_usuario.php">
                            <span class="material-symbols-outlined">badge</span> Perfil
                        </a>
                        <div class="dropdown-divider"></div>
                        <a class="dropdown-item" href="./../../Backend/Controllers/logout.php">
                            <span class="material-symbols-outlined">logout</span> Sair
                        </a>
                    </div>
                </li>
            </ul>
        </div>
    </nav>

    <div class="container mt-5">
        <div class="jumbotron text-center">
            <h2 class="display-4">Bem-vindo, <?php echo htmlspecialchars($usuario['Nome']); ?>!</h2>
            <p class="lead">Detalhes do seu perfil:</p>
        </div>
        
        <div class="card mb-4">
            <div class="card-header">
                <h4>Informações do Usuário</h4>
            </div>
            <div class="card-body">
                <p><strong>Nome Completo:</strong> <?php echo htmlspecialchars($usuario['Nome'] . ' ' . $usuario['Sobrenome']); ?></p>
                <p><strong>Email:</strong> <?php echo htmlspecialchars($usuario['Email']); ?></p>
                <p><strong>Identificação:</strong> <?php echo htmlspecialchars($usuario['ID_Usuario']); ?></p>
            </div>
        </div>
    </div>

    <footer class="text-center text-white bg-info mt-auto py-3">
        <div class="container">
            © 2024 Lanchonete. Todos os direitos reservados.
        </div>
    </footer>
    
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.5.4/dist/umd/popper.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>
