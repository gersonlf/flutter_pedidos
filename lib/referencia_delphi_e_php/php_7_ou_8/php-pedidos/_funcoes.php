<?php
    function responderJson($payload, $statusCode = 200){
        if (!headers_sent()) {
            http_response_code($statusCode);
            header('Content-Type: application/json; charset=utf-8');
        }

        echo json_encode($payload, JSON_UNESCAPED_UNICODE);
        exit;
    }

    function responderSucesso($mensagem = 'OK', $dados = array()){
        $payload = array_merge(
            array(
                'sucesso' => true,
                'mensagem' => $mensagem
            ),
            $dados
        );

        responderJson($payload);
    }

    function responderErro($mensagem, $statusCode = 500){
        error_log($mensagem);
        responderJson(
            array(
                'sucesso' => false,
                'mensagem' => $mensagem
            ),
            $statusCode
        );
    }

    function validarConexao($mysqli){
        if (mysqli_connect_errno()) {
            responderErro('Erro conectando ao banco: ' . mysqli_connect_error());
        }
    }

    function lerJsonEntrada(){
        $raw = file_get_contents('php://input');

        if (trim($raw) === '') {
            return (object) array();
        }

        $data = json_decode($raw);

        if (json_last_error() !== JSON_ERROR_NONE) {
            responderErro('JSON invalido: ' . json_last_error_msg(), 400);
        }

        return $data;
    }

    function textoUtf8($value){
        if ($value === null) {
            return '';
        }

        if (function_exists('mb_convert_encoding')) {
            return mb_convert_encoding($value, 'UTF-8', 'ISO-8859-1');
        }

        if (function_exists('iconv')) {
            return iconv('ISO-8859-1', 'UTF-8//IGNORE', $value);
        }

        return $value;
    }

    function criarTabelaVendasTag($mysqli, $origem){
        $qr  = 'show tables like "vendas_tag"';
        $mysql = $mysqli->query($qr);

        if (!$mysql) {
            responderErro('Erro executando query em _funcoes.php: ' . $mysqli->error);
        }
        
        if ($mysql->num_rows == 0) {
            $qr = 'create table if not exists vendas_tag (';
            $qr .= ' codigo int(11) not null default 0,';
            $qr .= ' origem int(11) not null default 0,';
            $qr .= ' tag int(11) not null default 0,';
            $qr .= ' primary key (codigo,origem))';
            $qr .= ' engine=innodb';

            gravarLog($mysqli, $qr, $origem, 'pedidos');            
            $mysql = $mysqli->query($qr);

            if (!$mysql) {
                responderErro('Erro executando query em _funcoes.php: ' . $mysqli->error);
            }
        } 
    }

    function pegaSequencia($mysqli, $tabela, $origem){  
        if ($tabela == 'seq_vendas') {
            $qr  = 'select sequencia';
            $qr .= ' from seq_vendas';
            $qr .= ' limit 1';
            $mysql = $mysqli->query($qr);

            if (!$mysql) {
                responderErro('Erro executando query em _funcoes.php: ' . $mysqli->error);
            }

            //error_log('funcoes - pegaSequencia');
            //error_log($qr);

            if ($mysql->num_rows == 0) {
                $idt = 1;                
            } else {
                $row = mysqli_fetch_assoc($mysql);            
                $idt = $row['sequencia'] + 1;
            }

            //error_log($idt);            

            if ($idt == 1){
                $qr = 'insert into seq_vendas';
            } else {
                $qr = 'update seq_vendas';
            }

            $qr .= ' set sequencia = ' . $idt;
            $mysql = $mysqli->query($qr);

            if (!$mysql) {
                responderErro('Erro executando query em _funcoes.php: ' . $mysqli->error);
            }

            //error_log($idt);                        

            return $idt . $origem;
        } else {
            $qr  = 'select idt';
            $qr .= ' from seq';
            $qr .= ' where tabela = "' . $tabela . '"';
            $qr .= ' and origem = ' .$origem;
            $mysql = $mysqli->query($qr);

            if (!$mysql) {
                responderErro('Erro executando query em _funcoes.php: ' . $mysqli->error);
            }

            if ($mysql->num_rows > 0) {
                $row = mysqli_fetch_assoc($mysql);            
                $idt = $row['idt'] + 1;
            
                $qr  = 'update seq set';
                $qr .= ' idt = ' .$idt;
                $qr .= ' where tabela = "' . $tabela . '"';
                $qr .= ' and origem = ' .$origem;
                $mysql = $mysqli->query($qr);        

                if (!$mysql) {
                    responderErro('Erro executando query em _funcoes.php: ' . $mysqli->error);
                }
            } else {
                $idt = 1;

                $qr  = 'insert into seq set';
                $qr .= ' idt = ' .$idt;
                $qr .= ' ,tabela = "' . $tabela . '"';
                $qr .= ' ,origem = ' .$origem;
                $mysql = $mysqli->query($qr);        

                if (!$mysql) {
                    responderErro('Erro executando query em _funcoes.php: ' . $mysqli->error);
                }
            }

            return $idt . $origem; 
        }
    }

    function incluirItem($mysqli, $origem, $data, $item){
        $qr  = 'select';
        $qr .= ' codigo codigoVenda,';
        $qr .= ' item + 1 itemVenda';
        $qr .= ' from vendas';
        $qr .= ' where cartao=' . $data->codigo_nova_comanda;
        $qr .= ' and status=0';
        $qr .= ' and origem=' . $origem;
        $qr .= ' and isnull(data_exc)';
        $qr .= ' order by item desc';
        $qr .= ' limit 1';
        $mysql = $mysqli->query($qr);

        if (!$mysql) {
            responderErro('Erro executando query em _funcoes.php: ' . $mysqli->error);
        }

        //error_log('funcoes-incluirItem');
        //error_log($qr);

        if ($mysql->num_rows == 0) {
            $codigoVenda = pegaSequencia($mysqli, 'seq_vendas', $origem);
            $itemVenda = 1;            
        } else {
            $row = mysqli_fetch_assoc($mysql);                        
            $codigoVenda = $row['codigoVenda'];
            $itemVenda = $row['itemVenda'];            
        }

        //error_log($codigoVenda);
        //error_log($itemVenda);                

        $datahora = new datetime();
        $dia = date_format($datahora, 'Y-m-d');
        $hora = date_format($datahora, 'H:i:s');

        $qr  = 'insert into vendas set';
        $qr .= ' codigo=' . $codigoVenda;
        $qr .= ' ,mesa=' . $item['codigoMesa'];
        $qr .= ' ,data="'. $dia . '"';
        $qr .= ' ,hora="' . $hora . '"';
        $qr .= ' ,cartao=' . $data->codigo_nova_comanda;
        $qr .= ' ,garcom=' . $item['codigoFuncionario'];
        $qr .= ' ,item=' . $itemVenda;
        $qr .= ' ,produto=' . $item['codigoProduto'];
        $qr .= ' ,barra="' . $item['codigoBarra'] . '"';
        $qr .= ' ,descricao="' . $item['descricaoProduto'] . '"';
        $qr .= ' ,quantidade=' . $item['qtdeProduto'];
        $qr .= ' ,valor_unitario=' . $item['valorUnitario'];
        $qr .= ' ,valor_total=' . $item['valorTotal'];
        $qr .= ' ,status=0';
        $qr .= ' ,origem=' . $origem;
        gravarLog($mysqli, $qr, $origem, $data->nome_funcionario);
        $mysql = $mysqli->query($qr);

        if (!$mysql) {
            responderErro('Erro executando query em _funcoes.php: ' . $mysqli->error);
        }

        //error_log($qr);

        if ($item['observacaoItem'] !== '') {
            $qr  = 'insert into vendas_obs set';
            $qr .= ' codigo=' . $codigoVenda;
            $qr .= ' ,item=' . $itemVenda;
            $qr .= ' ,origem=' . $origem;
            $qr .= ' ,observacoes="' .$item['observacaoItem'] . '"';
            $qr .= ' ,operador="' . $data->nome_funcionario . '"';
            $qr .= ' ,data_inc="' . $dia . '"';        
            gravarLog($mysqli, $qr, $origem, $data->nome_funcionario);
            $mysql = $mysqli->query($qr);        

            if (!$mysql) {
                responderErro('Erro executando query em _funcoes.php: ' . $mysqli->error);
            }
    
            //error_log($qr);        
        }

        try {
            $codigoTag = $item['codigoTag'];
            if ($codigoTag !== '') {
                criarTabelaVendasTag($mysqli, $origem);
                                
                $qr = 'insert ignore into vendas_tag set';
                $qr .= ' codigo=' . $codigoVenda;
                $qr .= ' ,origem=' . $origem;
                $qr .= ' ,tag=' . $codigoTag;
                gravarLog($mysqli, $qr, $origem, $data->nome_funcionario);
                $mysql = $mysqli->query($qr);    

                if (!$mysql) {
                    responderErro('Erro executando query em _funcoes.php: ' . $mysqli->error);
                }
            }    
        }                    
        catch(Exception $e) {}        
    }

    function excluirComanda($mysqli, $origem, $data){
        $qr  = 'select codigo codigoVenda';
        $qr .= ' from vendas';
        $qr .= ' where cartao=' . $data->codigo_comanda;
        $qr .= ' and origem=' . $origem;
        $qr .= ' and status=0';
        $qr .= ' limit 1';
        $mysql = $mysqli->query($qr);

        if (!$mysql) {
            responderErro('Erro executando query em _funcoes.php: ' . $mysqli->error);
        }

        //error_log('funcoes - excluirComanda');
        //error_log($qr);

        if ($mysql->num_rows > 0) {
            $row = mysqli_fetch_assoc($mysql);  
            $codigoVenda = $row['codigoVenda'];

            $datahora = new datetime();
            $dataExc = date_format($datahora, 'Y-m-d');
                        
            $qr  = 'update vendas set';
            $qr .= ' status=5';
            $qr .= ' ,user_exc=' . $data->codigo_funcionario;
            $qr .= ' ,data_exc="' . $dataExc . '"';
            $qr .= ' where codigo=' . $codigoVenda;
            $qr .= ' and origem=' . $origem;

            if ($data->item_venda > 0) {
                $qr .= ' and item=' . $data->item_venda;
            }

            gravarLog($mysqli, $qr, $origem, $data->nome_funcionario); 
            $mysql = $mysqli->query($qr);

            if (!$mysql) {
                responderErro('Erro executando query em _funcoes.php: ' . $mysqli->error);
            }

            //error_log($qr);

            $qr  = 'update vendas_obs set';
            $qr .= ' data_exc="' . $dataExc . '"';
            $qr .= ',operador="' . $data->nome_funcionario . '"';
            $qr .= ' where codigo=' . $codigoVenda;
            $qr .= ' and origem=' . $origem;

            if ($data->item_venda > 0) {
                $qr .= ' and item=' . $data->item_venda;
            }

            gravarLog($mysqli, $qr, $origem, $data->nome_funcionario);
            $mysql = $mysqli->query($qr);

            if (!$mysql) {
                responderErro('Erro executando query em _funcoes.php: ' . $mysqli->error);
            }

            //error_log($qr);            
        }
    }

    function gravarLog($mysqli, $query, $origem, $usuario) {
        $qr  = 'insert into log set';
        $qr .= ' id=0';
        $qr .= ',data=now()';
        $qr .= ',usuario="'. $usuario .'"';
        $qr .= ',origem=' . $origem;
        $qr .= ',envio = 0';
        $qr .= ',modulo="php-pedidos"';
        $qr .= ',itens=0';
        $qr .= ',str_sql = "' . mysqli_real_escape_string($mysqli, $query) . '"';

        $mysqli->query($qr);        
    }

    /*    
    function utf8_string_array_encode(&$array){
        $func = function(&$value,&$key){
            if(is_string($value)){
                $value = textoUtf8($value);
            }
            if(is_string($key)){
                $key = textoUtf8($key);
            }
            if(is_array($value)){
                utf8_string_array_encode($value);
            }
        };
        array_walk($array,$func);
        return $array;
    }    
    */    
?>
