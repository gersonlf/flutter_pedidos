<?php
    header('Content-Type: application/json; charset=utf-8');
    include '_config.php';
    include '_funcoes.php';

    $mysqli = new mysqli($servidor, $usuario, $senha, $banco, $porta);
    
    if (mysqli_connect_errno()) { 
        trigger_error(mysqli_connect_error());
    } else { 
        $data = json_decode(file_get_contents('php://input'));

        $qr  = 'update vendas set';
        $qr .= ' mesa=' . $data->codigo_nova_mesa;
        $qr .= ' where cartao=' . $data->codigo_comanda;
        $qr .= ' and origem=' . $origem;
        $qr .= ' and status=0';                
        gravarLog($mysqli, $qr, $origem, $data->nome_funcionario);
        $mysql = $mysqli->query($qr);

        //error_log('alterarMesa');
        //error_log($qr);
    }
?>        