<?php
    header('Content-Type: application/json; charset=utf-8');
    include '_config.php';
    include '_funcoes.php';

    $mysqli = new mysqli($servidor, $usuario, $senha, $banco, $porta);
    
    if (mysqli_connect_errno()) { 
        trigger_error(mysqli_connect_error());
    } else { 
        $data = json_decode(file_get_contents('php://input'));

        $qr  = 'select idt codigo_comanda';
        $qr .= ' from automacao_cozinha';
        $qr .= ' where origem=' . $origem;
  
        if ($data->tipo_pedido == 'pedidoPronto'){
            $qr .= ' and tipo="P"';
        } else if ($data->tipo_pedido == 'pedidoEntregue'){
            $qr .= ' and tipo="R"';
        }
        
        $qr .= ' order by idt';        
        $mysql = $mysqli->query($qr); 

        $retorno = array();
        $conta = 0;

        while ($row = mysqli_fetch_assoc($mysql)) {
            $retorno[$conta] = (object)null;            
            $retorno[$conta]->codigo_comanda = $row['codigo_comanda'];

            $conta++;
        }

        echo json_encode($retorno);         
    }
?>           