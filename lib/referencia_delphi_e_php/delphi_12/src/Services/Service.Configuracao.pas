unit Service.Configuracao;

interface

uses
  System.SysUtils,
  System.Classes,

  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  FireDAC.Stan.Async,
  FireDAC.DApt,
  FireDAC.UI.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Phys,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs,
  FireDAC.FMXUI.Wait,
  FireDAC.Comp.UI,

  Data.DB,

  System.IOUtils,
  System.UITypes,

  iniFiles,
  Util.Funcao,

  Singleton.Variaveis,

  FireDAC.Phys.SQLiteWrapper.Stat;

type
  TServiceConfiguracao = class(TDataModule)
    FDQuery: TFDQuery;
    FDConnection: TFDConnection;
    FDGUIxWaitCursor: TFDGUIxWaitCursor;
    FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink;
    FDMemTable: TFDMemTable;
    procedure DataModuleCreate(Sender: TObject);
  private
    procedure Criar;
    { Private declarations }
  public
    { Public declarations }

    procedure Ler;
    procedure Gravar;
  end;

var
  ServiceConfiguracao: TServiceConfiguracao;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}
{$R *.dfm}
{ TServiceConfiguracao }

procedure TServiceConfiguracao.Criar;
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
    FreeAndNil(qr);
  end;
end;

procedure TServiceConfiguracao.DataModuleCreate(Sender: TObject);
var
  LBasedados: string;

begin
  with FDConnection do
  begin
    Params.Values['DriverID'] := 'SQLite';
    LoginPrompt := False;
{$IFDEF ANDROID}
    LBasedados := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath,
      'PedidosDB.s3db');
{$ENDIF}
{$IFDEF IOS}
    LBasedados := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath,
      'PedidosDB.s3db');
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

  Criar;
end;

procedure TServiceConfiguracao.Gravar;
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
    qr.DisposeOf;
  end;
end;

procedure TServiceConfiguracao.Ler;
var
  qr: TFDQuery;

begin
  TVariaveis.GetInstancia.ServidorREST := 'sem ip';
  TVariaveis.GetInstancia.PortaREST := 80;
  TVariaveis.GetInstancia.Contexto := 'pedido.teste';
  TVariaveis.GetInstancia.ProtocoloREST := 'http';
  TVariaveis.GetInstancia.TecladoFisicoAtivado := False;

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
    qr.DisposeOf;
  end;
end;

end.
