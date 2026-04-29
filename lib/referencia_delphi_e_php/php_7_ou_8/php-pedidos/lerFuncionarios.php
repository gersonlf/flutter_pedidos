<?php
    header('Content-Type: application/json; charset=utf-8');
    include '_config.php';
    include '_funcoes.php';
    
    $mysqli = new mysqli($servidor, $usuario, $senha, $banco, $porta);
    validarConexao($mysqli);
 
        $data = lerJsonEntrada();
       
        $qr  = 'select';
        $qr .= ' idt codigo_funcionario,';
        $qr .= ' trim(nome) nome_funcionario';
        $qr .= ' from cad_funcionario';
        $qr .= ' where idt_empresa=' . $origem;
        $qr .= ' and tr100="S"';
        $qr .= ' and length(trim(nome))>0';
        $qr .= ' and isnull(data_exc)';
  
        if (($banco == 'pelanda') || ($banco == 'posto_pelanda')){
          $qr .= ' and desativado="N"';
          $qr .= ' and funcao in (3,6,8,11,22)';
        }
  
        $qr .= ' order by nome';        
        $mysql = $mysqli->query($qr);

        if (!$mysql) {
            responderErro('Erro executando query em lerFuncionarios.php: ' . $mysqli->error);
        }

        $retorno = array();
        $conta = 0;

        while ($row = mysqli_fetch_assoc($mysql)) {
            //$retorno[] = $row;

            $retorno[$conta] = (object)null;            
            $retorno[$conta]->codigo_funcionario = $row['codigo_funcionario'];
            $retorno[$conta]->nome_funcionario = textoUtf8($row['nome_funcionario']);

            $conta++;            
        }

        //$retorno = utf8_string_array_encode($retorno);
        responderJson($retorno);         
?>        