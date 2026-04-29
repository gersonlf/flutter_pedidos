unit Service.DM;

interface

uses
  System.SysUtils, System.Classes,
  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Stan.ExprFuncs,

  System.JSON,
  DataSet.Serialize,
  DataSet.Serialize.Config,
  RESTRequest4D,

  Singleton.Variaveis,

  System.IOUtils,
  System.UITypes,

  Util.Funcao, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.FMXUI.Wait, FireDAC.Phys.SQLiteWrapper.Stat,
  FireDAC.Comp.UI;

type
  TDM = class(TDataModule)
    mtProdutos: TFDMemTable;
    mtFuncionarios: TFDMemTable;
    mtComandas: TFDMemTable;
    mtItens: TFDMemTable;
    mtSenhas: TFDMemTable;
    mtEmpresas: TFDMemTable;
    mtPedidos: TFDMemTable;
    FDQuery: TFDQuery;
    FDConnection: TFDConnection;
    FDGUIxWaitCursor: TFDGUIxWaitCursor;
    FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink;
    FDMemTable: TFDMemTable;
    mtAcompanhamentos: TFDMemTable;
    mtAdicionais: TFDMemTable;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    procedure FecharTudo;
  public
    { Public declarations }
    procedure servidorMTFuncionariosPHP;
    procedure servidorMTAcompanhamentosPHP(AConsultaProduto: string);
    procedure servidorMTAdicionaisPHP(AConsultaProduto: string);
    procedure servidorMTProdutosPHP(AConsultaProduto: string);
    procedure servidorMTEmpresasPHP;
    procedure servidorMTComandasPHP(ACodigoComanda: string);
    procedure servidorMTItensPHP(ACodigoComanda: string);
    procedure servidorMTSenhasPHP(ASenha: string);
    procedure servidorMTPedidosPHP(ATipoPedido: string);

    procedure imprimirMTComandaPHP(ANomeFuncionario, ACodigoComanda: string);

    function consultarMesaPHP(ACodigoComanda: string): string;
    function consultarTagPHP(ACodigoComanda: string): string;
    function consultarBloqueioPHP(ACodigoComanda: string): string;

    procedure alterarMesaMTComandasPHP(ANomeFuncionario, ACodigoComanda, ACodigoNovaMesa: string);

    procedure alterarObservacaoMTItensPHP(ANomeFuncionario, ACodigoComanda, ACodigoItem, AObservacaoItem: string);

    procedure alterarComandaMTComandasPHP(ACodigoFuncionario, ANomeFuncionario, ACodigoComanda, ACodigoNovaComanda: string);

    procedure alterarComandaMTItensPHP(ACodigoFuncionario, ANomeFuncionario, ACodigoComanda, ACodigoNovaComanda,
      ACodigoItem: string);

    procedure inserirMTItensPHP(ACodigoFuncionario, ANomeFuncionario, ACodigoComanda, ACodigoMesa, ACodigoTag, ACodigoProduto, ACodigoBarra,
      ACodigoReduzido, ADescricaoProduto, AQuantidadeItem: string; AValorUnitario: double; AObservacaoItem: string);

    procedure excluirMTComandasPHP(ACodigoFuncionario, ANomeFuncionario, ACodigoComanda: string);

    procedure excluirMTItensPHP(ACodigoFuncionario, ANomeFuncionario, ACodigoComanda, ACodigoItem: string);

    procedure alterarPedidoProntoPHP(ACodigoComanda: string; ANomeFuncionario: string);
    procedure alterarPedidoEntreguePHP(ACodigoComanda: string; ANomeFuncionario: string);

    procedure atualizarTabelas;

    function filtrarMTFuncionarios(AConsultaFuncionario: string): boolean;
    function filtrarMTProdutos(AConsultaProduto: string; AConsultaEmDescricaoTambem: boolean): boolean;

    procedure limparFiltroProduto;

    function versaoApp(AURL: string): string;

    procedure Criar;
    procedure Ler;
    procedure Gravar;

    //function Login(ABaseURL: string; ABody: TJSONObject): string;
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}
{$R *.dfm}
{ TDM }

procedure TDM.alterarComandaMTComandasPHP(ACodigoFuncionario: string; ANomeFuncionario: string; ACodigoComanda: string;
  ACodigoNovaComanda: string);
var
  LResponse: IResponse;
  LBaseURL: string;
  LContexto: string;
  LJSONObject: TJSONObject;

begin
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndLower;

  LBaseURL := TVariaveis.GetInstancia.BaseURL;
  LContexto := 'php-' + TVariaveis.GetInstancia.Contexto;

  LJSONObject := TJSONObject.Create;
  LJSONObject.AddPair('codigo_comanda', ACodigoComanda);
  LJSONObject.AddPair('codigo_nova_comanda', ACodigoNovaComanda);
  LJSONObject.AddPair('codigo_funcionario', ACodigoFuncionario);
  LJSONObject.AddPair('nome_funcionario', ANomeFuncionario);
  LJSONObject.AddPair('item_venda', '0');

  LResponse := TRequest.New.BaseURL(LBaseURL).Resource(LContexto + '/alterarComanda.php').AddHeader('Connection', 'Close')
{$IFDEF IOS}
    .AddHeader('Accept-Encoding', 'identity')
{$ENDIF}
    .Accept('application/json').AddBody(LJSONObject).Timeout(0).Post;

  try
    if LResponse.StatusCode <> 200 then
      raise Exception.Create(LResponse.Content);
  finally
    LResponse := nil;
  end;
end;

procedure TDM.alterarComandaMTItensPHP(ACodigoFuncionario: string; ANomeFuncionario: string;
  ACodigoComanda, ACodigoNovaComanda, ACodigoItem: string);
var
  LResponse: IResponse;
  LBaseURL: string;
  LContexto: string;
  LJSONObject: TJSONObject;

begin
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndLower;

  LBaseURL := TVariaveis.GetInstancia.BaseURL;
  LContexto := 'php-' + TVariaveis.GetInstancia.Contexto;

  LJSONObject := TJSONObject.Create;
  LJSONObject.AddPair('codigo_comanda', ACodigoComanda);
  LJSONObject.AddPair('codigo_nova_comanda', ACodigoNovaComanda);
  LJSONObject.AddPair('item_venda', ACodigoItem);
  LJSONObject.AddPair('codigo_funcionario', ACodigoFuncionario);
  LJSONObject.AddPair('nome_funcionario', ANomeFuncionario);

  LResponse := TRequest.New.BaseURL(LBaseURL).Resource(LContexto + '/alterarComanda.php').AddHeader('Connection', 'Close')
  {$IFDEF IOS}
    .AddHeader('Accept-Encoding', 'identity')
  {$ENDIF}
    .Accept('application/json').AddBody(LJSONObject).Timeout(0).Post;

  try
    if LResponse.StatusCode <> 200 then
      raise Exception.Create(LResponse.Content);
  finally
    LResponse := nil;
  end;
end;

procedure TDM.alterarMesaMTComandasPHP(ANomeFuncionario: string; ACodigoComanda: string; ACodigoNovaMesa: string);
var
  LResponse: IResponse;
  LBaseURL: string;
  LContexto: string;
  LJSONObject: TJSONObject;

begin
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndNone;

  LBaseURL := TVariaveis.GetInstancia.BaseURL;
  LContexto := 'php-' + TVariaveis.GetInstancia.Contexto;

  LJSONObject := TJSONObject.Create;
  LJSONObject.AddPair('codigo_comanda', ACodigoComanda);
  LJSONObject.AddPair('codigo_nova_mesa', ACodigoNovaMesa);
  LJSONObject.AddPair('nome_funcionario', ANomeFuncionario);

  LResponse := TRequest.New.BaseURL(LBaseURL).Resource(LContexto + '/alterarMesa.php').AddHeader('Connection', 'Close')
  {$IFDEF IOS}
    .AddHeader('Accept-Encoding', 'identity')
  {$ENDIF}
    .Accept('application/json').AddBody(LJSONObject).Timeout(0).Post;

  try
    if LResponse.StatusCode <> 200 then
      raise Exception.Create(LResponse.Content);
  finally
    LResponse := nil;
  end;
end;

procedure TDM.alterarObservacaoMTItensPHP(ANomeFuncionario: string; ACodigoComanda: string; ACodigoItem: string;
  AObservacaoItem: string);
var
  LResponse: IResponse;
  LBaseURL: string;
  LContexto: string;
  LJSONObject: TJSONObject;
  LJSONObject2: TJSONObject;
  LMensagem: string;

begin
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndNone;

  LBaseURL := TVariaveis.GetInstancia.BaseURL;
  LContexto := 'php-' + TVariaveis.GetInstancia.Contexto;

  LJSONObject := TJSONObject.Create;
  LJSONObject.AddPair('codigo_comanda', ACodigoComanda);
  LJSONObject.AddPair('item_venda', ACodigoItem);
  LJSONObject.AddPair('nome_funcionario', ANomeFuncionario);
  LJSONObject.AddPair('observacao_item', AObservacaoItem);

  LResponse := TRequest.New.BaseURL(LBaseURL).Resource(LContexto + '/alterarObservacao.php').AddHeader('Connection', 'Close')
  {$IFDEF IOS}
    .AddHeader('Accept-Encoding', 'identity')
  {$ENDIF}
    .Accept('application/json').AddBody(LJSONObject).Timeout(0).Post;

  try
    if LResponse.StatusCode <> 200 then
      raise Exception.Create(LResponse.Content);

    LJSONObject2 := TJSONObject.Create;
    try
      LJSONObject2.Parse(BytesOf(LResponse.Content), 0);
      LMensagem := LJSONObject2.GetValue<string>('msg');

      if LMensagem <> '' then
        raise Exception.Create(LMensagem);
    finally
      LJSONObject2.Free;
    end;
  finally
    LResponse := nil;
  end;
end;

procedure TDM.atualizarTabelas;
var
  LConsultaProduto: string;

begin
  LConsultaProduto := EmptyStr;

  DM.servidorMTFuncionariosPHP;
  DM.servidorMTProdutosPHP(LConsultaProduto);
  DM.servidorMTEmpresasPHP;
end;

function TDM.consultarBloqueioPHP(ACodigoComanda: string): string;
var
  LResponse: IResponse;
  LBaseURL: string;
  LContexto: string;
  LJSONObject: TJSONObject;
  LJSONObject2: TJSONObject;

begin
  Result := '';

  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndNone;

  LBaseURL := TVariaveis.GetInstancia.BaseURL;
  LContexto := 'php-' + TVariaveis.GetInstancia.Contexto;

  LJSONObject := TJSONObject.Create;
  LJSONObject.AddPair('codigo_comanda', ACodigoComanda);

  LResponse := TRequest.New.BaseURL(LBaseURL).Resource(LContexto + '/lerBloqueio.php').AddHeader('Connection', 'Close')
  {$IFDEF IOS}
    .AddHeader('Accept-Encoding', 'identity')
  {$ENDIF}
    .Accept('application/json').AddBody(LJSONObject).Timeout(0).Post;

  try
    if LResponse.StatusCode <> 200 then
      raise Exception.Create(LResponse.Content);

    LJSONObject2 := TJSONObject.Create;
    try
      LJSONObject2.Parse(BytesOf(LResponse.Content), 0);
      Result := LJSONObject2.GetValue<string>('bloqueio');
    finally
      LJSONObject2.Free;
    end;
  finally
    LResponse := nil;
  end;
end;

function TDM.consultarMesaPHP(ACodigoComanda: string): string;
var
  LResponse: IResponse;
  LBaseURL: string;
  LContexto: string;
  LJSONObject: TJSONObject;
  LJSONObject2: TJSONObject;

begin
  Result := '';

  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndNone;

  LBaseURL := TVariaveis.GetInstancia.BaseURL;
  LContexto := 'php-' + TVariaveis.GetInstancia.Contexto;

  LJSONObject := TJSONObject.Create;
  LJSONObject.AddPair('codigo_comanda', ACodigoComanda);

  LResponse := TRequest.New.BaseURL(LBaseURL).Resource(LContexto + '/lerMesa.php').AddHeader('Connection', 'Close')
  {$IFDEF IOS}
    .AddHeader('Accept-Encoding', 'identity')
  {$ENDIF}
    .Accept('application/json').AddBody(LJSONObject).Timeout(0).Post;

  try
    if LResponse.StatusCode <> 200 then
      raise Exception.Create(LResponse.Content);

    LJSONObject2 := TJSONObject.Create;
    try
      LJSONObject2.Parse(BytesOf(LResponse.Content), 0);
      Result := LJSONObject2.GetValue<string>('mesa');
    finally
      LJSONObject2.Free;
    end;
  finally
    LResponse := nil;
  end;
end;

function TDM.consultarTagPHP(ACodigoComanda: string): string;
var
  LResponse: IResponse;
  LBaseURL: string;
  LContexto: string;
  LJSONObject: TJSONObject;
  LJSONObject2: TJSONObject;

begin
  Result := '';

  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndNone;

  LBaseURL := TVariaveis.GetInstancia.BaseURL;
  LContexto := 'php-' + TVariaveis.GetInstancia.Contexto;

  LJSONObject := TJSONObject.Create;
  LJSONObject.AddPair('codigo_comanda', ACodigoComanda);

  LResponse := TRequest.New.BaseURL(LBaseURL).Resource(LContexto + '/lerTag.php').AddHeader('Connection', 'Close')
  {$IFDEF IOS}
    .AddHeader('Accept-Encoding', 'identity')
  {$ENDIF}
    .Accept('application/json').AddBody(LJSONObject).Timeout(0).Post;

  try
    if LResponse.StatusCode <> 200 then
      raise Exception.Create(LResponse.Content);

    LJSONObject2 := TJSONObject.Create;
    try
      LJSONObject2.Parse(BytesOf(LResponse.Content), 0);
      Result := LJSONObject2.GetValue<string>('tag');
    finally
      LJSONObject2.Free;
    end;
  finally
    LResponse := nil;
  end;
end;

procedure TDM.Criar;
var
  qr: TFDQuery;

begin
  qr := TFDQuery.Create(nil);
  try
    with qr do
    begin
      Connection := FDConnection;

      try
        Close;
        SQL.Clear;
        SQL.Add('select name');
        SQL.Add(' from sqlite_master');
        SQL.Add(' where type="table"');
        SQL.Add(' and name like "configuracao"');
        Open;

        if RecordCount = 0 then
        begin
          Close;
          SQL.Clear;
          SQL.Add('create table if not exists configuracao (');
          SQL.Add(' servidor text not null,');
          SQL.Add(' porta integer not null,');
          SQL.Add(' contexto text not null,');
          SQL.Add(' protocolo text not null,');
          SQL.Add(' teclado text not null,');
          SQL.Add(' digitoverificador text not null,');
          SQL.Add(' excluiritemcomanda text not null,');
          SQL.Add(' primary key (servidor))');
          ExecSQL;
        end;
      except
      end;

      try
        Close;
        SQL.Clear;
        SQL.Add('alter table configuracao add column excluiritemcomanda text not null');
        ExecSQL;
      except
      end;
    end;
  finally
    qr.Close;
    qr.Free;
  end;
end;

procedure TDM.DataModuleCreate(Sender: TObject);
var
  LBasedados: string;

begin
  with FDConnection do
  begin
    Params.Values['DriverID'] := 'SQLite';
    LoginPrompt := False;
{$IFDEF ANDROID}
    LBasedados := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, 'PedidosDB.s3db');
{$ENDIF}
{$IFDEF IOS}
    LBasedados := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, 'PedidosDB.s3db');
{$ENDIF}
{$IFDEF MSWINDOWS}
    if FileExists('PedidosDB.s3db') then
      LBasedados := 'PedidosDB.s3db'
    else
      LBasedados := 'C:\developer\basedados-sqlite\PedidosDB.s3db';
{$ENDIF}
    Params.Values['DataBase'] := LBasedados;
    Connected := True;
  end;

  with mtComandas do
  begin
    FieldDefs.Clear;
    FieldDefs.Add('codigo_empresa', TFieldType.ftInteger);
    FieldDefs.Add('codigo_venda', TFieldType.ftInteger);
    FieldDefs.Add('codigo_comanda', TFieldType.ftInteger);
    FieldDefs.Add('codigo_mesa', TFieldType.ftInteger);
    FieldDefs.Add('codigo_tag', TFieldType.ftInteger);
    FieldDefs.Add('data_hora', TFieldType.ftString, 40);
    FieldDefs.Add('bloqueio', TFieldType.ftInteger);
    FieldDefs.Add('codigo_funcionario', TFieldType.ftInteger);
    FieldDefs.Add('nome_funcionario', TFieldType.ftString, 40);
    FieldDefs.Add('valor_total', TFieldType.ftFloat);

    Open;
  end;

  with mtItens do
  begin
    FieldDefs.Clear;
    FieldDefs.Add('codigo_empresa', TFieldType.ftInteger);
    FieldDefs.Add('codigo_venda', TFieldType.ftInteger);
    FieldDefs.Add('codigo_comanda', TFieldType.ftInteger);
    FieldDefs.Add('codigo_mesa', TFieldType.ftInteger);
    FieldDefs.Add('codigo_tag', TFieldType.ftInteger);
    FieldDefs.Add('data_hora', TFieldType.ftString, 40);
    FieldDefs.Add('codigo_funcionario', TFieldType.ftInteger);
    FieldDefs.Add('nome_funcionario', TFieldType.ftString, 40);
    FieldDefs.Add('item_venda', TFieldType.ftInteger);
    FieldDefs.Add('codigo_produto', TFieldType.ftInteger);
    FieldDefs.Add('codigo_barra', TFieldType.ftString, 13);
    FieldDefs.Add('codigo_reduzido', TFieldType.ftInteger);
    FieldDefs.Add('descricao_produto', TFieldType.ftString, 40);
    FieldDefs.Add('qtde_produto', TFieldType.ftFloat);
    FieldDefs.Add('valor_unitario', TFieldType.ftFloat);
    FieldDefs.Add('valor_desconto', TFieldType.ftFloat);
    FieldDefs.Add('valor_total', TFieldType.ftFloat);
    FieldDefs.Add('observacao_item', TFieldType.ftString, 255);

    Open;
  end;

  with mtProdutos do
  begin
    FieldDefs.Clear;
    FieldDefs.Add('codigo_produto', TFieldType.ftInteger);
    FieldDefs.Add('codigo_reduzido', TFieldType.ftInteger);
    FieldDefs.Add('codigo_barra', TFieldType.ftString, 13);
    FieldDefs.Add('descricao_produto', TFieldType.ftString, 40);
    FieldDefs.Add('grupo_produto', TFieldType.ftInteger);
    FieldDefs.Add('valor_unitario', TFieldType.ftFloat);
    FieldDefs.Add('unidade_produto', TFieldType.ftString, 2);

    Open;
  end;

  with mtAcompanhamentos do
  begin
    FieldDefs.Clear;
    FieldDefs.Add('codigo_produto', TFieldType.ftInteger);
    FieldDefs.Add('codigo_reduzido', TFieldType.ftInteger);
    FieldDefs.Add('codigo_barra', TFieldType.ftString, 13);
    FieldDefs.Add('descricao_produto', TFieldType.ftString, 40);
    FieldDefs.Add('grupo_produto', TFieldType.ftInteger);
    FieldDefs.Add('valor_unitario', TFieldType.ftFloat);
    FieldDefs.Add('unidade_produto', TFieldType.ftString, 2);
    FieldDefs.Add('quantidade_produto', TFieldType.ftFloat);
    FieldDefs.Add('quantidade_acompanhamento', TFieldType.ftInteger);

    Open;
  end;

  with mtAdicionais do
  begin
    FieldDefs.Clear;
    FieldDefs.Add('codigo_produto', TFieldType.ftInteger);
    FieldDefs.Add('codigo_reduzido', TFieldType.ftInteger);
    FieldDefs.Add('codigo_barra', TFieldType.ftString, 13);
    FieldDefs.Add('descricao_produto', TFieldType.ftString, 40);
    FieldDefs.Add('grupo_produto', TFieldType.ftInteger);
    FieldDefs.Add('valor_unitario', TFieldType.ftFloat);
    FieldDefs.Add('unidade_produto', TFieldType.ftString, 2);
    FieldDefs.Add('quantidade_produto', TFieldType.ftFloat);
    FieldDefs.Add('quantidade_acompanhamento', TFieldType.ftInteger);

    Open;
  end;

  with mtPedidos do
  begin
    FieldDefs.Clear;
    FieldDefs.Add('codigo_comanda', TFieldType.ftInteger);

    Open;
  end;

  Criar;
end;

procedure TDM.DataModuleDestroy(Sender: TObject);
begin
  FecharTudo;
end;

procedure TDM.excluirMTComandasPHP(ACodigoFuncionario: string; ANomeFuncionario: string; ACodigoComanda: string);
var
  LResponse: IResponse;
  LBaseURL: string;
  LContexto: string;
  LJSONObject: TJSONObject;

begin
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndNone;

  LBaseURL := TVariaveis.GetInstancia.BaseURL;
  LContexto := 'php-' + TVariaveis.GetInstancia.Contexto;

  LJSONObject := TJSONObject.Create;
  LJSONObject.AddPair('codigo_comanda', ACodigoComanda);
  LJSONObject.AddPair('codigo_funcionario', ACodigoFuncionario);
  LJSONObject.AddPair('nome_funcionario', ANomeFuncionario);
  LJSONObject.AddPair('item_venda', '0');

  LResponse := TRequest.New.BaseURL(LBaseURL).Resource(LContexto + '/excluirComanda.php').AddHeader('Connection', 'Close')
  {$IFDEF IOS}
    .AddHeader('Accept-Encoding', 'identity')
  {$ENDIF}
    .Accept('application/json').AddBody(LJSONObject).Timeout(0).Post;

  try
    if LResponse.StatusCode <> 200 then
      raise Exception.Create(LResponse.Content);
  finally
    LResponse := nil;
  end;
end;

procedure TDM.excluirMTItensPHP(ACodigoFuncionario: string; ANomeFuncionario: string; ACodigoComanda: string;
  ACodigoItem: string);
var
  LResponse: IResponse;
  LBaseURL: string;
  LContexto: string;
  LJSONObject: TJSONObject;

begin
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndNone;

  LBaseURL := TVariaveis.GetInstancia.BaseURL;
  LContexto := 'php-' + TVariaveis.GetInstancia.Contexto;

  LJSONObject := TJSONObject.Create;

  LJSONObject.AddPair('codigo_comanda', ACodigoComanda);
  LJSONObject.AddPair('item_venda', ACodigoItem);
  LJSONObject.AddPair('codigo_funcionario', ACodigoFuncionario);
  LJSONObject.AddPair('nome_funcionario', ANomeFuncionario);

  LResponse := TRequest.New.BaseURL(LBaseURL).Resource(LContexto + '/excluirComanda.php').AddHeader('Connection', 'Close')
  {$IFDEF IOS}
    .AddHeader('Accept-Encoding', 'identity')
  {$ENDIF}
    .Accept('application/json').AddBody(LJSONObject).Timeout(0).Post;

  try
    if LResponse.StatusCode <> 200 then
      raise Exception.Create(LResponse.Content);
  finally
    LResponse := nil;
  end;
end;

procedure TDM.FecharTudo;
var i: Integer;
begin
  // 1) Feche datasets/queries/memtables
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TFDDataSet then
      TFDDataSet(Components[i]).Close;

  // 2) Feche conexões (se houver)
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TFDConnection then
      if TFDConnection(Components[i]).Connected then
        TFDConnection(Components[i]).Close;

  // 3) Feche o Manager por último (opcional, mas limpa registries)
  FDManager.Close;
end;

function TDM.filtrarMTFuncionarios(AConsultaFuncionario: string): boolean;
// var
// LFiltro: string;

begin
  Result := False;

  try
    if not(AConsultaFuncionario.IsEmpty) then
    begin
      Result := DM.mtFuncionarios.Locate('codigo_funcionario', AConsultaFuncionario, [])

      { LFiltro := '(codigo_funcionario = ' + QuotedStr(AConsultaFuncionario) + ')';

        DM.mtFuncionarios.Filtered := False;
        DM.mtFuncionarios.Filter := LFiltro;
        DM.mtFuncionarios.Filtered := True; }
    end
    else
      DM.mtFuncionarios.First;

    // DM.mtFuncionarios.Filtered := False;
  except
  end;
end;

function TDM.filtrarMTProdutos(AConsultaProduto: string; AConsultaEmDescricaoTambem: boolean): boolean;
var
  LFiltro: string;

begin
  Result := False;

  DM.mtProdutos.Filtered := False;
  // DM.mtProdutos.Filter := LFiltro;
  // DM.mtProdutos.Filtered := True;
  DM.mtProdutos.First;

  try
    if not AConsultaEmDescricaoTambem then
    begin
      if (testaNumero(AConsultaProduto)) then
      begin
        if (AConsultaProduto.Length > 7) then
          Result := DM.mtProdutos.Locate('codigo_barra', AConsultaProduto, [])
        else if (AConsultaProduto.Length < 6) then
          Result := DM.mtProdutos.Locate('codigo_reduzido', AConsultaProduto, [])
        else
          Result := DM.mtProdutos.Locate('codigo_produto', AConsultaProduto, []);
      end;
    end
    else
    begin
      if (testaNumero(AConsultaProduto)) then
        LFiltro := '(codigo_produto = ' + QuotedStr(AConsultaProduto) + ')' + ' or (codigo_barra = ' +
          QuotedStr(AConsultaProduto) + ')' + ' or (codigo_reduzido = ' + QuotedStr(AConsultaProduto) + ')';

      if not(LFiltro.IsEmpty) and (AConsultaEmDescricaoTambem) then
        LFiltro := LFiltro + ' or (descricao_produto like ''%' + AConsultaProduto + '%'')'
      else if (AConsultaEmDescricaoTambem) then
        LFiltro := '(descricao_produto like ''%' + AConsultaProduto + '%'')';

      DM.mtProdutos.Filtered := False;
      DM.mtProdutos.Filter := LFiltro;
      DM.mtProdutos.Filtered := True;
      DM.mtProdutos.First;
    end;
  except
  end;
end;

procedure TDM.Gravar;
var
  qr: TFDQuery;

begin
  qr := TFDQuery.Create(nil);
  try
    with qr do
    begin
      Connection := FDConnection;
      Close;
      SQL.Clear;
      SQL.Add('delete from configuracao');
      ExecSQL;

      Close;
      SQL.Clear;
      SQL.Add('replace into configuracao ');
      SQL.Add(' (servidor,porta,contexto,protocolo,teclado,digitoverificador,excluiritemcomanda)');
      SQL.Add(' values');
      SQL.Add(' (:servidor,:porta,:contexto,:protocolo,:teclado,:digitoverificador,:excluiritemcomanda)');
      ParamByName('servidor').AsString := TVariaveis.GetInstancia.ServidorREST;
      ParamByName('porta').AsInteger := TVariaveis.GetInstancia.PortaREST;
      ParamByName('contexto').AsString := TVariaveis.GetInstancia.Contexto;
      ParamByName('protocolo').AsString := TVariaveis.GetInstancia.ProtocoloREST;

      if TVariaveis.GetInstancia.TecladoFisicoAtivado then
        ParamByName('teclado').AsString := 'on'
      else
        ParamByName('teclado').AsString := 'off';

      if TVariaveis.GetInstancia.ComandaComDigitoVerificador then
        ParamByName('digitoverificador').AsString := 'on'
      else
        ParamByName('digitoverificador').AsString := 'off';

      if TVariaveis.GetInstancia.ExcluirItemOuComanda then
        ParamByName('excluiritemcomanda').AsString := 'on'
      else
        ParamByName('excluiritemcomanda').AsString := 'off';

      ExecSQL;
    end;
  finally
    qr.Close;
    qr.Free;
  end;
end;

procedure TDM.imprimirMTComandaPHP(ANomeFuncionario: string; ACodigoComanda: string);
var
  LResponse: IResponse;
  LBaseURL: string;
  LContexto: string;
  LJSONObject: TJSONObject;

begin
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndNone;

  LBaseURL := TVariaveis.GetInstancia.BaseURL;
  LContexto := 'php-' + TVariaveis.GetInstancia.Contexto;

  LJSONObject := TJSONObject.Create;
  LJSONObject.AddPair('codigo_comanda', ACodigoComanda);
  LJSONObject.AddPair('nome_funcionario', ANomeFuncionario);

  LResponse := TRequest.New.BaseURL(LBaseURL).Resource(LContexto + '/imprimirComanda.php').AddHeader('Connection', 'Close')
  {$IFDEF IOS}
    .AddHeader('Accept-Encoding', 'identity')
  {$ENDIF}
    .Accept('application/json').AddBody(LJSONObject).Timeout(0).Post;

  try
    if LResponse.StatusCode <> 200 then
      raise Exception.Create(LResponse.Content);
  finally
    LResponse := nil;
  end;
end;

procedure TDM.inserirMTItensPHP(ACodigoFuncionario: string; ANomeFuncionario: string; ACodigoComanda: string;
  ACodigoMesa: string; ACodigoTag: string; ACodigoProduto: string; ACodigoBarra: string; ACodigoReduzido: string; ADescricaoProduto: string;
  AQuantidadeItem: string; AValorUnitario: double; AObservacaoItem: string);
var
  LResponse: IResponse;
  LBaseURL: string;
  LContexto: string;
  LJSONObject: string;

begin
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndNone;

  LBaseURL := TVariaveis.GetInstancia.BaseURL;
  LContexto := 'php-' + TVariaveis.GetInstancia.Contexto;

  mtItens.Open;
  mtItens.EmptyDataSet;

  {mtItens.Open;
  if (mtItens.RecordCount > 0) then
  begin
    mtItens.First;
    while not mtItens.Eof do
    begin
      try
        mtItens.Delete;
      finally
        mtItens.Next;
      end;
    end;
  end;}

  with mtItens do
  begin
    Open;
    Append;
    FieldByName('codigo_empresa').AsString := '0'; // vai usar a origem do php
    FieldByName('codigo_venda').AsInteger := 0;
    FieldByName('codigo_comanda').AsString := ACodigoComanda;
    FieldByName('codigo_mesa').AsString := ACodigoMesa;
    FieldByName('codigo_tag').AsString := ACodigoTag;
    FieldByName('data_hora').AsString := EmptyStr;
    FieldByName('codigo_funcionario').AsString := ACodigoFuncionario;
    FieldByName('nome_funcionario').AsString := ANomeFuncionario;
    FieldByName('item_venda').AsInteger := 0;
    FieldByName('codigo_produto').AsString := ACodigoProduto;
    FieldByName('codigo_barra').AsString := ACodigoBarra;
    FieldByName('codigo_reduzido').AsString := ACodigoReduzido;
    FieldByName('descricao_produto').AsString := ADescricaoProduto;

    AQuantidadeItem := StringReplace(AQuantidadeItem, '.', '', [rfReplaceAll]);
    FieldByName('qtde_produto').AsFloat := StrToFloat(AQuantidadeItem);

    FieldByName('valor_unitario').AsFloat := AValorUnitario;
    FieldByName('valor_desconto').AsFloat := 0;
    FieldByName('valor_total').AsFloat := StrToFloat(AQuantidadeItem) * AValorUnitario;
    FieldByName('observacao_item').AsString := AObservacaoItem;
    Post;

    LJSONObject := ToJSONObjectString(True);
  end;

  LResponse := TRequest.New.BaseURL(LBaseURL).Resource(LContexto + '/incluirItem.php').AddHeader('Connection', 'Close')
  {$IFDEF IOS}
    .AddHeader('Accept-Encoding', 'identity')
  {$ENDIF}
    .Accept('application/json').AddBody(LJSONObject).Timeout(0).Post;

  try
    if LResponse.StatusCode <> 200 then
      raise Exception.Create(LResponse.Content);
  finally
    LResponse := nil;
  end;
end;

procedure TDM.Ler;
var
  qr: TFDQuery;

begin
  TVariaveis.GetInstancia.ServidorREST := 'sem ip';
  TVariaveis.GetInstancia.PortaREST := 80;
  TVariaveis.GetInstancia.Contexto := 'pedido.teste';
  TVariaveis.GetInstancia.ProtocoloREST := 'http';
  TVariaveis.GetInstancia.TecladoFisicoAtivado := False;
  TVariaveis.GetInstancia.ComandaComDigitoVerificador := False;
  TVariaveis.GetInstancia.ExcluirItemOuComanda := False;

  qr := TFDQuery.Create(nil);
  try
    with qr do
    begin
      Connection := FDConnection;
      Close;
      SQL.Clear;
      SQL.Add('select *');
      SQL.Add(' from configuracao');
      SQL.Add(' limit 1');
      Open;

      if RecordCount > 0 then
      begin
        TVariaveis.GetInstancia.ServidorREST := FieldByName('servidor').AsString;
        TVariaveis.GetInstancia.PortaREST := FieldByName('porta').AsInteger;
        TVariaveis.GetInstancia.Contexto := FieldByName('contexto').AsString;
        TVariaveis.GetInstancia.ProtocoloREST := FieldByName('protocolo').AsString;

        try
          if FieldByName('teclado').AsString = 'on' then
            TVariaveis.GetInstancia.TecladoFisicoAtivado := True
          else
            TVariaveis.GetInstancia.TecladoFisicoAtivado := False;
        except
          TVariaveis.GetInstancia.TecladoFisicoAtivado := False;
        end;

        try
          if FieldByName('digitoverificador').AsString = 'on' then
            TVariaveis.GetInstancia.ComandaComDigitoVerificador := True
          else
            TVariaveis.GetInstancia.ComandaComDigitoVerificador := False;
        except
          TVariaveis.GetInstancia.ComandaComDigitoVerificador := False;
        end;

        try
          if FieldByName('excluiritemcomanda').AsString = 'on' then
            TVariaveis.GetInstancia.ExcluirItemOuComanda := True
          else
            TVariaveis.GetInstancia.ExcluirItemOuComanda := False;
        except
          TVariaveis.GetInstancia.ExcluirItemOuComanda := False;
        end;
      end;
    end;
  finally
    qr.Close;
    qr.Free;
  end;
end;

procedure TDM.limparFiltroProduto;
begin
  DM.mtProdutos.Filtered := False;
  DM.mtProdutos.Filter := '';
  DM.mtProdutos.Filtered := True;
  DM.mtProdutos.First;
end;

{function TDM.Login(ABaseURL: string; ABody: TJSONObject): string;
var
  LResponse: IResponse;
  LJSONObject: TJSONObject;

begin
  Result := '';

  if (Pos('sem ip', ABaseURL) > 0) then
  begin
    raise Exception.Create('Configure o endereço do servidor!');
  end;

  LResponse := TRequest.New.BaseURL(ABaseURL).Resource('cgi-bin/servidor.exe/v1.0/login').Accept('application/json')
    .AddHeader('Connection', 'Close').AddBody(ABody.ToJSON).Post;

  LJSONObject := TJSONObject.Create;
  try
    if LResponse.StatusCode = 200 then
    begin
      LJSONObject.Parse(BytesOf(LResponse.Content), 0);
      Result := LJSONObject.GetValue<string>('mytoken');
    end
    else
    begin
      LJSONObject.Parse(BytesOf(LResponse.Content), 0);
      raise Exception.Create('Erro: ' + LJSONObject.GetValue('code').ToString + ' - ' + LJSONObject.GetValue('error').ToString);
    end;
  finally
    LJSONObject.Free;
  end;
end;}

procedure TDM.alterarPedidoEntreguePHP(ACodigoComanda: string; ANomeFuncionario: string);
var
  LResponse: IResponse;
  LBaseURL: string;
  LContexto: string;
  LJSONObject: TJSONObject;

begin
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndNone;

  LBaseURL := TVariaveis.GetInstancia.BaseURL;
  LContexto := 'php-' + TVariaveis.GetInstancia.Contexto;

  LJSONObject := TJSONObject.Create;
  LJSONObject.AddPair('codigo_comanda', ACodigoComanda);
  LJSONObject.AddPair('nome_funcionario', ANomeFuncionario);

  LResponse := TRequest.New.BaseURL(LBaseURL).Resource(LContexto + '/lerPedidoEntregue.php').AddHeader('Connection', 'Close')
  {$IFDEF IOS}
    .AddHeader('Accept-Encoding', 'identity')
  {$ENDIF}
    .AddBody(LJSONObject).Accept('application/json').Timeout(0).Post;

  try
    if LResponse.StatusCode <> 200 then
      raise Exception.Create(LResponse.Content);
  finally
    LResponse := nil;
  end;
end;

procedure TDM.alterarPedidoProntoPHP(ACodigoComanda: string; ANomeFuncionario: string);
var
  LResponse: IResponse;
  LBaseURL: string;
  LContexto: string;
  LJSONObject: TJSONObject;

begin
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndNone;

  LBaseURL := TVariaveis.GetInstancia.BaseURL;
  LContexto := 'php-' + TVariaveis.GetInstancia.Contexto;

  LJSONObject := TJSONObject.Create;
  LJSONObject.AddPair('codigo_comanda', ACodigoComanda);
  LJSONObject.AddPair('nome_funcionario', ANomeFuncionario);

  LResponse := TRequest.New.BaseURL(LBaseURL).Resource(LContexto + '/lerPedidoPronto.php').AddHeader('Connection', 'Close')
{$IFDEF IOS}
    .AddHeader('Accept-Encoding', 'identity')
{$ENDIF}
    .AddBody(LJSONObject).Accept('application/json').Timeout(0).Post;

  try
    if LResponse.StatusCode <> 200 then
      raise Exception.Create(LResponse.Content);
  finally
    LResponse := nil;
  end;
end;

procedure TDM.servidorMTAcompanhamentosPHP(AConsultaProduto: string);
var
  LResponse: IResponse;
  LBaseURL: string;
  LContexto: string;
  LJSONObject: TJSONObject;

begin
  //mtAcompanhamentos.EmptyDataSet;

  FormatSettings.DecimalSeparator := '.';
  FormatSettings.ThousandSeparator := ',';

  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndNone;

  LBaseURL := TVariaveis.GetInstancia.BaseURL;
  LContexto := 'php-' + TVariaveis.GetInstancia.Contexto;

  try
    LJSONObject := TJSONObject.Create;
    LJSONObject.AddPair('consulta_produto', AConsultaProduto);

    LResponse := TRequest.New.BaseURL(LBaseURL).Resource(LContexto + '/lerAcompanhamentos.php').AddHeader('Connection', 'Close')
    {$IFDEF IOS}
      .AddHeader('Accept-Encoding', 'identity')
    {$ENDIF}
      .AddBody(LJSONObject).Accept('application/json').DataSetAdapter(mtAcompanhamentos).Timeout(0).Post;

    try
      FormatSettings.DecimalSeparator := ',';
      FormatSettings.ThousandSeparator := '.';
    finally
      LResponse := nil;
    end;
  except
  end;
end;

procedure TDM.servidorMTAdicionaisPHP(AConsultaProduto: string);
var
  LResponse: IResponse;
  LBaseURL: string;
  LContexto: string;
  LJSONObject: TJSONObject;

begin
  //mtAdicionais.EmptyDataSet;

  FormatSettings.DecimalSeparator := '.';
  FormatSettings.ThousandSeparator := ',';

  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndNone;

  LBaseURL := TVariaveis.GetInstancia.BaseURL;
  LContexto := 'php-' + TVariaveis.GetInstancia.Contexto;

  try
    LJSONObject := TJSONObject.Create;
    LJSONObject.AddPair('consulta_produto', AConsultaProduto);

    LResponse := TRequest.New.BaseURL(LBaseURL).Resource(LContexto + '/lerAdicionais.php').AddHeader('Connection', 'Close')
    {$IFDEF IOS}
      .AddHeader('Accept-Encoding', 'identity')
    {$ENDIF}
      .AddBody(LJSONObject).Accept('application/json').DataSetAdapter(mtAdicionais).Timeout(0).Post;

    try
      FormatSettings.DecimalSeparator := ',';
      FormatSettings.ThousandSeparator := '.';
    finally
      LResponse := nil;
    end;
  except
  end;
end;

procedure TDM.servidorMTComandasPHP(ACodigoComanda: string);
var
  LResponse: IResponse;
  LBaseURL: string;
  LContexto: string;
  LJSONObject: TJSONObject;

begin
  FormatSettings.DecimalSeparator := '.';
  FormatSettings.ThousandSeparator := ',';

  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndNone;

  LBaseURL := TVariaveis.GetInstancia.BaseURL;
  LContexto := 'php-' + TVariaveis.GetInstancia.Contexto;

  LJSONObject := TJSONObject.Create;
  LJSONObject.AddPair('codigo_comanda', ACodigoComanda);

  LResponse := TRequest.New.BaseURL(LBaseURL).Resource(LContexto + '/lerComandas.php').AddHeader('Connection', 'Close')
  {$IFDEF IOS}
    .AddHeader('Accept-Encoding', 'identity')
  {$ENDIF}
    .AddBody(LJSONObject).Accept('application/json').DataSetAdapter(mtComandas).Timeout(0).Post;

  try
    FormatSettings.DecimalSeparator := ',';
    FormatSettings.ThousandSeparator := '.';

    if LResponse.StatusCode <> 200 then
      raise Exception.Create(LResponse.Content);
  finally
    LResponse := nil;
  end;
end;

procedure TDM.servidorMTEmpresasPHP;
var
  LResponse: IResponse;
  LBaseURL: string;
  LContexto: string;

begin
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndLower;

  LBaseURL := TVariaveis.GetInstancia.BaseURL;
  LContexto := 'php-' + TVariaveis.GetInstancia.Contexto;

  LResponse := TRequest.New.BaseURL(LBaseURL).Resource(LContexto + '/lerEmpresas.php').AddHeader('Connection', 'Close')
  {$IFDEF IOS}
    .AddHeader('Accept-Encoding', 'identity')
  {$ENDIF}
    .Accept('application/json').DataSetAdapter(mtEmpresas).Timeout(0).Post;

  try
    if LResponse.StatusCode <> 200 then
      raise Exception.Create(LResponse.Content);
  finally
    LResponse := nil;
  end;
end;

procedure TDM.servidorMTFuncionariosPHP;
var
  LResponse: IResponse;
  LBaseURL: string;
  LContexto: string;

begin
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndNone;

  LBaseURL := TVariaveis.GetInstancia.BaseURL;
  LContexto := 'php-' + TVariaveis.GetInstancia.Contexto;

  LResponse := TRequest.New.BaseURL(LBaseURL).Resource(LContexto + '/lerFuncionarios.php').AddHeader('Connection', 'Close')
  {$IFDEF IOS}
    .AddHeader('Accept-Encoding', 'identity')
  {$ENDIF}
    .Accept('application/json').DataSetAdapter(mtFuncionarios).Timeout(0).Post;

  try
  if LResponse.StatusCode <> 200 then
    raise Exception.Create(LResponse.Content);
  finally
    LResponse := nil;
  end;
end;

procedure TDM.servidorMTItensPHP(ACodigoComanda: string);
var
  LResponse: IResponse;
  LBaseURL: string;
  LContexto: string;
  LJSONObject: TJSONObject;

begin
  FormatSettings.DecimalSeparator := '.';
  FormatSettings.ThousandSeparator := ',';

  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndNone;

  LBaseURL := TVariaveis.GetInstancia.BaseURL;
  LContexto := 'php-' + TVariaveis.GetInstancia.Contexto;

  LJSONObject := TJSONObject.Create;
  LJSONObject.AddPair('codigo_comanda', ACodigoComanda);

  LResponse := TRequest.New.BaseURL(LBaseURL).Resource(LContexto + '/lerItens.php').AddHeader('Connection', 'Close')
  {$IFDEF IOS}
    .AddHeader('Accept-Encoding', 'identity')
  {$ENDIF}
    .AddBody(LJSONObject).Accept('application/json').DataSetAdapter(mtItens).Timeout(0).Post;

  try
    FormatSettings.DecimalSeparator := ',';
    FormatSettings.ThousandSeparator := '.';

    if LResponse.StatusCode <> 200 then
      raise Exception.Create(LResponse.Content);
  finally
    LResponse := nil;
  end;
end;

procedure TDM.servidorMTPedidosPHP(ATipoPedido: string);
var
  LResponse: IResponse;
  LBaseURL: string;
  LContexto: string;
  LJSONObject: TJSONObject;

begin
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndNone;

  LBaseURL := TVariaveis.GetInstancia.BaseURL;
  LContexto := 'php-' + TVariaveis.GetInstancia.Contexto;

  LJSONObject := TJSONObject.Create;
  LJSONObject.AddPair('tipo_pedido', ATipoPedido);

  LResponse := TRequest.New.BaseURL(LBaseURL).Resource(LContexto + '/lerPedidos.php').AddHeader('Connection', 'Close')
{$IFDEF IOS}
    .AddHeader('Accept-Encoding', 'identity')
{$ENDIF}
    .AddBody(LJSONObject).Accept('application/json').DataSetAdapter(mtPedidos).Timeout(0).Post;

  try
    if LResponse.StatusCode <> 200 then
      raise Exception.Create(LResponse.Content);
  finally
    LResponse := nil;
  end;
end;

procedure TDM.servidorMTProdutosPHP(AConsultaProduto: string);
var
  LResponse: IResponse;
  LBaseURL: string;
  LContexto: string;
  LJSONObject: TJSONObject;

begin
  FormatSettings.DecimalSeparator := '.';
  FormatSettings.ThousandSeparator := ',';

  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndNone;

  LBaseURL := TVariaveis.GetInstancia.BaseURL;
  LContexto := 'php-' + TVariaveis.GetInstancia.Contexto;

  LJSONObject := TJSONObject.Create;
  LJSONObject.AddPair('consulta_produto', AConsultaProduto);

  LResponse := TRequest.New.BaseURL(LBaseURL).Resource(LContexto + '/lerProdutos.php').AddHeader('Connection', 'Close')
{$IFDEF IOS}
    .AddHeader('Accept-Encoding', 'identity')
{$ENDIF}
    .AddBody(LJSONObject).Accept('application/json').DataSetAdapter(mtProdutos).Timeout(0).Post;

  try
    FormatSettings.DecimalSeparator := ',';
    FormatSettings.ThousandSeparator := '.';

    if LResponse.StatusCode <> 200 then
      raise Exception.Create(LResponse.Content);
  finally
    LResponse := nil;
  end;
end;

procedure TDM.servidorMTSenhasPHP(ASenha: string);
var
  LResponse: IResponse;
  LBaseURL: string;
  LContexto: string;
  LJSONObject: TJSONObject;

begin
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndNone;

  LBaseURL := TVariaveis.GetInstancia.BaseURL;
  LContexto := 'php-' + TVariaveis.GetInstancia.Contexto;

  LJSONObject := TJSONObject.Create;
  LJSONObject.AddPair('senha', ASenha);

  LResponse := TRequest.New.BaseURL(LBaseURL).Resource(LContexto + '/lerSenhas.php').AddHeader('Connection', 'Close')
{$IFDEF IOS}
    .AddHeader('Accept-Encoding', 'identity')
{$ENDIF}
    .AddBody(LJSONObject).Accept('application/json').DataSetAdapter(mtSenhas).Timeout(0).Post;

  try
    if LResponse.StatusCode <> 200 then
      raise Exception.Create(LResponse.Content);
  finally
    LResponse := nil;
  end;
end;

function TDM.versaoApp(AURL: string): string;
var
  LResponse: IResponse;
  LBaseURL: string;
  LJSONObject: TJSONObject;

begin
  Result := '0';

  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndNone;

  LBaseURL := 'http://mysaas.com.br';

  LResponse := TRequest.New.BaseURL(LBaseURL).Resource('cgi-bin/servidor.exe/v2.0/versao').AddHeader('Connection', 'Close')
{$IFDEF IOS}
    .AddHeader('Accept-Encoding', 'identity')
{$ENDIF}
    .AddParam('url', AURL).Accept('application/json').Timeout(0).Get;

  try
    if LResponse.StatusCode <> 200 then
      raise Exception.Create(LResponse.Content)
    else
    begin
      LJSONObject := TJSONObject.Create;
      try
        LJSONObject.Parse(BytesOf(LResponse.Content), 0);
        Result := LJSONObject.GetValue<string>('versao');
      finally
        LJSONObject.DisposeOf;
      end;
    end;
  finally
    LResponse := nil;
  end;
end;

end.
