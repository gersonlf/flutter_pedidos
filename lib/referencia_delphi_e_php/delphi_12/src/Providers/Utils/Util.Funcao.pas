unit Util.Funcao;

interface

uses
  Classes, SysUtils,

{$IFDEF ANDROID}
  Androidapi.JNI.JavaTypes,
  Androidapi.Helpers,
  FMX.Helpers.Android,
{$ENDIF}
{$IFDEF IOS}
  iOSapi.Foundation, Macapi.ObjectiveC,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Winapi.Windows,
{$ENDIF}
  FMX.Types, FMX.Controls,
  FMX.Forms,
  FMX.Dialogs, FMX.Media,
  FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.Layouts,
  FMX.Platform,
  FMX.Graphics, FMX.Surfaces,
  FMX.ListView, FMX.TextLayout,
  FMX.Consts, FMX.ListView.Types,
  FMX.Objects,
  FMX.DialogService, System.UITypes,
  System.Types;

function verificaVersao: string;
procedure ligaOpacity(Sender: TObject);
procedure desligaOpacity(Sender: TObject);
function getTextHeight(const D: TListItemText; const Width: single; const Text: string): integer;
function testaNumero(LTexto: string): boolean;
//procedure embeddForm(AParent: TControl; AForm: TCustomForm);
procedure EmbeddForm(const AParent: TControl; const AForm: TCustomForm);
function formataFloatStr2(AValor: double): string;
function formataFloatStr3(AValor: double): string;

implementation

function formataFloatStr2(AValor: double): string;
var
  formatSettings: TFormatSettings;

begin
  formatSettings.ThousandSeparator := '.';
  formatSettings.DecimalSeparator := ',';

  Result := FormatFloat('#,##0.00', AValor);
end;

function formataFloatStr3(AValor: double): string;
var
  formatSettings: TFormatSettings;

begin
  formatSettings.ThousandSeparator := '.';
  formatSettings.DecimalSeparator := ',';

  Result := FormatFloat('#,##0.000', AValor);
end;

{procedure embeddForm(AParent: TControl; AForm: TCustomForm);
begin
  //while AForm.ChildrenCount > 0 do
  //  AForm.Children[0].Parent := AParent;
end;}

procedure EmbeddForm(const AParent: TControl; const AForm: TCustomForm);
var
  i: Integer;
  Obj: TFmxObject;
  Ctl: TControl;
begin
  if (AParent = nil) or (AForm = nil) then Exit;

  AParent.BeginUpdate;
  try
    // Percorrer de trás pra frente para não bagunçar o índice
    for i := AForm.ChildrenCount - 1 downto 0 do
    begin
      Obj := AForm.Children[i];
      if Obj is TControl then
      begin
        Ctl := TControl(Obj);
        // Opcional: desligar alinhamento enquanto move
        // Ctl.Stored := Ctl.Stored; // (não muda owner)
        Ctl.Parent := AParent; // reparenta
      end;
    end;
  finally
    AParent.EndUpdate;
  end;
end;

function testaNumero(LTexto: string): boolean;
var
  i: integer;

const
  cNumber = '0123456789';
begin
  Result := True;

  for i := 1 to Length(LTexto) do
    if (Pos(Copy(LTexto, i, 1), cNumber) = 0) then
    begin
      Result := False;
      Break
    end;

  // Result := True;
  // for i := 1 to Length(LTexto) do
  // if CharInSet(LTexto[i], ['0' .. '9']) then
  // Result := True
  // else
  // Break;
end;

function verificaVersao: string;
begin
  Result := '0';
end;

procedure ligaOpacity(Sender: TObject);
var
  x: integer;

begin
  x := 1;

  if (Sender is TRectangle) then
    TRectangle(Sender).Opacity := x
  else if (Sender is TImage) then
    TImage(Sender).Opacity := x
  else if (Sender is TLayout) then
    TLayout(Sender).Opacity := x
  else if (Sender is TRoundRect) then
    TRoundRect(Sender).Opacity := x;
end;

procedure desligaOpacity(Sender: TObject);
var
  x: double;

begin
  x := 0.6;

  if (Sender is TRectangle) then
    TRectangle(Sender).Opacity := x
  else if (Sender is TImage) then
    TImage(Sender).Opacity := x
  else if (Sender is TLayout) then
    TLayout(Sender).Opacity := x
  else if (Sender is TRoundRect) then
    TRoundRect(Sender).Opacity := x;
end;

function getTextHeight(const D: TListItemText; const Width: single; const Text: string): integer;
var
  Layout: TTextLayout;
  linha: integer;

begin
  // Create a TTextLayout to measure text dimensions
  Layout := TTextLayoutManager.DefaultTextLayout.Create;
  try
    Layout.BeginUpdate;
    try
      // Initialize layout parameters with those of the drawable
      Layout.Font.Assign(D.Font);
      Layout.VerticalAlign := D.TextVertAlign;
      Layout.HorizontalAlign := D.TextAlign;
      Layout.WordWrap := False;
      Layout.Trimming := TTextTrimming.None;
      Layout.MaxSize := TPointF.Create(Width, TTextLayout.MaxLayoutSize.Y);
      Layout.Text := Trim(Text);
    finally
      Layout.EndUpdate;
    end;

    linha := Round(Layout.Height);

    Layout.BeginUpdate;
    try
      // Initialize layout parameters with those of the drawable
      Layout.Font.Assign(D.Font);
      Layout.VerticalAlign := D.TextVertAlign;
      Layout.HorizontalAlign := D.TextAlign;
      Layout.WordWrap := True;
      Layout.Trimming := D.Trimming;
      Layout.MaxSize := TPointF.Create(Width, TTextLayout.MaxLayoutSize.Y);
      Layout.Text := Trim(Text);
    finally
      Layout.EndUpdate;
    end;

    // Get layout height
    Result := Round(Layout.Height);
    // Add one em to the height
    Layout.Text := Text + 'm';
    if Result < Round(Layout.Height) then
      Result := Result + linha;
  finally
    Layout.DisposeOf;
  end;
end;

end.
