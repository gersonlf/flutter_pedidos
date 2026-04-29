unit Menu.Item;

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

  View.Mensagem,

  Form.Item,
  Form.Produto,

  TecladoNumerico,
  TecladoAlfaNumerico,

  FMX.ListView.Appearances,
  FMX.ListView.Types,
  FMX.ListView,
  FMX.Ani;

type
  TMenuItem = class(TForm)
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
    TabItemProduto: TTabItem;
    RectangleProduto: TRectangle;
    ChangeTabActionProduto: TChangeTabAction;
    Timer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FConsultaProduto: string;

    FTelaItem: TFormItem;
    FTelaProduto: TFormProduto;

    FTecladoNumerico: TFormTecladoNumerico;
    FTecladoAlfaNumerico: TFormTecladoAlfaNumerico;

    FActionSheetItem: TActionSheet;

    FTravaBotaoAcao: boolean;
    FTravaBotaoConfirmar: boolean;

    procedure actionItem;
    procedure actionAlterarComanda(Sender: TObject);
    procedure actionAlterarObservacao(Sender: TObject);
    procedure actionExcluirItem(Sender: TObject);

    procedure botaoConfirmar(Sender: TObject);
    procedure botaoVoltar(Sender: TObject);
    procedure botaoAcao(Sender: TObject);
    procedure botaoAcao2(Sender: TObject);
    procedure botaoAdicionar(Sender: TObject);

    procedure alterarComanda(ACodigoComanda, ACodigoNovaComanda, AItemComanda: integer);
    procedure alterarComandaFim(Sender: TObject);

    procedure alterarObservacao(ACodigoComanda: integer; ACodigoItem: integer;
      AObservacaoItem: string);
    procedure alterarObservacaoFim(Sender: TObject);

    procedure adicionarItem(ACodigoComanda: integer; ACodigoMesa: integer; ACodigoProduto: integer;
      ACodigoBarra: string; ACodigoReduzido: integer; ADescricaoProduto: string;
      AQuantidadeItem: double; AValorUnitarioItem: double; AObservacaoItem: string);

    procedure adicionarItemFim(Sender: TObject);

    procedure excluirItem(ACodigoComanda: integer; AItemComanda: integer);
    procedure excluirItemFim(Sender: TObject);

    procedure confirmaSenha(ASenha: string);
    procedure confirmaSenhaFim(Sender: TObject);

    procedure carregaFormProduto;

    procedure carregaMenuComanda;
    procedure carregaMenuComandaFim(Sender: TObject);

    procedure carregaMenuItem;
    procedure carregaMenuItemFim(Sender: TObject);

    procedure listViewItemClickProduto(const Sender: TObject; const AItem: TListViewItem);

    procedure listViewItemClickExItem(const Sender: TObject; ItemIndex: integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);

    procedure resetTimer;

    procedure tecladoNumericoQuantidade(AExecutar: boolean);
    procedure tecladoNumericoProduto(AExecutar: boolean);
    procedure tecladoNumericoAlterarComanda(AExecutar: boolean);
    procedure tecladoNumericoSenhaExcluirItem(AExecutar: boolean);

    procedure tecladoAlfaNumericoProduto(AExecutar: boolean);
    procedure tecladoAlfaNumericoAlterarObservacaoItem(AExecutar: boolean);
    procedure tecladoAlfaNumericoAlterarObservacaoQtde(AExecutar: boolean);
  public
    { Public declarations }
    procedure ajustaForm;
  end;

var
  MenuItem: TMenuItem;

implementation

{$R *.fmx}

uses
  View.Menu,
  Menu.Comanda;

{ TMenuComanda }

procedure TMenuItem.actionAlterarComanda(Sender: TObject);
begin
  resetTimer;

  FActionSheetItem.HideMenu;

  if TVariaveis.GetInstancia.Bloqueio = 0 then
    tecladoNumericoAlterarComanda(True)
  else
    ShowMessage('Comanda bloqueada!!!' + #13 + 'Operação não pode ser realizada.' + #13 +
      'Entre em contato com a gerência.');
end;

procedure TMenuItem.actionAlterarObservacao(Sender: TObject);
begin
  resetTimer;

  FActionSheetItem.HideMenu;

  if TVariaveis.GetInstancia.Bloqueio = 0 then
    tecladoAlfaNumericoAlterarObservacaoItem(True)
  else
    ShowMessage('Comanda bloqueada!!!' + #13 + 'Operação não pode ser realizada.' + #13 +
      'Entre em contato com a gerência.');
end;

procedure TMenuItem.actionExcluirItem(Sender: TObject);
begin
  resetTimer;

  FActionSheetItem.HideMenu;

  if TVariaveis.GetInstancia.Bloqueio = 0 then
  begin
    if TVariaveis.GetInstancia.excluirItemOuComanda then
      tecladoNumericoSenhaExcluirItem(True)
    else
      excluirItem(TVariaveis.GetInstancia.CodigoComanda, TVariaveis.GetInstancia.CodigoItem);
  end
  else
    ShowMessage('Comanda bloqueada!!!' + #13 + 'Operação não pode ser realizada.' + #13 +
      'Entre em contato com a gerência.');
end;

procedure TMenuItem.actionItem;
begin
  FActionSheetItem := TActionSheet.Create(Self);
  FActionSheetItem.TitleFontSize := 12;
  FActionSheetItem.TitleMenuText := 'O que deseja fazer?';
  FActionSheetItem.TitleFontColor := $FF8B8B8B;

  FActionSheetItem.CancelMenuText := 'Cancelar';
  FActionSheetItem.CancelFontSize := 17;
  FActionSheetItem.CancelFontColor := $FF087AF7;

  FActionSheetItem.BackgroundOpacity := 0.5;
  FActionSheetItem.MenuColor := $FFFFFFFF;

  FActionSheetItem.AddItem('001', 'Excluir Item', actionExcluirItem, $FFE7404A);
  FActionSheetItem.AddItem('002', 'Trocar Comanda', actionAlterarComanda);
  FActionSheetItem.AddItem('003', 'Alterar Observação', actionAlterarObservacao);
end;

procedure TMenuItem.adicionarItem(ACodigoComanda: integer; ACodigoMesa: integer;
  ACodigoProduto: integer; ACodigoBarra: string; ACodigoReduzido: integer;
  ADescricaoProduto: string; AQuantidadeItem: double; AValorUnitarioItem: double;
  AObservacaoItem: string);
var
  LThread: TThread;

begin
  resetTimer;

  TLoading.Show(ViewMenu, 'Aguarde, inserindo item...');

  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      DM.inserirMTItens(ACodigoComanda, ACodigoMesa, ACodigoProduto, ACodigoBarra, ACodigoReduzido,
        ADescricaoProduto, AQuantidadeItem, AValorUnitarioItem, AObservacaoItem);
    end);

  LThread.OnTerminate := adicionarItemFim;
  LThread.start;
end;

procedure TMenuItem.adicionarItemFim(Sender: TObject);
var
  ex: TObject;

begin
  Sleep(100);
  TLoading.Hide;

  ex := TThread(Sender).FatalException;
  if Assigned(TThread(Sender).FatalException) then
    ShowMessage('Erro inserindo item!, tente novamente...' + #13 + Exception(ex).Message)
  else
    carregaMenuItem;

  FTravaBotaoAcao := False;
  FTravaBotaoConfirmar := False;
end;

procedure TMenuItem.ajustaForm;
begin
  resetTimer;

  TVariaveis.GetInstancia.TelaAnterior := TVariaveis.GetInstancia.TelaAtiva;
  TVariaveis.GetInstancia.TelaAtiva := 'TMenuItem';
end;

procedure TMenuItem.alterarComanda(ACodigoComanda, ACodigoNovaComanda, AItemComanda: integer);
var
  LThread: TThread;

begin
  resetTimer;

  TLoading.Show(ViewMenu, 'Aguarde, alterando item...');

  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      DM.alterarComandaMTItens(ACodigoComanda, ACodigoNovaComanda, AItemComanda);
    end);

  LThread.OnTerminate := alterarComandaFim;
  LThread.start;
end;

procedure TMenuItem.alterarComandaFim(Sender: TObject);
var
  ex: TObject;

begin
  Sleep(100);
  TLoading.Hide;

  ex := TThread(Sender).FatalException;
  if Assigned(TThread(Sender).FatalException) then
    ShowMessage('Erro alterando comanda!, tente novamente...' + #13 + Exception(ex).Message)
  else
    carregaMenuComanda;
end;

procedure TMenuItem.alterarObservacao(ACodigoComanda: integer; ACodigoItem: integer;
AObservacaoItem: string);
var
  LThread: TThread;

begin
  resetTimer;

  TLoading.Show(ViewMenu, 'Aguarde, alterando observação do item...');

  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      DM.alterarObservacaoMTItens(ACodigoComanda, ACodigoItem, AObservacaoItem);
    end);

  LThread.OnTerminate := alterarObservacaoFim;
  LThread.start;
end;

procedure TMenuItem.alterarObservacaoFim(Sender: TObject);
var
  ex: TObject;

begin
  Sleep(100);
  TLoading.Hide;

  ex := TThread(Sender).FatalException;
  if Assigned(TThread(Sender).FatalException) then
    ShowMessage('Erro alterando observação!, tente novamente ou clique em voltar...' + #13 +
      Exception(ex).Message)
  else if (TVariaveis.GetInstancia.TelaAtiva = 'TFormTecladoAlfaNumerico') and
    (FTecladoAlfaNumerico.FFuncaoDoTeclado = 'observacaoQtde') then
    tecladoNumericoQuantidade(True)
  else
    carregaMenuItem;

  FTravaBotaoConfirmar := False;
end;

procedure TMenuItem.botaoAcao(Sender: TObject);
begin
  if (FTecladoNumerico.FFuncaoDoTeclado = 'produto') and
    (FTecladoNumerico.LabelResultado.Text <> '') and not FTravaBotaoAcao then
  begin
    FTravaBotaoAcao := True;

    resetTimer;

    TVariaveis.GetInstancia.QuantidadeItem := 1;
    TVariaveis.GetInstancia.ObservacaoItem := '';

    adicionarItem(TVariaveis.GetInstancia.CodigoComanda, TVariaveis.GetInstancia.CodigoMesa,
      TVariaveis.GetInstancia.CodigoProduto, TVariaveis.GetInstancia.CodigoBarra,
      TVariaveis.GetInstancia.CodigoReduzido, TVariaveis.GetInstancia.DescricaoProduto,
      TVariaveis.GetInstancia.QuantidadeItem, TVariaveis.GetInstancia.ValorUnitario,
      TVariaveis.GetInstancia.ObservacaoItem);
  end;
end;

procedure TMenuItem.botaoAcao2(Sender: TObject);
begin
  resetTimer;

  if (TVariaveis.GetInstancia.TelaAtiva = 'TFormTecladoNumerico') then
  begin
    if (FTecladoNumerico.FFuncaoDoTeclado = 'produto') then
      tecladoAlfaNumericoProduto(True)
    else if (FTecladoNumerico.FFuncaoDoTeclado = 'quantidade') then
      tecladoAlfaNumericoAlterarObservacaoQtde(True);
  end;
end;

procedure TMenuItem.botaoAdicionar(Sender: TObject);
begin
  resetTimer;

  if TVariaveis.GetInstancia.Bloqueio = 0 then
    tecladoNumericoProduto(True)
  else
    ShowMessage('Comanda bloqueada!!!' + #13 + 'Operação não pode ser realizada.' + #13 +
      'Entre em contato com a gerência.');
end;

procedure TMenuItem.botaoConfirmar(Sender: TObject);
var
  formatSettings: TFormatSettings;

begin
  resetTimer;

  if not FTravaBotaoConfirmar then
    if (TVariaveis.GetInstancia.TelaAtiva = 'TFormTecladoNumerico') then
    begin
      if (FTecladoNumerico.FFuncaoDoTeclado = 'produto') and
        (FTecladoNumerico.LabelResultado.Text <> '') then
      begin
        // TVariaveis.GetInstancia.CodigoProduto := FTecladoNumerico.LabelResultado.Tag;
        // TVariaveis.GetInstancia.DescricaoProduto := FTecladoNumerico.LabelResultado.Text;

        tecladoNumericoQuantidade(True);
      end
      else if (FTecladoNumerico.FFuncaoDoTeclado = 'quantidade') and
        (FTecladoNumerico.FValorRetorno <> '') then
      begin
        FTravaBotaoConfirmar := True;

        formatSettings.ThousandSeparator := '.';
        formatSettings.DecimalSeparator := ',';

        TVariaveis.GetInstancia.QuantidadeItem := StrToFloat(FTecladoNumerico.FValorRetorno);

        adicionarItem(TVariaveis.GetInstancia.CodigoComanda, TVariaveis.GetInstancia.CodigoMesa,
          TVariaveis.GetInstancia.CodigoProduto, TVariaveis.GetInstancia.CodigoBarra,
          TVariaveis.GetInstancia.CodigoReduzido, TVariaveis.GetInstancia.DescricaoProduto,
          TVariaveis.GetInstancia.QuantidadeItem, TVariaveis.GetInstancia.ValorUnitario,
          TVariaveis.GetInstancia.ObservacaoItem)
      end
      else if (FTecladoNumerico.FFuncaoDoTeclado = 'senhaExcluirItem') and
        (FTecladoNumerico.FValorRetorno <> '') then
        confirmaSenha(FTecladoNumerico.FValorRetorno)
      else if (FTecladoNumerico.FFuncaoDoTeclado = 'alterarComanda') and
        (FTecladoNumerico.FValorRetorno <> '') then
      begin
        TVariaveis.GetInstancia.CodigoNovaComanda := StrToInt(FTecladoNumerico.FValorRetorno);

        alterarComanda(TVariaveis.GetInstancia.CodigoComanda,
          TVariaveis.GetInstancia.CodigoNovaComanda, TVariaveis.GetInstancia.CodigoItem);
      end;
    end
    else if (TVariaveis.GetInstancia.TelaAtiva = 'TFormTecladoAlfaNumerico') then
    begin
      if (FTecladoAlfaNumerico.FFuncaoDoTeclado = 'produto') and
        (FTecladoAlfaNumerico.FValorRetorno <> '') then
      begin
        FConsultaProduto := FTecladoAlfaNumerico.FValorRetorno;

        carregaFormProduto;
      end
      else if (FTecladoAlfaNumerico.FFuncaoDoTeclado = 'observacaoItem') then
      begin
        FTravaBotaoConfirmar := True;

        TVariaveis.GetInstancia.ObservacaoItem := FTecladoAlfaNumerico.FValorRetorno;

        alterarObservacao(TVariaveis.GetInstancia.CodigoComanda, TVariaveis.GetInstancia.CodigoItem,
          TVariaveis.GetInstancia.ObservacaoItem);
      end
      else if (FTecladoAlfaNumerico.FFuncaoDoTeclado = 'observacaoQtde') then
      begin
        FTravaBotaoConfirmar := True;

        TVariaveis.GetInstancia.ObservacaoItem := FTecladoAlfaNumerico.FValorRetorno;

        alterarObservacao(TVariaveis.GetInstancia.CodigoComanda, TVariaveis.GetInstancia.CodigoItem,
          TVariaveis.GetInstancia.ObservacaoItem);
      end;
    end;
end;

procedure TMenuItem.botaoVoltar(Sender: TObject);
begin
  TVariaveis.GetInstancia.ObservacaoItem := '';
  resetTimer;

  if (TVariaveis.GetInstancia.TelaAtiva = 'TMenuItem') then
    carregaMenuComanda
  else if (TVariaveis.GetInstancia.TelaAtiva = 'TFormItem') then
    carregaMenuComanda
  else if (TVariaveis.GetInstancia.TelaAtiva = 'TFormProduto') then
    carregaMenuItem
  else if (TVariaveis.GetInstancia.TelaAtiva = 'TFormTecladoNumerico') then
  begin
    carregaMenuItem
  end
  else if (TVariaveis.GetInstancia.TelaAtiva = 'TFormTecladoAlfaNumerico') then
  begin
    if (TVariaveis.GetInstancia.TelaAnterior = 'TFormTecladoNumerico') and
      (FTecladoNumerico.FFuncaoDoTeclado = 'alterarObservacao') then
      tecladoNumericoQuantidade(True)
    else
      carregaMenuItem;
  end;
end;

procedure TMenuItem.carregaMenuComanda;
var
  t: TThread;

begin
  resetTimer;

  TLoading.Show(MenuItem, 'Aguarde, imprimindo itens...');

  t := TThread.CreateAnonymousThread(
    procedure
    begin
      DM.imprimirMTComanda(TVariaveis.GetInstancia.CodigoComanda);
    end);

  t.OnTerminate := carregaMenuComandaFim;
  t.start;
end;

procedure TMenuItem.carregaMenuComandaFim(Sender: TObject);
var
  ex: TObject;

begin
  Sleep(100);
  TLoading.Hide;

  ex := TThread(Sender).FatalException;
  if Assigned(TThread(Sender).FatalException) then
    ShowMessage('Erro imprimindo itens!, tente novamente...' + #13 + Exception(ex).Message)
  else
  begin
    if not Assigned(MenuComanda) then
      Application.CreateForm(TMenuComanda, MenuComanda);

    Application.MainForm := MenuComanda;
    MenuComanda.Show;

    MenuItem.TabControl.ActiveTab := TabItemBase;
    MenuItem.Close;
  end;
end;

procedure TMenuItem.carregaMenuItem;
var
  t: TThread;

begin
  resetTimer;

  TLoading.Show(MenuItem, 'Aguarde, carregando itens...');

  t := TThread.CreateAnonymousThread(
    procedure
    begin
      DM.servidorMTItens(TVariaveis.GetInstancia.CodigoComanda,
        TVariaveis.GetInstancia.CodigoEmpresa, 0);
    end);

  t.OnTerminate := carregaMenuItemFim;
  t.start;
end;

procedure TMenuItem.carregaMenuItemFim(Sender: TObject);
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
    FTelaItem.ajustaForm(True);
    ChangeTabActionBase.Execute;
  end;
end;

procedure TMenuItem.confirmaSenha(ASenha: string);
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

procedure TMenuItem.confirmaSenhaFim(Sender: TObject);
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
    if (TVariaveis.GetInstancia.TelaAtiva = 'TFormTecladoNumerico') then
    begin
      if (DM.mtSenhas.RecordCount > 0) and (FTecladoNumerico.FFuncaoDoTeclado = 'senhaExcluirItem')
      then
        excluirItem(TVariaveis.GetInstancia.CodigoComanda, TVariaveis.GetInstancia.CodigoItem)
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

            if (FTecladoNumerico.FFuncaoDoTeclado = 'senhaExcluirItem') then
              carregaMenuItem;
          end);
      end;
    end;
  end;
end;

procedure TMenuItem.carregaFormProduto;
begin
  resetTimer;

  FTelaProduto.FConsultaProduto := FConsultaProduto;
  FTelaProduto.FPesquisarEmDescricaoTambem := True;
  FTelaProduto.ajustaForm(True);
  ChangeTabActionProduto.Execute;
end;

procedure TMenuItem.excluirItem(ACodigoComanda: integer; AItemComanda: integer);
var
  LThread: TThread;

begin
  resetTimer;

  TLoading.Show(ViewMenu, 'Aguarde, excluindo item...');

  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      DM.excluirMTItens(ACodigoComanda, AItemComanda);
    end);

  LThread.OnTerminate := excluirItemFim;
  LThread.start;
end;

procedure TMenuItem.excluirItemFim(Sender: TObject);
var
  ex: TObject;

begin
  Sleep(100);
  TLoading.Hide;

  ex := TThread(Sender).FatalException;
  if Assigned(TThread(Sender).FatalException) then
    ShowMessage('Erro carregando itens!, tente novamente...' + #13 + Exception(ex).Message)
  else
    carregaMenuItem;
end;

procedure TMenuItem.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Timer.Enabled := False;
end;

procedure TMenuItem.FormCreate(Sender: TObject);
begin
{$IFDEF MSWINDOWS}
  MenuItem.Width := 800;
  MenuItem.Height := 600;
  MenuItem.Top := ViewMenu.Top;
  MenuItem.Left := ViewMenu.Left;

  MenuItem.WindowState := TWindowState.wsMaximized;
{$ENDIF}
  actionItem;

  FTelaItem := TFormItem.Create(Self);
  FTelaItem.ImageVoltar.OnClick := botaoVoltar;
  FTelaItem.ImageNovoItem.OnClick := botaoAdicionar;
  FTelaItem.ListView.OnItemClickEx := listViewItemClickExItem;

  FTelaProduto := TFormProduto.Create(Self);
  FTelaProduto.ImageVoltar.OnClick := botaoVoltar;
  FTelaProduto.ListView.OnItemClick := listViewItemClickProduto;

  FTecladoNumerico := TFormTecladoNumerico.Create(Self);
  FTecladoNumerico.LabelAcaoConfirmar.OnClick := botaoConfirmar;
  FTecladoNumerico.LabelAcaoListar.OnClick := botaoAcao;
  FTecladoNumerico.LabelAcaoVoltar.OnClick := botaoVoltar;
  FTecladoNumerico.Label11.OnClick := botaoAcao2;

  FTecladoAlfaNumerico := TFormTecladoAlfaNumerico.Create(Self);
  FTecladoAlfaNumerico.LabelAcaoConfirmar.OnClick := botaoConfirmar;
  FTecladoAlfaNumerico.LabelAcaoVoltar.OnClick := botaoVoltar;

  embeddForm(RectangleBase, FTelaItem);
  embeddForm(RectangleProduto, FTelaProduto);
  embeddForm(RectangleTecladoNumerico, FTecladoNumerico);
  embeddForm(RectangleTecladoAlfaNumerico, FTecladoAlfaNumerico);

  TabControl.ActiveTab := TabItemBase;
end;

procedure TMenuItem.FormDestroy(Sender: TObject);
begin
  FActionSheetItem.DisposeOf;
end;

procedure TMenuItem.FormShow(Sender: TObject);
begin
  FTravaBotaoAcao := False;
  FTravaBotaoConfirmar := False;

  resetTimer;

  FTelaItem.ajustaForm(True);
  ChangeTabActionBase.Execute;
end;

procedure TMenuItem.listViewItemClickExItem(const Sender: TObject; ItemIndex: integer;
const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
var
  txt: TListItemText;
  Item: TListViewItem;

begin
  resetTimer;

  if TListView(Sender).Selected <> nil then
  begin
    Item := TListView(Sender).Items[ItemIndex];

    TVariaveis.GetInstancia.CodigoItem := Item.Tag;

    txt := TListItemText(Item.Objects.FindDrawable('Text16'));
    TVariaveis.GetInstancia.ObservacaoItem := txt.Text;

    if ItemObject is TListItemImage then
    begin
      if (TListItemImage(ItemObject).Name = 'image1') then
        FActionSheetItem.ShowMenu;
    end;
  end;
end;

procedure TMenuItem.listViewItemClickProduto(const Sender: TObject; const AItem: TListViewItem);
var
  txt: TListItemText;
  formatSettings: TFormatSettings;

begin
  resetTimer;

  if TListView(Sender).Selected <> nil then
  begin
    formatSettings.ThousandSeparator := '.';
    formatSettings.DecimalSeparator := ',';

    txt := TListItemText(AItem.Objects.FindDrawable('Text2'));
    TVariaveis.GetInstancia.DescricaoProduto := txt.Text;

    txt := TListItemText(AItem.Objects.FindDrawable('Text6'));
    TVariaveis.GetInstancia.CodigoProduto := StrToInt(txt.Text);

    txt := TListItemText(AItem.Objects.FindDrawable('Text7'));
    TVariaveis.GetInstancia.CodigoBarra := txt.Text;

    txt := TListItemText(AItem.Objects.FindDrawable('Text8'));
    try
      TVariaveis.GetInstancia.CodigoReduzido := StrToInt(txt.Text);
    except
      TVariaveis.GetInstancia.CodigoReduzido := 0;
    end;

    txt := TListItemText(AItem.Objects.FindDrawable('Text10'));
    try
      TVariaveis.GetInstancia.ValorUnitario := StrToFloat(txt.Text);
    except
      TVariaveis.GetInstancia.ValorUnitario := 0;
    end;

    txt := TListItemText(AItem.Objects.FindDrawable('Text11'));
    TVariaveis.GetInstancia.UnidadeProduto := UpperCase(txt.Text);

    tecladoNumericoQuantidade(True);
  end;
end;

procedure TMenuItem.resetTimer;
begin
  Timer.Enabled := False;
  Timer.Enabled := True;
end;

procedure TMenuItem.tecladoAlfaNumericoAlterarObservacaoItem(AExecutar: boolean);
begin
  resetTimer;

  FTecladoAlfaNumerico.FFuncaoDoTeclado := 'observacaoItem';
  FTecladoAlfaNumerico.LabelTitulo.Text := 'informe a observação';
  FTecladoAlfaNumerico.LabelResultado.Text := 'Observação';
  FTecladoAlfaNumerico.LabelValor.Text := TVariaveis.GetInstancia.ObservacaoItem;
  FTecladoAlfaNumerico.LabelResultado.Text := EmptyStr;
  FTecladoAlfaNumerico.FTecladoFisico := TVariaveis.GetInstancia.TecladoFisicoAtivado;
  FTecladoAlfaNumerico.ajustaForm;
  ChangeTabActionTecladoAlfaNumerico.Execute;
  if FTecladoAlfaNumerico.FTecladoFisico then
    FTecladoAlfaNumerico.EditValor.SetFocus;
end;

procedure TMenuItem.tecladoAlfaNumericoAlterarObservacaoQtde(AExecutar: boolean);
begin
  resetTimer;

  FTecladoAlfaNumerico.FFuncaoDoTeclado := 'observacaoQtde';
  FTecladoAlfaNumerico.LabelTitulo.Text := 'informe a observação';
  FTecladoAlfaNumerico.LabelResultado.Text := 'Observação';
  FTecladoAlfaNumerico.LabelValor.Text := TVariaveis.GetInstancia.ObservacaoItem;
  FTecladoAlfaNumerico.LabelResultado.Text := EmptyStr;
  FTecladoAlfaNumerico.FTecladoFisico := TVariaveis.GetInstancia.TecladoFisicoAtivado;
  FTecladoAlfaNumerico.ajustaForm;
  ChangeTabActionTecladoAlfaNumerico.Execute;
  if FTecladoAlfaNumerico.FTecladoFisico then
    FTecladoAlfaNumerico.EditValor.SetFocus;
end;

procedure TMenuItem.tecladoAlfaNumericoProduto(AExecutar: boolean);
begin
  resetTimer;

  FTecladoAlfaNumerico.FFuncaoDoTeclado := 'produto';
  FTecladoAlfaNumerico.LabelTitulo.Text := 'informe o produto';
  FTecladoAlfaNumerico.LabelResultado.Text := 'Produto';
  FTecladoAlfaNumerico.LabelValor.Text := EmptyStr;
  FTecladoAlfaNumerico.LabelResultado.Text := EmptyStr;
  FTecladoAlfaNumerico.FTecladoFisico := TVariaveis.GetInstancia.TecladoFisicoAtivado;
  FTecladoAlfaNumerico.ajustaForm;
  ChangeTabActionTecladoAlfaNumerico.Execute;
  if FTecladoAlfaNumerico.FTecladoFisico then
    FTecladoAlfaNumerico.EditValor.SetFocus;
end;

procedure TMenuItem.tecladoNumericoAlterarComanda(AExecutar: boolean);
begin
  resetTimer;

  TVariaveis.GetInstancia.ObservacaoItem := '';

  FTecladoNumerico.FFuncaoDoTeclado := 'alterarComanda';
  FTecladoNumerico.LabelTitulo.Text := 'informe a nova comanda';
  FTecladoNumerico.LabelResultado.Text := 'Comanda atual: ' +
    IntToStr(TVariaveis.GetInstancia.CodigoComanda);
  FTecladoNumerico.LabelValor.Text := EmptyStr;
  FTecladoNumerico.FValorRetorno := EmptyStr;
  FTecladoNumerico.FSenhaRetorno := EmptyStr;
  FTecladoNumerico.FTecladoFisico := TVariaveis.GetInstancia.TecladoFisicoAtivado;
  FTecladoNumerico.FTeclaDecimal := False;
  FTecladoNumerico.ajustaForm;
  ChangeTabActionTecladoNumerico.Execute;
  if FTecladoNumerico.FTecladoFisico then
    FTecladoNumerico.EditValor.SetFocus;
end;

procedure TMenuItem.tecladoNumericoProduto(AExecutar: boolean);
begin
  resetTimer;

  TVariaveis.GetInstancia.ObservacaoItem := '';

  FTecladoNumerico.FFuncaoDoTeclado := 'produto';
  FTecladoNumerico.LabelTitulo.Text := 'informe o produto';
  FTecladoNumerico.LabelResultado.Text := EmptyStr;
  FTecladoNumerico.LabelValor.Text := EmptyStr;
  FTecladoNumerico.FValorRetorno := EmptyStr;
  FTecladoNumerico.FSenhaRetorno := EmptyStr;
  FTecladoNumerico.FTecladoFisico := TVariaveis.GetInstancia.TecladoFisicoAtivado;
  FTecladoNumerico.FTeclaDecimal := False;
  FTecladoNumerico.ajustaForm;
  ChangeTabActionTecladoNumerico.Execute;
  if FTecladoNumerico.FTecladoFisico then
    FTecladoNumerico.EditValor.SetFocus;
end;

procedure TMenuItem.tecladoNumericoQuantidade(AExecutar: boolean);
begin
  resetTimer;

  FTecladoNumerico.FFuncaoDoTeclado := 'quantidade';
  FTecladoNumerico.LabelTitulo.Text := 'informe a quantidade';
  FTecladoNumerico.LabelResultado.Text := TVariaveis.GetInstancia.DescricaoProduto;
  FTecladoNumerico.LabelValor.Text := EmptyStr;
  FTecladoNumerico.FValorRetorno := EmptyStr;
  FTecladoNumerico.FSenhaRetorno := EmptyStr;
  FTecladoNumerico.FTecladoFisico := TVariaveis.GetInstancia.TecladoFisicoAtivado;

  if TVariaveis.GetInstancia.UnidadeProduto = 'KG' then
    FTecladoNumerico.FTeclaDecimal := True
  else
    FTecladoNumerico.FTeclaDecimal := False;

  FTecladoNumerico.ajustaForm;
  ChangeTabActionTecladoNumerico.Execute;
  if FTecladoNumerico.FTecladoFisico then
    FTecladoNumerico.EditValor.SetFocus;
end;

procedure TMenuItem.tecladoNumericoSenhaExcluirItem(AExecutar: boolean);
begin
  resetTimer;

  TVariaveis.GetInstancia.ObservacaoItem := '';

  FTecladoNumerico.FFuncaoDoTeclado := 'senhaExcluirItem';
  FTecladoNumerico.LabelTitulo.Text := 'informe a senha';
  FTecladoNumerico.LabelResultado.Text := EmptyStr;
  FTecladoNumerico.LabelValor.Text := EmptyStr;
  FTecladoNumerico.FValorRetorno := EmptyStr;
  FTecladoNumerico.FSenhaRetorno := EmptyStr;
  FTecladoNumerico.FTecladoFisico := TVariaveis.GetInstancia.TecladoFisicoAtivado;
  FTecladoNumerico.FTeclaDecimal := False;
  FTecladoNumerico.ajustaForm;
  ChangeTabActionTecladoNumerico.Execute;
  if FTecladoNumerico.FTecladoFisico then
    FTecladoNumerico.EditValor.SetFocus;
end;

procedure TMenuItem.TimerTimer(Sender: TObject);
begin
  TVariaveis.GetInstancia.ObservacaoItem := '';

  Timer.Enabled := False;
  carregaMenuComanda;
end;

end.
