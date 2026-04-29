unit View.Mensagem;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Layouts;

type
  TViewMensagem = class(TForm)
    Layout: TLayout;
    Rectangle: TRectangle;
    LabelMensagem: TLabel;
    RoundRectOK: TRoundRect;
    LabelOK: TLabel;
    procedure RoundRectOKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ViewMensagem: TViewMensagem;

implementation
uses
  View.Menu;

{$R *.fmx}

procedure TViewMensagem.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
end;

procedure TViewMensagem.FormCreate(Sender: TObject);
begin
{$IFDEF MSWINDOWS}
//  ViewMensagem.Width := 800;
//  ViewMensagem.Height := 600;
//  ViewMensagem.Top := ViewMenu.Top;
//  ViewMensagem.Left := ViewMenu.Left;

  ViewMensagem.WindowState := TWindowState.wsMaximized;
{$ENDIF}
end;

procedure TViewMensagem.RoundRectOKClick(Sender: TObject);
begin
  Close;
end;

end.
