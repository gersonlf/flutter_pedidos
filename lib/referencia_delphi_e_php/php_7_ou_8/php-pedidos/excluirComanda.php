<?php
    header('Content-Type: application/json; charset=utf-8');
    include '_config.php';
    include '_funcoes.php';

    $mysqli = new mysqli($servidor, $usuario, $senha, $banco, $porta);
    
    validarConexao($mysqli);

    $data = lerJsonEntrada();

    excluirComanda($mysqli, $origem, $data);

    responderSucesso('Comanda excluida');
?>        