<?php
    header('Content-Type: application/json; charset=utf-8');
    include '_config.php';
    include '_funcoes.php';

    $mysqli = new mysqli($servidor, $usuario, $senha, $banco, $porta);
    validarConexao($mysqli);
 
        $data = lerJsonEntrada();

        criarTabelaVendasTag($mysqli, $origem);
                
        $qr  = 'show tables like "automacao_cozinha"';
        $mysql = $mysqli->query($qr);

        if (!$mysql) {
            responderErro('Erro executando query em lerEmpresas.php: ' . $mysqli->error);
        }

        if ($mysql->num_rows > 0) {
            $controlaCozinha = 'S';
        } else {
            $controlaCozinha = 'N';
        }
         
        $qr  = 'show columns from cad_empresa like "controla_tag"';
        $mysql = $mysqli->query($qr);

        if (!$mysql) {
            responderErro('Erro executando query em lerEmpresas.php: ' . $mysqli->error);
        }

        if ($mysql->num_rows == 0) {
            $qr = 'alter table cad_empresa add column controla_tag enum("S","N") not null default "N" after controla_mesa';
            gravarLog($mysqli, $qr, $origem, 'pedidos');            
            $mysql = $mysqli->query($qr);

            if (!$mysql) {
                responderErro('Erro executando query em lerEmpresas.php: ' . $mysqli->error);
            }
        }

        $qr  = 'show columns from cad_empresa like "controla_troca"';
        $mysql = $mysqli->query($qr);

        if (!$mysql) {
            responderErro('Erro executando query em lerEmpresas.php: ' . $mysqli->error);
        }

        if ($mysql->num_rows == 0) {
            $qr = 'alter table cad_empresa add column controla_troca enum("S","N","D") not null default "N" after controla_tag';
            gravarLog($mysqli, $qr, $origem, 'pedidos');            
            $mysql = $mysqli->query($qr);

            if (!$mysql) {
                responderErro('Erro executando query em lerEmpresas.php: ' . $mysqli->error);
            }
        }

        $qr  = 'select';
        $qr .= ' controla_mesa,';
        $qr .= ' controla_tag,';
        $qr .= ' controla_troca,';        
        $qr .= ' "' . $controlaCozinha . '" controla_cozinha';
        $qr .= ' from cad_empresa';
        $qr .= ' where idt=' . $origem;
        $mysql = $mysqli->query($qr);

        if (!$mysql) {
            responderErro('Erro executando query em lerEmpresas.php: ' . $mysqli->error);
        }

        $retorno = array();

        while ($row = mysqli_fetch_assoc($mysql)) {
            $retorno[] = $row;
        }

        //$retorno = utf8_string_array_encode($retorno);        
        responderJson($retorno);
?>        