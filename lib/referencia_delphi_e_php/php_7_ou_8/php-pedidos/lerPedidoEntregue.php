<?php
    header('Content-Type: application/json; charset=utf-8');
    include '_config.php';
    include '_funcoes.php';

    $mysqli = new mysqli($servidor, $usuario, $senha, $banco, $porta);
    
    if (mysqli_connect_errno()) { 
        trigger_error(mysqli_connect_error());
    } else { 
        $data = json_decode(file_get_contents('php://input'));

        $qr  = 'delete from automacao_cozinha';
        $qr .= ' where origem=' . $origem;
        $qr .= ' and idt=' . $data->codigo_comanda;
        gravarLog($mysqli, $qr, $origem, $data->nome_funcionario);
        $mysql = $mysqli->query($qr);          
    }
?>             