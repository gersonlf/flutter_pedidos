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
        $qr .= ' a.origem codigoEmpresa,';
        $qr .= ' a.codigo codigoVenda,';
        $qr .= ' a.cartao codigoComanda,';
        $qr .= ' coalesce(max(a.mesa),0) codigoMesa,';
        $qr .= ' coalesce(max(e.tag),0) codigoTag,';        
        $qr .= ' concat(date_format(max(a.data),"%d/%m/%Y")," ",date_format(max(a.hora),"%H:%i:%s")) dataHora,';
        $qr .= ' a.garcom codigoFuncionario,';
        $qr .= ' left(c.nome,40) nomeFuncionario,';
        $qr .= ' a.item itemVenda,';
        $qr .= ' a.produto codigoProduto,';
        $qr .= ' lpad(if(isnull(a.barra),"",a.barra),13,0) codigoBarra,';
        $qr .= ' coalesce(b.codigo_reduzido,0) codigoReduzido,';
        $qr .= ' left(a.descricao,40) descricaoProduto,';
        $qr .= ' a.quantidade qtdeProduto,';
        $qr .= ' a.valor_unitario valorUnitario,';
        $qr .= ' coalesce(a.desconto,0) valorDesconto,';
        $qr .= ' a.valor_total valorTotal,';
        $qr .= ' d.observacoes observacaoItem';
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
        $qr .= ' and a.cartao=' . $data->codigo_comanda;

        if ($data->item_venda > 0){
            $qr .= ' and a.item=' . $data->item_venda;
        }
        
        $qr .= ' and isnull(a.data_exc)';
        $qr .= ' group by a.cartao,a.item';
        $qr .= ' order by a.data desc, a.hora desc';
        $mysql = $mysqli->query($qr);

        //error_log('alterarComanda');
        //error_log($qr);        
        
        while ($row = mysqli_fetch_assoc($mysql)) {
            incluirItem($mysqli, $origem, $data, $row);
        }
        
        excluirComanda($mysqli, $origem, $data);
    }
?>             