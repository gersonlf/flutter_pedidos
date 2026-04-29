unit Menu.Comanda;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.TabControl, System.Actions, FMX.ActnList,

  Service.DM,
  Singleton.Variaveis,
  Util.Funcao,
  Util.ActionSheet,
  Util.Loading,

  Menu.Item,
  Form.Comanda,

  View.Mensagem,

  TecladoNumerico,
  TecladoAlfaNumerico,

  FMX.ListView.Appearances,
  FMX.ListView.Types,
  FMX.ListView,
  FMX.Ani;

type
  TMenuComanda = class(TForm)
    RectangleBase: TRectangle;
    TabControl: TTabControl;
    TabItemBase: TTabItem;
    ActionList: TActionList;
    TabItemTecladoAlfaNumerico: TTabItem;
    RectangleTecladoAlfaNumerico: TRectangle;
    TabItemTecladoNumerico: TTabItem;
    RectangleTecladoNumerico: TRectangle;
    ChangeTabActionBase: TChangeTabAction;
    ChangeTabActionTecladoNumerico: TChangeTabAction;
    ChangeTabActionTecladoAlfaNumerico: TChangeTabAction;
    Timer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FTelaComanda: TFormComanda;

    FTecladoNumerico: TFormTecladoNumerico;
    FTecladoAlfaNumerico: TFormTecladoAlfaNumerico;

    FActionSheetComanda: TActionSheet;

    procedure actionComanda;
    procedure actionAlterarComanda(Sender: TObject);
    procedure actionAlterarMesa(Sender: TObject);
    procedure actionExcluirComanda(Sender: TObject);

    procedure botaoConfirmar(Sender: TObject);
    procedure botaoVoltar(Sender: TObject);
    procedure botaoAcao(Sender: TObject);
    procedure botaoAdicionar(Sender: TObject);

    procedure alterarComanda(ACodigoComanda: integer; ACodigoNovaComanda: integer);
    procedure alterarComandaFim(Sender: TObject);

    procedure alterarMesa(ACodigoComanda: integer; ACodigoNovaMesa: integer);
    procedure alterarMesaFim(Sender: TObject);

    procedure excluirComanda(ACodigoComanda: integer);
    procedure excluirComandaFim(Sender: TObject);

    procedure confirmaSenha(ASenha: string);
    procedure confirmaSenhaFim(Sender: TObject);

    procedure carregaViewMenu;

    procedure carregaMenuItem;
    procedure carregaMenuItemFim(Sender: TObject);

    procedure carregaTelaComanda;
    procedure carregaTelaComandaFim(Sender: TObject);

    procedure consultarMesa;
    procedure consultarMesaFim(Sender: TObject);

    procedure consultarComanda;
    procedure consultarComandaFim(Sender: TObject);

    procedure listViewItemClickExComanda(const Sender: TObject; ItemIndex: integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);

    procedure resetTimer;

    procedure tecladoNumericoComanda(AExecutar: boolean);
    procedure tecladoNumericoMesa(AExecutar: boolean);
    procedure tecladoNumericoAlterarComanda(AExecutar: boolean);
    procedure tecladoNumericoAlterarMesa(AExecutar: boolean);
    procedure tecladoNumericoSenhaExcluirComanda(AExecutar: boolean);
  public
    { Public declarations }
    procedure ajustaForm;
  end;

var
  MenuComanda: TMenuComanda;

implementation

{$R *.fmx}

uses
  View.Menu;

{ TMenuComanda }

procedure TMenuComanda.actionAlterarComanda(Sender: TObject);
begin
  resetTimer;

  FActionSheetComanda.HideMenu;

  if TVariaveis.GetInstancia.Bloqueio = 0 then
    tecladoNumericoAlterarComanda(True)
  else
    ShowMessage('Comanda bloqueada!!!' + #13 + 'Operação não pode ser realizada.' + #13 +
      'Entre em contato com a gerência.');
end;

procedure TMenuComanda.actionAlterarMesa(Sender: TObject);
begin
  resetTimer;

  FActionSheetComanda.HideMenu;

  if TVariaveis.GetInstancia.Bloqueio = 0 then
    tecladoNumericoAlterarMesa(True)
  else
    ShowMessage('Comanda bloqueada!!!' + #13 + 'Operação não pode ser realizada.' + #13 +
      'Entre em contato com a gerência.');
end;

procedure TMenuComanda.actionComanda;
begin
  FActionSheetComanda := TActionSheet.Create(Self);
  FActionSheetComanda.TitleFontSize := 12;
  FActionSheetComanda.TitleMenuText := 'O que deseja fazer?';
  FActionSheetComanda.TitleFontColor := $FF8B8B8B;

  FActionSheetComanda.CancelMenuText := 'Cancelar';
  FActionSheetComanda.CancelFontSize := 17;
  FActionSheetComanda.CancelFontColor := $FF087AF7;

  FActionSheetComanda.BackgroundOpacity := 0.5;
  FActionSheetComanda.MenuColor := $FFFFFFFF;

  FActionSheetComanda.AddItem('001', 'Excluir Comanda', actionExcluirComanda, $FFE7404A);
  FActionSheetComanda.AddItem('002', 'Trocar Comanda', actionAlterarComanda);
  FActionSheetComanda.AddItem('003', 'Trocar Mesa', actionAlterarMesa);
end;

procedure TMenuComanda.actionExcluirComanda(Sender: TObject);
begin
  resetTimer;

  FActionSheetComanda.HideMenu;

  if TVariaveis.GetInstancia.Bloqueio = 0 then
  begin
    if TVariaveis.GetInstancia.ExcluirItemOuComanda then
      tecladoNumericoSenhaExcluirComanda(True)
    else
      excluirComanda(TVariaveis.GetInstancia.CodigoComanda);
  end
  else
    ShowMessage('Comanda bloqueada!!!' + #13 + 'Operação não pode ser realizada.' + #13 +
      'Entre em contato com a gerência.');
end;

procedure TMenuComanda.ajustaForm;
begin
  resetTimer;

  TVariaveis.GetInstancia.TelaAnterior := TVariaveis.GetInstancia.TelaAtiva;
  TVariaveis.GetInstancia.TelaAtiva := 'TMenuComanda';
end;

procedure TMenuComanda.alterarComanda(ACodigoComanda: integer; ACodigoNovaComanda: integer);
var
  LThread: TThread;

begin
  resetTimer;

  TLoading.Show(ViewMenu, 'Aguarde, alterando comanda...');

  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      DM.alterarComandaMTComandas(ACodigoComanda, ACodigoNovaComanda);
    end);

  LThread.OnTerminate := alterarComandaFim;
  LThread.start;
end;

procedure TMenuComanda.alterarComandaFim(Sender: TObject);
var
  ex: TObject;

begin
  Sleep(100);
  TLoading.Hide;

  ex := TThread(Sender).FatalException;
  if Assigned(TThread(Sender).FatalException) then
    ShowMessage('Erro alterando comanda!, tente novamente...' + #13 + Exception(ex).Message)
  else
    carregaTelaComanda;
end;

procedure TMenuComanda.alterarMesa(ACodigoComanda: integer; ACodigoNovaMesa: integer);
var
  LThread: TThread;

begin
  resetTimer;

  TLoading.Show(ViewMenu, 'Aguarde, alterando mesa...');

  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      try
        DM.alterarMesaMTComandas(ACodigoComanda, ACodigoNovaMesa);
      except
        on ex: Exception do
          raise Exception.Create(ex.Message);
      end;
    end);

  LThread.OnTerminate := alterarMesaFim;
  LThread.start;
end;

procedure TMenuComanda.alterarMesaFim(Sender: TObject);
var
  ex: TObject;

begin
  Sleep(100);
  TLoading.Hide;

  ex := TThread(Sender).FatalException;
  if Assigned(TThread(Sender).FatalException) then
    ShowMessage('Erro alterando mesa!, tente novamente...' + #13 + Exception(ex).Message)
  else
    carregaTelaComanda;
end;

procedure TMenuComanda.botaoAcao(Sender: TObject);
begin
  resetTimer;

  carregaTelaComanda;
end;

procedure TMenuComanda.botaoAdicionar(Sender: TObject);
begin
  resetTimer;

  tecladoNumericoComanda(True);
end;

procedure TMenuComanda.botaoConfirmar(Sender: TObject);
begin
  resetTimer;

  if (TVariaveis.GetInstancia.TelaAtiva = 'TFormTecladoNumerico') then
  begin
    if (FTecladoNumerico.FFuncaoDoTeclado = 'comanda') and (FTecladoNumerico.FValorRetorno <> '')
    then
    begin
      TVariaveis.GetInstancia.CodigoComanda := StrToInt(FTecladoNumerico.FValorRetorno);
      TVariaveis.GetInstancia.CodigoMesa := 0;

      consultarComanda;
    end
    else if (FTecladoNumerico.FFuncaoDoTeclado = 'mesa') and (FTecladoNumerico.FValorRetorno <> '')
    then
    begin
      TVariaveis.GetInstancia.CodigoMesa := StrToInt(FTecladoNumerico.FValorRetorno);

      carregaMenuItem;
    end
    else if (FTecladoNumerico.FFuncaoDoTeclado = 'alterarComanda') and
      (FTecladoNumerico.FValorRetorno <> '') then
      alterarComanda(TVariaveis.GetInstancia.CodigoComanda,
        StrToInt(FTecladoNumerico.FValorRetorno))
    else if (FTecladoNumerico.FFuncaoDoTeclado = 'alterarMesa') and
      (FTecladoNumerico.FValorRetorno <> '') then
      alterarMesa(TVariaveis.GetInstancia.CodigoComanda, StrToInt(FTecladoNumerico.FValorRetorno))
    else if (FTecladoNumerico.FFuncaoDoTeclado = 'senhaExcluirComanda') and
      (FTecladoNumerico.FValorRetorno <> '') then
      confirmaSenha(FTecladoNumerico.FValorRetorno);
  end;
end;

procedure TMenuComanda.botaoVoltar(Sender: TObject);
begin
  resetTimer;

  if (TVariaveis.GetInstancia.TelaAtiva = 'TMenuComanda') then
    carregaViewMenu
  else if (TVariaveis.GetInstancia.TelaAtiva = 'TFormComanda') then
    carregaViewMenu
  else if (TVariaveis.GetInstancia.TelaAtiva = 'TFormTecladoNumerico') then
  begin
    if (FTecladoNumerico.FFuncaoDoTeclado = 'comanda') then
      carregaViewMenu
    else
      carregaTelaComanda;
  end;
end;

procedure TMenuComanda.carregaMenuItem;
var
  t: TThread;

begin
  resetTimer;

  TLoading.Show(MenuComanda, 'Aguarde, carregando itens...');

  t := TThread.CreateAnonymousThread(
    procedure
    begin
      DM.servidorMTItens(TVariaveis.GetInstancia.CodigoComanda,
        TVariaveis.GetInstancia.CodigoEmpresa, 0);
    end);

  t.OnTerminate := carregaMenuItemFim;
  t.start;
end;

procedure TMenuComanda.carregaMenuItemFim(Sender: TObject);
var
  ex: TObject;

begin
  Sleep(100);
  TLoading.Hide;

  ex := TThread(Sender).FatalException;
  if Assigned(TThread(Sender).FatalException) then
    ShowMessage('Erro carregando itens!, tente novamente...' + #13 + Exception(ex).Message)
  else
  begin
    if not Assigned(MenuItem) then
      Application.CreateForm(TMenuItem, MenuItem);

    Application.MainForm := MenuItem;
    MenuItem.Show;

    MenuComanda.TabControl.ActiveTab := TabItemBase;
    MenuComanda.Close;
  end;
end;

procedure TMenuComanda.confirmaSenha(ASenha: string);
var
  LThread: TThread;

begin
  resetTimer;

  TLoading.Show(ViewMenu, 'Aguarde, consultado senha...');

  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      DM.servidorMTSenhas(ASenha);
    end);

  LThread.OnTerminate := confirmaSenhaFim;
  LThread.start;
end;

procedure TMenuComanda.confirmaSenhaFim(Sender: TObject);
var
  ex: TObject;

begin
  Sleep(100);
  TLoading.Hide;

  ex := TThread(Sender).FatalException;
  if Assigned(TThread(Sender).FatalException) then
    ShowMessage('Erro consultando senha!, tente novamente...' + #13 + Exception(ex).Message)
  else
  begin
    if (DM.mtSenhas.RecordCount > 0) and (FTecladoNumerico.FFuncaoDoTeclado = 'senhaExcluirComanda')
    then
      excluirComanda(TVariaveis.GetInstancia.CodigoComanda)
    else
    begin
      if NOT Assigned(ViewMensagem) then
        Application.CreateForm(TViewMensagem, ViewMensagem);

{$IFDEF MSWINDOWS}
      // ViewMensagem.Width := 800;
      // ViewMensagem.Height := 600;
      // ViewMensagem.Top := ViewMenu.Top;
      // ViewMensagem.Left := ViewMenu.Left;

      ViewMensagem.WindowState := TWindowState.wsMaximized;
{$ENDIF}
      ViewMensagem.LabelMensagem.Text := 'Senha inválida!';
      ViewMensagem.ShowModal(
        procedure(ModalResult: TModalResult)
        begin
          ViewMensagem := nil;

          if (FTecladoNumerico.FFuncaoDoTeclado = 'senhaExcluirComanda') then
            carregaTelaComanda;
        end);
    end;
  end;
end;

procedure TMenuComanda.consultarComanda;
var
  t: TThread;

begin
  resetTimer;

  TLoading.Show(MenuComanda, 'Aguarde, consultando comanda...');

  t := TThread.CreateAnonymousThread(
    procedure
    begin
      TVariaveis.GetInstancia.Bloqueio :=
        StrToInt(DM.consultarComanda(TVariaveis.GetInstancia.CodigoEmpresa,
        TVariaveis.GetInstancia.CodigoComanda));
    end);

  t.OnTerminate := consultarComandaFim;
  t.start;
end;

procedure TMenuComanda.consultarComandaFim(Sender: TObject);
begin
  Sleep(100);
  TLoading.Hide;

  if Assigned(TThread(Sender).FatalException) then
    ShowMessage('Erro consultado comanda!, tente novamente...' + #13 +
      Exception(TThread(Sender).FatalException).Message)
  else if TVariaveis.GetInstancia.Bloqueio = 0 then
  begin
    if DM.mtEmpresas.FieldByName('controlaMesa').AsString = 'S' then
      consultarMesa
    else
      carregaMenuItem;
  end
  else
    carregaMenuItem;
end;

procedure TMenuComanda.consultarMesa;
var
  t: TThread;

begin
  resetTimer;

  TLoading.Show(MenuComanda, 'Aguarde, consultando mesa...');

  t := TThread.CreateAnonymousThread(
    procedure
    begin
      TVariaveis.GetInstancia.CodigoMesa :=
        StrToInt(DM.consultarMesa(TVariaveis.GetInstancia.CodigoEmpresa,
        TVariaveis.GetInstancia.CodigoComanda));
    end);

  t.OnTerminate := consultarMesaFim;
  t.start;
end;

procedure TMenuComanda.consultarMesaFim(Sender: TObject);
begin
  Sleep(100);
  TLoading.Hide;

  if Assigned(TThread(Sender).FatalException) then
    ShowMessage('Erro consultado mesa!, tente novamente...' + #13 +
      Exception(TThread(Sender).FatalException).Message)
  else if TVariaveis.GetInstancia.CodigoMesa = -1 then
    tecladoNumericoMesa(True)
  else
    carregaMenuItem;
end;

procedure TMenuComanda.carregaTelaComanda;
var
  t: TThread;

begin
  resetTimer;

  TLoading.Show(MenuComanda, 'Aguarde, carregando comandas...');

  t := TThread.CreateAnonymousThread(
    procedure
    begin
      DM.servidorMTComandas('', TVariaveis.GetInstancia.CodigoEmpresa, 0);
    end);

  t.OnTerminate := carregaTelaComandaFim;
  t.start;
end;

procedure TMenuComanda.carregaTelaComandaFim(Sender: TObject);
var
  ex: TObject;

begin
  Sleep(100);
  TLoading.Hide;

  ex := TThread(Sender).FatalException;
  if Assigned(TThread(Sender).FatalException) then
    ShowMessage('Erro carregando comandas!, tente novamente...' + #13 + Exception(ex).Message)
  else
  begin
    FTelaComanda.ajustaForm(True);
    ChangeTabActionBase.Execute;
  end;
end;

procedure TMenuComanda.carregaViewMenu;
begin
  if not Assigned(ViewMenu) then
    Application.CreateForm(TViewMenu, ViewMenu);

  Application.MainForm := ViewMenu;
  ViewMenu.Show;

  MenuComanda.TabControl.ActiveTab := TabItemBase;
  MenuComanda.Close;
end;

procedure TMenuComanda.excluirComanda(ACodigoComanda: integer);
var
  LThread: TThread;

begin
  resetTimer;

  TLoading.Show(ViewMenu, 'Aguarde, excluindo comanda...');

  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      DM.excluirMTComandas(ACodigoComanda);
    end);

  LThread.OnTerminate := excluirComandaFim;
  LThread.start;
end;

procedure TMenuComanda.excluirComandaFim(Sender: TObject);
var
  ex: TObject;

begin
  Sleep(100);
  TLoading.Hide;

  ex := TThread(Sender).FatalException;
  if Assigned(TThread(Sender).FatalException) then
    ShowMessage('Erro excluindo comanda!, tente novamente...' + #13 + Exception(ex).Message)
  else
    carregaTelaComanda;
end;

procedure TMenuComanda.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Timer.Enabled := False;
end;

procedure TMenuComanda.FormCreate(Sender: TObject);
begin
{$IFDEF MSWINDOWS}
  // MenuComanda.Width := 800;
  // MenuComanda.Height := 600;
  // MenuComanda.Top := ViewMenu.Top;
  // MenuComanda.Left := ViewMenu.Left;

  MenuComanda.WindowState := TWindowState.wsMaximized;
{$ENDIF}
  actionComanda;

  FTelaComanda := TFormComanda.Create(Self);
  FTelaComanda.ImageMenu.OnClick := botaoVoltar;
  FTelaComanda.ImageNovaComanda.OnClick := botaoAdicionar;
  FTelaComanda.ListView.OnItemClickEx := listViewItemClickExComanda;

  FTecladoNumerico := TFormTecladoNumerico.Create(Self);
  FTecladoNumerico.LabelAcaoConfirmar.OnClick := botaoConfirmar;
  FTecladoNumerico.LabelAcaoListar.OnClick := botaoAcao;
  FTecladoNumerico.LabelAcaoVoltar.OnClick := botaoVoltar;

  FTecladoAlfaNumerico := TFormTecladoAlfaNumerico.Create(Self);
  FTecladoAlfaNumerico.LabelAcaoConfirmar.OnClick := botaoConfirmar;
  FTecladoAlfaNumerico.LabelAcaoVoltar.OnClick := botaoVoltar;

  embeddForm(RectangleBase, FTelaComanda);
  embeddForm(RectangleTecladoNumerico, FTecladoNumerico);
  embeddForm(RectangleTecladoAlfaNumerico, FTecladoAlfaNumerico);

  //TabControl.ActiveTab := TabItemBase;
  TabControl.ActiveTab := TabItemTecladoNumerico;
end;

procedure TMenuComanda.FormDestroy(Sender: TObject);
begin
  FActionSheetComanda.DisposeOf;
end;

procedure TMenuComanda.FormShow(Sender: TObject);
begin
  resetTimer;
  tecladoNumericoComanda(True);
  //carregaTelaComanda;
end;

procedure TMenuComanda.listViewItemClickExComanda(const Sender: TObject; ItemIndex: integer;
const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
var
  txt: TListItemText;
  Item: TListViewITem;

begin
  resetTimer;

  if TListView(Sender).Selected <> nil then
  begin
    Item := TListView(Sender).Items[ItemIndex];

    txt := TListItemText(Item.Objects.FindDrawable('Text3'));
    TVariaveis.GetInstancia.CodigoComanda := StrToInt(txt.Text);

    txt := TListItemText(Item.Objects.FindDrawable('Text4'));
    try
      TVariaveis.GetInstancia.CodigoMesa := StrToInt(txt.Text);
    except
      TVariaveis.GetInstancia.CodigoMesa := 0;
    end;

    txt := TListItemText(Item.Objects.FindDrawable('Text9'));
    try
      TVariaveis.GetInstancia.Bloqueio := StrToInt(txt.Text);
    except
      TVariaveis.GetInstancia.Bloqueio := 0;
    end;

    if ItemObject is TListItemImage then
    begin
      if (TListItemImage(ItemObject).Name = 'image1') then
        FActionSheetComanda.ShowMenu;
    end
    else
      carregaMenuItem;
  end;
end;

procedure TMenuComanda.resetTimer;
begin
  Timer.Enabled := False;
  Timer.Enabled := True;
end;

procedure TMenuComanda.tecladoNumericoAlterarComanda(AExecutar: boolean);
begin
  resetTimer;

  FTecladoNumerico.FFuncaoDoTeclado := 'alterarComanda';
  FTecladoNumerico.LabelTitulo.Text := 'informe a nova comanda';
  FTecladoNumerico.LabelResultado.Text := 'Comanda atual: ' +
    IntToStr(TVariaveis.GetInstancia.CodigoComanda);
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

procedure TMenuComanda.tecladoNumericoAlterarMesa(AExecutar: boolean);
begin
  resetTimer;

  FTecladoNumerico.FFuncaoDoTeclado := 'alterarMesa';
  FTecladoNumerico.LabelTitulo.Text := 'informe a nova mesa';
  FTecladoNumerico.LabelResultado.Text := 'Nova Mesa';
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

procedure TMenuComanda.tecladoNumericoComanda(AExecutar: boolean);
begin
  resetTimer;

  FTecladoNumerico.FFuncaoDoTeclado := 'comanda';
  FTecladoNumerico.LabelTitulo.Text := 'informe a comanda';
  FTecladoNumerico.LabelResultado.Text := TVariaveis.GetInstancia.NomeFuncionario;
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

procedure TMenuComanda.tecladoNumericoMesa(AExecutar: boolean);
begin
  resetTimer;

  FTecladoNumerico.FFuncaoDoTeclado := 'mesa';
  FTecladoNumerico.LabelTitulo.Text := 'informe a mesa';
  FTecladoNumerico.LabelResultado.Text := TVariaveis.GetInstancia.NomeFuncionario;
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

procedure TMenuComanda.tecladoNumericoSenhaExcluirComanda(AExecutar: boolean);
begin
  resetTimer;

  FTecladoNumerico.FFuncaoDoTeclado := 'senhaExcluirComanda';
  FTecladoNumerico.LabelTitulo.Text := 'informe a senha';
  FTecladoNumerico.LabelResultado.Text := EmptyStr;
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

procedure TMenuComanda.TimerTimer(Sender: TObject);
begin
  Timer.Enabled := False;
  carregaViewMenu;
end;

end.
