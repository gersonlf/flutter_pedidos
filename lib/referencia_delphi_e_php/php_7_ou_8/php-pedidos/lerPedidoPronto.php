<?php
    header('Content-Type: application/json; charset=utf-8');
    include '_config.php';
    include '_funcoes.php';

    $mysqli = new mysqli($servidor, $usuario, $senha, $banco, $porta);
    
    validarConexao($mysqli);

    $data = lerJsonEntrada();

    $qr  = 'update automacao_cozinha set';
    $qr .= ' tipo="R"';
    $qr .= ' where origem=' . $origem;
    $qr .= ' and tipo="N"';
    gravarLog($mysqli, $qr, $origem, $data->nome_funcionario);
    $mysql = $mysqli->query($qr);

    if (!$mysql) {
        responderErro('Erro executando query em lerPedidoPronto.php: ' . $mysqli->error);
    }

    if (!$mysql) {
        responderErro('Erro atualizando pedidos prontos: ' . $mysqli->error);
    }

    $qr  = 'select idt';
    $qr .= ' from automacao_cozinha';
    $qr .= ' where origem=' . $origem;
    $qr .= ' and idt=' . $data->codigo_comanda;
    $mysql = $mysqli->query($qr);

    if (!$mysql) {
        responderErro('Erro executando query em lerPedidoPronto.php: ' . $mysqli->error);
    }

    if (!$mysql) {
        responderErro('Erro consultando pedido pronto: ' . $mysqli->error);
    }
  
    if ($mysql->num_rows == 0) {
        $qr  = 'insert ignore into automacao_cozinha set';
        $qr .= ' tipo="N"';
        $qr .= ' ,origem=' . $origem;
        $qr .= ' ,idt=' . $data->codigo_comanda;
        gravarLog($mysqli, $qr, $origem, $data->nome_funcionario);
        $mysql = $mysqli->query($qr);

        if (!$mysql) {
            responderErro('Erro executando query em lerPedidoPronto.php: ' . $mysqli->error);
        }
    } else {
        $qr  = 'update automacao_cozinha set';
        $qr .= ' tipo="N"';
        $qr .= ' where origem=' . $origem;
        $qr .= ' and idt=' . $data->codigo_comanda;
        gravarLog($mysqli, $qr, $origem, $data->nome_funcionario);
        $mysql = $mysqli->query($qr);            

        if (!$mysql) {
            responderErro('Erro executando query em lerPedidoPronto.php: ' . $mysqli->error);
        }
    }

    if (!$mysql) {
        responderErro('Erro chamando pedido pronto: ' . $mysqli->error);
    }

    responderSucesso('Pedido chamado');
?>           