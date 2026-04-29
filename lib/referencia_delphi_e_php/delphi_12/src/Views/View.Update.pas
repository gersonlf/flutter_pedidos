{$WARN SYMBOL_DEPRECATED OFF}
unit View.Update;

interface

uses
  System.SysUtils, System.Types,
  System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls,
  FMX.Forms, FMX.Graphics,
  FMX.Dialogs,
  FMX.Controls.Presentation,
  FMX.Layouts,
  FMX.StdCtrls,
  FMX.Objects,
  System.Json,

  Util.OpenViewURL,
  Util.Funcao,
  View.Menu;

type
  TViewUpdate = class(TForm)
    LabelVersao: TLabel;
    RectangleUpdate: TRectangle;
    LabelTitulo: TLabel;
    ImageFundo: TImage;
    Layout1: TLayout;
    ImageSeta: TImage;
    LabelTexto: TLabel;
    Layout2: TLayout;
    Layout3: TLayout;
    RectangleBotao: TRectangle;
    SpeedButtonUpdate: TSpeedButton;
    SpeedButtonVoltar: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure SpeedButtonUpdateMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
      X, Y: Single);
    procedure SpeedButtonUpdateClick(Sender: TObject);
    procedure SpeedButtonUpdateMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
      X, Y: Single);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SpeedButtonVoltarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    FURL: string;
    FVersaoApp: string;
    FVersaoServidor: string;
    FPlataforma: string;

    { Public declarations }
  end;

var
  ViewUpdate: TViewUpdate;

implementation

{$R *.fmx}

procedure TViewUpdate.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
end;

procedure TViewUpdate.FormCreate(Sender: TObject);
begin
{$IFDEF MSWINDOWS}
  ViewUpdate.WindowState := TWindowState.wsMaximized;
{$ENDIF}
end;

procedure TViewUpdate.SpeedButtonUpdateClick(Sender: TObject);
begin
  OpenURL(FURL, false);
end;

procedure TViewUpdate.SpeedButtonUpdateMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  desligaOpacity(Sender);
end;

procedure TViewUpdate.SpeedButtonUpdateMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  ligaOpacity(Sender);
end;

procedure TViewUpdate.SpeedButtonVoltarClick(Sender: TObject);
begin
  if NOT Assigned(ViewMenu) then
    Application.CreateForm(TViewMenu, ViewMenu);

  Application.MainForm := ViewMenu;
  ViewMenu.FVersaoApp := FVersaoApp;
  ViewMenu.FPlataforma := FPlataforma;
  ViewMenu.Show;
  ViewUpdate.Close;
end;

procedure TViewUpdate.FormShow(Sender: TObject);
begin
  if FVersaoApp <> FVersaoServidor then
  begin
    RectangleUpdate.Visible := true;
    ImageSeta.Position.Y := 0;
    ImageSeta.Opacity := 0;
    LabelTitulo.Opacity := 0;
    LabelTexto.Opacity := 0;
    RectangleBotao.Opacity := 0;

    RectangleUpdate.BringToFront;
    RectangleUpdate.AnimateFloat('Margins.Top', 0, 0.8, TAnimationType.InOut,
      TInterpolationType.Circular);

    ImageSeta.AnimateFloatDelay('Position.Y', 50, 0.5, 1, TAnimationType.Out,
      TInterpolationType.Back);
    ImageSeta.AnimateFloatDelay('Opacity', 1, 0.4, 0.9);

    LabelTitulo.AnimateFloatDelay('Opacity', 1, 0.7, 1.3);
    LabelTexto.AnimateFloatDelay('Opacity', 1, 0.7, 1.6);
    RectangleBotao.AnimateFloatDelay('Opacity', 1, 0.7, 1.9);
  end;
end;

end.
