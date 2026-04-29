<?php
    header('Content-Type: application/json; charset=utf-8');
    include '_config.php';
    include '_funcoes.php';

    $mysqli = new mysqli($servidor, $usuario, $senha, $banco, $porta);
    
    validarConexao($mysqli);

    $data = lerJsonEntrada();

    $qr  = 'update vendas set';
    $qr .= ' mesa=' . $data->codigo_nova_mesa;
    $qr .= ' where cartao=' . $data->codigo_comanda;
    $qr .= ' and origem=' . $origem;
    $qr .= ' and status=0';                
    gravarLog($mysqli, $qr, $origem, $data->nome_funcionario);
    $mysql = $mysqli->query($qr);

    if (!$mysql) {
        responderErro('Erro executando query em alterarMesa.php: ' . $mysqli->error);
    }

    if (!$mysql) {
        responderErro('Erro alterando mesa: ' . $mysqli->error);
    }

    responderSucesso('Mesa alterada', array('linhas_afetadas' => $mysqli->affected_rows));
?>        