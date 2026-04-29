<?php
    header('Content-Type: application/json; charset=utf-8');
    include '_config.php';
    include '_funcoes.php';
    
    $mysqli = new mysqli($servidor, $usuario, $senha, $banco, $porta);
    
    if (mysqli_connect_errno()) { 
        trigger_error(mysqli_connect_error());
    } else { 
        $data = json_decode(file_get_contents('php://input'));
       
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

        $retorno = array();
        $conta = 0;

        while ($row = mysqli_fetch_assoc($mysql)) {
            //$retorno[] = $row;

            $retorno[$conta] = (object)null;            
            $retorno[$conta]->codigo_funcionario = $row['codigo_funcionario'];
            $retorno[$conta]->nome_funcionario = utf8_encode($row['nome_funcionario']);

            $conta++;            
        }

        //$retorno = utf8_string_array_encode($retorno);
        echo json_encode($retorno);         
    }
?>           