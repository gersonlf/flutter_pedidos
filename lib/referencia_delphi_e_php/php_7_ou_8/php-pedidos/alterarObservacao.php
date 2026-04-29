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

        $qr  = 'select a.codigo codigo_venda,';
        $qr .= ' a.cartao codigo_comanda,';
        $qr .= ' if(isnull(a.mesa),a.cartao,a.mesa) codigo_mesa,';
        $qr .= ' coalesce(max(e.tag),0) codigoTag,';        
        $qr .= ' a.item item_venda,';
        $qr .= ' a.produto codigo_produto,';
        $qr .= ' a.descricao descricao_produto,';
        $qr .= ' f.nome nome_funcionario,';
        $qr .= ' sum(a.quantidade) qtde_produto,';
        $qr .= ' ob.observacoes observacao_item,';
        $qr .= ' concat(date_format(a.data,"%d/%m/%Y")," ",a.hora) data_hora';
        $qr .= ' from vendas a';
        $qr .= ' inner join cad_produto p';
        $qr .= ' left join cad_funcionario f';
        $qr .= ' on a.garcom = f.idt';
        $qr .= ' inner join vendas_cozinha c';
        $qr .= ' on a.codigo = c.codigo';
        $qr .= ' and a.item = c.item';
        $qr .= ' and a.origem = c.origem';
        $qr .= ' left join vendas_obs ob';
        $qr .= ' on a.codigo = ob.codigo';
        $qr .= ' and a.item = ob.item';
        $qr .= ' and a.origem = ob.origem';
        $qr .= ' left join vendas_tag e';
        $qr .= ' on a.codigo=e.codigo and a.origem=e.origem';
        $qr .= ' where a.origem =' . $origem;
        $qr .= ' and a.status = 0';
        $qr .= ' and c.status = 9';
        $qr .= ' and a.produto=p.idt';
        $qr .= ' and p.controle_cozinha="S"';
        $qr .= ' and a.cartao=' . $data->codigo_comanda;
        $qr .= ' and a.item=' . $data->item_venda;
        $qr .= ' group by a.mesa,f.nome,a.item';
        $qr .= ' order by a.data desc,a.hora desc';
        $mysql = $mysqli->query($qr);        
  
        //error_log('alterarObservacao');
        //error_log($qr);

        if ($mysql->num_rows == 0) {  
            $qr  = 'select codigo';
            $qr .= ' from vendas';
            $qr .= ' where cartao=' . $data->codigo_comanda;
            $qr .= ' and origem=' . $origem;
            $qr .= ' and status=0';
            $qr .= ' limit 1';
            $mysql = $mysqli->query($qr); 

            //error_log($qr);

            if ($mysql->num_rows > 0) {  
                $row = mysqli_fetch_assoc($mysql);                          
                $codigoVenda = $row['codigo'];
  
                $qr  = 'select codigo';
                $qr .= ' from vendas_obs';
                $qr .= ' where codigo=' . $codigoVenda;
                $qr .= ' and item=' . $data->item_venda;
                $qr .= ' and origem=' . $origem;
                $qr .= ' limit 1';
                $mysql = $mysqli->query($qr); 

                //error_log($qr);

                $datahora = new datetime();
                $dia = date_format($datahora, 'Y-m-d');
                $hora = date_format($datahora, 'H:i:s');

                if ($mysql->num_rows == 0) {              
                    $qr  = 'insert into vendas_obs set';
                    $qr .= ' codigo=' . $codigoVenda;
                    $qr .= ' ,item=' . $data->item_venda;
                    $qr .= ' ,origem=' . $origem;
                    $qr .= ' ,observacoes="' . $data->observacao_item . '"';
                    $qr .= ' ,operador="' . $data->nome_funcionario .'"';
                    $qr .= ' ,data_inc="' . $dia . '"';
                    gravarLog($mysqli, $qr, $origem, $data->nome_funcionario);
                    $mysql = $mysqli->query($qr);            

                    //error_log($qr);                    
                } else {
                    $qr  = 'update vendas_obs set';
                    $qr .= ' observacoes="' . $data->observacao_item . '"';
                    $qr .= ' ,operador="' . $data->nome_funcionario . '"';
                    $qr .= ' ,data_alt="' . $dia . '"';
                    $qr .= ' where codigo=' . $codigoVenda;
                    $qr .= ' and item=' . $data->item_venda;
                    $qr .= ' and origem=' . $origem;
                    gravarLog($mysqli, $qr, $origem, $data->nome_funcionario);
                    $mysql = $mysqli->query($qr);

                    //error_log($qr);                    
                }            
            }

            $msg = '';
        } else {
            $msg = 'Comanda já foi impressa na cozinha, não é possível fazer a alteração na observação agora!';
        }
        
        $retorno = array();
        $retorno['msg'] = $msg;

        //$retorno = utf8_string_array_encode($retorno);                
        echo json_encode($retorno);            
    }
?>