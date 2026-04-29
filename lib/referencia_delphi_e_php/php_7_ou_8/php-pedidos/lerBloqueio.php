<?php
    header('Content-Type: application/json; charset=utf-8');
    include '_config.php';
    include '_funcoes.php';
    
    $mysqli = new mysqli($servidor, $usuario, $senha, $banco, $porta);
    validarConexao($mysqli);
 
        $data = lerJsonEntrada();

        $qr  = 'select if(d.bloqueia_vendas_em_horas="S",date_add(concat(min(a.data)," ",min(a.hora)),interval 28800 second)<now(),0) bloqueio';
        $qr .= ' from vendas a';
        $qr .= ' inner join cadcontas d on a.origem=d.codigo';
        $qr .= ' where a.origem=' . $origem;
        $qr .= ' and a.cartao=' . $data->codigo_comanda;
        $qr .= ' and a.status=0';
        $qr .= ' and a.quantidade>0';
        $qr .= ' and isnull(a.data_exc)';
        $qr .= ' group by a.cartao, concat(a.data," ",a.hora)';
        $qr .= ' order by concat(a.data," ",a.hora)';
        $qr .= ' limit 1';
        $mysql = $mysqli->query($qr);        

        if (!$mysql) {
            responderErro('Erro executando query em lerBloqueio.php: ' . $mysqli->error);
        }
  
        if ($mysql->num_rows == 0) {
            $qr  = 'select comanda';
            $qr .= ' from bloqueio_comanda';
            $qr .= ' where origem=' . $origem;
            $qr .= ' and comanda=' . $data->codigo_comanda;
            $qr .= ' and isnull(data_exc)';
            $qr .= ' limit 1';
            $mysql = $mysqli->query($qr);                  

            if (!$mysql) {
                responderErro('Erro executando query em lerBloqueio.php: ' . $mysqli->error);
            }

            if ($mysql->num_rows > 0) {
                $bloqueio = '9999999';
            } else {
                $bloqueio = '0';
            }
        } else {
            $row = mysqli_fetch_assoc($mysql);            
            $bloqueio = $row['bloqueio'];
        }

        $retorno = array();
        $retorno['bloqueio'] = $bloqueio;

        //$retorno = utf8_string_array_encode($retorno);        
        responderJson($retorno);         
?>        