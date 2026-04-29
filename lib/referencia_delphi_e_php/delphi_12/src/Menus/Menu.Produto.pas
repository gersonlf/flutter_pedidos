unit Menu.Produto;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.TabControl, System.Actions, FMX.ActnList,

  Service.DM,
  Singleton.Variaveis,
  Util.Funcao,

  Form.Produto,

  TecladoNumerico,
  TecladoAlfaNumerico,

  FMX.ListView.Appearances,
  FMX.ListView.Types,
  FMX.ListView,
  FMX.Ani;

type
  TMenuProduto = class(TForm)
    TabControl: TTabControl;
    TabItemBase: TTabItem;
    RectangleBase: TRectangle;
    TabItemTecladoAlfaNumerico: TTabItem;
    RectangleTecladoAlfaNumerico: TRectangle;
    TabItemTecladoNumerico: TTabItem;
    RectangleTecladoNumerico: TRectangle;
    ActionList: TActionList;
    ChangeTabActionMenu: TChangeTabAction;
    ChangeTabActionTecladoAlfaNumerico: TChangeTabAction;
    ChangeTabActionTecladoNumerico: TChangeTabAction;
    Timer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TimerTimer(Sender: TObject);
  private
    { Private declarations }
    FTelaProduto: TFormProduto;

    FTecladoAlfaNumerico: TFormTecladoAlfaNumerico;

    procedure botaoConfirmar(Sender: TObject);
    procedure botaoVoltar(Sender: TObject);

    procedure carregaViewMenu;
    procedure carregaFormProduto(AConsultaProduto: string; APesquisarEmDescricaoTambem: boolean);

    procedure resetTimer;

    procedure tecladoAlfaNumericoProduto(AExecutar: boolean);
  public
    { Public declarations }
    procedure ajustaForm;
  end;

var
  MenuProduto: TMenuProduto;

implementation

{$R *.fmx}

uses
  View.Menu;

procedure TMenuProduto.ajustaForm;
begin
  TVariaveis.GetInstancia.TelaAnterior := TVariaveis.GetInstancia.TelaAtiva;
  TVariaveis.GetInstancia.TelaAtiva := 'TMenuProduto';
end;

procedure TMenuProduto.botaoConfirmar(Sender: TObject);
begin
  resetTimer;

  if (TVariaveis.GetInstancia.TelaAtiva = 'TFormTecladoAlfaNumerico') then
  begin
    if (FTecladoAlfaNumerico.FFuncaoDoTeclado = 'produto') and
      (FTecladoAlfaNumerico.FValorRetorno <> '') then
      carregaFormProduto(FTecladoAlfaNumerico.FValorRetorno, True);
  end;
end;

procedure TMenuProduto.botaoVoltar(Sender: TObject);
begin
  resetTimer;

  if (TVariaveis.GetInstancia.TelaAtiva = 'TMenuProduto') then
    carregaViewMenu
  else if (TVariaveis.GetInstancia.TelaAtiva = 'TFormProduto') then
    carregaViewMenu
  else if (TVariaveis.GetInstancia.TelaAtiva = 'TFormTecladoAlfaNumerico') then
    carregaViewMenu;
end;

procedure TMenuProduto.carregaFormProduto(AConsultaProduto: string;
  APesquisarEmDescricaoTambem: boolean);
begin
  resetTimer;

  FTelaProduto.FConsultaProduto := AConsultaProduto;
  FTelaProduto.FPesquisarEmDescricaoTambem := APesquisarEmDescricaoTambem;
  FTelaProduto.ajustaForm(True);
  ChangeTabActionMenu.Execute;
end;

procedure TMenuProduto.carregaViewMenu;
begin
  if not Assigned(ViewMenu) then
    Application.CreateForm(TViewMenu, ViewMenu);

  Application.MainForm := ViewMenu;
  ViewMenu.Show;

  tecladoAlfaNumericoProduto(False);
  MenuProduto.TabControl.ActiveTab := TabItemTecladoAlfaNumerico;
  MenuProduto.Close;
end;

procedure TMenuProduto.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Timer.Enabled := False;
end;

procedure TMenuProduto.FormCreate(Sender: TObject);
begin
{$IFDEF MSWINDOWS}
//  MenuProduto.Width := 800;
//  MenuProduto.Height := 600;
//  MenuProduto.Top := ViewMenu.Top;
//  MenuProduto.Left := ViewMenu.Left;

  MenuProduto.WindowState := TWindowState.wsMaximized;
{$ENDIF}
  FTelaProduto := TFormProduto.Create(Self);
  FTelaProduto.ImageVoltar.OnClick := botaoVoltar;

  FTecladoAlfaNumerico := TFormTecladoAlfaNumerico.Create(Self);
  FTecladoAlfaNumerico.LabelAcaoConfirmar.OnClick := botaoConfirmar;
  FTecladoAlfaNumerico.LabelAcaoVoltar.OnClick := botaoVoltar;

  embeddForm(RectangleBase, FTelaProduto);
  embeddForm(RectangleTecladoAlfaNumerico, FTecladoAlfaNumerico);

  tecladoAlfaNumericoProduto(False);
  TabControl.ActiveTab := TabItemTecladoAlfaNumerico;
end;

procedure TMenuProduto.FormShow(Sender: TObject);
begin
  resetTimer;

  tecladoAlfaNumericoProduto(True);
end;

procedure TMenuProduto.resetTimer;
begin
  Timer.Enabled := False;
  Timer.Enabled := True;
end;

procedure TMenuProduto.tecladoAlfaNumericoProduto(AExecutar: boolean);
begin
  resetTimer;

  FTecladoAlfaNumerico.FFuncaoDoTeclado := 'produto';
  FTecladoAlfaNumerico.LabelTitulo.Text := 'informe o produto';
  FTecladoAlfaNumerico.LabelValor.Text := EmptyStr;
  FTecladoAlfaNumerico.FValorRetorno := EmptyStr;
  FTecladoAlfaNumerico.FSenhaRetorno := EmptyStr;
  FTecladoAlfaNumerico.FTecladoFisico := TVariaveis.GetInstancia.TecladoFisicoAtivado;

  if AExecutar then
  begin
    FTecladoAlfaNumerico.ajustaForm;
    ChangeTabActionTecladoAlfaNumerico.Execute;
    if FTecladoAlfaNumerico.FTecladoFisico then
      FTecladoAlfaNumerico.EditValor.SetFocus;
  end;
end;

procedure TMenuProduto.TimerTimer(Sender: TObject);
begin
  Timer.Enabled := False;

  carregaViewMenu;
end;

end.
