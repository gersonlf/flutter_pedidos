# Resumo do projeto pedidos_restaurante

Este arquivo resume o que foi feito ate agora na recriacao do sistema Delphi/PHP em Flutter. O objetivo do projeto nao e converter o Delphi literalmente, mas recriar o fluxo operacional em modulos pequenos, usando Flutter como novo app e mantendo compatibilidade inicial com os scripts PHP existentes.

## Contexto inicial

Foi analisada a pasta de referencia em:

- `lib/referencia_delphi_e_php/delphi_12/src`
- `lib/referencia_delphi_e_php/php_7_ou_8/php-pedidos`

A analise gerou o documento:

- `docs/analise_delphi.md`

Esse documento mapeia:

- telas existentes no Delphi;
- entidades principais;
- tabelas e campos usados;
- fluxo de uso do sistema;
- regras de negocio importantes;
- endpoints REST/PHP necessarios para o Flutter.

## Fundacao Flutter criada

Foi criada a base do app Flutter com uma estrutura modular:

- `lib/main.dart`
- `lib/app/pedidos_app.dart`
- `lib/features/home/home_page.dart`
- `lib/features/settings/settings_page.dart`

Tambem foram criadas estruturas centrais:

- configuracao local do app;
- montagem de URL dos scripts PHP;
- cliente/rede base;
- modelos Dart para as entidades do dominio.

Dependencias adicionadas ao projeto:

- `http`
- `shared_preferences`

## Configuracao

Foi implementada a configuracao local do app, permitindo definir:

- servidor;
- porta;
- contexto PHP;
- protocolo HTTP/HTTPS;
- teclado fisico;
- digito verificador de comanda;
- exigencia de senha para excluir item/comanda.

Arquivos envolvidos:

- `lib/core/config/app_config.dart`
- `lib/core/config/app_config_store.dart`
- `lib/features/settings/settings_page.dart`

## Tela inicial

A Home passou a centralizar o fluxo principal:

1. configurar servidor;
2. selecionar funcionario;
3. selecionar comanda;
4. abrir itens da comanda;
5. abrir cozinha/preparo.

Ela tambem guarda o funcionario e a comanda selecionados durante o uso.

Arquivo envolvido:

- `lib/features/home/home_page.dart`

## Modulo Funcionarios

Foi implementado o modulo de funcionarios:

- listagem de funcionarios via `lerFuncionarios.php`;
- selecao de funcionario operador;
- validacao de senha autorizada para exclusao via `lerSenhas.php`.

Arquivos envolvidos:

- `lib/core/models/funcionario.dart`
- `lib/features/employees/employee_repository.dart`
- `lib/features/employees/employee_selection_page.dart`

## Modulo Comandas

Foi implementado o modulo de comandas:

- listagem de comandas abertas via `lerComandas.php`;
- consulta direta por codigo;
- consulta de mesa via `lerMesa.php`;
- consulta de tag via `lerTag.php`;
- consulta de bloqueio via `lerBloqueio.php`;
- selecao de comanda para lancar itens;
- troca de mesa via `alterarMesa.php`;
- exclusao de comanda via `excluirComanda.php`;
- confirmacao de exclusao;
- validacao de senha quando a configuracao exigir.

Tambem foi ajustada a Home para limpar a comanda selecionada quando uma comanda e excluida.

Arquivos envolvidos:

- `lib/core/models/comanda.dart`
- `lib/features/commands/command_repository.dart`
- `lib/features/commands/command_selection.dart`
- `lib/features/commands/command_selection_page.dart`
- `lib/features/home/home_page.dart`

## Modulo Produtos

Foi implementado o suporte a produtos, acompanhamentos e adicionais:

- pesquisa de produtos via `lerProdutos.php`;
- busca de acompanhamentos via `lerAcompanhamentos.php`;
- busca de adicionais via `lerAdicionais.php`;
- tela de pesquisa de produto;
- tela de selecao de opcoes para acompanhamentos/adicionais.

Arquivos envolvidos:

- `lib/core/models/produto.dart`
- `lib/features/products/product_repository.dart`
- `lib/features/products/product_search_page.dart`
- `lib/features/products/product_options_page.dart`

## Modulo Itens da Comanda

Foi implementado o fluxo de itens:

- listagem de itens da comanda via `lerItens.php`;
- inclusao de item via `incluirItem.php`;
- fluxo de quantidade e observacao;
- selecao de acompanhamentos;
- selecao de adicionais;
- inclusao de acompanhamentos e adicionais como itens separados;
- alteracao de observacao via `alterarObservacao.php`;
- exclusao de item via `excluirComanda.php`;
- validacao de senha para exclusao quando configurado;
- botao para enviar a comanda para cozinha via `imprimirComanda.php`.

Arquivos envolvidos:

- `lib/core/models/item_comanda.dart`
- `lib/features/items/item_repository.dart`
- `lib/features/items/item_list_page.dart`
- `lib/features/products/product_repository.dart`
- `lib/features/products/product_search_page.dart`
- `lib/features/products/product_options_page.dart`
- `lib/features/kitchen/kitchen_repository.dart`

## Modulo Cozinha/Preparo

Foi implementada a primeira versao do modulo de cozinha/preparo:

- modelo para pedido de cozinha;
- listagem de pedidos prontos via `lerPedidos.php` com `tipo_pedido=pedidoPronto`;
- listagem de pedidos entregues via `lerPedidos.php` com `tipo_pedido=pedidoEntregue`;
- chamada de comanda via `lerPedidoPronto.php`;
- remocao de chamada/entrega via `lerPedidoEntregue.php`;
- tela com abas `Prontos` e `Entregues`;
- campo para informar uma comanda e chamar o pedido;
- entrada do modulo Cozinha na Home.

Arquivos envolvidos:

- `lib/core/models/pedido_cozinha.dart`
- `lib/features/kitchen/kitchen_repository.dart`
- `lib/features/kitchen/kitchen_page.dart`
- `lib/features/home/home_page.dart`
- `lib/features/items/item_list_page.dart`

## Modelos criados

Modelos Dart usados ate agora:

- `lib/core/models/empresa_config.dart`
- `lib/core/models/funcionario.dart`
- `lib/core/models/comanda.dart`
- `lib/core/models/item_comanda.dart`
- `lib/core/models/produto.dart`
- `lib/core/models/pedido_cozinha.dart`

## Repositorios criados

Repositorios de acesso aos scripts PHP:

- `lib/features/employees/employee_repository.dart`
- `lib/features/commands/command_repository.dart`
- `lib/features/products/product_repository.dart`
- `lib/features/items/item_repository.dart`
- `lib/features/kitchen/kitchen_repository.dart`

## Telas criadas ou alteradas

Telas principais e modulares:

- `lib/app/pedidos_app.dart`
- `lib/features/home/home_page.dart`
- `lib/features/settings/settings_page.dart`
- `lib/features/employees/employee_selection_page.dart`
- `lib/features/commands/command_selection_page.dart`
- `lib/features/products/product_search_page.dart`
- `lib/features/products/product_options_page.dart`
- `lib/features/items/item_list_page.dart`
- `lib/features/kitchen/kitchen_page.dart`

## Arquivos de suporte/teste

Arquivos de suporte envolvidos:

- `pubspec.yaml`
- `pubspec.lock`
- `test/widget_test.dart`
- `lib/core/network/api_client.dart`

O teste de widget atual valida que a Home carrega e mostra a entrada de configuracao.

## Arquivos de referencia consultados

Principais arquivos Delphi/PHP consultados para orientar a recriacao:

- `lib/referencia_delphi_e_php/delphi_12/src/Views/View.Menu.pas`
- `lib/referencia_delphi_e_php/delphi_12/src/Views/View.Menu.fmx`
- `lib/referencia_delphi_e_php/delphi_12/src/Forms/Form.Funcionario.pas`
- `lib/referencia_delphi_e_php/delphi_12/src/Forms/Form.Comanda.pas`
- `lib/referencia_delphi_e_php/delphi_12/src/Forms/Form.Item.pas`
- `lib/referencia_delphi_e_php/delphi_12/src/Forms/Form.Produto.pas`
- `lib/referencia_delphi_e_php/delphi_12/src/Forms/Form.Configuracao.pas`
- `lib/referencia_delphi_e_php/delphi_12/src/Lists/List.Funcionario.pas`
- `lib/referencia_delphi_e_php/delphi_12/src/Lists/List.Comanda.pas`
- `lib/referencia_delphi_e_php/delphi_12/src/Lists/List.Item.pas`
- `lib/referencia_delphi_e_php/delphi_12/src/Lists/List.Produto.pas`
- `lib/referencia_delphi_e_php/delphi_12/src/Lists/List.Pedido.pas`
- `lib/referencia_delphi_e_php/delphi_12/src/Lists/List.Acompanhamento.pas`
- `lib/referencia_delphi_e_php/delphi_12/src/Lists/List.Adicional.pas`
- `lib/referencia_delphi_e_php/delphi_12/src/Services/Service.DM.pas`
- `lib/referencia_delphi_e_php/php_7_ou_8/php-pedidos/lerFuncionarios.php`
- `lib/referencia_delphi_e_php/php_7_ou_8/php-pedidos/lerSenhas.php`
- `lib/referencia_delphi_e_php/php_7_ou_8/php-pedidos/lerComandas.php`
- `lib/referencia_delphi_e_php/php_7_ou_8/php-pedidos/lerMesa.php`
- `lib/referencia_delphi_e_php/php_7_ou_8/php-pedidos/lerTag.php`
- `lib/referencia_delphi_e_php/php_7_ou_8/php-pedidos/lerBloqueio.php`
- `lib/referencia_delphi_e_php/php_7_ou_8/php-pedidos/alterarMesa.php`
- `lib/referencia_delphi_e_php/php_7_ou_8/php-pedidos/excluirComanda.php`
- `lib/referencia_delphi_e_php/php_7_ou_8/php-pedidos/lerProdutos.php`
- `lib/referencia_delphi_e_php/php_7_ou_8/php-pedidos/lerAcompanhamentos.php`
- `lib/referencia_delphi_e_php/php_7_ou_8/php-pedidos/lerAdicionais.php`
- `lib/referencia_delphi_e_php/php_7_ou_8/php-pedidos/lerItens.php`
- `lib/referencia_delphi_e_php/php_7_ou_8/php-pedidos/incluirItem.php`
- `lib/referencia_delphi_e_php/php_7_ou_8/php-pedidos/alterarObservacao.php`
- `lib/referencia_delphi_e_php/php_7_ou_8/php-pedidos/imprimirComanda.php`
- `lib/referencia_delphi_e_php/php_7_ou_8/php-pedidos/lerPedidos.php`
- `lib/referencia_delphi_e_php/php_7_ou_8/php-pedidos/lerPedidoPronto.php`
- `lib/referencia_delphi_e_php/php_7_ou_8/php-pedidos/lerPedidoEntregue.php`

## Validacoes executadas

Durante as etapas foram executados:

- `dart format lib test`
- `dart analyze`
- `flutter test`

O ultimo estado validado passou em:

- formatacao sem pendencias;
- analise sem issues;
- teste de widget passando.

Observacao: a pasta atual nao esta inicializada como repositorio Git, entao nao foi possivel usar `git status`/`git diff` para listar alteracoes formalmente.

## Estado atual do app

Hoje o app ja permite o fluxo basico:

1. configurar servidor;
2. selecionar funcionario;
3. selecionar ou consultar comanda;
4. trocar mesa da comanda;
5. excluir comanda;
6. abrir itens da comanda;
7. pesquisar produto;
8. escolher acompanhamentos/adicionais;
9. incluir item;
10. alterar observacao;
11. excluir item;
12. enviar comanda para cozinha;
13. abrir cozinha;
14. listar pedidos prontos/entregues;
15. chamar comanda;
16. remover chamada/entrega.

## Pontos ainda pendentes ou incompletos

Alguns comportamentos do Delphi ainda nao foram recriados:

- troca de comanda inteira;
- troca de item para outra comanda;
- regra completa de `controla_troca` da empresa;
- leitura e aplicacao completa de `lerEmpresas.php`;
- exigencia automatica de mesa quando `controla_mesa=S`;
- exigencia automatica de tag quando `controla_tag=S`;
- digito verificador de comanda;
- senha local para acessar configuracao;
- refresh automatico periodico da Home;
- tratamento centralizado de erros HTTP/PHP;
- testes unitarios dos repositorios e modelos;
- testes de widget para as telas novas;
- polimento visual para uso em tablet/celular no restaurante;
- validacao em ambiente real com o PHP e banco do cliente.

## Sugestoes de proximos passos

1. Implementar regras da empresa

   Criar um repositorio para `lerEmpresas.php`, carregar `controla_mesa`, `controla_tag`, `controla_troca` e `controla_cozinha`, e usar essas regras para habilitar/desabilitar fluxos.

2. Fechar fluxo de mesa e tag

   Quando a comanda retornar `mesa=-1` ou `tag=-1`, solicitar mesa/tag antes de lancar itens, respeitando a configuracao da empresa.

3. Implementar troca de comanda

   Adicionar troca de comanda inteira e troca de item para outra comanda usando `alterarComanda.php`, incluindo senha quando `controla_troca=S` e bloqueio quando `controla_troca=D`.

4. Melhorar camada de rede

   Centralizar cabecalhos, timeout, parse de JSON, resposta vazia e mensagens de erro em um cliente unico para reduzir duplicacao entre repositorios.

5. Expandir testes

   Criar testes para:

   - parse dos modelos;
   - repositorios com `http.Client` mockado;
   - selecao de funcionario;
   - selecao de comanda;
   - inclusao/exclusao de item;
   - tela de cozinha.

6. Ajustar UX operacional

   Melhorar o fluxo para uso rapido por garcom:

   - manter funcionario selecionado;
   - voltar da tela de itens ja enviando para cozinha quando fizer sentido;
   - reduzir toques para incluir varios itens na mesma comanda;
   - destacar status de bloqueio, mesa, tag e envio para cozinha.

7. Testar contra servidor real

   Rodar o app conectado ao PHP real para validar payloads e retornos, principalmente nos scripts que retornam corpo vazio ou mensagens inconsistentes.

8. Preparar primeira versao demonstravel

   Depois dos pontos acima, organizar uma versao piloto com:

   - configuracao;
   - funcionarios;
   - comandas;
   - itens;
   - cozinha;
   - testes basicos;
   - instrucoes simples de execucao.
