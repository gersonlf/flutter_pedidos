unit Menu.Funcionario;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.TabControl, System.Actions, FMX.ActnList,

  Singleton.Variaveis,
  Util.Funcao,

  Menu.Comanda,
  Form.Funcionario,

  TecladoNumerico,
  TecladoAlfaNumerico,

  FMX.ListView.Appearances,
  FMX.ListView.Types,
  FMX.ListView,
  FMX.Ani;

type
  TMenuFuncionario = class(TForm)
    TabControl: TTabControl;
    TabItemBase: TTabItem;
    RectangleBase: TRectangle;
    TabItemTecladoNumerico: TTabItem;
    RectangleTecladoNumerico: TRectangle;
    TabItemTecladoAlfaNumerico: TTabItem;
    RectangleTecladoAlfaNumerico: TRectangle;
    ActionList: TActionList;
    ChangeTabActionBase: TChangeTabAction;
    ChangeTabActionTecladoAlfaNumerico: TChangeTabAction;
    ChangeTabActionTecladoNumerico: TChangeTabAction;
    Timer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FTelaFuncionario: TFormFuncionario;

    FTecladoNumerico: TFormTecladoNumerico;
    FTecladoAlfaNumerico: TFormTecladoAlfaNumerico;

    procedure botaoConfirmar(Sender: TObject);
    procedure botaoVoltar(Sender: TObject);
    procedure botaoAcao(Sender: TObject);

    procedure carregaViewMenu;
    procedure carregaTelaFuncionario;
    procedure carregaMenuComanda;

    procedure resetTimer;

    procedure listViewItemClickFuncionario(const Sender: TObject; const AItem: TListViewItem);
    procedure tecladoNumericoFuncionario(AExecutar: boolean);
  public
    { Public declarations }
    procedure ajustaForm;
  end;

var
  MenuFuncionario: TMenuFuncionario;

implementation

{$R *.fmx}

uses
  View.Menu;

procedure TMenuFuncionario.ajustaForm;
begin
  TVariaveis.GetInstancia.TelaAnterior := TVariaveis.GetInstancia.TelaAtiva;
  TVariaveis.GetInstancia.TelaAtiva := 'TMenuFuncionario';
end;

procedure TMenuFuncionario.botaoAcao(Sender: TObject);
begin
  resetTimer;

  carregaTelaFuncionario;
end;

procedure TMenuFuncionario.botaoConfirmar(Sender: TObject);
begin
  resetTimer;

  if (TVariaveis.GetInstancia.TelaAtiva = 'TFormTecladoNumerico') then
  begin
    if (FTecladoNumerico.FFuncaoDoTeclado = 'funcionario') and
      (FTecladoNumerico.LabelResultado.Text <> '') then
    begin
      TVariaveis.GetInstancia.CodigoFuncionario := FTecladoNumerico.LabelResultado.Tag;
      TVariaveis.GetInstancia.NomeFuncionario := FTecladoNumerico.LabelResultado.Text;

      carregaMenuComanda;
    end;
  end;
end;

procedure TMenuFuncionario.botaoVoltar(Sender: TObject);
begin
  resetTimer;

  if (TVariaveis.GetInstancia.TelaAtiva = 'TMenuFuncionario') then
    carregaViewMenu
  else if (TVariaveis.GetInstancia.TelaAtiva = 'TFormFuncionario') then
    carregaViewMenu
  else if (TVariaveis.GetInstancia.TelaAtiva = 'TFormTecladoNumerico') then
    carregaViewMenu;
end;

procedure TMenuFuncionario.carregaMenuComanda;
begin
  resetTimer;

  if not Assigned(MenuComanda) then
    Application.CreateForm(TMenuComanda, MenuComanda);

  Application.MainForm := MenuComanda;
  MenuComanda.Show;

  tecladoNumericoFuncionario(False);
  MenuFuncionario.TabControl.ActiveTab := TabItemTecladoNumerico;
  MenuFuncionario.Close;
end;

procedure TMenuFuncionario.carregaTelaFuncionario;
begin
  resetTimer;

  FTelaFuncionario.ajustaForm(True);
  ChangeTabActionBase.Execute;
end;

procedure TMenuFuncionario.carregaViewMenu;
begin
  if not Assigned(ViewMenu) then
    Application.CreateForm(TViewMenu, ViewMenu);

  Application.MainForm := ViewMenu;
  ViewMenu.Show;

  MenuFuncionario.TabControl.ActiveTab := TabItemTecladoNumerico;
  MenuFuncionario.Close;
end;

procedure TMenuFuncionario.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Timer.Enabled := False;
end;

procedure TMenuFuncionario.FormCreate(Sender: TObject);
begin
{$IFDEF MSWINDOWS}
//  MenuFuncionario.Width := 800;
//  MenuFuncionario.Height := 600;
//  MenuFuncionario.Top := ViewMenu.Top;
//  MenuFuncionario.Left := ViewMenu.Left;

  MenuFuncionario.WindowState := TWindowState.wsMaximized;
{$ENDIF}
  FTelaFuncionario := TFormFuncionario.Create(Self);
  FTelaFuncionario.ImageMenu.OnClick := botaoVoltar;
  FTelaFuncionario.ListView.OnItemClick := listViewItemClickFuncionario;

  FTecladoNumerico := TFormTecladoNumerico.Create(Self);
  FTecladoNumerico.LabelAcaoConfirmar.OnClick := botaoConfirmar;
  FTecladoNumerico.LabelAcaoListar.OnClick := botaoAcao;
  FTecladoNumerico.LabelAcaoVoltar.OnClick := botaoVoltar;

  FTecladoAlfaNumerico := TFormTecladoAlfaNumerico.Create(Self);
  FTecladoAlfaNumerico.LabelAcaoConfirmar.OnClick := botaoConfirmar;
  FTecladoAlfaNumerico.LabelAcaoVoltar.OnClick := botaoVoltar;

  embeddForm(RectangleBase, FTelaFuncionario);
  embeddForm(RectangleTecladoNumerico, FTecladoNumerico);
  embeddForm(RectangleTecladoAlfaNumerico, FTecladoAlfaNumerico);

  tecladoNumericoFuncionario(False);
  TabControl.ActiveTab := TabItemTecladoNumerico;
end;

procedure TMenuFuncionario.FormShow(Sender: TObject);
begin
  resetTimer;

  tecladoNumericoFuncionario(True);
end;

procedure TMenuFuncionario.listViewItemClickFuncionario(const Sender: TObject;
  const AItem: TListViewItem);
var
  txt: TListItemText;

begin
  resetTimer;

  if TListView(Sender).Selected <> nil then
  begin
    txt := TListItemText(AItem.Objects.FindDrawable('Text4'));
    TVariaveis.GetInstancia.CodigoFuncionario := StrToInt(txt.Text);

    txt := TListItemText(AItem.Objects.FindDrawable('Text2'));
    TVariaveis.GetInstancia.NomeFuncionario := txt.Text;

    carregaMenuComanda;
  end;
end;

procedure TMenuFuncionario.resetTimer;
begin
  Timer.Enabled := False;
  Timer.Enabled := True;
end;

procedure TMenuFuncionario.tecladoNumericoFuncionario(AExecutar: boolean);
begin
  resetTimer;

  FTecladoNumerico.FFuncaoDoTeclado := 'funcionario';
  FTecladoNumerico.LabelTitulo.Text := 'informe o funcionário';
  FTecladoNumerico.LabelResultado.Text := '';
  FTecladoNumerico.LabelValor.Text := EmptyStr;
  FTecladoNumerico.FValorRetorno := EmptyStr;
  FTecladoNumerico.FSenhaRetorno := EmptyStr;
  FTecladoNumerico.FTecladoFisico := TVariaveis.GetInstancia.TecladoFisicoAtivado;
  FTecladoNumerico.FTeclaDecimal := False;

  if AExecutar then
  begin
    FTecladoNumerico.ajustaForm;
    ChangeTabActionTecladoNumerico.Execute;
    if FTecladoNumerico.FTecladoFisico then
      FTecladoNumerico.EditValor.SetFocus;
  end;
end;

procedure TMenuFuncionario.TimerTimer(Sender: TObject);
begin
  Timer.Enabled := False;

  carregaViewMenu;
end;

end.
