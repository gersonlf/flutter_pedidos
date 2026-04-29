<?php
    header('Content-Type: application/json; charset=utf-8');
    include '_config.php';
    include '_funcoes.php';

    $mysqli = new mysqli($servidor, $usuario, $senha, $banco, $porta);
    validarConexao($mysqli);
 
        $data = lerJsonEntrada();

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

        if (!$mysql) {
            responderErro('Erro executando query em lerPedidos.php: ' . $mysqli->error);
        }

        $retorno = array();
        $conta = 0;

        while ($row = mysqli_fetch_assoc($mysql)) {
            $retorno[$conta] = (object)null;            
            $retorno[$conta]->codigo_comanda = $row['codigo_comanda'];

            $conta++;
        }

        responderJson($retorno);         
?>        