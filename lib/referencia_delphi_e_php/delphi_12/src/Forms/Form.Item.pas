unit Form.Item;

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
  TFormItem = class(TForm)
    LayoutBase: TLayout;
    RectangleMenu: TRectangle;
    LabelMenu: TLabel;
    ImageVoltar: TImage;
    ImageNovoItem: TImage;
    RectangleFuncionario: TRectangle;
    LabelFuncionario: TLabel;
    RectangleCabecalho: TRectangle;
    LabelComanda: TLabel;
    LabelValor: TLabel;
    ListView: TListView;
    ImageMaisOpcoes: TImage;
    procedure ListViewUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FValorTotal: double;
    FQtdeItens: integer;

    procedure inserirItemListView;
    procedure atualizarItemListView(AItem: TListViewItem; AInserindo: Boolean);

  public
    { Public declarations }
    FPodeExecutar: Boolean;

    procedure ajustaForm(ACarregar: Boolean);
    procedure carregaLista;
    procedure insereLista;
  end;

var
  FormItem: TFormItem;

implementation

{$R *.fmx}
{ TFormItem }

procedure TFormItem.ajustaForm(ACarregar: Boolean);
begin
  TVariaveis.GetInstancia.TelaAnterior := TVariaveis.GetInstancia.TelaAtiva;
  TVariaveis.GetInstancia.TelaAtiva := 'TFormItem';

  if TVariaveis.GetInstancia.CodigoFuncionario > 0 then
    LabelFuncionario.Text := TVariaveis.GetInstancia.NomeFuncionario;

  if TVariaveis.GetInstancia.CodigoComanda > 0 then
    LabelComanda.Text := 'Cmd: ' + IntToStr(TVariaveis.GetInstancia.CodigoComanda);

  if (TVariaveis.GetInstancia.CodigoMesa > 0) then
    LabelComanda.Text := LabelComanda.Text + ' - M: ' +
      IntToStr(TVariaveis.GetInstancia.CodigoMesa);

  FValorTotal := 0;
  FQtdeItens := 0;
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

procedure TFormItem.atualizarItemListView(AItem: TListViewItem; AInserindo: Boolean);
var
  txt: TListItemText;
  img: TListItemImage;
  X: integer;
  Y: integer;

begin
  with AItem do
  begin
    X := 5;

    txt := TListItemText(Objects.FindDrawable('Text1'));
    with txt do
    begin
      Text := 'Qtde';
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Trailing;
      Font.Size := 10;
      Width := Trunc((Application.MainForm.Width-10)/3);
      Height := 10;
      PlaceOffset.X := X;
      PlaceOffset.Y := 10;
      Opacity := 0.7;
    end;

    txt := TListItemText(Objects.FindDrawable('Text2'));
    with txt do
    begin
      Text := 'Total R$';
      Align := TListItemAlign.Trailing;
      TextAlign := TTextAlign.Trailing;
      TextVertAlign := TTextAlign.Trailing;
      Font.Size := 10;
      Width := Trunc((Application.MainForm.Width-10)/3);
      Height := 10;
      PlaceOffset.X := X;
      PlaceOffset.Y := 10;
      Opacity := 0.7;
    end;

    txt := TListItemText(Objects.FindDrawable('Text3'));
    with txt do
    begin
      Text := 'Unitario R$';
      Align := TListItemAlign.Center;
      TextAlign := TTextAlign.Center;
      TextVertAlign := TTextAlign.Trailing;
      Font.Size := 10;
      Width := Trunc((Application.MainForm.Width-10)/3);
      Height := 10;
      PlaceOffset.X := X;
      PlaceOffset.Y := 10;
      Opacity := 0.7;
    end;

    Y := trunc(txt.PlaceOffset.Y + txt.Height + 1);

    txt := TListItemText(Objects.FindDrawable('Text4'));
    with txt do
    begin
      if AInserindo then
        Text := formataFloatStr(DM.mtItens.FieldByName('qtdeProduto').AsFloat);
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Trailing;
      TextColor := $FF27408B;
      Font.Size := 18;
      Width := Trunc((Application.MainForm.Width-10)/3);
      Height := 20;
      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 1;
    end;

    txt := TListItemText(Objects.FindDrawable('Text5'));
    with txt do
    begin
      if AInserindo then
        Text := formataFloatStr(DM.mtItens.FieldByName('valorUnitario').AsFloat *
          DM.mtItens.FieldByName('qtdeProduto').AsFloat);
      Align := TListItemAlign.Trailing;
      TextAlign := TTextAlign.Trailing;
      TextVertAlign := TTextAlign.Trailing;
      TextColor := $FF27408B;

      Font.Size := 18;
      Width := Trunc((Application.MainForm.Width-10)/3);
      Height := 20;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 1;
    end;

    txt := TListItemText(Objects.FindDrawable('Text6'));
    with txt do
    begin
      if AInserindo then
        Text := formataFloatStr(DM.mtItens.FieldByName('valorUnitario').AsFloat);
      Align := TListItemAlign.Center;
      TextAlign := TTextAlign.Center;
      TextVertAlign := TTextAlign.Trailing;
      TextColor := $FF27408B;

      Font.Size := 18;
      Width := Trunc((Application.MainForm.Width-10)/3);
      Height := 20;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 1;
    end;

    Y := trunc(txt.PlaceOffset.Y + txt.Height + 10);

    txt := TListItemText(Objects.FindDrawable('Text7'));
    with txt do
    begin
      Text := 'Produto';
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

    txt := TListItemText(Objects.FindDrawable('Text8'));
    with txt do
    begin
      Text := 'Barra';
      Align := TListItemAlign.Trailing;
      TextAlign := TTextAlign.Trailing;
      TextVertAlign := TTextAlign.Trailing;
      Font.Size := 10;
      Width := Trunc((Application.MainForm.Width-10)/3);
      Height := 10;
      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 0.7;
    end;

    txt := TListItemText(Objects.FindDrawable('Text9'));
    with txt do
    begin
      Text := 'Reduzido';
      Align := TListItemAlign.Center;
      TextAlign := TTextAlign.Center;
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
        Text := DM.mtItens.FieldByName('codigoProduto').AsString;
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Trailing;
      TextColor := $FF27408B;

      Font.Size := 18;
      Width := Trunc((Application.MainForm.Width-10)/3);
      Height := 20;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 1;
    end;

    txt := TListItemText(Objects.FindDrawable('Text11'));
    with txt do
    begin
      if AInserindo and (DM.mtItens.FieldByName('codigoBarra').AsString <> '0000000000000') then
        Text := DM.mtItens.FieldByName('codigoBarra').AsString;
      Align := TListItemAlign.Trailing;
      TextAlign := TTextAlign.Trailing;
      TextVertAlign := TTextAlign.Trailing;
      TextColor := $FF27408B;

      Font.Size := 18;
      Width := Trunc((Application.MainForm.Width-10)/3);
      Height := 20;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 1;
    end;

    txt := TListItemText(Objects.FindDrawable('Text12'));
    with txt do
    begin
      if AInserindo and (DM.mtItens.FieldByName('codigoReduzido').AsInteger > 0) then
        Text := DM.mtItens.FieldByName('codigoReduzido').AsString;
      Align := TListItemAlign.Center;
      TextAlign := TTextAlign.Center;
      TextVertAlign := TTextAlign.Trailing;
      TextColor := $FF27408B;

      Font.Size := 18;
      Width := Trunc((Application.MainForm.Width-10)/3);
      Height := 20;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 1;
    end;

    Y := trunc(txt.PlaceOffset.Y + txt.Height + 10);

    txt := TListItemText(Objects.FindDrawable('Text13'));
    with txt do
    begin
      Text := 'Descrição';
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

    txt := TListItemText(Objects.FindDrawable('Text14'));
    with txt do
    begin
      if AInserindo then
        Text := DM.mtItens.FieldByName('descricaoProduto').AsString;
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Leading;

      Font.Size := 18;
      Width := Trunc(Application.MainForm.Width-10);
      Height := 50;

       PlaceOffset.X := X;
       PlaceOffset.Y := Y;
       Opacity := 1;
       WordWrap := True;
       Trimming := TTextTrimming.None;
    end;

    Y := trunc(txt.PlaceOffset.Y + txt.Height + 10);

    txt := TListItemText(Objects.FindDrawable('Text15'));
    with txt do
    begin
      Text := 'Observação';
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

    txt := TListItemText(Objects.FindDrawable('Text16'));
    with txt do
    begin
      if AInserindo and not(DM.mtItens.FieldByName('observacaoItem').AsString.IsEmpty) then
        Text := DM.mtItens.FieldByName('observacaoItem').AsString;
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Trailing;

      Font.Size := 12;
      Width := Trunc(Application.MainForm.Width-10);
      Height := 16;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 1;
      Trimming := TTextTrimming.None;
    end;

    Y := trunc(txt.PlaceOffset.Y + txt.Height + 10);

    txt := TListItemText(Objects.FindDrawable('Text17'));
    with txt do
    begin
      Text := 'Funcionário';
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

    txt := TListItemText(Objects.FindDrawable('Text18'));
    with txt do
    begin
      if AInserindo then
        Text := DM.mtItens.FieldByName('nomeFuncionario').AsString;
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Trailing;

      Font.Size := 12;
      Width := Trunc(Application.MainForm.Width-10);
      Height := 16;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 1;
      WordWrap := True;
      Trimming := TTextTrimming.None;
    end;

    Y := trunc(txt.PlaceOffset.Y + txt.Height + 1);

    txt := TListItemText(Objects.FindDrawable('Text19'));
    with txt do
    begin
      if AInserindo then
        Text := DM.mtItens.FieldByName('dataHora').AsString;;
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Trailing;
      TextColor := $FFFF3030;

      Font.Size := 12;
      Width := Trunc(Application.MainForm.Width-10);
      Height := 16;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 0.7;
    end;

    Y := trunc(txt.PlaceOffset.Y + txt.Height + 10);

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

procedure TFormItem.carregaLista;
begin
  // DM.servidorMTItens(TVariaveis.GetInstancia.CodigoComanda,
  // TVariaveis.GetInstancia.CodigoEmpresa, FPagina);
end;

procedure TFormItem.FormCreate(Sender: TObject);
begin
  ImageMaisOpcoes.Visible := False;
end;

procedure TFormItem.insereLista;
begin
  ListView.BeginUpdate;
  with DM.mtItens do
  begin
    if not(IsEmpty) then
    begin
      First;

      while not Eof do
      begin
        try
          FValorTotal := FValorTotal + FieldByName('valorTotal').AsFloat;
          FQtdeItens := FQtdeItens + 1;

          inserirItemListView;
        finally
          Next;
        end;
      end;
    end;
  end;
  ListView.EndUpdate;

  LabelValor.Text := 'R$ ' + formataFloatStr(FValorTotal) + ' - Qtde: ' + FQtdeItens.ToString;
end;

procedure TFormItem.inserirItemListView;
var
  LItem: TListViewItem;

begin
  LItem := ListView.Items.Add;
  LItem.Tag := DM.mtItens.FieldByName('itemVenda').AsInteger;

  atualizarItemListView(LItem, True);
end;

procedure TFormItem.ListViewUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
begin
  atualizarItemListView(AItem, False);
end;

end.
