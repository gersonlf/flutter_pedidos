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

        $qr  = 'select';
        $qr .= ' a.origem codigo_empresa,';
        $qr .= ' a.codigo codigo_venda,';
        $qr .= ' a.cartao codigo_comanda,';
        $qr .= ' coalesce(a.mesa,0) codigo_mesa,';
        $qr .= ' coalesce(e.tag,0) codigo_tag,';
        $qr .= ' concat(date_format(a.data,"%d/%m/%Y")," ",date_format(a.hora,"%H:%i:%s")) data_hora,';
        $qr .= ' if(d.bloqueia_vendas_em_horas="S",date_add(concat(min(data)," ",min(hora)),interval 28800 second)<now(),0) bloqueio,';
        $qr .= ' left(c.nome,40) nome_funcionario,';
        $qr .= ' sum(valor_total) valor_total';  
        $qr .= ' from vendas a';
        $qr .= ' inner join cad_produto b';
        $qr .= ' inner join cad_funcionario c';
        $qr .= ' inner join cadcontas d on a.origem=d.codigo';
        $qr .= ' left join vendas_tag e on a.codigo=e.codigo and a.origem=e.origem';  
        $qr .= ' where a.produto=b.idt';
        $qr .= ' and a.garcom=c.idt';
        $qr .= ' and a.origem=' . $origem;
  
        if ($data->codigo_comanda !== '') {
            $qr .= ' and a.cartao=' . $data->codigo_comanda;
        }
  
        $qr .= ' and a.status=0';  
        $qr .= ' and a.quantidade>0';  
        $qr .= ' and isnull(a.data_exc)';
        $qr .= ' group by a.cartao';
        $qr .= ' order by a.cartao';
        $mysql = $mysqli->query($qr);

        //error_log('lerComanda');        
        //error_log($qr);

        $retorno = array();
        $conta = 0;

        while ($row = mysqli_fetch_assoc($mysql)) {
            //$retorno[] = $row;
            
            $retorno[$conta] = (object)null;
            $retorno[$conta]->codigo_empresa = $row['codigo_empresa'];
            $retorno[$conta]->codigo_venda = $row['codigo_venda'];
            $retorno[$conta]->codigo_comanda = $row['codigo_comanda'];
            $retorno[$conta]->codigo_mesa = $row['codigo_mesa'];
            $retorno[$conta]->codigo_tag = $row['codigo_tag'];            
            $retorno[$conta]->data_hora = $row['data_hora'];
            $retorno[$conta]->bloqueio = $row['bloqueio'];
            $retorno[$conta]->nome_funcionario = utf8_encode($row['nome_funcionario']);
            $retorno[$conta]->valor_total = $row['valor_total'];

            $conta++;            
        }

        //$retorno = utf8_string_array_encode($retorno);            
        echo json_encode($retorno); 
    }
?>

