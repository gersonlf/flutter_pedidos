# Analise do sistema Delphi para recriacao em Flutter

## Escopo analisado

Referencia principal:

- `lib/referencia_delphi_e_php/delphi_12/src`
- Apoio para tabelas e payloads REST: `lib/referencia_delphi_e_php/php_7_ou_8/php-pedidos`

Objetivo desta analise: entender comportamento, telas, entidades, dados e endpoints necessarios para recriar o sistema em Flutter, sem converter literalmente a UI ou a arquitetura Delphi.

## 1. Lista de telas existentes

### Telas principais

| Tela Delphi | Papel no sistema | Equivalente sugerido em Flutter |
| --- | --- | --- |
| `View.Splash` | Tela inicial/carregamento. | Splash/loading inicial. |
| `View.Menu` | Tela principal atual, concentra menu, configuracao, listas, comandas, itens, produtos, cozinha e teclados embutidos via abas. | Home com navegacao por rotas/telas reais. |
| `View.Update` | Tela de atualizacao/versao. | Tela/modal de atualizacao, se ainda for necessario. |
| `View.Mensagem` | Modal generico para mensagens como senha invalida. | Dialog/snackbar padronizado. |

### Subtelas/abas usadas dentro de `View.Menu`

| Aba/componente | Conteudo |
| --- | --- |
| `TabItemMenu` | Menu inicial com funcionario atual, botoes Funcionario, Comanda, Produto, Cozinha, Configuracoes e Atualizar. |
| `TabItemConfiguracao` | Configuracao de servidor, porta, contexto, protocolo, teclado fisico, digito verificador e senha para excluir. |
| `TabItemTecladoNumerico` | Entrada numerica reutilizada para funcionario, comanda, mesa, tag, item, quantidade, senha, porta e cozinha. |
| `TabItemTecladoAlfaNumerico` | Entrada alfanumerica reutilizada para produto, endereco, contexto e observacao. |
| `TabItemListViewFuncionario` | Lista de funcionarios. |
| `TabItemListViewComanda` | Lista de comandas abertas. |
| `TabItemListViewItem` | Lista de itens de uma comanda. |
| `TabItemListViewProduto` | Lista de produtos pesquisados. |
| `TabItemListViewAcompanhamentos` | Lista de acompanhamentos obrigatorios/opcionais vinculados ao produto. |
| `TabItemListViewAdicionais` | Lista de adicionais vinculados ao produto. |
| `TabItemListViewPedido` | Lista de pedidos de cozinha/prontos/entregues. |
| `TabItemConfirmacao` | Confirmacao para chamar/alterar status de pedido. |

### Telas antigas/modulares ainda presentes

Ha uma estrutura anterior separada por menus e forms. Ela parece parcialmente substituida pela tela principal `View.Menu`, mas documenta o mesmo dominio:

| Tela Delphi | Papel |
| --- | --- |
| `Menu.Funcionario` + `Form.Funcionario` | Escolha/listagem de funcionario. |
| `Menu.Comanda` + `Form.Comanda` | Entrada/listagem/acoes de comanda. |
| `Menu.Item` + `Form.Item` | Listagem de itens e acoes sobre item. |
| `Menu.Produto` + `Form.Produto` | Pesquisa/listagem de produtos. |
| `Menu.Configuracao` + `Form.Configuracao` | Configuracao local do app. |
| `TecladoNumerico` | Teclado customizado para numeros/senhas/quantidades. |
| `TecladoAlfaNumerico` | Teclado customizado para texto/pesquisa/observacao. |

## 2. Lista de entidades principais

| Entidade | Descricao | Campos principais observados |
| --- | --- | --- |
| Configuracao local | Dados salvos no SQLite do app. | `servidor`, `porta`, `contexto`, `protocolo`, `teclado`, `digitoverificador`, `excluiritemcomanda`. |
| Empresa/configuracao operacional | Regras globais vindas do backend. | `controla_mesa`, `controla_tag`, `controla_troca`, `controla_cozinha`. |
| Funcionario | Usuario/garcom que opera comandas. | `codigo_funcionario`, `nome_funcionario`; para senha: `codigo`, `nome`. |
| Comanda | Agrupador de venda/pedido por cartao/comanda. | `codigo_empresa`, `codigo_venda`, `codigo_comanda`, `codigo_mesa`, `codigo_tag`, `data_hora`, `bloqueio`, `nome_funcionario`, `valor_total`. |
| Item da comanda | Produto lancado na comanda. | `codigo_venda`, `item_venda`, `codigo_produto`, `descricao_produto`, `qtde_produto`, `valor_unitario`, `valor_desconto`, `valor_total`, `observacao_item`. |
| Produto | Item vendavel. | `codigo_produto`, `codigo_reduzido`, `codigo_barra`, `descricao_produto`, `grupo_produto`, `valor_unitario`, `unidade_produto`. |
| Acompanhamento | Produto filho/composicao tipo acompanhamento. | Campos de produto + `quantidade_acompanhamento`; `valor_unitario` vem como `0`. |
| Adicional | Produto filho/composicao tipo adicional. | Campos de produto + `quantidade_acompanhamento`; pode ter `valor_unitario`. |
| Mesa | Numero de mesa associado a comanda. | `mesa`/`codigo_mesa`; `-1` indica ausencia de mesa para comanda ainda sem itens. |
| Tag | Identificador extra associado a venda/comanda. | `tag`/`codigo_tag`; `-1` indica ausencia de tag para comanda ainda sem itens. |
| Pedido de cozinha | Controle de chamada/pronto/entregue. | `codigo_comanda`, `tipo` em `automacao_cozinha`. |
| Bloqueio de comanda | Estado que impede operacoes. | `bloqueio` calculado por tempo ou tabela `bloqueio_comanda`. |
| Log | Auditoria das SQL executadas pelo PHP. | `data`, `usuario`, `origem`, `modulo`, `str_sql`. |

## 3. Lista de tabelas e campos usados

### SQLite local do app

| Tabela | Campos |
| --- | --- |
| `configuracao` | `servidor text not null`, `porta integer not null`, `contexto text not null`, `protocolo text not null`, `teclado text not null`, `digitoverificador text not null`, `excluiritemcomanda text not null`, `primary key (servidor)`. |

### Tabelas MySQL usadas pelo backend PHP

| Tabela | Campos usados | Uso |
| --- | --- | --- |
| `cad_empresa` | `idt`, `controla_mesa`, `controla_tag`, `controla_troca` | Carrega regras operacionais da empresa. O PHP cria `controla_tag` e `controla_troca` se faltarem. |
| `cadcontas` | `codigo`, `bloqueia_vendas_em_horas` | Calcula bloqueio automatico por tempo. |
| `cad_funcionario` | `idt`, `idt_empresa`, `nome`, `tr100`, `tr100_excluir`, `senha`, `data_exc`, `desativado`, `funcao` | Lista operadores e valida senha para exclusao/troca. |
| `cad_produto` | `idt`, `codigo_reduzido`, `codigo_barra`, `descricao`, `grupo`, `unidade`, `ativo`, `data_exc`, `controle_cozinha`, `quantidade_acompanhamento` | Cadastro de produtos, acompanhamentos, adicionais e itens de cozinha. |
| `cad_produto_codigo_barra` | `idt_produto`, `codigo_barra` | Codigos alternativos de barra. |
| `cad_produto_kit` | `produto`, `produto_kit`, `tipo_composicao`, `preco_venda`, `data_exc` | Relaciona produto principal com acompanhamentos (`tipo_composicao=2`) e adicionais (`tipo_composicao=3`). |
| `estoque` | `codigo`, `origem`, `ativo`, `preco_vendaV` | Preco/atividade do produto por empresa/origem. |
| `vendas` | `codigo`, `origem`, `mesa`, `data`, `hora`, `cartao`, `garcom`, `item`, `produto`, `barra`, `descricao`, `quantidade`, `valor_unitario`, `desconto`, `valor_total`, `status`, `data_exc`, `user_exc` | Tabela central de itens lancados em comandas. |
| `vendas_obs` | `codigo`, `item`, `origem`, `observacoes`, `operador`, `data_inc`, `data_alt`, `data_exc` | Observacoes por item de venda. |
| `vendas_tag` | `codigo`, `origem`, `tag` | Tag vinculada a venda/comanda. Criada pelo PHP se nao existir. |
| `vendas_cozinha` | `codigo`, `item`, `produto`, `status`, `origem`, `operador`, `data_inc`, `atendido` | Controle de impressao/envio de itens para cozinha. |
| `automacao_cozinha` | `idt`, `origem`, `tipo` | Controle de pedidos prontos/entregues/chamados. |
| `bloqueio_comanda` | `origem`, `comanda`, `data_exc` | Bloqueio manual de comanda. |
| `seq_vendas` | `sequencia` | Sequencia especial para `vendas.codigo`. |
| `seq` | `tabela`, `origem`, `idt` | Sequencia generica. |
| `log` | `id`, `data`, `usuario`, `origem`, `envio`, `modulo`, `itens`, `str_sql` | Auditoria de alteracoes feitas pelo PHP. |

### Estruturas em memoria no Delphi

| MemTable | Campos |
| --- | --- |
| `mtFuncionarios` | Recebe `codigo_funcionario`, `nome_funcionario`. |
| `mtEmpresas` | Recebe `controla_mesa`, `controla_tag`, `controla_troca`, `controla_cozinha`. |
| `mtComandas` | `codigo_empresa`, `codigo_venda`, `codigo_comanda`, `codigo_mesa`, `codigo_tag`, `data_hora`, `bloqueio`, `codigo_funcionario`, `nome_funcionario`, `valor_total`. |
| `mtItens` | `codigo_empresa`, `codigo_venda`, `codigo_comanda`, `codigo_mesa`, `codigo_tag`, `data_hora`, `codigo_funcionario`, `nome_funcionario`, `item_venda`, `codigo_produto`, `codigo_barra`, `codigo_reduzido`, `descricao_produto`, `qtde_produto`, `valor_unitario`, `valor_desconto`, `valor_total`, `observacao_item`. |
| `mtProdutos` | `codigo_produto`, `codigo_reduzido`, `codigo_barra`, `descricao_produto`, `grupo_produto`, `valor_unitario`, `unidade_produto`. |
| `mtAcompanhamentos` | Campos de produto + `quantidade_produto`, `quantidade_acompanhamento`. |
| `mtAdicionais` | Campos de produto + `quantidade_produto`, `quantidade_acompanhamento`. |
| `mtPedidos` | `codigo_comanda`. |
| `mtSenhas` | `codigo`, `nome`. |

## 4. Fluxo de uso do sistema

### Inicializacao

1. App abre em splash/menu.
2. `DM.Ler` carrega configuracao local SQLite.
3. `atualizarTabelas` busca funcionarios, produtos e empresa no backend.
4. O menu habilita/desabilita cozinha conforme `controla_cozinha`.
5. Regras de empresa ficam em memoria: controle de mesa, tag, troca de comanda e exigencia local de senha para exclusao.

### Operacao normal de pedido

1. Operador escolhe/informa funcionario.
2. Operador informa a comanda ou escolhe da lista.
3. Sistema consulta mesa, tag e bloqueio da comanda.
4. Se a comanda estiver bloqueada, bloqueia a operacao.
5. Se a empresa controla mesa e a comanda ainda nao tem mesa (`mesa=-1`), solicita mesa.
6. Se a empresa controla tag, solicita tag.
7. Operador informa/pesquisa produto.
8. Ao selecionar produto, o sistema busca acompanhamentos.
9. Se houver acompanhamentos, usuario marca os desejados e segue para adicionais.
10. Se houver adicionais, usuario marca os desejados.
11. Ao finalizar, o sistema grava acompanhamentos, adicionais e o item principal na comanda.
12. A lista de itens da comanda e recarregada.

### Acoes sobre comanda

Na lista de comandas, o menu de opcoes oferece:

- Excluir comanda.
- Trocar comanda.
- Trocar mesa.

Fluxo comum:

1. Verifica se a comanda esta bloqueada.
2. Se bloqueada, impede a operacao.
3. Para exclusao, se `excluiritemcomanda` estiver ativo, pede senha.
4. Para troca, se `controla_troca = "D"`, desabilita a troca.
5. Para troca, se `controla_troca = "S"`, exige senha antes de permitir.
6. Chama o endpoint correspondente e recarrega a lista.

### Acoes sobre item

Na lista de itens, o menu de opcoes oferece:

- Excluir item.
- Trocar comanda do item.
- Alterar observacao.

Fluxo comum:

1. Verifica bloqueio da comanda atual.
2. Para exclusao, pode exigir senha conforme configuracao local.
3. Para troca de item, pode exigir senha conforme `controla_troca`.
4. Ao trocar para outra comanda, tambem verifica se a comanda destino esta desbloqueada.
5. Ao alterar observacao, o backend impede a alteracao se o item ja foi impresso/enviado para cozinha com status especifico.

### Cozinha/pedidos

1. Botao Cozinha solicita numero da comanda.
2. Confirma/chama a comanda via endpoint de pedido pronto.
3. Ha lista de pedidos por tipo:
   - `pedidoPronto`
   - `pedidoEntregue`
4. Confirmacao pode mover/remover pedidos em `automacao_cozinha`.
5. Ao sair/voltar de itens, o sistema chama impressao/envio para cozinha para itens ainda nao enviados.

### Configuracao

1. Acesso a configuracao exige senha calculada localmente: `FormatDateTime('ddnn', now())`.
2. Campos configuraveis:
   - endereco do servidor;
   - porta;
   - contexto;
   - protocolo HTTP/HTTPS;
   - teclado fisico on/off;
   - digito verificador de comanda on/off;
   - exigir senha para excluir item/comanda on/off.
3. Ao confirmar, grava no SQLite e recarrega configuracao.

## 5. Regras de negocio importantes

- A comanda nao pode receber alteracoes quando `bloqueio <> 0`.
- Bloqueio pode vir de:
  - venda antiga quando `cadcontas.bloqueia_vendas_em_horas = "S"` e passou 28800 segundos;
  - registro em `bloqueio_comanda`;
  - retorno especial `9999999` para bloqueio manual.
- Comandas sem itens retornam `mesa=-1` e/ou `tag=-1`; isso dispara pedido de mesa/tag dependendo da configuracao da empresa.
- `controla_mesa = "S"` exige mesa quando a comanda ainda nao tem mesa.
- `controla_tag = "S"` exige tag no fluxo de lancamento.
- `controla_troca = "D"` desabilita troca de comanda.
- `controla_troca = "S"` exige senha para troca de comanda ou troca de item para outra comanda.
- `excluiritemcomanda = on` exige senha para excluir item/comanda.
- Senha valida precisa existir em `cad_funcionario`, com `tr100_excluir="S"` e senha numerica/MD5 correspondente.
- Produto so aparece se ativo, com estoque ativo, descricao preenchida e preco maior que zero.
- Produto pode ser pesquisado por `idt`, `codigo_reduzido`, codigo de barras principal, codigo de barras alternativo ou descricao.
- Quantidade aceita decimal somente quando unidade do produto e `KG`; para outras unidades, quantidade e inteira.
- Ao inserir item:
  - se a comanda ainda nao tem venda aberta, cria novo `codigo` via `seq_vendas`;
  - se ja existe, usa o mesmo `codigo` e incrementa `item`;
  - `valor_total = quantidade * valor_unitario`;
  - grava observacao em `vendas_obs` se preenchida;
  - grava tag em `vendas_tag` quando informada.
- Acompanhamentos sao gravados como itens separados, quantidade `1`, valor `0`.
- Adicionais sao gravados como itens separados, quantidade `1`, com preco proprio.
- O item principal tambem e gravado como item separado, atualmente com quantidade `1` no fluxo com acompanhamentos/adicionais em `View.Menu`.
- Excluir comanda/item nao remove fisicamente: atualiza `vendas.status=5`, `user_exc`, `data_exc` e marca `vendas_obs.data_exc`.
- Trocar comanda duplica/reinsere os itens na nova comanda e marca os itens antigos como excluidos.
- Alterar observacao pode ser recusado se o item ja foi impresso/enviado para cozinha.
- Impressao/envio para cozinha insere em `vendas_cozinha` apenas produtos com `cad_produto.controle_cozinha="S"` e que ainda nao estejam com `status=9`.
- A tela principal tem atualizacao periodica enquanto esta no menu.
- O app usa `BaseURL = protocolo://servidor:porta` e contexto PHP como `php-<contexto>`.

## 6. Endpoints REST necessarios para o Flutter

### Observacao geral

O Delphi atual usa POST para quase todos os scripts PHP em:

`{baseUrl}/php-{contexto}/{script}.php`

Para Flutter, o ideal e expor uma API REST nova, com nomes consistentes e payloads tipados. A tabela abaixo mapeia o endpoint atual e uma rota sugerida.

### Autenticacao/configuracao

| Necessidade | PHP atual | Metodo sugerido | Rota Flutter/API sugerida | Payload/parametros | Retorno |
| --- | --- | --- | --- | --- | --- |
| Login/token legado | `cgi-bin/servidor.exe/v1.0/login` | `POST` | `/auth/login` | `usuario`, `senha` | token/sessao. |
| Versao do servidor/app | `cgi-bin/servidor.exe/v2.0/versao?url=...` | `GET` | `/app/version` | `url` | `versao`. |
| Regras da empresa | `lerEmpresas.php` | `GET` | `/empresa/configuracao` | nenhum alem do contexto/origem | `controla_mesa`, `controla_tag`, `controla_troca`, `controla_cozinha`. |

### Consultas principais

| Necessidade | PHP atual | Metodo sugerido | Rota Flutter/API sugerida | Payload atual | Retorno |
| --- | --- | --- | --- | --- | --- |
| Listar funcionarios | `lerFuncionarios.php` | `GET` | `/funcionarios` | nenhum | lista de `codigo_funcionario`, `nome_funcionario`. |
| Validar senha de permissao | `lerSenhas.php` | `POST` | `/funcionarios/validar-senha` | `senha` | funcionario autorizado: `codigo`, `nome`. |
| Pesquisar produtos | `lerProdutos.php` | `GET` | `/produtos?consulta=` | `consulta_produto` | lista de produtos. |
| Listar acompanhamentos | `lerAcompanhamentos.php` | `GET` | `/produtos/{produtoId}/acompanhamentos` | `consulta_produto` | lista de produtos/acompanhamentos. |
| Listar adicionais | `lerAdicionais.php` | `GET` | `/produtos/{produtoId}/adicionais` | `consulta_produto` | lista de produtos/adicionais. |
| Listar comandas | `lerComandas.php` | `GET` | `/comandas?codigo=` | `codigo_comanda` opcional | lista de comandas abertas. |
| Listar itens da comanda | `lerItens.php` | `GET` | `/comandas/{codigoComanda}/itens` | `codigo_comanda` | lista de itens. |
| Consultar mesa | `lerMesa.php` | `GET` | `/comandas/{codigoComanda}/mesa` | `codigo_comanda` | `mesa`; `-1` quando nao existe. |
| Consultar tag | `lerTag.php` | `GET` | `/comandas/{codigoComanda}/tag` | `codigo_comanda` | `tag`; `-1` quando nao existe. |
| Consultar bloqueio | `lerBloqueio.php` | `GET` | `/comandas/{codigoComanda}/bloqueio` | `codigo_comanda` | `bloqueio`. |

### Mutacoes de comanda/item

| Necessidade | PHP atual | Metodo sugerido | Rota Flutter/API sugerida | Payload principal | Retorno esperado |
| --- | --- | --- | --- | --- | --- |
| Incluir item | `incluirItem.php` | `POST` | `/comandas/{codigoComanda}/itens` | `codigo_comanda`, `codigo_mesa`, `codigo_tag`, `codigo_funcionario`, `nome_funcionario`, `codigo_produto`, `codigo_barra`, `codigo_reduzido`, `descricao_produto`, `qtde_produto`, `valor_unitario`, `valor_total`, `observacao_item` | item criado: `codigoVenda`, `itemVenda`. |
| Excluir comanda | `excluirComanda.php` | `DELETE` | `/comandas/{codigoComanda}` | `codigo_comanda`, `codigo_funcionario`, `nome_funcionario`, `item_venda=0` | sucesso/erro. |
| Excluir item | `excluirComanda.php` | `DELETE` | `/comandas/{codigoComanda}/itens/{itemVenda}` | `codigo_comanda`, `item_venda`, `codigo_funcionario`, `nome_funcionario` | sucesso/erro. |
| Alterar mesa | `alterarMesa.php` | `PATCH` | `/comandas/{codigoComanda}/mesa` | `codigo_comanda`, `codigo_nova_mesa`, `nome_funcionario` | sucesso/erro. |
| Trocar comanda inteira | `alterarComanda.php` | `POST` | `/comandas/{codigoComanda}/trocar` | `codigo_comanda`, `codigo_nova_comanda`, `codigo_funcionario`, `nome_funcionario`, `item_venda=0` | sucesso/erro. |
| Trocar item de comanda | `alterarComanda.php` | `POST` | `/comandas/{codigoComanda}/itens/{itemVenda}/trocar-comanda` | `codigo_comanda`, `codigo_nova_comanda`, `item_venda`, `codigo_funcionario`, `nome_funcionario` | sucesso/erro. |
| Alterar observacao do item | `alterarObservacao.php` | `PATCH` | `/comandas/{codigoComanda}/itens/{itemVenda}/observacao` | `codigo_comanda`, `item_venda`, `nome_funcionario`, `observacao_item` | `msg` vazio ou mensagem de bloqueio. |
| Enviar/imprimir comanda na cozinha | `imprimirComanda.php` | `POST` | `/comandas/{codigoComanda}/cozinha/imprimir` | `codigo_comanda`, `nome_funcionario` | sucesso/erro. |

### Cozinha / pedidos

| Necessidade | PHP atual | Metodo sugerido | Rota Flutter/API sugerida | Payload atual | Retorno |
| --- | --- | --- | --- | --- | --- |
| Listar pedidos por tipo | `lerPedidos.php` | `GET` | `/cozinha/pedidos?tipo=pedidoPronto|pedidoEntregue` | `tipo_pedido` | lista de `codigo_comanda`. |
| Marcar/chamar pedido pronto | `lerPedidoPronto.php` | `POST` | `/cozinha/pedidos/{codigoComanda}/pronto` | `codigo_comanda`, `nome_funcionario` | sucesso/erro. |
| Marcar pedido entregue/remover chamada | `lerPedidoEntregue.php` | `POST` ou `DELETE` | `/cozinha/pedidos/{codigoComanda}/entregue` | `codigo_comanda`, `nome_funcionario` | sucesso/erro. |

## Recomendacoes para a recriacao em Flutter

- Separar a UI em telas reais: `Home`, `Configuracao`, `SelecionarFuncionario`, `SelecionarComanda`, `DetalheComanda`, `PesquisarProduto`, `SelecionarAcompanhamentos`, `SelecionarAdicionais`, `Cozinha`.
- Manter configuracao local em storage SQLite/SharedPreferences, mas encapsulada em um servico.
- Trocar os scripts PHP soltos por uma API com contrato unico, validacao e tratamento de erros consistente.
- Representar bloqueios/permissoes no frontend, mas manter a validacao tambem no backend.
- Evitar recriar os teclados customizados se o teclado nativo Flutter atender; manter apenas um componente de entrada numerica com a regra de decimal para `KG`.
- Criar modelos Dart para `Funcionario`, `Produto`, `Comanda`, `ItemComanda`, `EmpresaConfig`, `PedidoCozinha`.
- Implementar um `PedidoService`/`ApiClient` com timeout, tratamento de erro e logs.
- Confirmar a regra de quantidade do item principal quando ha acompanhamentos/adicionais: no fluxo atual de `View.Menu`, o item principal e gravado com quantidade `1` depois das selecoes.
