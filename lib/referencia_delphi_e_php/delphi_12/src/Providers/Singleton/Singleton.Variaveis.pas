unit Singleton.Variaveis;

interface

uses
  System.SysUtils,
  System.Classes,
  System.StrUtils,
  System.Types,
  System.NetEncoding,
  EncdDecd;

type
  TVariaveis = class(TPersistent)

  strict private
    class var FInstancia: TVariaveis;
    constructor Create();

  private
    FComandaDigitoVerificador: Boolean;
    FTecladoFisicoAtivado: Boolean;

    FServidorREST: string;
    FPortaREST: integer;
    FProtocoloREST: string;

    FBaseURL: string;
    FContexto: string;
    FToken: string;

    FServidorMySQL: string;
    FPortaMySQL: integer;
    FBasedadosMySQL: string;

    //FUsuarioContexto: string;
    //FSenhaContexto: string;

    FCodigoEmpresa: integer;

    //FDataVencimentoToken: string;
    //FHoraVencimentoToken: string;

    FExcluirItemComanda: Boolean;

    //FCodigoItem: integer;
    //FCodigoNovaComanda: integer;
    //FcodigoMesa: integer;

    FWidthScreen: integer;
    FReleaseApp: integer;

    class

    procedure ReleaseInstancia;

    procedure SetComandaDigitoVerificador(const Value: Boolean);
    procedure SetTecladoFisicoAtivado(const Value: Boolean);
    //procedure SetToken(const Value: string);
    procedure SetContexto(const Value: string);
    procedure SetPortaREST(const Value: integer);
    procedure SetProtocoloREST(const Value: string);
    procedure SetServidorREST(const Value: string);

    procedure SetWidthScreen(const Value: integer);

    //procedure SetCodigoMesa(const Value: integer);
    //procedure SetCodigoItem(const Value: integer);
    //procedure SetCodigoNovaComanda(const Value: integer);
    procedure SetReleaseApp(const Value: integer);

    procedure SetExcluirItemComanda(const Value: Boolean);

  public

    class function GetInstancia(): TVariaveis;

  published

    property TecladoFisicoAtivado: Boolean read FTecladoFisicoAtivado write SetTecladoFisicoAtivado;
    property ServidorREST: string read FServidorREST write SetServidorREST;
    property PortaREST: integer read FPortaREST write SetPortaREST;
    property ProtocoloREST: string read FProtocoloREST write SetProtocoloREST;
    property BaseURL: string read FBaseURL;
    property Contexto: string read FContexto write SetContexto;
    //property Token: string read FToken write SetToken;
    property ServidorMySQL: string read FServidorMySQL;
    property PortaMySQL: integer read FPortaMySQL;
    property BasedadosMySQL: string read FBasedadosMySQL;
    //property UsuarioContexto: string read FUsuarioContexto;
    //property SenhaContexto: string read FSenhaContexto;
    //property CodigoEmpresa: integer read FCodigoEmpresa;

    //property DataVencimentoToken: string read FDataVencimentoToken;
    //property HoraVencimentoToken: string read FHoraVencimentoToken;

    property ComandaComDigitoVerificador: boolean read FComandaDigitoVerificador write SetComandaDigitoVerificador;

    property ReleaseApp: integer read FReleaseApp write SetReleaseApp;

    //property CodigoItem: integer read FCodigoItem write SetCodigoItem;
    //property CodigoNovaComanda: integer read FCodigoNovaComanda write SetCodigoNovaComanda;
    //property CodigoMesa: integer read FCodigoMesa write SetCodigoMesa;

    property WidthScreen: integer read FWidthScreen write SetWidthScreen;

    property ExcluirItemOuComanda: Boolean read FExcluirItemComanda write SetExcluirItemComanda;
  end;

implementation

{ TVariaveis }

constructor TVariaveis.Create;
begin
  FTecladoFisicoAtivado := False;
end;

class function TVariaveis.GetInstancia: TVariaveis;
begin
  if not Assigned(FInstancia)
  then
    FInstancia := TVariaveis.Create;

  Result := FInstancia;
end;

class procedure TVariaveis.ReleaseInstancia;
begin
  if Assigned(Self.FInstancia)
  then
    Self.FInstancia.Free;
end;

{procedure TVariaveis.SetCodigoItem(const Value: integer);
begin
  FCodigoItem := Value;
end;}

{procedure TVariaveis.SetCodigoMesa(const Value: integer);
begin
  FCodigoMesa := Value;
end;}

{procedure TVariaveis.SetCodigoNovaComanda(const Value: integer);
begin
  FCodigoNovaComanda := Value;
end;}

procedure TVariaveis.SetComandaDigitoVerificador(const Value: Boolean);
begin
  FComandaDigitoVerificador := Value;
end;

procedure TVariaveis.SetContexto(const Value: string);
begin
  FContexto := Value;
end;

procedure TVariaveis.SetPortaREST(const Value: integer);
begin
  FPortaREST := Value;
  FBaseURL := FProtocoloREST + '://' + FServidorREST + ':' + FPortaREST.ToString;
end;

procedure TVariaveis.SetProtocoloREST(const Value: string);
begin
  FProtocoloREST := Value;
  FBaseURL := FProtocoloREST + '://' + FServidorREST + ':' + FPortaREST.ToString;
end;

procedure TVariaveis.SetReleaseApp(const Value: integer);
begin
  FReleaseApp := Value;
end;

procedure TVariaveis.SetServidorREST(const Value: string);
begin
  FServidorREST := Value;
  FBaseURL := FProtocoloREST + '://' + FServidorREST + ':' + FPortaREST.ToString;
end;

procedure TVariaveis.SetTecladoFisicoAtivado(const Value: Boolean);
begin
  FTecladoFisicoAtivado := Value;
end;

{procedure TVariaveis.SetToken(const Value: string);
var
  LStr: TStringDynArray;
begin
  FToken := Value;
  if FToken <> ''
  then
  begin
    LStr := SplitString(DecodeString(Value), '|');
    FUsuarioContexto := LStr[0];
    FSenhaContexto := LStr[1];
    FServidorMySQL := LStr[2];
    FBasedadosMySQL := LStr[3];
    FPortaMySQL := StrToIntDef(LStr[4], 3306);
    FCodigoEmpresa := StrToIntDef(LStr[5], 0);
    FDataVencimentoToken := LStr[6];
    FHoraVencimentoToken := LStr[7];
  end;
end;}

procedure TVariaveis.SetWidthScreen(const Value: integer);
begin
  FWidthScreen := Value;
end;

procedure TVariaveis.SetExcluirItemComanda(const Value: Boolean);
begin
  FExcluirItemComanda := Value;
end;

initialization

finalization

TVariaveis.ReleaseInstancia();

end.
