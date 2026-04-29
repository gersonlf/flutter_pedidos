<?php
    header('Content-Type: application/json; charset=utf-8');
    include '_config.php';
    include '_funcoes.php';

    $mysqli = new mysqli($servidor, $usuario, $senha, $banco, $porta);
    
    if (mysqli_connect_errno()) { 
        trigger_error(mysqli_connect_error());
    } else { 
        $data = json_decode(file_get_contents('php://input'));

        $qr  = 'update automacao_cozinha set';
        $qr .= ' tipo="R"';
        $qr .= ' where origem=' . $origem;
        $qr .= ' and tipo="N"';
        gravarLog($mysqli, $qr, $origem, $data->nome_funcionario);
        $mysql = $mysqli->query($qr);  

        $qr  = 'select idt';
        $qr .= ' from automacao_cozinha';
        $qr .= ' where origem=' . $origem;
        $qr .= ' and idt=' . $data->codigo_comanda;
        $mysql = $mysqli->query($qr);          
  
        if ($mysql->num_rows == 0) {
            $qr  = 'insert ignore into automacao_cozinha set';
            $qr .= ' tipo="N"';
            $qr .= ' ,origem=' . $origem;
            $qr .= ' ,idt=' . $data->codigo_comanda;
            gravarLog($mysqli, $qr, $origem, $data->nome_funcionario);
            $mysql = $mysqli->query($qr);
        } else {
            $qr  = 'update automacao_cozinha set';
            $qr .= ' tipo="N"';
            $qr .= ' where origem=' . $origem;
            $qr .= ' and idt=' . $data->codigo_comanda;
            gravarLog($mysqli, $qr, $origem, $data->nome_funcionario);
            $mysql = $mysqli->query($qr);            
        }
    }
?>           