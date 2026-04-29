<?php
    header('Content-Type: application/json; charset=utf-8');
    include '_config.php';
    include '_funcoes.php';

    $mysqli = new mysqli($servidor, $usuario, $senha, $banco, $porta);
    validarConexao($mysqli);
 
        $data = lerJsonEntrada();

        $qr  = 'select coalesce(mesa,0) mesa';
        $qr .= ' from vendas';
        $qr .= ' where origem=' . $origem;
        $qr .= ' and cartao=' . $data->codigo_comanda;
        $qr .= ' and status=0';
        $qr .= ' and quantidade>0';
        $qr .= ' and isnull(data_exc)';
        $qr .= ' order by item desc';
        $qr .= ' limit 1';
        $mysql = $mysqli->query($qr);

        if (!$mysql) {
            responderErro('Erro executando query em lerMesa.php: ' . $mysqli->error);
        }

        if ($mysql->num_rows == 0) {
            $mesa = '-1';
        } else {
            $row = mysqli_fetch_assoc($mysql);                                    
            $mesa = $row['mesa'];  
        }

        $retorno = array();
        $retorno['mesa'] = $mesa;
        
        responderJson($retorno);        
?>        