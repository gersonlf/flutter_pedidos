# AGENTS.md

## Objetivo Do Projeto

Este projeto e um app Flutter para pedidos de restaurante, inspirado no sistema original em Delphi/PHP. O foco atual e transformar o fluxo em um web app mobile/PWA por padrao, mantendo comportamento operacional parecido com o Delphi: teclados proprios, consulta incremental, fluxo rapido para lancar itens e execucao em Android, iOS e desktop.

Sempre que fizer modificacoes relevantes neste projeto, atualize este arquivo com:

- arquivos alterados;
- decisoes novas;
- comandos de teste/deploy executados;
- pendencias ou cuidados descobertos.

## Ambiente Atual

- Workspace: `D:\Developer\flutter_pedidos`
- PWA de testes: `C:\httpd-2.4.46-win64-VS16\htdocs\pedidos-app`
- URL de testes da PWA: `http://192.168.3.10/pedidos-app/`
- PHP usado pela PWA: `http://192.168.3.10/php-pedidos/`
- Fontes PHP realmente usados no teste: `C:\httpd-2.4.46-win64-VS16\htdocs\php-pedidos`
- Copia de referencia PHP no repo: `lib\referencia_delphi_e_php\php_7_ou_8\php-pedidos`
- Referencia Delphi no repo: `lib\referencia_delphi_e_php\delphi_12`

Configuracao correta no app para acessar os scripts PHP de teste:

- Servidor: `192.168.3.10`
- Porta: `80`
- Contexto: `pedidos`
- Protocolo: `http`

## Comandos Importantes

Validacao padrao:

```powershell
flutter analyze
flutter test
```

Build web manual:

```powershell
flutter build web --base-href /pedidos-app/
```

Publicar PWA na pasta do Apache:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\deploy_pwa.ps1
```

O script `scripts\deploy_pwa.ps1` compila o web build com `--base-href /pedidos-app/`, limpa `C:\httpd-2.4.46-win64-VS16\htdocs\pedidos-app` e copia `build\web` para la. Sempre rodar esse script depois de uma nova compilacao destinada a teste no aparelho.

Builds ja validados anteriormente:

```powershell
flutter build web --base-href /pedidos-app/
flutter build windows
flutter build apk --debug
```

## Decisoes Tomadas

### PWA E Plataforma

- O app deve ser mobile/PWA por padrao.
- A versao web/PWA deve ser testada pelo Apache local em `/pedidos-app/`.
- A base local foi iniciada com Sembast/IndexedDB, mas os dados operacionais de funcionario, produto, comanda e itens ainda vem dos scripts PHP.
- Fullscreen foi implementado para Web/PWA, Android/iOS e desktop.

### Dados E PHP

Hoje o app ainda consulta dados no PHP:

- Funcionarios: `lerFuncionarios.php`
- Produtos: `lerProdutos.php`
- Comandas: `lerComandas.php`
- Itens: `lerItens.php`
- Inclusao de item: `incluirItem.php`
- Acompanhamentos: `lerAcompanhamentos.php`
- Adicionais: `lerAdicionais.php`

O Flutter envia para produto o campo `consulta_produto`. O PHP atual pesquisa em `codigo_produto`, `codigo_reduzido`, `codigo_barra`, tabela auxiliar de barras e descricao. Para evitar produto errado no lancamento de item, o app filtra o retorno no cliente seguindo a regra do Delphi.

### Regra De Busca De Produto No Modo Item

Foi restaurado o comportamento do Delphi para lancamento de item:

- ate 5 digitos: procurar por `codigo_reduzido`;
- 6 ou 7 digitos: procurar por `codigo_produto`;
- mais de 7 digitos: procurar por `codigo_barra`;
- texto com letras: procurar por `descricao_produto`.

Na consulta/listagem de produtos, a busca continua mais aberta: codigo, reduzido, barras ou descricao.

### Teclado Operacional

O teclado operacional fica em `lib\core\widgets\operational_keyboard.dart`.

Recursos adicionados:

- teclado numerico e alfanumerico proprios;
- linha numerica alfanumerica corrigida para `1234567890`;
- `previewLoader` para mostrar consulta incremental enquanto digita;
- `clearOnOpen` para limpar campos operacionais ao abrir o teclado;
- `replaceInitialValueOnFirstInput` para abrir quantidade com `1` selecionado e substituir na primeira tecla;
- preview de produto dentro do teclado;
- preview de funcionario dentro do teclado numerico, buscando pelo codigo digitado e mostrando o primeiro funcionario encontrado;
- suporte a `listar`, `confirmar`, `voltar`, `limpar` e `del`.
- quando `listar` nao tiver acao, o botao permanece ocupando o lugar no teclado, mas sem caption.

Campos com `clearOnOpen: true`:

- produto;
- funcionario;
- comanda;
- chamada/cozinha.

O teclado de quantidade no fluxo de itens usa teclas vermelhas.

Cores especificas de teclados numericos:

- funcionario: card da home, titulo/lista, codigo e teclado em laranja (`0xFFFF9A7B`);
- comanda: card da home, titulo/lista, codigo e teclado em verde (`0xFF35B779`);
- itens/produto: card de itens na home, titulo/lista, codigo do produto e teclado de produto em azul (`0xFF4169E1`);
- consulta/lista de produtos: card de consulta da home, titulo/lista, teclado e codigo do produto em vermelho (`0xFFE53935`);
- mesa: titulo e teclas numericas em rosa (`0xFFE91E63`);
- tag: titulo e teclas numericas em roxo (`0xFF7B1FA2`);
- quantidade de item: teclas vermelhas (`0xFFE53935`).
- ao informar mesa ou tag apos selecionar uma comanda, o botao `voltar` retorna para a lista de comandas.

Menu principal:

- Os cards principais usam altura minima padronizada de 92 px para manter ritmo visual parecido.
- Os botoes `Selecionar`, `Abrir` e `Consultar` usam estilo tonal com fundo branco e icone/texto na cor do card, evitando o verde forte padrao.
- Os botoes flutuantes `Adicionar` seguem a cor da lista: comanda em verde e itens em azul.

Padrao dos botoes do teclado, seguindo a referencia Delphi:

- `voltar` fecha o teclado e retorna para a tela que abriu o teclado;
- em funcionario e comanda, `listar` fecha o teclado e mostra a lista ja presente na propria tela;
- no teclado numerico de produto dentro da tela de itens, `voltar` e `listar` apenas retornam para a lista de itens sem inserir; somente `confirmar` avanca para quantidade.
- a lista de comandas tem botao flutuante `Adicionar`; no modo operacional/PWA ele abre direto o teclado numerico de comanda.

### Fluxo De Adicionar Item

Na tela de itens, ao tocar em `Adicionar`:

1. Abre direto o teclado de produto.
2. Ao digitar, mostra a primeira correspondencia valida.
3. Ao confirmar, se o produto for valido, abre o teclado de quantidade.
4. A quantidade abre com `1` como valor default.
5. Se confirmar direto, usa `1`.
6. Se digitar outro valor, substitui o `1`.
7. Os botoes `voltar` e `listar` no teclado de produto cancelam e voltam para a lista de itens sem inserir.

### Listas De Itens E Comandas

- A lista de itens deve seguir a organizacao do Delphi: Qtde, Unitario, Total; Produto, Reduzido, Barra; Descricao; Observacao; Funcionario; Data/Hora.
- `lerItens.php` ja retorna `codigo_reduzido`, `codigo_barra`, `nome_funcionario` e `data_hora`; o modelo `ItemComanda` deve manter esses campos.
- A lista de comandas deve exibir Comanda, Tag, Mesa, Funcionario, Data/Hora e total.
- Em itens e comandas, `data_hora` deve aparecer em vermelho e com fonte bem pequena.
- Os menus de contexto de itens e comandas ficam no canto direito da ultima linha informativa do card: em itens na linha do funcionario; em comandas na linha do valor total.
- Os codigos principais das listas usam marcador eliptico na cor da area: funcionario em laranja, comanda em verde, produto do item em azul e produto da consulta em vermelho.
- A AppBar da lista de itens deve mostrar apenas `Itens`; o numero da comanda fica no card de resumo abaixo.
- O atalho de enviar/imprimir comanda para cozinha foi removido da lista de itens por nao corresponder ao comportamento visual do Delphi. O modulo de cozinha continua acessivel pelo menu principal quando habilitado.

## Arquivos Alterados No Trabalho Atual

Principais arquivos alterados ate este ponto:

- `README.md`
- `scripts\deploy_pwa.ps1`
- `lib\core\widgets\operational_keyboard.dart`
- `lib\core\platform\app_fullscreen.dart`
- `lib\core\platform\app_fullscreen_io.dart`
- `lib\core\platform\app_fullscreen_web.dart`
- `lib\core\platform\app_fullscreen_stub.dart`
- `lib\core\local\pedidos_database.dart`
- `lib\core\local\pedidos_database_opener.dart`
- `lib\core\local\pedidos_database_opener_io.dart`
- `lib\core\local\pedidos_database_opener_web.dart`
- `lib\core\local\pedidos_database_opener_stub.dart`
- `lib\features\home\home_page.dart`
- `lib\features\products\product_repository.dart`
- `lib\features\products\product_search_page.dart`
- `lib\features\items\item_list_page.dart`
- `lib\features\employees\employee_selection_page.dart`
- `lib\features\commands\command_selection_page.dart`
- `lib\features\kitchen\kitchen_page.dart`
- `test\product_repository_test.dart`

Verificar sempre `git status --short` antes de novas alteracoes, pois ha trabalho local ainda nao necessariamente commitado.

## Testes Adicionados Ou Atualizados

`test\product_repository_test.dart` cobre:

- tolerancia a warnings PHP antes do JSON;
- erro com preview de resposta invalida;
- busca de produto no modo item por `codigo_reduzido`;
- busca de produto no modo item por `codigo_produto`;
- busca de produto no modo item por `codigo_barra`.

Ultima validacao executada:

- `flutter analyze`: passou;
- `flutter test`: passou com 26 testes;
- `scripts\deploy_pwa.ps1`: executado com sucesso.

## Pendencias E Proximos Pontos

- Decidir quando migrar dados para base local no aparelho/browser. A infraestrutura Sembast/IndexedDB existe, mas os cadastros operacionais ainda consultam PHP.
- Avaliar sincronizacao offline/online para produtos, funcionarios e comandas se a base local passar a ser fonte primaria.
- Conferir no aparelho real o fluxo completo:
  - selecionar funcionario;
  - selecionar/consultar comanda;
  - adicionar item direto pelo teclado de produto;
  - confirmar quantidade default `1`;
  - substituir quantidade digitando outro valor;
  - listar produtos pelo botao `listar`;
  - incluir acompanhamentos/adicionais.
- Revisar se o comportamento do teclado fisico deve seguir exatamente o mesmo fluxo operacional do PWA sem teclado fisico.
- Commitar/pushar o conjunto atual quando o usuario aprovar.

## Git E Deploy

O projeto tem Git e remote GitHub:

- Remote: `https://github.com/gersonlf/flutter_pedidos.git`
- Branch principal usada ate agora: `main`

Historico relevante:

- Commit anterior publicado: `31a80f7 Adiciona teclado operacional e suporte PWA`

Antes de commit/push:

```powershell
git status --short
flutter analyze
flutter test
```

Depois de alteracoes destinadas ao teste:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\deploy_pwa.ps1
```
