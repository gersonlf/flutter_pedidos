unit Controller.Login;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,

  Service.Login,
  Singleton.Variaveis;

type
  TControllerLogin = class

  private

  public
    procedure Login;
  end;

implementation

{ TControllerLogin }

procedure TControllerLogin.Login;
var
  LService: TServiceLogin;
  LBody: TJSONObject;
  LBaseURL: string;
  LContexto: string;

begin
  LService := TServiceLogin.Create(nil);
  try
    LContexto := TVariaveis.GetInstancia.Contexto;
    LBaseURL := TVariaveis.GetInstancia.BaseURL;
    LBody := TJSONObject.Create;
    try
      LBody.AddPair('usuario', LContexto);
      LBody.AddPair('senha', 'mysoftsistemas');
      TVariaveis.GetInstancia.Token := LService.Login(LBaseURL, LBody);
    finally
      LBody.DisposeOf;
    end;
  finally
    LService.DisposeOf;
  end;
end;

end.
