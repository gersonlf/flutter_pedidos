<?php
    header('Content-Type: application/json; charset=utf-8');
    include '_config.php';
    include '_funcoes.php';
    
    $mysqli = new mysqli($servidor, $usuario, $senha, $banco, $porta);
    validarConexao($mysqli);
 
        $data = lerJsonEntrada();

        $qr  = 'select';
        $qr .= ' codigo codigoVenda,';
        $qr .= ' item + 1 itemVenda';
        $qr .= ' from vendas';
        $qr .= ' where cartao=' . $data->codigo_comanda;
        $qr .= ' and status=0';
        $qr .= ' and quantidade>0';
        $qr .= ' and origem=' . $origem;
        $qr .= ' order by item desc';
        $qr .= ' limit 1';
        $mysql = $mysqli->query($qr);   

        if (!$mysql) {
            responderErro('Erro executando query em incluirItem.php: ' . $mysqli->error);
        }

        if ($mysql->num_rows == 0) {
            $codigoVenda = pegaSequencia($mysqli, 'seq_vendas', $origem);
            $itemVenda = 1;            
        } else {
            $row = mysqli_fetch_assoc($mysql);  
            $codigoVenda = $row['codigoVenda'];
            $itemVenda = $row['itemVenda'];
        }

        $datahora = new datetime();
        $dia = date_format($datahora, 'Y-m-d');
        $hora = date_format($datahora, 'H:i:s');

        $qr  = 'insert into vendas set';
        $qr .= ' codigo=' . $codigoVenda;
        $qr .= ' ,mesa=' . $data->codigo_mesa;
        $qr .= ' ,data="' . $dia . '"';
        $qr .= ' ,hora="' . $hora . '"';
        $qr .= ' ,cartao=' . $data->codigo_comanda;
        $qr .= ' ,garcom=' . $data->codigo_funcionario;
        $qr .= ' ,item=' . $itemVenda;
        $qr .= ' ,produto=' . $data->codigo_produto;
        $qr .= ' ,barra="' . $data->codigo_barra .'"';
        $qr .= ' ,descricao="' . $data->descricao_produto .'"';
        $qr .= ' ,quantidade=' . $data->qtde_produto;
        $qr .= ' ,valor_unitario=' . $data->valor_unitario;
        $qr .= ' ,valor_total=' . $data->valor_total;
        $qr .= ' ,status=0';
        $qr .= ' ,origem=' . $origem;
        gravarLog($mysqli, $qr, $origem, $data->nome_funcionario);
        $mysql = $mysqli->query($qr);

        if (!$mysql) {
            responderErro('Erro executando query em incluirItem.php: ' . $mysqli->error);
        }
  
        if ($data->observacao_item !== ''){
            $qr  = 'select codigo';
            $qr .= ' from vendas_obs';
            $qr .= ' where codigo=' . $codigoVenda;
            $qr .= ' and item=' . $itemVenda;
            $qr .= ' and origem=' .$origem;
            $qr .= ' limit 1';
            $mysql = $mysqli->query($qr);

            if (!$mysql) {
                responderErro('Erro executando query em incluirItem.php: ' . $mysqli->error);
            }

            if ($mysql->num_rows == 0) {  
                if ($data->observacao_item !== '') {
                    $qr  = 'insert into vendas_obs set';
                    $qr .= ' codigo=' . $codigoVenda;
                    $qr .= ' ,item=' . $itemVenda;
                    $qr .= ' ,origem=' . $origem;
                    $qr .= ' ,observacoes="' . $data->observacao_item . '"';
                    $qr .= ' ,operador="' . $data->nome_funcionario . '"';
                    $qr .= ' ,data_inc="' . $dia . '"';
                    gravarLog($mysqli, $qr, $origem, $data->nome_funcionario);
                    $mysql = $mysqli->query($qr);                            

                    if (!$mysql) {
                        responderErro('Erro executando query em incluirItem.php: ' . $mysqli->error);
                    }
                }        
            } else {
                $qr  = 'update vendas_obs set';
                $qr .= ' observacoes="' . $data->observacao_item . '"';
                $qr .= ' ,operador="' . $data->nome_funcionario . '"';
                $qr .= ' ,data_alt="' . $dia . '"';
                $qr .= ' where codigo=' . $codigoVenda;
                $qr .= ' and item=' . $itemVenda;
                $qr .= ' and origem=' . $origem;
                gravarLog($mysqli, $qr, $origem, $data->nome_funcionario);
                $mysql = $mysqli->query($qr);                        

                if (!$mysql) {
                    responderErro('Erro executando query em incluirItem.php: ' . $mysqli->error);
                }
            }    
        }

        try {
            $codigoTag = $data->codigo_tag;
            if ($codigoTag !== '') {
                criarTabelaVendasTag($mysqli, $origem);
                                
                //$qr = 'insert ignore into vendas_tag set';
                $qr = 'replace into vendas_tag set';                
                $qr .= ' codigo=' . $codigoVenda;
                $qr .= ' ,origem=' . $origem;
                $qr .= ' ,tag=' . $codigoTag;
                gravarLog($mysqli, $qr, $origem, $data->nome_funcionario);
                $mysql = $mysqli->query($qr);    

                if (!$mysql) {
                    responderErro('Erro executando query em incluirItem.php: ' . $mysqli->error);
                }
            }    
        }                    
        catch(Exception $e) {}

        $qr  = 'select';
        $qr .= ' codigo codigoVenda,';
        $qr .= ' item itemVenda';
        $qr .= ' from vendas';
        $qr .= ' where codigo=' . $codigoVenda;
        $qr .= ' and item=' . $itemVenda;
        $qr .= ' and origem=' . $origem;
        $mysql = $mysqli->query($qr);

        if (!$mysql) {
            responderErro('Erro executando query em incluirItem.php: ' . $mysqli->error);
        }
        
        $retorno = array();

        while ($row = mysqli_fetch_assoc($mysql)) {
            $retorno[] = $row;
        }

        //$retorno = utf8_string_array_encode($retorno);        
        responderJson($retorno);         
?>        