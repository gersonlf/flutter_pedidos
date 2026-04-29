unit Form.Produto;

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
  TFormProduto = class(TForm)
    LayoutBase: TLayout;
    RectangleMenu: TRectangle;
    LabelMenu: TLabel;
    ImageVoltar: TImage;
    ListView: TListView;
    procedure ListViewUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
  private
    { Private declarations }
    procedure inserirItemListView;
    procedure atualizarItemListView(AItem: TListViewItem; AInserindo: Boolean);
  public
    { Public declarations }
    FConsultaProduto: string;
    FPesquisarEmDescricaoTambem: boolean;
    FPodeExecutar: Boolean;

    procedure ajustaForm(ACarregar: Boolean);
    procedure carregaLista;
    procedure insereLista;
  end;

var
  FormProduto: TFormProduto;

implementation

{$R *.fmx}
{ TFormProduto }

procedure TFormProduto.ajustaForm(ACarregar: Boolean);
begin
  TVariaveis.GetInstancia.TelaAnterior := TVariaveis.GetInstancia.TelaAtiva;
  TVariaveis.GetInstancia.TelaAtiva := 'TFormProduto';

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

procedure TFormProduto.atualizarItemListView(AItem: TListViewItem; AInserindo: Boolean);
var
  txt: TListItemText;
  X: integer;
  Y: integer;

begin
  with AItem do
  begin
    X := 5;
    Y := 10;

    txt := TListItemText(Objects.FindDrawable('Text1'));
    with txt do
    begin
      Text := 'Produto';
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

    Y := trunc(txt.PlaceOffset.Y + txt.Height + 1);

    txt := TListItemText(Objects.FindDrawable('Text2'));
    with txt do
    begin
      if AInserindo then
        Text := DM.mtProdutos.FieldByName('descricaoProduto').AsString;
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Leading;

      Font.Size := 18;
      Width := Trunc(Application.MainForm.Width-10);
      Height := 50;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 1;
    end;

    Y := trunc(txt.PlaceOffset.Y + txt.Height + 10);

    txt := TListItemText(Objects.FindDrawable('Text3'));
    with txt do
    begin
      Text := 'Codigo';
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Trailing;

      Font.Size := 10;
      Width := Trunc((Application.MainForm.Width-10)/3);
      Height := 10;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 0.7;
    end;

    txt := TListItemText(Objects.FindDrawable('Text4'));
    with txt do
    begin
      Text := 'Barra';
      Align := TListItemAlign.Trailing;
      TextAlign := TTextAlign.Trailing;
      TextVertAlign := TTextAlign.Trailing;

      Font.Size := 10;
      Width := Trunc((Application.MainForm.Width-10)/3);
      Height := 10;

      PlaceOffset.X := 0;
      PlaceOffset.Y := Y;
      Opacity := 0.7;
    end;

    txt := TListItemText(Objects.FindDrawable('Text5'));
    with txt do
    begin
      Text := 'Reduzido';
      Align := TListItemAlign.Center;
      TextAlign := TTextAlign.Center;
      TextVertAlign := TTextAlign.Trailing;

      Font.Size := 10;
      Width := Trunc((Application.MainForm.Width-10)/3);
      Height := 10;

      PlaceOffset.X := -5;
      PlaceOffset.Y := Y;
      Opacity := 0.7;
    end;

    Y := trunc(txt.PlaceOffset.Y + txt.Height + 1);

    txt := TListItemText(Objects.FindDrawable('Text6'));
    with txt do
    begin
      if AInserindo then
        Text := DM.mtProdutos.FieldByName('codigoProduto').AsString;
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Leading;
      TextColor := $FF27408B;

      Font.Size := 18;
      Width := Trunc((Application.MainForm.Width-10)/3);
      Height := 20;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 1;
    end;

    txt := TListItemText(Objects.FindDrawable('Text7'));
    with txt do
    begin
      if AInserindo and (DM.mtProdutos.FieldByName('codigoBarra').AsString <> '0000000000000') then
        Text := DM.mtProdutos.FieldByName('codigoBarra').AsString;
      Align := TListItemAlign.Trailing;
      TextAlign := TTextAlign.Trailing;
      TextVertAlign := TTextAlign.Leading;
      TextColor := $FF27408B;

      Font.Size := 18;
      Width := Trunc((Application.MainForm.Width-10)/3);
      Height := 20;

      PlaceOffset.X := 0;
      PlaceOffset.Y := Y;
      Opacity := 1;
    end;

    txt := TListItemText(Objects.FindDrawable('Text8'));
    with txt do
    begin
      if AInserindo and (DM.mtProdutos.FieldByName('codigoReduzido').AsInteger > 0) then
        Text := DM.mtProdutos.FieldByName('codigoReduzido').AsString;
      Align := TListItemAlign.Center;
      TextAlign := TTextAlign.Center;
      TextVertAlign := TTextAlign.Leading;
      TextColor := $FF27408B;

      Font.Size := 18;
      Width := Trunc((Application.MainForm.Width-10)/3);
      Height := 20;

      PlaceOffset.X := -5;
      PlaceOffset.Y := Y;
      Opacity := 1;
    end;

    Y := trunc(txt.PlaceOffset.Y + txt.Height + 10);

    txt := TListItemText(Objects.FindDrawable('Text9'));
    with txt do
    begin
      Text := 'Preço';
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Trailing;

      Font.Size := 10;
      Width := Trunc((Application.MainForm.Width-10)/3);
      Height := 10;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 0.7;
    end;

    Y := trunc(txt.PlaceOffset.Y + txt.Height + 1);

    txt := TListItemText(Objects.FindDrawable('Text10'));
    with txt do
    begin
      if AInserindo then
        Text := formataFloatStr(DM.mtProdutos.FieldByName('valorUnitario').AsFloat);
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Leading;
      TextColor := $FFFF3030;

      Font.Size := 18;
      Width := Trunc((Application.MainForm.Width-10)/3);
      Height := 20;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 0.7;
    end;

    //invisivel
    txt := TListItemText(Objects.FindDrawable('Text11'));
    with txt do
    begin
      if AInserindo then
        Text := DM.mtProdutos.FieldByName('unidadeProduto').AsString;;
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Leading;
      TextColor := $FFFF3030;

      Font.Size := 18;
      Width := Trunc((Application.MainForm.Width-10)/3);
      Height := 20;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 0.7;
      Visible := False;
    end;

    Y := trunc(txt.PlaceOffset.Y + txt.Height + 10);
    Height := Y;
  end;
end;

procedure TFormProduto.carregaLista;
begin
  DM.filtrarMTProdutos(FConsultaProduto, FPesquisarEmDescricaoTambem);
end;

procedure TFormProduto.insereLista;
begin
  ListView.BeginUpdate;
  with DM.mtProdutos do
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

procedure TFormProduto.inserirItemListView;
var
  LItem: TListViewItem;

begin
  LItem := ListView.Items.Add;
  LItem.TagString := DM.mtProdutos.FieldByName('descricaoProduto').AsString;
  LItem.Tag := DM.mtProdutos.FieldByName('codigoProduto').AsInteger;

  atualizarItemListView(LItem, True);
end;

procedure TFormProduto.ListViewUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
begin
  atualizarItemListView(AItem, False);
end;

end.
