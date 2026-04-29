unit Service.Login;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  DataSet.Serialize,
  RESTRequest4D;

type
  TServiceLogin = class(TDataModule)
  private
    { Private declarations }
  public
    function Login(ABaseURL: string; ABody: TJSONObject): string;
    { Public declarations }
  end;

var
  ServiceLogin: TServiceLogin;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}
{$R *.dfm}
{ TServiceLogin }

function TServiceLogin.Login(ABaseURL: string; ABody: TJSONObject): string;
var
  LResponse: IResponse;
  LJSONObject: TJSONObject;

begin
  Result := '';

  if (Pos('sem ip', ABaseURL) > 0)
  then
  begin
    raise Exception.Create('Configure o endereço do servidor!');
  end;

  LResponse := TRequest.New.BaseURL(ABaseURL).Resource('cgi-bin/servidor.exe/v1.0/login')
    .Accept('application/json')
    .AddHeader('Connection', 'Close')
    .AddBody(ABody.ToJSON)
    .Post;

  LJSONObject := TJSONObject.Create;
  try
    if LResponse.StatusCode = 200
    then
    begin
      LJSONObject.Parse(BytesOf(LResponse.Content), 0);
      Result := LJSONObject.GetValue<string>('mytoken');
    end
    else
    begin
      LJSONObject.Parse(BytesOf(LResponse.Content), 0);
      raise Exception.Create('Erro: ' + LJSONObject.GetValue('code').ToString + ' - ' +
        LJSONObject.GetValue('error').ToString);
    end;
  finally
    LJSONObject.Free;
  end;
end;

end.
