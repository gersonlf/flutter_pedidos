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

        $qr  = 'select a.codigo,';
        $qr .= ' a.cartao,';
        $qr .= ' if(isnull(a.mesa),a.cartao,a.mesa) mesa,';
        $qr .= ' coalesce(max(e.tag),0) codigoTag,';        
        $qr .= ' a.item,';
        $qr .= ' a.produto codigo_produto,';
        $qr .= ' f.nome nome_funcionario,';
        $qr .= ' a.descricao nome_produto,';
        $qr .= ' sum(a.quantidade) quantidade,';
        $qr .= ' ob.observacoes,';
        $qr .= ' concat(date_format(a.data,"%d/%m/%Y")," ",a.hora) data,';
        $qr .= ' a.origem';
        $qr .= ' from vendas a';
        $qr .= ' inner join cad_produto p';
        $qr .= ' left join cad_funcionario f';
        $qr .= ' on a.garcom = f.idt';
        $qr .= ' left join vendas_cozinha c';
        $qr .= ' on a.codigo = c.codigo';
        $qr .= ' and a.item = c.item';
        $qr .= ' and a.origem = c.origem';
        $qr .= ' left join vendas_obs ob';
        $qr .= ' on a.codigo = ob.codigo';
        $qr .= ' and a.item = ob.item';
        $qr .= ' and a.origem = ob.origem';
        $qr .= ' left join vendas_tag e';
        $qr .= ' on a.codigo=e.codigo and a.origem=e.origem';
        $qr .= ' where a.origem = ' . $origem;
        $qr .= ' and a.status = 0';
        $qr .= ' and (c.status <> 9 or isnull(c.status))';
        $qr .= ' and a.produto=p.idt';
        $qr .= ' and p.controle_cozinha="S"';
        $qr .= ' and a.cartao = '  . $data->codigo_comanda;
        $qr .= ' group by mesa,nome_funcionario,a.item';
        $qr .= ' order by a.data desc,a.hora desc';        
        $mysql = $mysqli->query($qr);

        $datahora = new datetime();
        $dia = date_format($datahora, 'Y-m-d');
        $diahora = date_format($datahora, 'Y-m-d H:i:s');

        while ($row = mysqli_fetch_assoc($mysql)) {
            $qr  = 'select codigo';
            $qr .= ' from vendas_cozinha';
            $qr .= ' where codigo=' . $row['codigo'];
            $qr .= ' and produto=' . $row['codigo_produto'];
            $qr .= ' and item=' . $row['item'];
            $qr .= ' and origem=' . $origem;
            $mysql2 = $mysqli->query($qr);

            if ($mysql2->num_rows == 0) {
                $qr  = 'insert ignore into vendas_cozinha set';
                $qr .= ' codigo=' . $row['codigo'];
                $qr .= ' ,item=' . $row['item'];
                $qr .= ' ,produto=' . $row['codigo_produto'];
                $qr .= ' ,status=0';
                $qr .= ' ,origem=' . $origem;
                $qr .= ' ,operador="' . $data->nome_funcionario . '"';
                $qr .= ' ,data_inc="' . $dia . '"';
                $qr .= ' ,atendido="' . $diahora . '"';
                gravarLog($mysqli, $qr, $origem, $data->nome_funcionario);                    
                $mysql3 = $mysqli->query($qr);
            }
        }            
    }
?>        