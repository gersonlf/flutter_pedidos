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
        $qr .= ' a.idt codigo_produto,';
        $qr .= ' if(isnull(a.codigo_reduzido) or a.codigo_reduzido="",0,a.codigo_reduzido) codigo_reduzido,';
        $qr .= ' if(isnull(c.codigo_barra),if(isnull(a.codigo_barra),"",a.codigo_barra),if(isnull(c.codigo_barra),"",c.codigo_barra)) codigo_barra,';
        $qr .= ' left(a.descricao,40) descricao_produto,';
        $qr .= ' a.grupo grupo_produto,';
        $qr .= ' b.preco_vendaV valor_unitario,';
        $qr .= ' if(isnull(a.unidade) or a.unidade="","UN",a.unidade) unidade_produto';
        $qr .= ' from cad_produto a';
        $qr .= ' inner join estoque b';
        $qr .= ' on a.idt=b.codigo';
        $qr .= ' left join cad_produto_codigo_barra c';
        $qr .= ' on a.idt=c.idt_produto';
        $qr .= ' where b.origem=' . $origem;
        $qr .= ' and not isnull(a.descricao)';
        $qr .= ' and a.descricao<>""';
        $qr .= ' and a.ativo="S"';
        $qr .= ' and b.ativo="S"';
        $qr .= ' and b.preco_vendaV>0';
  
        if ($data->consulta_produto !== ''){
          $qr .= ' and (a.idt="' . $data->consulta_produto . '"';
          $qr .= ' or a.codigo_reduzido="'  . $data->consulta_produto . '"';
          $qr .= ' or a.codigo_barra="' . $data->consulta_produto . '"';
          $qr .= ' or c.codigo_barra="' . $data->consulta_produto . '"';
          $qr .= ' or a.descricao like "%' . $data->consulta_produto . '%")';
        }
  
        $qr .= ' order by a.descricao';
        $mysql = $mysqli->query($qr);

        $retorno = array();
        $conta = 0;

        while ($row = mysqli_fetch_assoc($mysql)) {
            //$retorno[] = $row;

            $retorno[$conta] = (object)null;            
            $retorno[$conta]->codigo_produto = $row['codigo_produto'];
            $retorno[$conta]->codigo_reduzido = $row['codigo_reduzido'];
            $retorno[$conta]->codigo_barra = utf8_encode($row['codigo_barra']);
            $retorno[$conta]->descricao_produto = utf8_encode($row['descricao_produto']);
            $retorno[$conta]->grupo_produto = $row['grupo_produto'];
            $retorno[$conta]->valor_unitario = $row['valor_unitario'];
            $retorno[$conta]->unidade_produto = utf8_encode($row['unidade_produto']);

            $conta++;            
        }

        //$retorno = utf8_string_array_encode($retorno);        
        echo json_encode($retorno);
    }
?>        