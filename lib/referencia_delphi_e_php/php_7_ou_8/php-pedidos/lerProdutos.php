<?php
    header('Content-Type: application/json; charset=utf-8');
    include '_config.php';
    include '_funcoes.php';

    $mysqli = new mysqli($servidor, $usuario, $senha, $banco, $porta);
    validarConexao($mysqli);
 
        $data = lerJsonEntrada();

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

        if (!$mysql) {
            responderErro('Erro executando query em lerProdutos.php: ' . $mysqli->error);
        }

        $retorno = array();
        $conta = 0;

        while ($row = mysqli_fetch_assoc($mysql)) {
            //$retorno[] = $row;

            $retorno[$conta] = (object)null;            
            $retorno[$conta]->codigo_produto = $row['codigo_produto'];
            $retorno[$conta]->codigo_reduzido = $row['codigo_reduzido'];
            $retorno[$conta]->codigo_barra = textoUtf8($row['codigo_barra']);
            $retorno[$conta]->descricao_produto = textoUtf8($row['descricao_produto']);
            $retorno[$conta]->grupo_produto = $row['grupo_produto'];
            $retorno[$conta]->valor_unitario = $row['valor_unitario'];
            $retorno[$conta]->unidade_produto = textoUtf8($row['unidade_produto']);

            $conta++;            
        }

        //$retorno = utf8_string_array_encode($retorno);        
        responderJson($retorno);
?>        