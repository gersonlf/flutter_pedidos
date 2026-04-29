unit Form.Comanda;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Layouts, FMX.TabControl,

  Data.DB,

  Util.Notificacao,
  Util.Funcao,
  Singleton.Variaveis,
  Service.DM,

  FMX.Ani;

type
  TFormComanda = class(TForm)
    LayoutBase: TLayout;
    RectangleMenu: TRectangle;
    LabelMenu: TLabel;
    ImageMenu: TImage;
    ImageNovaComanda: TImage;
    ListView: TListView;
    ImageMaisOpcoes: TImage;
    RectangleFuncionario: TRectangle;
    LabelFuncionario: TLabel;
    procedure ListViewUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure inserirItemListView;
    procedure atualizarItemListView(AItem: TListViewItem; AInserindo: Boolean);
  public
    { Public declarations }
    FConsultaNome: string;
    FPodeExecutar: Boolean;

    procedure ajustaForm(ACarregar: Boolean);
    procedure carregaLista;
    procedure insereLista;
  end;

var
  FormComanda: TFormComanda;

implementation

{$R *.fmx}
{ TFormComanda }

procedure TFormComanda.ajustaForm(ACarregar: Boolean);
begin
  TVariaveis.GetInstancia.TelaAnterior := TVariaveis.GetInstancia.TelaAtiva;
  TVariaveis.GetInstancia.TelaAtiva := 'TFormComanda';

  if TVariaveis.GetInstancia.CodigoFuncionario > 0 then
    LabelFuncionario.Text := TVariaveis.GetInstancia.NomeFuncionario;

  FPodeExecutar := False;

  if ACarregar then
  begin
    ListView.BeginUpdate;
    ListView.ScrollTo(0);
    ListView.Items.Clear;
    ListView.EndUpdate;

    carregaLista;
    insereLista;
  end;

  FPodeExecutar := True;
end;

procedure TFormComanda.atualizarItemListView(AItem: TListViewItem; AInserindo: Boolean);
var
  LListItemText: TListItemText;
  img: TListItemImage;
  X: integer;
  Y: integer;

begin
  with AItem do
  begin
    X := 5;

    LListItemText := TListItemText(Objects.FindDrawable('Text1'));
    with LListItemText do
    begin
      Text := 'Comanda';
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Trailing;

      Font.Size := 10;
      Width := Trunc((Application.MainForm.Width-10)/2);
      Height := 10;

      PlaceOffset.X := X;
      PlaceOffset.Y := 10;
      Opacity := 0.7;
    end;

    LListItemText := TListItemText(Objects.FindDrawable('Text2'));
    with LListItemText do
    begin
      if AInserindo and (DM.mtComandas.FieldByName('codigoMesa').AsInteger > 0) then
        Text := 'Mesa';
      Align := TListItemAlign.Trailing;
      TextAlign := TTextAlign.Trailing;
      TextVertAlign := TTextAlign.Trailing;

      Font.Size := 10;
      Width := Trunc((Application.MainForm.Width-10)/2);
      Height := 10;

      PlaceOffset.X := X;
      PlaceOffset.Y := 10;
      Opacity := 0.7;
    end;

    Y := trunc(LListItemText.PlaceOffset.Y + LListItemText.Height + 1);

    LListItemText := TListItemText(Objects.FindDrawable('Text3'));
    with LListItemText do
    begin
      if AInserindo then
        Text := DM.mtComandas.FieldByName('codigoComanda').AsString;
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Leading;
      TextColor := $FF27408B;

      Font.Size := 18;
      Width := Trunc((Application.MainForm.Width-10)/2);
      Height := 20;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 1;
    end;

    LListItemText := TListItemText(Objects.FindDrawable('Text4'));
    with LListItemText do
    begin
      if AInserindo and (DM.mtComandas.FieldByName('codigoMesa').AsInteger > 0) then
        Text := DM.mtComandas.FieldByName('codigoMesa').AsString;
      Align := TListItemAlign.Trailing;
      TextAlign := TTextAlign.Trailing;
      TextVertAlign := TTextAlign.Leading;
      TextColor := $FF27408B;

      Font.Size := 18;
      Width := Trunc((Application.MainForm.Width-10)/2);
      Height := 20;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 1;
    end;

    Y := trunc(LListItemText.PlaceOffset.Y + LListItemText.Height + 10);

    LListItemText := TListItemText(Objects.FindDrawable('Text5'));
    with LListItemText do
    begin
      Text := 'Funcionário';
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Trailing;

      Font.Size := 10;
      Width := Trunc((Application.MainForm.Width-10)/2);
      Height := 10;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 0.7;
    end;

    Y := trunc(LListItemText.PlaceOffset.Y + LListItemText.Height + 1);

    LListItemText := TListItemText(Objects.FindDrawable('Text6'));
    with LListItemText do
    begin
      if AInserindo then
        Text := DM.mtComandas.FieldByName('nomeFuncionario').AsString;
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Leading;

      Font.Size := 18;
      Width := Trunc((Application.MainForm.Width-10)/2);
      Height := 50;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 1;
      WordWrap := True;
      Trimming := TTextTrimming.None;
    end;

    Y := trunc(LListItemText.PlaceOffset.Y + LListItemText.Height + 10);

    LListItemText := TListItemText(Objects.FindDrawable('Text7'));
    with LListItemText do
    begin
      Text := 'Data/Hora';
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Trailing;

      Font.Size := 10;
      Width := Trunc((Application.MainForm.Width-10)/2);
      Height := 10;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 0.7;
    end;

    Y := trunc(LListItemText.PlaceOffset.Y + LListItemText.Height + 1);

    LListItemText := TListItemText(Objects.FindDrawable('Text8'));
    with LListItemText do
    begin
      if AInserindo then
        Text := DM.mtComandas.FieldByName('dataHora').AsString;
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Leading;
      TextColor := $FFFF3030;

      Font.Size := 12;
      Width := Trunc((Application.MainForm.Width-10)/2);
      Height := 16;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 0.7;
    end;

    LListItemText := TListItemText(Objects.FindDrawable('Text9'));
    with LListItemText do
    begin
      if AInserindo then
        Text := DM.mtComandas.FieldByName('bloqueio').AsString;
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Leading;
      TextColor := $FFFF3030;

      Font.Size := 12;
      Width := Trunc((Application.MainForm.Width-10)/2);
      Height := 16;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 0.7;
      Visible := False;
    end;

    Y := trunc(LListItemText.PlaceOffset.Y + LListItemText.Height + 10);

    img := TListItemImage(Objects.FindDrawable('image1'));
    img.Bitmap := ImageMaisOpcoes.Bitmap;
    with img do
    begin
      Align := TListItemAlign.Trailing;

      Width := 50;
      Height := 50;

      PlaceOffset.X := 10;
      PlaceOffset.Y := Y - 60;
      Opacity := 0.9;
    end;

    Height := Y;
  end;
end;

procedure TFormComanda.carregaLista;
begin
  // DM.servidorMTComandas(FConsultaCodigo, TVariaveis.GetInstancia.CodigoEmpresa, FPagina);
end;

procedure TFormComanda.FormCreate(Sender: TObject);
begin
  ImageMaisOpcoes.Visible := False;
end;

procedure TFormComanda.insereLista;
begin
  ListView.BeginUpdate;
  with DM.mtComandas do
  begin
    if not(IsEmpty) then
    begin
      First;

      while not Eof do
      begin
        try
          inserirItemListView;
        finally
          Next;
        end;
      end;
    end;
  end;
  ListView.EndUpdate;
end;

procedure TFormComanda.inserirItemListView;
var
  LItem: TListViewItem;

begin
  LItem := ListView.Items.Add;
  LItem.Tag := DM.mtComandas.FieldByName('codigoComanda').AsInteger;

  atualizarItemListView(LItem, True);
end;

procedure TFormComanda.ListViewUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
begin
  atualizarItemListView(AItem, False);
end;

end.
