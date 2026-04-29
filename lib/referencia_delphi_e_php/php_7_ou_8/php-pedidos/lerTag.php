<?php
    header('Content-Type: application/json; charset=utf-8');
    include '_config.php';
    include '_funcoes.php';

    $mysqli = new mysqli($servidor, $usuario, $senha, $banco, $porta);
    
    if (mysqli_connect_errno()) { 
        trigger_error(mysqli_connect_error());
    } else { 
        $data = json_decode(file_get_contents('php://input'));
        
        criarTabelaVendasTag($mysqli, $origem);

        $qr  = 'select coalesce(b.tag,0) tag';
        $qr .= ' from vendas a';
        $qr .= ' left join vendas_tag b';
        $qr .= ' on a.codigo=b.codigo and a.origem=b.origem';
        $qr .= ' where a.origem=' . $origem;
        $qr .= ' and a.cartao=' . $data->codigo_comanda;
        $qr .= ' and a.status=0';
        $qr .= ' and a.quantidade>0';
        $qr .= ' and isnull(a.data_exc)';
        $qr .= ' order by a.item desc';
        $qr .= ' limit 1';
        $mysql = $mysqli->query($qr);

        if ($mysql->num_rows == 0) {
            $tag = '-1';
        } else {
            $row = mysqli_fetch_assoc($mysql);                                    
            $tag = $row['tag'];  
        }

        $retorno = array();
        $retorno['tag'] = $tag;
        
        echo json_encode($retorno);        
    }
?>  