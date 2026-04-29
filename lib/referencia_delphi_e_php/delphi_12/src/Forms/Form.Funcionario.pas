unit Form.Funcionario;

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
  TFormFuncionario = class(TForm)
    LayoutBase: TLayout;
    RectangleMenu: TRectangle;
    LabelMenu: TLabel;
    ImageMenu: TImage;
    ListView: TListView;
    procedure ListViewUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
  private
    { Private declarations }
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
  FormFuncionario: TFormFuncionario;

implementation

{$R *.fmx}
{ TFormFuncionario }

procedure TFormFuncionario.ajustaForm(ACarregar: Boolean);
begin
  TVariaveis.GetInstancia.TelaAnterior := TVariaveis.GetInstancia.TelaAtiva;
  TVariaveis.GetInstancia.TelaAtiva := 'TFormFuncionario';

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

procedure TFormFuncionario.atualizarItemListView(AItem: TListViewItem; AInserindo: Boolean);
var
  LListItemText: TListItemText;
  Y: integer;
  X: integer;

begin
  with AItem do
  begin
    X := 5;
    Y := 10;

    // cabecalho
    LListItemText := TListItemText(Objects.FindDrawable('Text1'));
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

    // item
    LListItemText := TListItemText(Objects.FindDrawable('Text2'));
    with LListItemText do
    begin
      if AInserindo then
        Text := DM.mtFuncionarios.FieldByName('nomeFuncionario').AsString;
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

    Y := trunc(LListItemText.PlaceOffset.Y + LListItemText.Height + 10);

    // cabecalho
    LListItemText := TListItemText(Objects.FindDrawable('Text3'));
    with LListItemText do
    begin
      Text := 'Código';
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

    // item
    LListItemText := TListItemText(Objects.FindDrawable('Text4'));
    with LListItemText do
    begin
      if AInserindo then
        Text := DM.mtFuncionarios.FieldByName('codigoFuncionario').AsString;
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Leading;
      TextColor := $FF27408B;

      Font.Size := 18;
      Width := Trunc(Application.MainForm.Width-10);
      Height := 20;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 1;
    end;

    Y := trunc(LListItemText.PlaceOffset.Y + LListItemText.Height + 10);
    Height := Y;
  end;
end;

procedure TFormFuncionario.carregaLista;
begin
  DM.filtrarMTFuncionarios('');
end;

procedure TFormFuncionario.insereLista;
begin
  ListView.BeginUpdate;
  with DM.mtFuncionarios do
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

procedure TFormFuncionario.inserirItemListView;
var
  LItem: TListViewItem;

begin
  LItem := ListView.Items.Add;
  LItem.Tag := DM.mtFuncionarios.FieldByName('codigoFuncionario').AsInteger;

  atualizarItemListView(LItem, True);
end;

procedure TFormFuncionario.ListViewUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
begin
  atualizarItemListView(AItem, False);
end;

end.
