{$WARN SYMBOL_DEPRECATED OFF}
unit View.Splash;

interface

uses
  System.SysUtils, System.Types,
  System.UITypes, System.Classes,
  System.Variants, System.Threading,
  FMX.Types, FMX.Controls,
  FMX.Forms, FMX.Graphics,
  FMX.Dialogs, FMX.Objects,
{$IFDEF IOS}
  Macapi.CoreFoundation,
{$ENDIF}
{$IFDEF ANDROID}
  Androidapi.JNI.GraphicsContentViewText, Androidapi.JNIBridge, Androidapi.JNI.JavaTypes,
  FMX.Helpers.Android, Androidapi.JNI.Net, Androidapi.JNI.Os, Androidapi.Helpers,
  Androidapi.IOUtils, Androidapi.JNI.App, Androidapi.NativeActivity,
{$ENDIF}
  Service.DM,

  Util.Notificacao,
  Util.Funcao,

  View.Update,
  View.Menu;

type
  TViewSplash = class(TForm)
    Image: TImage;
    Timer: TTimer;
    procedure FormShow(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FURL: string;
    FVersaoApp: string;
    FVersaoServidor: string;
    FPlataforma: string;

    procedure onTerminateVerificaVersao(Sender: TObject);
  public
    { Public declarations }
  end;

var
  ViewSplash: TViewSplash;

implementation

{$R *.fmx}

procedure TViewSplash.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  ViewSplash := nil;
end;

procedure TViewSplash.FormCreate(Sender: TObject);
var
  LVersaoApp: string;
{$IFDEF WIN32}
  LMajor, LMinor, LBuild: cardinal;
{$ENDIF}
{$IFDEF ANDROID}
  PackageManager: JPackageManager;
  PackageInfo: JPackageInfo;
{$ENDIF}
{$IFDEF IOS}
  function GetAppVersionStr: string;
  var
    CFStr: CFStringRef;
    Range: CFRange;
  begin
    CFStr := CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle, kCFBundleVersionKey);
    Range.location := 0;
    Range.length := CFStringGetLength(CFStr);
    SetLength(Result, Range.length);
    CFStringGetCharacters(CFStr, Range, PChar(Result));
  end;
{$ENDIF}
begin
{$IFDEF ANDROID}
  PackageManager := SharedActivityContext.getPackageManager;
  PackageInfo := PackageManager.getPackageInfo(SharedActivityContext.getPackageName, 0);
  LVersaoApp := JStringToString(PackageInfo.versionName);
{$ENDIF}
{$IFDEF IOS}
  // LVersaoApp := TNSString.Wrap(CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle,
  // kCFBundleVersionKey)).UTF8String;
  LVersaoApp := GetAppVersionStr;
{$ENDIF}
{$IFDEF WIN32}
  System.SysUtils.GetProductVersion(ParamStr(0), LMajor, LMinor, LBuild);
  LVersaoApp := Concat(IntToStr(LMajor), '.', IntToStr(LMinor), '.', IntToStr(LBuild));
{$ENDIF}
{$IFDEF WIN64}
  System.SysUtils.GetProductVersion(ParamStr(0), LMajor, LMinor, LBuild);
  LVersaoApp := Concat(IntToStr(LMajor), '.', IntToStr(LMinor), '.', IntToStr(LBuild));
{$ENDIF}
  //FVersaoApp := LVersaoApp;

  FVersaoApp := '3.0.19';

{$IFDEF WIN32}
  FPlataforma := 'win32';
{$ENDIF}
{$IFDEF WIN64}
  FPlataforma := 'win64';
{$ENDIF}
{$IFDEF IOS32}
  FPlataforma := 'iOS32';
{$ENDIF}
{$IFDEF IOS64}
  FPlataforma := 'iOS64';
{$ENDIF}
{$IFDEF ANDROID32}
  FPlataforma := 'android32';
{$ENDIF}
{$IFDEF ANDROID64}
  FPlataforma := 'android64';
{$ENDIF}
{$IFDEF MSWINDOWS}
  ViewSplash.WindowState := TWindowState.wsMaximized;
{$ENDIF}

{$IFDEF VER330}
//delphi rio (10.3.3)
if FPlataforma = 'android32' then
  FURL := 'https://install.appcenter.ms/users/gerson-gvzz/apps/pedidos-android32-4.4-9.0/distribution_groups/interno'
else
  FURL := 'https://install.appcenter.ms/users/gerson-gvzz/apps/pedidos-' +
    FPlataforma + '/distribution_groups/interno';
{$ENDIF}
{$IFDEF VER340}
//delphi sidney (10.4.2)
if FPlataforma = 'android32' then
  FURL := 'https://install.appcenter.ms/users/gerson-gvzz/apps/pedidos-android32-10/distribution_groups/interno'
else
  FURL := 'https://install.appcenter.ms/users/gerson-gvzz/apps/pedidos-' +
    FPlataforma + '/distribution_groups/interno';
{$ENDIF}
{$IFDEF VER350}
//delphi alexandria (11)
if FPlataforma = 'android32' then
  FURL := 'https://install.appcenter.ms/users/gerson-gvzz/apps/pedidos-android32-10/distribution_groups/interno'
else
  FURL := 'https://install.appcenter.ms/users/gerson-gvzz/apps/pedidos-' +
    FPlataforma + '/distribution_groups/interno';
{$ENDIF}

//  FURL := 'https://install.appcenter.ms/users/gerson-gvzz/apps/pedidos-' + LPlataformaApp +
//    '/distribution_groups/interno';

  Image.Align := TAlignLayout.Center;
end;

procedure TViewSplash.FormShow(Sender: TObject);
begin
  Timer.Interval := 3000;
  Timer.Enabled := true;

  Image.Opacity := 0;
  Image.Align := TAlignLayout.None;
  Image.AnimateFloat('Opacity', 1, 0.6);
  Image.AnimateFloatDelay('Position.X', ViewSplash.Width + Image.Width + 0, 0.5, 2.5,
    TAnimationType.&In, TInterpolationType.Back);
end;

procedure TViewSplash.TimerTimer(Sender: TObject);
var
  t: TThread;

begin
  Timer.Enabled := false;
  TLoading.Show(ViewSplash, 'Aguarde, verificando atualizacao para o aplicativo...');

  t := TThread.CreateAnonymousThread(
    procedure
    begin
      //FVersaoServidor := DM.versaoApp(FURL);
      FVersaoServidor := FVersaoApp;
    end);

  t.OnTerminate := onTerminateVerificaVersao;
  t.Start;
end;

procedure TViewSplash.onTerminateVerificaVersao(Sender: TObject);
begin
  Sleep(100);
  TLoading.Hide;

  {if FVersaoServidor <> FVersaoApp then
  begin
    if NOT Assigned(ViewUpdate) then
      Application.CreateForm(TViewUpdate, ViewUpdate);

    Application.MainForm := ViewUpdate;
    ViewUpdate.FURL := FURL;
    ViewUpdate.FVersaoApp := FVersaoApp;
    ViewUpdate.FVersaoServidor := FVersaoServidor;
    ViewUpdate.FPlataforma := FPlataforma;
    ViewUpdate.Show;
    ViewSplash.Close;
  end
  else }
  begin
    if NOT Assigned(ViewMenu) then
      Application.CreateForm(TViewMenu, ViewMenu);

    Application.MainForm := ViewMenu;
    ViewMenu.FVersaoApp := FVersaoApp;
    ViewMenu.FVersaoServidor := FVersaoServidor;
    ViewMenu.FPlataforma := FPlataforma;
    ViewMenu.Show;
    ViewSplash.Close;
  end;
end;

end.
