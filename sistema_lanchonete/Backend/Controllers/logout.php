<?php
session_start();


session_unset();
session_destroy();

header("Location: ./../../Backend/Controllers/login.php");
exit();
?>
