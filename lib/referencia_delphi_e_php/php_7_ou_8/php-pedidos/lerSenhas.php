<?php
    header('Content-Type: application/json; charset=utf-8');
    include '_config.php';
    include '_funcoes.php';
    
    $mysqli = new mysqli($servidor, $usuario, $senha, $banco, $porta);
    validarConexao($mysqli);
 
        $data = lerJsonEntrada();

        $qr  = 'select';
        $qr .= ' idt codigo,';
        $qr .= ' nome';
        $qr .= ' from cad_funcionario';
        $qr .= ' where isnull(data_exc)';
        $qr .= ' and (senha=md5(' . $data->senha . ') or senha=' . $data->senha . ')';
        $qr .= ' and length(senha)>0 and not isnull(senha)';
        $qr .= ' and senha > 0';
        $qr .= ' and "' . $data->senha . '" > 0';
        $qr .= ' and tr100_excluir="S"';
        $qr .= ' limit 1';                
        $mysql = $mysqli->query($qr);

        if (!$mysql) {
            responderErro('Erro executando query em lerSenhas.php: ' . $mysqli->error);
        }

        $retorno = array();
        $conta = 0;

        while ($row = mysqli_fetch_assoc($mysql)) {
            //$retorno[] = $row;

            $retorno[$conta] = (object)null;             
            $retorno[$conta]->codigo = $row['codigo'];
            $retorno[$conta]->nome = textoUtf8($row['nome']);
             
            $conta++;              
        }

        //$retorno = utf8_string_array_encode($retorno);         
        responderJson($retorno);    
?>        