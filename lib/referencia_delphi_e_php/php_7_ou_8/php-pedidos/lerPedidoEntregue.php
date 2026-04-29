<?php
    header('Content-Type: application/json; charset=utf-8');
    include '_config.php';
    include '_funcoes.php';

    $mysqli = new mysqli($servidor, $usuario, $senha, $banco, $porta);
    
    validarConexao($mysqli);

    $data = lerJsonEntrada();

    $qr  = 'delete from automacao_cozinha';
    $qr .= ' where origem=' . $origem;
    $qr .= ' and idt=' . $data->codigo_comanda;
    gravarLog($mysqli, $qr, $origem, $data->nome_funcionario);
    $mysql = $mysqli->query($qr);

    if (!$mysql) {
        responderErro('Erro executando query em lerPedidoEntregue.php: ' . $mysqli->error);
    }

    if (!$mysql) {
        responderErro('Erro removendo pedido entregue: ' . $mysqli->error);
    }

    responderSucesso('Pedido removido', array('linhas_afetadas' => $mysqli->affected_rows));
?>             