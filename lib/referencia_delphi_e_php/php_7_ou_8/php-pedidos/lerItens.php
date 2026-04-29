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
        $qr .= ' a.garcom codigo_funcionario,';
        $qr .= ' left(c.nome,40) nome_funcionario,';
        $qr .= ' a.item item_venda,';
        $qr .= ' a.produto codigo_produto,';
        $qr .= ' lpad(if(isnull(a.barra),"",a.barra),13,0) codigo_barra,';    
        $qr .= ' coalesce(if (b.codigo_reduzido REGEXP "^[0-9]+\\.?[0-9]*$", b.codigo_reduzido,0) ,0) codigo_reduzido,'; 
        $qr .= ' left(a.descricao,40) descricao_produto,';
        $qr .= ' a.quantidade qtde_produto,';
        $qr .= ' a.valor_unitario valor_unitario,';
        $qr .= ' coalesce(a.desconto,0) valor_desconto,';
        $qr .= ' a.valor_total valor_total,';
        $qr .= ' if(isnull(d.observacoes),"",d.observacoes) observacao_item';
        $qr .= ' from vendas a';
        $qr .= ' inner join cad_produto b';
        $qr .= ' on a.produto=b.idt';
        $qr .= ' inner join cad_funcionario c';
        $qr .= ' on a.garcom=c.idt';
        $qr .= ' left join vendas_obs d';
        $qr .= ' on a.codigo=d.codigo';
        $qr .= ' and a.item=d.item';
        $qr .= ' and a.origem=d.origem';
        $qr .= ' left join vendas_tag e';
        $qr .= ' on a.codigo=e.codigo and a.origem=e.origem';
        $qr .= ' where a.origem=' . $origem;
        $qr .= ' and a.status=0';
        $qr .= ' and a.quantidade>0';
        $qr .= ' and a.cartao=' . $data->codigo_comanda;
        $qr .= ' and isnull(a.data_exc)';
        $qr .= ' order by a.data desc, a.hora desc';        
        $mysql = $mysqli->query($qr);

        //error_log('lerItens');        
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
            $retorno[$conta]->codigo_funcionario = $row['codigo_funcionario'];
            $retorno[$conta]->nome_funcionario = utf8_encode($row['nome_funcionario']);
            $retorno[$conta]->item_venda = $row['item_venda'];
            $retorno[$conta]->codigo_produto = $row['codigo_produto'];
            $retorno[$conta]->codigo_barra = utf8_encode($row['codigo_barra']);
            $retorno[$conta]->codigo_reduzido = $row['codigo_reduzido'];
            $retorno[$conta]->descricao_produto = utf8_encode($row['descricao_produto']);
            $retorno[$conta]->qtde_produto = $row['qtde_produto'];
            $retorno[$conta]->valor_unitario = $row['valor_unitario'];
            $retorno[$conta]->valor_desconto = $row['valor_desconto'];
            $retorno[$conta]->valor_total = $row['valor_total'];
            $retorno[$conta]->observacao_item = utf8_encode($row['observacao_item']);

            $conta++;
        }

        //$retorno = utf8_string_array_encode($retorno);        
        echo json_encode($retorno);         
    }
?>        