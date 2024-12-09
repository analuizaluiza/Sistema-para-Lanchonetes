<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Lanchonete</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="./../../Raiz/CSS/style2.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@100..900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css" />
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>

</head>
<body>
    <div class="container mt-5">
        <div class="screen">
            <h1 class="card-header text-center bg-info text-white">Login</h1>
            <div class="screen__content">
                <form class="login" id="loginForm" method="post" action="./../../Backend/Controllers/autenticar.php">
                    <div class="form-group">
                        <label for="email" class="sr-only">Email:</label>
                        <div class="input-group">
                            <div class="input-group-prepend">
                                <span class="input-group-text">
                                    <span class="material-symbols-outlined">person</span>
                                </span>
                            </div>
                            <input type="text" class="form-control" id="email" name="email" placeholder="Email" required>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="password" class="sr-only">Senha:</label>
                        <div class="input-group">
                            <div class="input-group-prepend">
                                <span class="input-group-text">
                                    <span class="material-symbols-outlined">lock</span>
                                </span>
                            </div>
                            <input type="password" class="form-control" id="password" name="senha" placeholder="Senha" required>
                        </div>
                    </div>
                    <button class="btn btn-info btn-block d-flex justify-content-center align-items-center" type="submit">
                        <span class="button__text">Entrar</span>
                        <span class="material-symbols-outlined ml-2">chevron_right</span>
                    </button>
                    <div id="error-message" class="error-message mt-3" style="display: none;"></div>
                </form>
                <div class="text-center mt-3">
                    <a href="./../../Frontend/Views/redefinir_senha.html" class="btn btn-link" style="color: #17a2b8;">Redefinir Senha</a>
                    <span class="text-muted mx-2">|</span>
                    <a href="./../../Frontend/Views/cadastrar.html" class="btn btn-link" style="color: #17a2b8;">Cadastre-se Aqui</a>
                </div>
            </div>
        </div>
    </div>

    <div class="screen__background">
        <span class="screen__background__shape screen__background__shape1"></span>
        <span class="screen__background__shape screen__background__shape2"></span>
        <span class="screen__background__shape screen__background__shape3"></span>
        <span class="screen__background__shape screen__background__shape4"></span>
        <span class="screen__background__shape screen__background__shape5"></span>
        <span class="screen__background__shape screen__background__shape6"></span>
        <span class="screen__background__shape screen__background__shape7"></span>
        <span class="screen__background__shape screen__background__shape8"></span>
    </div>

   
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('loginForm').addEventListener('submit', function(event) {
                event.preventDefault();

                const email = document.getElementById('email').value;
                const password = document.getElementById('password').value;

                fetch('autenticar.php', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: `email=${encodeURIComponent(email)}&senha=${encodeURIComponent(password)}`
                })
                .then(response => response.json())
                .then(data => {
                    if (data.status === 'success') {
                        window.location.href = './../../Backend/Controllers/perfil_usuario.php'; 
                    } else {
                        showError(data.message);
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    showError('Erro ao processar a solicitação.');
                });

                function showError(message) {
                    const errorMessage = document.getElementById('error-message');
                    errorMessage.textContent = message;
                    errorMessage.style.display = 'block';
                    setTimeout(() => {
                        errorMessage.style.display = 'none';
                    }, 3000);
                }
            });
        });
    </script>
</body>
</html>
