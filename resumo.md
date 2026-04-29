# Resumo do projeto flutter_pedidos

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
- cliente/rede centralizado;
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
- troca de comanda inteira via `alterarComanda.php`;
- confirmacao de exclusao;
- validacao de senha quando a configuracao exigir.
- aplicacao de `controla_troca` para troca livre, com senha ou desabilitada.
- tratamento de resposta vazia em `alterarComanda.php` como sucesso.
- digito verificador opcional na leitura/consulta de comanda, removendo o ultimo digito quando a configuracao estiver ativa.

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
- troca de item para outra comanda via `alterarComanda.php`;
- validacao de senha para exclusao quando configurado;
- aplicacao de `controla_troca` para troca livre, com senha ou desabilitada;
- recarga da lista de itens apos troca de item;
- envio de `codigo_tag` vazio quando nao ha tag real, evitando persistir tag `0`;
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

## Regras da empresa

Foi iniciada a leitura e aplicacao das regras da empresa via `lerEmpresas.php`:

- modelo `EmpresaConfig` com parse de `controla_mesa`, `controla_tag`, `controla_troca` e `controla_cozinha`;
- repositorio `CompanyRepository` para carregar as regras no inicio do app;
- exibicao das regras carregadas na Home;
- aviso na Home quando as regras nao puderem ser carregadas;
- habilitacao do modulo Cozinha somente quando `controla_cozinha=S`;
- bloqueio do envio para cozinha na tela de itens quando a cozinha estiver desabilitada;
- exigencia de mesa antes de abrir itens quando `controla_mesa=S`;
- exigencia de tag antes de abrir itens quando `controla_tag=S`.

Arquivos envolvidos:

- `lib/core/models/empresa_config.dart`
- `lib/features/company/company_repository.dart`
- `lib/features/home/home_page.dart`
- `lib/features/items/item_list_page.dart`
- `lib/features/commands/command_selection.dart`

## Camada de rede

Foi centralizado o acesso HTTP/JSON em `ApiClient`, reduzindo duplicacao nos repositorios.

Comportamentos tratados no cliente central:

- montagem do endpoint PHP;
- headers padrao para JSON;
- `POST` com corpo JSON;
- timeout de 20 segundos;
- decodificacao por `bodyBytes` em UTF-8;
- resposta vazia como sucesso quando permitido;
- extracao de JSON valido quando o PHP imprime avisos antes/depois do corpo;
- mensagem de erro com trecho da resposta quando o corpo nao e JSON valido.

Repositorios migrados para usar o cliente central:

- `CompanyRepository`
- `CommandRepository`
- `EmployeeRepository`
- `ItemRepository`
- `KitchenRepository`
- `ProductRepository`

Arquivos envolvidos:

- `lib/core/network/api_client.dart`
- `test/api_client_test.dart`

## Padronizacao dos scripts PHP

Foi aplicada a padronizacao dos scripts PHP para evitar sucesso com corpo vazio e respostas de erro em HTML/warning.

Foram adicionados helpers em `_funcoes.php`:

- `responderJson`;
- `responderSucesso`;
- `responderErro`;
- `validarConexao`;
- `lerJsonEntrada`.

Scripts de acao padronizados para retornar JSON:

- `alterarComanda.php`;
- `alterarMesa.php`;
- `alterarObservacao.php`;
- `excluirComanda.php`;
- `imprimirComanda.php`;
- `incluirItem.php`;
- `lerPedidoPronto.php`;
- `lerPedidoEntregue.php`.

Scripts de leitura padronizados mantendo o formato de sucesso original esperado pelo Flutter:

- `lerAcompanhamentos.php`;
- `lerAdicionais.php`;
- `lerBloqueio.php`;
- `lerComandas.php`;
- `lerEmpresas.php`;
- `lerFuncionarios.php`;
- `lerItens.php`;
- `lerMesa.php`;
- `lerPedidos.php`;
- `lerProdutos.php`;
- `lerSenhas.php`;
- `lerTag.php`.

Formato de sucesso usado nos scripts de acao quando nao ha lista/mapa legado para retornar:

- `sucesso`;
- `mensagem`;
- campos adicionais quando util, como `linhas_afetadas`, `itens_alterados` ou `itens_enviados`.

Tambem foi adicionada resposta JSON de erro para falha de conexao, JSON invalido e falhas de query nos scripts ajustados. Chamadas antigas a `utf8_encode` foram trocadas por `textoUtf8`, evitando avisos em PHP mais novo.

## Modelos criados

Modelos Dart usados ate agora:

- `lib/core/models/empresa_config.dart`
- `lib/core/models/funcionario.dart`
- `lib/core/models/comanda.dart`
- `lib/core/models/item_comanda.dart`
- `lib/core/models/produto.dart`
- `lib/core/models/pedido_cozinha.dart`
- `lib/core/models/empresa_config.dart`

## Repositorios criados

Repositorios de acesso aos scripts PHP:

- `lib/features/company/company_repository.dart`
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
- `test/api_client_test.dart`
- `test/command_check_digit_test.dart`
- `test/command_repository_test.dart`
- `test/company_repository_test.dart`
- `test/item_repository_test.dart`
- `test/product_repository_test.dart`
- `lib/core/network/api_client.dart`

O teste de widget atual valida que a Home carrega e mostra a entrada de configuracao. Tambem foram adicionados testes para o repositorio de produtos e para o carregamento das regras da empresa.

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
- `lib/referencia_delphi_e_php/php_7_ou_8/php-pedidos/alterarComanda.php`
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
- `lib/referencia_delphi_e_php/php_7_ou_8/php-pedidos/lerEmpresas.php`

## Validacoes executadas

Durante as etapas foram executados:

- `dart format lib test`
- `dart analyze`
- `flutter test`

O ultimo estado validado passou em:

- formatacao sem pendencias;
- analise sem issues;
- testes passando.

Observacao: a pasta atual ja esta inicializada como repositorio Git, com remoto `origin` apontando para `https://github.com/gersonlf/flutter_pedidos.git`.

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
17. carregar regras da empresa;
18. exigir mesa/tag conforme configuracao da empresa;
19. habilitar/desabilitar cozinha conforme configuracao da empresa.
20. trocar comanda inteira conforme regra `controla_troca`;
21. trocar item para outra comanda conforme regra `controla_troca`.
22. aplicar digito verificador opcional somente na leitura/consulta de comanda.

## Pontos ainda pendentes ou incompletos

Alguns comportamentos do Delphi ainda nao foram recriados:

- persistencia/troca de tag fora do fluxo de inclusao de item;
- senha local para acessar configuracao;
- refresh automatico periodico da Home;
- tratamento centralizado de erros HTTP/PHP;
- testes unitarios dos repositorios e modelos;
- testes de widget para as telas novas;
- polimento visual para uso em tablet/celular no restaurante;
- validacao em ambiente real com o PHP e banco do cliente.

## Sugestoes de proximos passos

1. Fechar persistencia de tag

   Hoje a tag exigida entra no payload de inclusao do item. Ainda falta um fluxo explicito para alterar ou informar tag fora da inclusao, caso o uso real exija isso.

2. Expandir testes

   Criar testes para:

   - parse dos modelos;
   - repositorios com `http.Client` mockado;
   - selecao de funcionario;
   - selecao de comanda;
   - inclusao/exclusao de item;
   - tela de cozinha.

3. Ajustar UX operacional

   Melhorar o fluxo para uso rapido por garcom:

   - manter funcionario selecionado;
   - voltar da tela de itens ja enviando para cozinha quando fizer sentido;
   - reduzir toques para incluir varios itens na mesma comanda;
   - destacar status de bloqueio, mesa, tag e envio para cozinha.

4. Testar contra servidor real

   Rodar o app conectado ao PHP real para validar payloads e retornos, principalmente nos scripts que retornam corpo vazio ou mensagens inconsistentes.

5. Preparar primeira versao demonstravel

   Depois dos pontos acima, organizar uma versao piloto com:

   - configuracao;
   - funcionarios;
   - comandas;
   - itens;
   - cozinha;
   - testes basicos;
   - instrucoes simples de execucao.
