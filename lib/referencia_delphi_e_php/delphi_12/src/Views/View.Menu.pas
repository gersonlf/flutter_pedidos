unit View.Menu;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Actions,
  System.JSON,

  System.UIConsts,

  Data.DB,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Objects,
  FMX.Layouts,
  FMX.TabControl,
  FMX.ActnList,
  FMX.ListView.Appearances,
  FMX.ListView.Types,
  FMX.ListView,
{$IFDEF ANDROID}
  FMX.VirtualKeyBoard,
  FMX.Platform,
{$ENDIF}
  Util.ActionSheet,
  Util.Funcao,
  Util.Notificacao,

  Singleton.Variaveis,
  Service.DM,

  TecladoNumerico,
  TecladoAlfaNumerico,

  View.Mensagem,

  List.Comanda,
  List.Pedido,
  List.Funcionario,
  List.Item,
  List.Produto,
  List.Acompanhamento,
  List.Adicional,

  FMX.Ani,
  FMX.ListView.Adapters.Base,
  FMX.Edit;

type
  TViewMenu = class(TForm)
    LayoutBase: TLayout;
    RectangleMenu: TRectangle;
    LabelMenu: TLabel;
    ImageConfiguracoes: TImage;
    ImageAtualizar: TImage;
    LayoutMenu: TLayout;
    LayoutBotaoFuncionario: TLayout;
    RectangleBotaoFuncionario: TRectangle;
    LabelBotaoFuncionario: TLabel;
    LayoutBotaoComanda: TLayout;
    RectangleBotaoComanda: TRectangle;
    LabelBotaoComanda: TLabel;
    LayoutBotaoProduto: TLayout;
    RectangleBotaoProduto: TRectangle;
    LabelBotaoProduto: TLabel;
    RectangleFuncionario: TRectangle;
    LabelFuncionarioMenu: TLabel;
    TabControl: TTabControl;
    TabItemMenu: TTabItem;
    TabItemTecladoNumerico: TTabItem;
    RectangleBase: TRectangle;
    ActionList: TActionList;
    ChangeTabActionMenu: TChangeTabAction;
    ChangeTabActionTecladoNumerico: TChangeTabAction;
    TabItemTecladoAlfaNumerico: TTabItem;
    ChangeTabActionTecladoAlfaNumerico: TChangeTabAction;
    LayoutCozinha: TLayout;
    RectangleCozinha: TRectangle;
    LabelCozinha: TLabel;
    TabItemListViewPedido: TTabItem;
    Rectangle3: TRectangle;
    Label2: TLabel;
    ImageVoltarPedido: TImage;
    ListViewPedido: TListView;
    ChangeTabActionListViewPedido: TChangeTabAction;
    TabItemConfirmacao: TTabItem;
    Layout3: TLayout;
    Layout4: TLayout;
    LabelMensagem: TLabel;
    RectangleConfirmacaoSim: TRectangle;
    RectangleConfirmacaoNao: TRectangle;
    Label6: TLabel;
    Label7: TLabel;
    ChangeTabActionConfirmacao: TChangeTabAction;
    TabItemListViewComanda: TTabItem;
    TabItemConfiguracao: TTabItem;
    TabItemListViewFuncionario: TTabItem;
    TabItemListViewItem: TTabItem;
    TabItemListViewProduto: TTabItem;
    Layout1: TLayout;
    Rectangle1: TRectangle;
    Label1: TLabel;
    Layout2: TLayout;
    Layout5: TLayout;
    Label3: TLabel;
    RectangleEndereco: TRectangle;
    LabelEndereco: TLabel;
    Layout6: TLayout;
    Label4: TLabel;
    RectanglePorta: TRectangle;
    LabelPorta: TLabel;
    Layout7: TLayout;
    Label5: TLabel;
    RectangleContexto: TRectangle;
    LabelContexto: TLabel;
    Layout8: TLayout;
    Label8: TLabel;
    RectangleProtocolo: TRectangle;
    LabelProtocolo: TLabel;
    Layout9: TLayout;
    Label9: TLabel;
    RectangleTecladoFisico: TRectangle;
    LabelTecladoFisico: TLabel;
    Layout10: TLayout;
    Label10: TLabel;
    RectangleComandaDigitoVerificador: TRectangle;
    LabelComandaDigitoVerificador: TLabel;
    Layout11: TLayout;
    Label11: TLabel;
    RectangleExcluirItemComanda: TRectangle;
    LabelExcluirItemComanda: TLabel;
    Layout12: TLayout;
    Rectangle2: TRectangle;
    Label12: TLabel;
    ImageNovaComanda: TImage;
    ListViewComanda: TListView;
    ImageMaisOpcoesComanda: TImage;
    Rectangle4: TRectangle;
    LabelFuncionarioComanda: TLabel;
    Layout13: TLayout;
    Rectangle5: TRectangle;
    Label14: TLabel;
    ListViewFuncionario: TListView;
    Layout14: TLayout;
    Rectangle6: TRectangle;
    Label15: TLabel;
    ImageVoltarItem: TImage;
    ImageNovoItem: TImage;
    RectangleFuncionarioItem: TRectangle;
    LabelFuncionarioItem: TLabel;
    RectangleCabecalho: TRectangle;
    LabelComandaItem: TLabel;
    LabelValor: TLabel;
    ListViewItem: TListView;
    ImageMaisOpcoesItem: TImage;
    Layout15: TLayout;
    Rectangle8: TRectangle;
    Label17: TLabel;
    ImageVoltarProduto: TImage;
    ListViewProduto: TListView;
    ChangeTabActionListViewComanda: TChangeTabAction;
    ChangeTabActionListViewFuncionario: TChangeTabAction;
    ChangeTabActionListViewItem: TChangeTabAction;
    ChangeTabActionListViewProduto: TChangeTabAction;
    ChangeTabActionConfiguracao: TChangeTabAction;
    RectangleTecladoNumerico: TRectangle;
    ImageVoltarConfiguracao: TImage;
    ImageVoltarFuncionario: TImage;
    ImageVoltarComanda: TImage;
    RectangleTecladoAlfaNumerico: TRectangle;
    RectangleConfirmarConfiguracao: TRectangle;
    Label13: TLabel;
    TimerAtualizacao: TTimer;
    TabItemListViewAcompanhamentos: TTabItem;
    TabItemListViewAdicionais: TTabItem;
    Layout16: TLayout;
    Rectangle7: TRectangle;
    Label16: TLabel;
    ImageVoltarAcompanhamentos: TImage;
    ListViewAcompanhamentos: TListView;
    Layout17: TLayout;
    Rectangle9: TRectangle;
    Label18: TLabel;
    ImageVoltarAdicionais: TImage;
    ListViewAdicionais: TListView;
    ChangeTabActionListViewAcompanhamento: TChangeTabAction;
    ChangeTabActionListViewAdicional: TChangeTabAction;
    ImageProximoAcompanhamentos: TImage;
    ImageProximoAdicionais: TImage;
    procedure ImageConfiguracoesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RectangleBotaoFuncionarioClick(Sender: TObject);
    procedure ImageAtualizarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RectangleCozinhaClick(Sender: TObject);
    procedure ListViewPedidoUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
    procedure ListViewPedidoItemClick(const Sender: TObject; const AItem: TListViewItem);
    procedure RectangleConfirmacaoSimClick(Sender: TObject);
    procedure RectangleConfirmacaoNaoClick(Sender: TObject);
    procedure ImageVoltarConfiguracaoClick(Sender: TObject);
    procedure ListViewComandaUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
    procedure ListViewFuncionarioUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
    procedure ListViewItemUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
    procedure ListViewProdutoUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
    procedure ImageVoltarFuncionarioClick(Sender: TObject);
    procedure ListViewFuncionarioItemClick(const Sender: TObject; const AItem: TListViewItem);
    procedure ImageVoltarComandaClick(Sender: TObject);
    procedure ChangeTabActionListViewComandaUpdate(Sender: TObject);
    procedure ChangeTabActionMenuUpdate(Sender: TObject);
    procedure RectangleBotaoComandaClick(Sender: TObject);
    procedure ListViewComandaItemClickEx(const Sender: TObject; ItemIndex: Integer; const LocalClickPos: TPointF;
      const ItemObject: TListItemDrawable);
    procedure ChangeTabActionListViewItemUpdate(Sender: TObject);
    procedure ImageVoltarItemClick(Sender: TObject);
    procedure ImageNovoItemClick(Sender: TObject);
    procedure ImageNovaComandaClick(Sender: TObject);
    procedure RectangleBotaoProdutoClick(Sender: TObject);
    procedure ImageVoltarPedidoClick(Sender: TObject);
    procedure ImageVoltarProdutoClick(Sender: TObject);
    procedure ListViewProdutoItemClick(const Sender: TObject; const AItem: TListViewItem);
    procedure RectangleConfirmarConfiguracaoClick(Sender: TObject);
    procedure RectangleProtocoloClick(Sender: TObject);
    procedure RectangleTecladoFisicoClick(Sender: TObject);
    procedure RectangleComandaDigitoVerificadorClick(Sender: TObject);
    procedure RectangleExcluirItemComandaClick(Sender: TObject);
    procedure RectangleEnderecoClick(Sender: TObject);
    procedure RectanglePortaClick(Sender: TObject);
    procedure RectangleContextoClick(Sender: TObject);
    procedure ListViewItemItemClickEx(const Sender: TObject; ItemIndex: Integer; const LocalClickPos: TPointF;
      const ItemObject: TListItemDrawable);
    procedure FormDestroy(Sender: TObject);
    procedure ChangeTabActionConfiguracaoUpdate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure TimerAtualizacaoTimer(Sender: TObject);
    procedure ImageVoltarAcompanhamentosClick(Sender: TObject);
    procedure ListViewAcompanhamentosItemClick(const Sender: TObject; const AItem: TListViewItem);
    procedure ListViewAcompanhamentosUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
    procedure ImageProximoAcompanhamentosClick(Sender: TObject);
    procedure ImageVoltarAdicionaisClick(Sender: TObject);
    procedure ListViewAdicionaisItemClick(const Sender: TObject; const AItem: TListViewItem);
    procedure ListViewAdicionaisUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
    procedure ImageProximoAdicionaisClick(Sender: TObject);
    procedure TabControlChange(Sender: TObject);

  private
    { Private declarations }
    FTecladoNumerico: TFormTecladoNumerico;
    FTecladoAlfaNumerico: TFormTecladoAlfaNumerico;

    FDataAtualizacao: TDateTime;
    FTelaAnterior: string;

    FCodigoComanda: string;
    FCodigoMesa: string;
    FCodigoTag: string;
    FBloqueio: string;
    FExcluirItemOuComanda: string;

    FCodigoFuncionario: string;
    FNomeFuncionario: string;

    FCodigoItem: string;

    FCodigoProduto: string;
    FNomeProduto: string;
    FCodigoReduzido: string;
    FCodigoBarra: string;
    FValorUnitario: double;
    FUnidadeProduto: string;
    FObservacao: string;
    FQuantidade: string;

    FControlaMesa: string;
    FControlaTag: string;
    FControlaTroca: string;

    FCodigoNovaMesa: string;

    FActionSheetComanda: TActionSheet;
    FActionSheetItem: TActionSheet;

    FListViewComandaClick: boolean;

    procedure actionItem;
    procedure actionAlterarComandaItem(Sender: TObject);
    procedure actionAlterarObservacao(Sender: TObject);
    procedure actionExcluirItem(Sender: TObject);

    procedure alterarComandaItem(ACodigoFuncionario, ANomeFuncionario, ACodigoComanda, ACodigoNovaComanda,
      ACodigoItem: string);
    procedure alterarComandaItemFim(Sender: TObject);

    procedure alterarObservacao(ANomeFuncionario, ACodigoComanda, ACodigoItem, AObservacaoItem: string);

    procedure excluirItem(ACodigoFuncionario, ANomeFuncionario, ACodigoComanda, ACodigoItem: string);

    procedure confirmaSenhaItem(ASenha: string);
    procedure confirmaSenhaItemFim(Sender: TObject);

    procedure imprimirComanda(ANomeFuncionario, ACodigoComanda: string);

    procedure actionComanda;
    procedure actionAlterarComanda(Sender: TObject);
    procedure actionAlterarMesa(Sender: TObject);
    procedure actionExcluirComanda(Sender: TObject);

    procedure alterarComanda(ACodigoFuncionario, ANomeFuncionario, ACodigoComanda, ACodigoNovaComanda: string);
    procedure alterarComandaFim(Sender: TObject);

    procedure alterarMesa(ANomeFuncionario, ACodigoComanda, ACodigoNovaMesa: string);

    procedure excluirComanda(ACodigoFuncionario, ANomeFuncionario, ACodigoComanda: string);

    procedure confirmaSenhaComanda(ASenha: string);
    procedure confirmaSenhaComandaFim(Sender: TObject);

    procedure confirmaSenhaAlterarComanda(ASenha: string);
    procedure confirmaSenhaAlterarComandaFim(Sender: TObject);

    procedure confirmaSenhaAlterarComandaItem(ASenha: string);
    procedure confirmaSenhaAlterarComandaItemFim(Sender: TObject);

    procedure atualizarTabelas;
    procedure atualizarTabelasFim(Sender: TObject);

    procedure focusTecladoNumerico;
    procedure tecladoNumerico;
    procedure tecladoNumericoSenhaConfiguracao;
    procedure tecladoNumericoComanda;
    procedure tecladoNumericoMesa;
    procedure tecladoNumericoTag;
    procedure tecladoNumericoFuncionario;
    procedure tecladoNumericoItem;
    procedure tecladoNumericoQuantidade;
    procedure tecladoNumericoPedido;
    procedure tecladoNumericoPortaServidor;
    procedure tecladoNumericoAlterarMesa;
    procedure tecladoNumericoAlterarComanda;
    procedure tecladoNumericoAlterarComandaItem;
    procedure tecladoNumericoSenhaExcluirComanda;
    procedure tecladoNumericoSenhaExcluirItem;
    procedure tecladoNumericoSenhaAlterarComanda;
    procedure tecladoNumericoSenhaAlterarComandaItem;

    procedure focusTecladoAlfaNumerico;
    procedure tecladoAlfaNumerico;
    procedure tecladoAlfaNumericoProdutoMenu;
    procedure tecladoAlfaNumericoProdutoItem;
    procedure tecladoAlfaNumericoObservacaoQuantidade;
    procedure tecladoAlfaNumericoEnderecoServidor;
    procedure tecladoAlfaNumericoContexto;
    procedure tecladoAlfaNumericoAlterarObservacaoItem;
    procedure tecladoAlfanumericoObservacao;

    procedure inserirItemListViewPedido;
    procedure inserirItemListViewComanda;
    procedure inserirItemListViewFuncionario;
    procedure inserirItemListViewItem;
    procedure inserirItemListViewProduto;
    procedure inserirItemListViewAcompanhamento;
    procedure inserirItemListViewAdicional;

    procedure insereListaPedido;
    procedure insereListaComanda;
    procedure insereListaFuncionario;
    procedure insereListaItem;
    procedure insereListaProduto;
    procedure insereListaAcompanhamento;
    procedure insereListaAdicional;

    procedure carregaListViewPedido;
    procedure carregaListViewPedidoFim(Sender: TObject);

    procedure carregaListViewComanda;
    procedure carregaListViewComandaFim(Sender: TObject);

    procedure carregaListViewFuncionario;
    procedure carregaListViewFuncionarioFim(Sender: TObject);

    procedure carregaListViewItem(ACodigoComanda: string);
    procedure carregaListViewItemFim(Sender: TObject);

    procedure carregaListViewProduto;
    procedure carregaListViewProdutoFim(Sender: TObject);

    procedure carregaListViewAcompanhamento;
    procedure carregaListViewAcompanhamentoFim(Sender: TObject);

    procedure carregaListViewAdicional;
    procedure carregaListViewAdicionalFim(Sender: TObject);

    procedure alterarObservacaoFim(Sender: TObject);
    procedure alterarMesaFim(Sender: TObject);

    procedure excluirItemFim(Sender: TObject);
    procedure excluirComandaFim(Sender: TObject);

    procedure gravarItem;
    procedure gravarAcompanhamentos;
    procedure gravarAdicionais;
  public
    { Public declarations }
    FVersaoApp: string;
    FVersaoServidor: string;
    FPlataforma: string;

    FValorTotal: double;
    FQtdeItens: Integer;

    procedure ajustaForm;

    procedure botaoConfirmarTecladoNumerico(Sender: TObject);
    procedure botaoVoltarTecladoNumerico(Sender: TObject);
    procedure botaoListarTecladoNumerico(Sender: TObject);
    procedure botaoAcaoTecladoNumerico(Sender: TObject);

    procedure botaoConfirmarTecladoAlfaNumerico(Sender: TObject);
    procedure botaoVoltarTecladoAlfaNumerico(Sender: TObject);

    //procedure validarLogin;
    //procedure validarLoginFim(Sender: TObject);
  end;

var
  ViewMenu: TViewMenu;

implementation

{$R *.fmx}

procedure TViewMenu.actionAlterarComanda(Sender: TObject);
begin
  FActionSheetComanda.HideMenu;

  if FControlaTroca = 'D' then
    ShowMessage('Operação desabilitada!' + #13 + 'Não é possível fazer a troca.')
  else
  if FControlaTroca = 'S' then
    tecladoNumericoSenhaAlterarComanda
  else
  begin
    if FBloqueio = '0' then
      tecladoNumericoAlterarComanda
    else
      ShowMessage('Comanda bloqueada!!!' + #13 + 'Operação não pode ser realizada.' + #13 + 'Entre em contato com a gerência.');
  end;
end;

procedure TViewMenu.actionAlterarComandaItem(Sender: TObject);
begin
  FActionSheetItem.HideMenu;

  if FControlaTroca = 'D' then
    ShowMessage('Operação desabilitada!' + #13 + 'Não é possível fazer a troca.')
  else
  if FControlaTroca = 'S' then
    tecladoNumericoSenhaAlterarComandaItem
  else
  begin
    if FBloqueio = '0' then
      tecladoNumericoAlterarComandaItem
    else
      ShowMessage('Comanda bloqueada!!!' + #13 + 'Operação não pode ser realizada.' + #13 + 'Entre em contato com a gerência.');
  end;
end;

procedure TViewMenu.actionAlterarMesa(Sender: TObject);
begin
  FActionSheetComanda.HideMenu;

  if FBloqueio = '0' then
    tecladoNumericoAlterarMesa
  else
    ShowMessage('Comanda bloqueada!!!' + #13 + 'Operação não pode ser realizada.' + #13 + 'Entre em contato com a gerência.');
end;

procedure TViewMenu.actionAlterarObservacao(Sender: TObject);
begin
  FActionSheetItem.HideMenu;

  if FBloqueio = '0' then
    tecladoAlfaNumericoAlterarObservacaoItem
  else
    ShowMessage('Comanda bloqueada!!!' + #13 + 'Operação não pode ser realizada.' + #13 + 'Entre em contato com a gerência.');
end;

procedure TViewMenu.actionComanda;
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

procedure TViewMenu.actionExcluirComanda(Sender: TObject);
begin
  FActionSheetComanda.HideMenu;

  if FBloqueio = '0' then
  begin
    if FExcluirItemOuComanda = '1' then
      tecladoNumericoSenhaExcluirComanda
    else
      excluirComanda(FCodigoFuncionario, FNomeFuncionario, FCodigoComanda);
  end
  else
    ShowMessage('Comanda bloqueada!!!' + #13 + 'Operação não pode ser realizada.' + #13 + 'Entre em contato com a gerência.');
end;

procedure TViewMenu.actionExcluirItem(Sender: TObject);
begin
  FActionSheetItem.HideMenu;

  if FBloqueio = '0' then
  begin
    if FExcluirItemOuComanda = '1' then
      tecladoNumericoSenhaExcluirItem
    else
      excluirItem(FCodigoFuncionario, FNomeFuncionario, FCodigoComanda, FCodigoItem);
  end
  else
    ShowMessage('Comanda bloqueada!!!' + #13 + 'Operação não pode ser realizada.' + #13 + 'Entre em contato com a gerência.');
end;

procedure TViewMenu.actionItem;
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
  FActionSheetItem.AddItem('002', 'Trocar Comanda', actionAlterarComandaItem);
  FActionSheetItem.AddItem('003', 'Alterar Observação', actionAlterarObservacao);
end;

procedure TViewMenu.ajustaForm;
begin

end;

procedure TViewMenu.alterarComanda(ACodigoFuncionario, ANomeFuncionario, ACodigoComanda,
  ACodigoNovaComanda: string);
var
  LThread: TThread;

begin
  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      DM.alterarComandaMTComandasPHP(ACodigoFuncionario, ANomeFuncionario, ACodigoComanda, ACodigoNovaComanda);
    end);

  LThread.OnTerminate := alterarComandaFim;
  LThread.start;
end;

procedure TViewMenu.alterarComandaFim(Sender: TObject);
begin
  if Assigned(TThread(Sender).FatalException) then
    ShowMessage('Erro alterando comanda!, tente novamente...' + #13 + Exception(TThread(Sender).FatalException).Message)
  else
    carregaListViewComanda;
end;

procedure TViewMenu.alterarComandaItem(ACodigoFuncionario, ANomeFuncionario, ACodigoComanda, ACodigoNovaComanda,
  ACodigoItem: string);
var
  LThread: TThread;

begin
  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      DM.alterarComandaMTItensPHP(ACodigoFuncionario, ANomeFuncionario, ACodigoComanda, ACodigoNovaComanda, ACodigoItem);
    end);

  LThread.OnTerminate := alterarComandaItemFim;
  LThread.start;
end;

procedure TViewMenu.alterarComandaItemFim(Sender: TObject);
var
  ex: TObject;

begin
  ex := TThread(Sender).FatalException;
  if Assigned(TThread(Sender).FatalException) then
    ShowMessage('Erro alterando comanda!, tente novamente...' + #13 + Exception(ex).Message)
  else
    carregaListViewComanda;
end;

procedure TViewMenu.alterarMesa(ANomeFuncionario, ACodigoComanda, ACodigoNovaMesa: string);
var
  LThread: TThread;

begin
  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      FCodigoNovaMesa := ACodigoNovaMesa;
      DM.alterarMesaMTComandasPHP(ANomeFuncionario, ACodigoComanda, ACodigoNovaMesa);
    end);

  LThread.OnTerminate := alterarMesaFim;
  LThread.start;
end;

procedure TViewMenu.alterarMesaFim(Sender: TObject);
var
  ex: TObject;
  LItem: TListViewItem;
  LListItemText: TListItemText;

begin
  ex := TThread(Sender).FatalException;
  if Assigned(TThread(Sender).FatalException) then
    ShowMessage('Erro alterando mesa!, tente novamente...' + #13 + Exception(ex).Message)
  else
  begin
    LItem := TListViewItem(ListViewComanda.Items[ListViewComanda.Tag]);
    with LItem do
    begin
      LListItemText := TListItemText(Objects.FindDrawable('Text4'));
      with LListItemText do
      begin
        Text := FCodigoNovaMesa;
      end;
    end;

    FCodigoNovaMesa := EmptyStr;
    ChangeTabActionListViewComanda.Execute;
  end;
end;

procedure TViewMenu.alterarObservacao(ANomeFuncionario, ACodigoComanda, ACodigoItem, AObservacaoItem: string);
var
  LThread: TThread;

begin
  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      FObservacao := AObservacaoItem;

      DM.alterarObservacaoMTItensPHP(ANomeFuncionario, ACodigoComanda, ACodigoItem, AObservacaoItem);
    end);

  LThread.OnTerminate := alterarObservacaoFim;
  LThread.start;
end;

procedure TViewMenu.alterarObservacaoFim(Sender: TObject);
var
  ex: TObject;
  LItem: TListViewItem;
  LListItemText: TListItemText;

begin
  ex := TThread(Sender).FatalException;
  if Assigned(TThread(Sender).FatalException) then
    ShowMessage('Erro alterando observação!, tente novamente...' + #13 + Exception(ex).Message)
  else
  begin
    LItem := TListViewItem(ListViewItem.Items[ListViewItem.Tag]);
    with LItem do
    begin
      LListItemText := TListItemText(Objects.FindDrawable('Text16'));
      with LListItemText do
      begin
        Text := FObservacao;
      end;
    end;

    FObservacao := EmptyStr;
    ChangeTabActionListViewItem.Execute;
  end;
end;

procedure TViewMenu.atualizarTabelas;
var
  LThread: TThread;

begin
  TimerAtualizacao.Enabled := False;
  TLoading.Show(ViewMenu, 'Aguarde, atualizando tabelas...');

  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      DM.atualizarTabelas;
    end);

  LThread.OnTerminate := atualizarTabelasFim;
  LThread.start;
end;

procedure TViewMenu.atualizarTabelasFim(Sender: TObject);
var
  ex: TObject;

begin
  Sleep(100);
  TLoading.Hide;

  TimerAtualizacao.Enabled := True;

  ex := TThread(Sender).FatalException;
  if Assigned(TThread(Sender).FatalException) then
    ShowMessage('Erro carregando tabelas!, tente novamente...' + #13 + Exception(ex).Message)
  else
  begin
    if DM.mtEmpresas.FieldByName('controla_cozinha').AsString = 'S' then
      RectangleCozinha.Enabled := True
    else
      RectangleCozinha.Enabled := False;

    FControlaMesa := DM.mtEmpresas.FieldByName('controla_mesa').AsString;

    try
      FControlaTag := DM.mtEmpresas.FieldByName('controla_tag').AsString;
    except
      FControlaTag := 'N';
    end;

    try
      FControlaTroca := DM.mtEmpresas.FieldByName('controla_troca').AsString;
    except
      FControlaTroca := 'N';
    end;

    if TVariaveis.GetInstancia.ExcluirItemOuComanda then
      FExcluirItemOuComanda := '1'
    else
      FExcluirItemOuComanda := '0';
  end;
end;

procedure TViewMenu.botaoAcaoTecladoNumerico(Sender: TObject);
begin
  inherited;

  if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoItem') then
    tecladoAlfaNumericoProdutoItem
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoQuantidade') then
  begin
    FQuantidade := FTecladoNumerico.FValorRetorno;
    tecladoAlfaNumericoObservacaoQuantidade;
  end;
end;

procedure TViewMenu.botaoConfirmarTecladoAlfaNumerico(Sender: TObject);
begin
  inherited;

  if (FTecladoAlfaNumerico.FFuncaoDoTeclado = 'TecladoAlfaNumericoProdutoItem') and (FTecladoAlfaNumerico.FValorRetorno <> '')
  then
    carregaListViewProduto
  else if (FTecladoAlfaNumerico.FFuncaoDoTeclado = 'TecladoAlfaNumericoProdutoMenu') and
    (FTecladoAlfaNumerico.FValorRetorno <> '') then
    carregaListViewProduto
  else if (FTecladoAlfaNumerico.FFuncaoDoTeclado = 'TecladoAlfaNumericoObservacaoQuantidade') then
  begin
    FObservacao := FTecladoAlfaNumerico.FValorRetorno;
    tecladoNumericoQuantidade;
  end
  else if (FTecladoAlfaNumerico.FFuncaoDoTeclado = 'TecladoAlfaNumericoEnderecoServidor') and
    (FTecladoAlfaNumerico.FValorRetorno <> '') then
  begin
    TVariaveis.GetInstancia.ServidorREST := FTecladoAlfaNumerico.FValorRetorno;
    ChangeTabActionConfiguracao.Execute;
  end
  else if (FTecladoAlfaNumerico.FFuncaoDoTeclado = 'TecladoAlfaNumericoContexto') and (FTecladoAlfaNumerico.FValorRetorno <> '')
  then
  begin
    TVariaveis.GetInstancia.Contexto := FTecladoAlfaNumerico.FValorRetorno;
    ChangeTabActionConfiguracao.Execute;
  end
  else if (FTecladoAlfaNumerico.FFuncaoDoTeclado = 'TecladoAlfaNumericoAlterarObservacaoItem') then
  begin
    FObservacao := FTecladoAlfaNumerico.FValorRetorno;
    alterarObservacao(FNomeFuncionario, FCodigoComanda, FCodigoItem, FObservacao);
    FObservacao := EmptyStr;
  end
  else if (FTecladoAlfaNumerico.FFuncaoDoTeclado = 'TecladoAlfaNumericoObservacao') then
  begin
    FObservacao := FTecladoAlfaNumerico.FValorRetorno;
    ShowMessage('implementar');
    FObservacao := EmptyStr;
  end;
end;

procedure TViewMenu.botaoConfirmarTecladoNumerico(Sender: TObject);
begin
  inherited;

  if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoSenhaConfiguracao') and
    (FTecladoNumerico.FValorRetorno <> '') then
  begin
    if (FormatDateTime('ddnn', now()) = FTecladoNumerico.FSenhaRetorno) then
      ChangeTabActionConfiguracao.Execute
    else
    begin
      if NOT Assigned(ViewMensagem) then
        Application.CreateForm(TViewMensagem, ViewMensagem);

{$IFDEF MSWINDOWS}
      ViewMensagem.WindowState := TWindowState.wsMaximized;
{$ENDIF}
      ViewMensagem.LabelMensagem.Text := 'Senha inválida!';
      ViewMensagem.ShowModal(
        procedure(ModalResult: TModalResult)
        begin
          ViewMensagem := nil;

          ajustaForm;
          ChangeTabActionMenu.Execute;
        end);
    end;
  end
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoPedidoPronto') and
    (FTecladoNumerico.FValorRetorno <> '') then
  begin
    FCodigoComanda := FTecladoNumerico.FValorRetorno;
    DM.alterarPedidoProntoPHP(FCodigoComanda, FNomeFuncionario);
    ChangeTabActionMenu.Execute;
  end
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoFuncionario')  and
  (FTecladoNumerico.FValorRetorno <> '') then
  begin
    if (FTecladoNumerico.FValorRetorno.ToInteger > 0) and
      (FTecladoNumerico.LabelResultado.Text <> '') then
    begin
      FCodigoFuncionario := FTecladoNumerico.FValorRetorno;
      FNomeFuncionario := FTecladoNumerico.LabelResultado.Text;
      tecladoNumericoComanda;
    end;
  end
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoComanda') and
    (FTecladoNumerico.FValorRetorno <> '') then
  begin
    if (FTecladoNumerico.FValorRetorno.ToInteger > 0) and
      (FTecladoNumerico.LabelResultado.Text <> '') then
    begin
      FCodigoComanda := FTecladoNumerico.FValorRetorno;
      FCodigoMesa := DM.consultarMesaPHP(FCodigoComanda);

      try
        FCodigoTag := DM.consultarTagPHP(FCodigoComanda);
      except
        FCodigoTag := '0';
      end;

      FBloqueio := DM.consultarBloqueioPHP(FCodigoComanda);

      if FBloqueio = '0' then
      begin
        FListViewComandaClick := False;

        if (FControlaMesa = 'S') and (FCodigoMesa = '-1') then
          tecladoNumericoMesa
        else
        begin
          if (FControlaTag = 'S') {and (FCodigoTag = '-1')} then
            tecladoNumericoTag
          else
            tecladoNumericoItem;
        end;
      end
      else
        ShowMessage('Comanda bloqueada!!!' + #13 + 'Operação não pode ser realizada.' + #13 + 'Entre em contato com a gerência.');
    end;
  end
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoMesa') then
  begin
    if FTecladoNumerico.FValorRetorno = '' then
      FCodigoMesa := '0'
    else
      FCodigoMesa := FTecladoNumerico.FValorRetorno;

    if (FControlaTag = 'S') and (FCodigoTag = '-1') then
      tecladoNumericoTag
    else
      tecladoNumericoItem;
  end
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoTag') then
  begin
    if FTecladoNumerico.FValorRetorno = '' then
      FCodigoTag := '0'
    else
      FCodigoTag := FTecladoNumerico.FValorRetorno;

    if FListViewComandaClick then
    begin
      FTelaAnterior := 'ListViewComanda';
      carregaListViewItem(FCodigoComanda);
    end
    else
      tecladoNumericoItem;
  end
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoItem') and
    (FTecladoNumerico.FValorRetorno <> '') and
    (FTecladoNumerico.LabelResultado.Text <> '') then
  begin
    FCodigoProduto := FTecladoNumerico.FCodigoProduto;
    FNomeProduto := FTecladoNumerico.FNomeProduto;
    FCodigoBarra := FTecladoNumerico.FCodigoBarra;
    FCodigoReduzido := FTecladoNumerico.FCodigoReduzido;
    FUnidadeProduto := FTecladoNumerico.FUnidadeProduto;
    FValorUnitario := FTecladoNumerico.FValorUnitario;
    FObservacao := EmptyStr;

    // ******
    //tecladoNumericoQuantidade;
    carregaListViewAcompanhamento;
  end
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoQuantidade') and
    (FTecladoNumerico.FValorRetorno <> '') then
  begin
    FQuantidade := FTecladoNumerico.FValorRetorno;

    DM.inserirMTItensPHP(FCodigoFuncionario, FNomeFuncionario, FCodigoComanda, FCodigoMesa, FCodigoTag, FCodigoProduto,
      FCodigoBarra, FCodigoReduzido, FNomeProduto, FQuantidade, FValorUnitario, FObservacao);

    FCodigoProduto := EmptyStr;
    FNomeProduto := EmptyStr;
    FCodigoBarra := EmptyStr;
    FCodigoReduzido := EmptyStr;
    FUnidadeProduto := EmptyStr;
    FValorUnitario := 0;
    FObservacao := EmptyStr;
    FQuantidade := EmptyStr;

    tecladoNumericoItem;
  end
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoPortaServidor') and
    (FTecladoNumerico.FValorRetorno <> '') then
  begin
    TVariaveis.GetInstancia.PortaREST := FTecladoNumerico.FValorRetorno.ToInteger;
    ChangeTabActionConfiguracao.Execute;
  end
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoAlterarComandaItem') and
    (FTecladoNumerico.FValorRetorno <> '')
  then
  begin
    if DM.consultarBloqueioPHP(FTecladoNumerico.FValorRetorno) = '0' then
    begin
      alterarComandaItem(FCodigoFuncionario, FNomeFuncionario, FCodigoComanda, FTecladoNumerico.FValorRetorno,
        FCodigoItem);
      FObservacao := EmptyStr;
    end
    else
      ShowMessage('Comanda bloqueada!!!' + #13 + 'Operação não pode ser realizada.' + #13 + 'Entre em contato com a gerência.');
  end
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoSenhaAlterarComanda') and
    (FTecladoNumerico.FValorRetorno <> '')
  then
    confirmaSenhaAlterarComanda(FTecladoNumerico.FValorRetorno)
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoSenhaAlterarComandaItem') and
    (FTecladoNumerico.FValorRetorno <> '')
  then
    confirmaSenhaAlterarComandaItem(FTecladoNumerico.FValorRetorno)
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoSenhaExcluirComanda') and
    (FTecladoNumerico.FValorRetorno <> '')
  then
    confirmaSenhaComanda(FTecladoNumerico.FValorRetorno)
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoSenhaExcluirItem') and
    (FTecladoNumerico.FValorRetorno <> '')
  then
  begin
    confirmaSenhaItem(FTecladoNumerico.FValorRetorno);
    FObservacao := EmptyStr;
  end
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoAlterarMesa') and
    (FTecladoNumerico.FValorRetorno <> '') then
    alterarMesa(FNomeFuncionario, FCodigoComanda, FTecladoNumerico.FValorRetorno)
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoAlterarComanda') and
    (FTecladoNumerico.FValorRetorno <> '') then
  begin
    if DM.consultarBloqueioPHP(FTecladoNumerico.FValorRetorno) = '0' then
      alterarComanda(FCodigoFuncionario, FNomeFuncionario, FCodigoComanda, FTecladoNumerico.FValorRetorno)
    else
      ShowMessage('Comanda bloqueada!!!' + #13 + 'Operação não pode ser realizada.' + #13 + 'Entre em contato com a gerência.');
  end;
end;

procedure TViewMenu.botaoListarTecladoNumerico(Sender: TObject);
begin
  inherited;

  if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoPedidoPronto') then
    carregaListViewPedido
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoFuncionario') then
    carregaListViewFuncionario
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoComanda') then
    carregaListViewComanda
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoItem') then
    carregaListViewItem(FCodigoComanda);
end;

procedure TViewMenu.botaoVoltarTecladoAlfaNumerico(Sender: TObject);
begin
  inherited;

  if (FTecladoAlfaNumerico.FFuncaoDoTeclado = 'TecladoAlfaNumericoProdutoMenu') then
    ChangeTabActionMenu.Execute
  else if (FTecladoAlfaNumerico.FFuncaoDoTeclado = 'TecladoAlfaNumericoProdutoItem') then
    tecladoNumericoItem
  else if (FTecladoAlfaNumerico.FFuncaoDoTeclado = 'TecladoAlfaNumericoObservacaoQuantidade') then
    tecladoNumericoQuantidade
  else if (FTecladoAlfaNumerico.FFuncaoDoTeclado = 'TecladoAlfaNumericoEnderecoServidor') then
    ChangeTabActionConfiguracao.Execute
  else if (FTecladoAlfaNumerico.FFuncaoDoTeclado = 'TecladoAlfaNumericoContexto') then
    ChangeTabActionConfiguracao.Execute
  else if (FTecladoAlfaNumerico.FFuncaoDoTeclado = 'TecladoAlfaNumericoAlterarObservacaoItem') then
    ChangeTabActionListViewItem.Execute
  else if (FTecladoAlfaNumerico.FFuncaoDoTeclado = 'TecladoAlfaNumericoObservacao') then
    ChangeTabActionListViewItem.Execute;
end;

procedure TViewMenu.botaoVoltarTecladoNumerico(Sender: TObject);
begin
  inherited;

  if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoSenhaConfiguracao') then
    ChangeTabActionMenu.Execute
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoPedidoPronto') then
    ChangeTabActionMenu.Execute
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoFuncionario') then
    ChangeTabActionMenu.Execute
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoComanda') then
    ChangeTabActionMenu.Execute
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoItem') then
  begin
    imprimirComanda(FNomeFuncionario, FCodigoComanda);

    if FTelaAnterior = 'ListViewComanda' then
      carregaListViewComanda
    else
      tecladoNumericoComanda;
  end
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoQuantidade') then
    tecladoNumericoItem
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoPortaServidor') then
    ChangeTabActionConfiguracao.Execute
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoMesa') then
    tecladoNumericoComanda
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoAlterarComandaItem') then
    ChangeTabActionListViewItem.Execute
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoAlterarMesa') then
    ChangeTabActionListViewComanda.Execute
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoAlterarComanda') then
    ChangeTabActionListViewComanda.Execute
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoSenhaExcluirItem') then
    ChangeTabActionListViewItem.Execute
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoSenhaExcluirComanda') then
    ChangeTabActionListViewComanda.Execute
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoSenhaAlterarComanda') then
    ChangeTabActionListViewComanda.Execute
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoSenhaAlterarComandaItem') then
    ChangeTabActionListViewItem.Execute
  else if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoTag') then
    ChangeTabActionListViewComanda.Execute;
end;

procedure TViewMenu.carregaListViewAcompanhamento;
var
  LThread: TThread;

begin
  //não usar, atrapalha leitura do codigo de barras
  //TLoading.Show(ViewMenu, 'Aguarde, carregando acompanhamentos...');
  //não usar, atrapalha leitura do codigo de barras

  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      ListViewAcompanhamentos.BeginUpdate;
      ListViewAcompanhamentos.ScrollTo(0);
      ListViewAcompanhamentos.Items.Clear;
      ListViewAcompanhamentos.EndUpdate;

      try
        DM.servidorMTAcompanhamentosPHP(FCodigoProduto);
        if not DM.mtAcompanhamentos.IsEmpty then
          insereListaAcompanhamento;
      except
        //DM.mtAcompanhamentos.EmptyDataSet;
      end;
    end);

  LThread.OnTerminate := carregaListViewAcompanhamentoFim;
  LThread.start;
end;

procedure TViewMenu.carregaListViewAcompanhamentoFim(Sender: TObject);
var
  ex: TObject;

begin
  Sleep(100);

  //não usar, atrapalha leitura do codigo de barras
  //TLoading.Hide;
  //não usar, atrapalha leitura do codigo de barras

  ex := TThread(Sender).FatalException;
  if Assigned(TThread(Sender).FatalException) then
    tecladoNumericoQuantidade
  else
  begin
    if DM.mtAcompanhamentos.IsEmpty then
    begin
      FTecladoNumerico.Label1.Text := 'acompanhamentos2';
      tecladoNumericoQuantidade;
    end
    else
    begin
      {FQuantidade := '1';

      DM.inserirMTItensPHP(FCodigoFuncionario, FNomeFuncionario, FCodigoComanda, FCodigoMesa, FCodigoProduto,
        FCodigoBarra, FCodigoReduzido, FNomeProduto, FQuantidade, FValorUnitario, FObservacao);

      //FCodigoProduto := EmptyStr;
      FNomeProduto := EmptyStr;
      FCodigoBarra := EmptyStr;
      FCodigoReduzido := EmptyStr;
      FUnidadeProduto := EmptyStr;
      FValorUnitario := 0;
      FObservacao := EmptyStr;
      FQuantidade := EmptyStr;}

      //ChangeTabActionListViewAcompanhamento.Execute;
      TThread.Synchronize(nil,
        procedure
        begin
          TabControl.ActiveTab := TabItemListViewAcompanhamentos;
        end);
    end;
  end;
end;

procedure TViewMenu.carregaListViewAdicional;
var
  LThread: TThread;

begin
  TLoading.Show(ViewMenu, 'Aguarde, carregando adicionais...');

  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      ListViewAdicionais.BeginUpdate;
      ListViewAdicionais.ScrollTo(0);
      ListViewAdicionais.Items.Clear;
      ListViewAdicionais.EndUpdate;

      try
        DM.servidorMTAdicionaisPHP(FCodigoProduto);
        if not DM.mtAdicionais.IsEmpty then
          insereListaAdicional;
      except
        //DM.mtAdicionais.EmptyDataSet;
      end;
    end);

  LThread.OnTerminate := carregaListViewAdicionalFim;
  LThread.start;
end;

procedure TViewMenu.carregaListViewAdicionalFim(Sender: TObject);
begin
  Sleep(100);
  TLoading.Hide;

  if DM.mtAdicionais.IsEmpty then
  begin
    gravarAcompanhamentos;
    gravarItem;
    carregaListViewItem(FCodigoComanda);
  end
  else
  begin
    //ChangeTabActionListViewAdicional.Execute;
    TThread.Synchronize(nil,
      procedure
      begin
        TabControl.ActiveTab := TabItemListViewAdicionais;
      end);
  end;
end;

procedure TViewMenu.carregaListViewComanda;
var
  LThread: TThread;

begin
  TLoading.Show(ViewMenu, 'Aguarde, carregando comandas...');

  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      ListViewComanda.BeginUpdate;
      ListViewComanda.ScrollTo(0);
      ListViewComanda.Items.Clear;
      ListViewComanda.EndUpdate;

      DM.servidorMTComandasPHP('');
      insereListaComanda;
    end);

  LThread.OnTerminate := carregaListViewComandaFim;
  LThread.start;
end;

procedure TViewMenu.carregaListViewComandaFim(Sender: TObject);
var
  ex: TObject;

begin
  Sleep(100);
  TLoading.Hide;

  ex := TThread(Sender).FatalException;
  if Assigned(TThread(Sender).FatalException) then
    ShowMessage('Erro carregando comandas! Tente novamente!' + #13 + Exception(ex).Message)
  else
  begin
    //ChangeTabActionListViewComanda.Execute;
    TThread.Synchronize(nil,
      procedure
      begin
        LabelFuncionarioComanda.Text := FNomeFuncionario;
        TabControl.ActiveTab := TabItemListViewComanda;
      end);
  end;
end;

procedure TViewMenu.carregaListViewFuncionario;
var
  LThread: TThread;

begin
  TLoading.Show(ViewMenu, 'Aguarde, carregando funcionarios...');

  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      ListViewFuncionario.BeginUpdate;
      ListViewFuncionario.ScrollTo(0);
      ListViewFuncionario.Items.Clear;
      ListViewFuncionario.EndUpdate;

      DM.filtrarMTFuncionarios('');
      insereListaFuncionario;
    end);

  LThread.OnTerminate := carregaListViewFuncionarioFim;
  LThread.start;
end;

procedure TViewMenu.carregaListViewFuncionarioFim(Sender: TObject);
var
  ex: TObject;

begin
  Sleep(100);
  TLoading.Hide;

  ex := TThread(Sender).FatalException;
  if Assigned(TThread(Sender).FatalException) then
    ShowMessage('Erro carregando funcionarios! Tente novamente!' + #13 + Exception(ex).Message)
  else
  begin
    //ChangeTabActionListViewFuncionario.Execute;
    TThread.Synchronize(nil,
      procedure
      begin
        TabControl.ActiveTab := TabItemListViewFuncionario;
      end);
  end;
end;

procedure TViewMenu.carregaListViewItem(ACodigoComanda: string);
var
  LThread: TThread;

begin
  TLoading.Show(ViewMenu, 'Aguarde, carregando itens...');

  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      ListViewItem.BeginUpdate;
      ListViewItem.ScrollTo(0);
      ListViewItem.Items.Clear;
      ListViewItem.EndUpdate;

      DM.servidorMTItensPHP(ACodigoComanda);
      insereListaItem;
    end);

  LThread.OnTerminate := carregaListViewItemFim;
  LThread.start;
end;

procedure TViewMenu.carregaListViewItemFim(Sender: TObject);
var
  ex: TObject;

begin
  Sleep(100);
  TLoading.Hide;

  ex := TThread(Sender).FatalException;
  if Assigned(TThread(Sender).FatalException) then
    ShowMessage('Erro carregando itens! Tente novamente!' + #13 + Exception(ex).Message)
  else
  begin
    //ChangeTabActionListViewItem.Execute;

    TThread.Synchronize(nil,
      procedure
      begin
        if (FCodigoMesa = '0') or (FCodigoMesa = '') then
          LabelComandaItem.Text := 'CMD: ' + FCodigoComanda
        else
          LabelComandaItem.Text := 'CMD: ' + FCodigoComanda + ' - M: ' + FCodigoMesa;

        if (FCodigoTag <> '0') and (FCodigoTag <> '') and (FCodigoTag <> '-1') then
          LabelComandaItem.Text := LabelComandaItem.Text + ' - T: ' + FCodigoTag;

        LabelFuncionarioItem.Text := FNomeFuncionario;
        TabControl.ActiveTab := TabItemListViewItem;
      end);
  end;
end;

procedure TViewMenu.carregaListViewPedido;
var
  LThread: TThread;

begin
  TLoading.Show(ViewMenu, 'Aguarde, consultando pedidos...');

  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      DM.servidorMTPedidosPHP('pedidoPronto');
    end);

  LThread.OnTerminate := carregaListViewPedidoFim;
  LThread.start;
end;

procedure TViewMenu.carregaListViewPedidoFim(Sender: TObject);
var
  ex: TObject;

begin
  Sleep(100);
  TLoading.Hide;

  ex := TThread(Sender).FatalException;
  if Assigned(TThread(Sender).FatalException) then
    ShowMessage('Erro consultando pedidos! Tente novamente!' + #13 + Exception(ex).Message)
  else
  begin
    insereListaPedido;

    //ChangeTabActionListViewPedido.Execute;
    TThread.Synchronize(nil,
      procedure
      begin
        TabControl.ActiveTab := TabItemListViewPedido;
      end);
  end;
end;

procedure TViewMenu.carregaListViewProduto;
var
  LThread: TThread;

begin
  TLoading.Show(ViewMenu, 'Aguarde, carregando produtos...');

  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      ListViewProduto.BeginUpdate;
      ListViewProduto.ScrollTo(0);
      ListViewProduto.Items.Clear;
      ListViewProduto.EndUpdate;

      DM.filtrarMTProdutos(FTecladoAlfaNumerico.FValorRetorno, True);
      insereListaProduto;
    end);

  LThread.OnTerminate := carregaListViewProdutoFim;
  LThread.start;
end;

procedure TViewMenu.carregaListViewProdutoFim(Sender: TObject);
begin
  Sleep(100);
  TLoading.Hide;

  //ChangeTabActionListViewProduto.Execute;
  TThread.Synchronize(nil,
    procedure
    begin
      TabControl.ActiveTab := TabItemListViewProduto;
    end);
end;

procedure TViewMenu.ChangeTabActionConfiguracaoUpdate(Sender: TObject);
begin
  LabelEndereco.Text := TVariaveis.GetInstancia.ServidorREST;
  LabelPorta.Text := TVariaveis.GetInstancia.PortaREST.ToString;
  LabelContexto.Text := TVariaveis.GetInstancia.Contexto;

  if TVariaveis.GetInstancia.ProtocoloREST = 'https' then
    LabelProtocolo.Text := 'https on'
  else
    LabelProtocolo.Text := 'https off';

  if TVariaveis.GetInstancia.TecladoFisicoAtivado = False then
    LabelTecladoFisico.Text := 'teclado off'
  else
    LabelTecladoFisico.Text := 'teclado on';

  if TVariaveis.GetInstancia.ComandaComDigitoVerificador = False then
    LabelComandaDigitoVerificador.Text := 'digito verificador off'
  else
    LabelComandaDigitoVerificador.Text := 'digito verificador on';

  if TVariaveis.GetInstancia.ExcluirItemOuComanda = True then
    LabelExcluirItemComanda.Text := 'digitar senha para excluir on'
  else
    LabelExcluirItemComanda.Text := 'digitar senha para excluir off';
end;

procedure TViewMenu.ChangeTabActionListViewComandaUpdate(Sender: TObject);
begin
  LabelFuncionarioComanda.Text := FNomeFuncionario;
end;

procedure TViewMenu.ChangeTabActionListViewItemUpdate(Sender: TObject);
begin
  if (FCodigoMesa = '0') or (FCodigoMesa = '') then
    LabelComandaItem.Text := 'CMD: ' + FCodigoComanda
  else
    LabelComandaItem.Text := 'CMD: ' + FCodigoComanda + ' - M: ' + FCodigoMesa;

  if (FCodigoTag <> '0') and (FCodigoTag <> '') and (FCodigoTag <> '-1') then
    LabelComandaItem.Text := LabelComandaItem.Text + ' - T: ' + FCodigoTag;

  LabelFuncionarioItem.Text := FNomeFuncionario;
end;

procedure TViewMenu.ChangeTabActionMenuUpdate(Sender: TObject);
begin
  LabelFuncionarioMenu.Text := FNomeFuncionario;

//  if FDataAtualizacao <> Date then
//    validarLogin;
end;

procedure TViewMenu.confirmaSenhaAlterarComanda(ASenha: string);
var
  LThread: TThread;

begin
  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      DM.servidorMTSenhasPHP(ASenha);
    end);

  LThread.OnTerminate := confirmaSenhaAlterarComandaFim;
  LThread.start;
end;

procedure TViewMenu.confirmaSenhaAlterarComandaFim(Sender: TObject);
var
  ex: TObject;

begin
  ex := TThread(Sender).FatalException;
  if Assigned(TThread(Sender).FatalException) then
    ShowMessage('Erro consultando senha!, tente novamente...' + #13 + Exception(ex).Message)
  else
  begin
    if (DM.mtSenhas.RecordCount > 0) and
      (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoSenhaAlterarComanda') then
    begin
      if FBloqueio = '0' then
        tecladoNumericoAlterarComanda
      else
        ShowMessage('Comanda bloqueada!!!' + #13 + 'Operação não pode ser realizada.' + #13 + 'Entre em contato com a gerência.');
    end
    else
    begin
      if NOT Assigned(ViewMensagem) then
        Application.CreateForm(TViewMensagem, ViewMensagem);

{$IFDEF MSWINDOWS}
      ViewMensagem.WindowState := TWindowState.wsMaximized;
{$ENDIF}
      ViewMensagem.LabelMensagem.Text := 'Senha inválida!';
      ViewMensagem.ShowModal(
        procedure(ModalResult: TModalResult)
        begin
          ViewMensagem := nil;

          if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoSenhaAlterarComanda') then
            ChangeTabActionListViewComanda.Execute;
        end);
    end;
  end;
end;

procedure TViewMenu.confirmaSenhaAlterarComandaItem(ASenha: string);
var
  LThread: TThread;

begin
  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      DM.servidorMTSenhasPHP(ASenha);
    end);

  LThread.OnTerminate := confirmaSenhaAlterarComandaItemFim;
  LThread.start;
end;

procedure TViewMenu.confirmaSenhaAlterarComandaItemFim(Sender: TObject);
var
  ex: TObject;

begin
  ex := TThread(Sender).FatalException;
  if Assigned(TThread(Sender).FatalException) then
    ShowMessage('Erro consultando senha!, tente novamente...' + #13 + Exception(ex).Message)
  else
  begin
    if (DM.mtSenhas.RecordCount > 0) and
      (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoSenhaAlterarComandaItem') then
    begin
      if FBloqueio = '0' then
        tecladoNumericoAlterarComandaItem
      else
        ShowMessage('Comanda bloqueada!!!' + #13 + 'Operação não pode ser realizada.' + #13 + 'Entre em contato com a gerência.');
    end
    else
    begin
      if NOT Assigned(ViewMensagem) then
        Application.CreateForm(TViewMensagem, ViewMensagem);

{$IFDEF MSWINDOWS}
      ViewMensagem.WindowState := TWindowState.wsMaximized;
{$ENDIF}
      ViewMensagem.LabelMensagem.Text := 'Senha inválida!';
      ViewMensagem.ShowModal(
        procedure(ModalResult: TModalResult)
        begin
          ViewMensagem := nil;

          if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoSenhaAlterarComandaItem') then
            ChangeTabActionListViewItem.Execute;
        end);
    end;
  end;
end;

procedure TViewMenu.confirmaSenhaComanda(ASenha: string);
var
  LThread: TThread;

begin
  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      DM.servidorMTSenhasPHP(ASenha);
    end);

  LThread.OnTerminate := confirmaSenhaComandaFim;
  LThread.start;
end;

procedure TViewMenu.confirmaSenhaComandaFim(Sender: TObject);
var
  ex: TObject;

begin
  ex := TThread(Sender).FatalException;
  if Assigned(TThread(Sender).FatalException) then
    ShowMessage('Erro consultando senha!, tente novamente...' + #13 + Exception(ex).Message)
  else
  begin
    if (DM.mtSenhas.RecordCount > 0) and (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoSenhaExcluirComanda') then
      excluirComanda(DM.mtSenhas.FieldByName('codigo').AsString, DM.mtSenhas.FieldByName('nome').AsString,
        FCodigoComanda)
    else
    begin
      if NOT Assigned(ViewMensagem) then
        Application.CreateForm(TViewMensagem, ViewMensagem);

{$IFDEF MSWINDOWS}
      ViewMensagem.WindowState := TWindowState.wsMaximized;
{$ENDIF}
      ViewMensagem.LabelMensagem.Text := 'Senha inválida!';
      ViewMensagem.ShowModal(
        procedure(ModalResult: TModalResult)
        begin
          ViewMensagem := nil;

          if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoSenhaExcluirComanda') then
            ChangeTabActionListViewComanda.Execute;
        end);
    end;
  end;
end;

procedure TViewMenu.confirmaSenhaItem(ASenha: string);
var
  LThread: TThread;

begin
  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      DM.servidorMTSenhasPHP(ASenha);
    end);

  LThread.OnTerminate := confirmaSenhaItemFim;
  LThread.start;
end;

procedure TViewMenu.confirmaSenhaItemFim(Sender: TObject);
var
  ex: TObject;

begin
  ex := TThread(Sender).FatalException;
  if Assigned(TThread(Sender).FatalException) then
    ShowMessage('Erro consultando senha!, tente novamente...' + #13 + Exception(ex).Message)
  else
  begin
    if (DM.mtSenhas.RecordCount > 0) and (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoSenhaExcluirItem') then
      excluirItem(DM.mtSenhas.FieldByName('codigo').AsString, DM.mtSenhas.FieldByName('nome').AsString,
        FCodigoComanda, FCodigoItem)
    else
    begin
      if NOT Assigned(ViewMensagem) then
        Application.CreateForm(TViewMensagem, ViewMensagem);

{$IFDEF MSWINDOWS}
      ViewMensagem.WindowState := TWindowState.wsMaximized;
{$ENDIF}
      ViewMensagem.LabelMensagem.Text := 'Senha inválida!';
      ViewMensagem.ShowModal(
        procedure(ModalResult: TModalResult)
        begin
          ViewMensagem := nil;

          if (FTecladoNumerico.FFuncaoDoTeclado = 'TecladoNumericoSenhaExcluirItem') then
            ChangeTabActionListViewItem.Execute;
        end);
    end;
  end;
end;

procedure TViewMenu.excluirComanda(ACodigoFuncionario, ANomeFuncionario, ACodigoComanda: string);
var
  LThread: TThread;

begin
  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      DM.excluirMTComandasPHP(ACodigoFuncionario, ANomeFuncionario, ACodigoComanda);
    end);

  LThread.OnTerminate := excluirComandaFim;

  LThread.start;
end;

procedure TViewMenu.excluirComandaFim(Sender: TObject);
var
  ex: TObject;

begin
  ex := TThread(Sender).FatalException;
  if Assigned(TThread(Sender).FatalException) then
    ShowMessage('Erro excluindo comanda!, tente novamente...' + #13 + Exception(ex).Message)
  else
  begin
    ListViewComanda.BeginUpdate;
    ListViewComanda.Items.Delete(ListViewComanda.Tag);
    ListViewComanda.EndUpdate;

    ChangeTabActionListViewComanda.Execute;
  end;
end;

procedure TViewMenu.excluirItem(ACodigoFuncionario, ANomeFuncionario, ACodigoComanda, ACodigoItem: string);
var
  LThread: TThread;

begin
  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      DM.excluirMTItensPHP(ACodigoFuncionario, ANomeFuncionario, ACodigoComanda, ACodigoItem);
    end);

  LThread.OnTerminate := excluirItemFim;
  LThread.start;
end;

procedure TViewMenu.excluirItemFim(Sender: TObject);
var
  ex: TObject;
  LItem: TListViewItem;
  LListItemText: TListItemText;
  LValorTotal: string;

begin
  ex := TThread(Sender).FatalException;
  if Assigned(TThread(Sender).FatalException) then
    ShowMessage('Erro excluindo item!, tente novamente...' + #13 + Exception(ex).Message)
  else
  begin
    LItem := TListViewItem(ListViewItem.Items[ListViewItem.Tag]);
    with LItem do
    begin
      try
        LListItemText := TListItemText(Objects.FindDrawable('Text5'));
        with LListItemText do
        begin
          LValorTotal := Text;
        end;
      except
      end;
    end;

    try
      LValorTotal := StringReplace(LValorTotal, '.', '', [rfReplaceAll]);
      FValorTotal := FValorTotal - StrToFloat(LValorTotal);

      FQtdeItens := FQtdeItens - 1;
      LabelValor.Text := 'R$ ' + formataFloatStr2(FValorTotal) + ' - Qtde: ' + FQtdeItens.ToString;
    except
    end;

    ListViewItem.BeginUpdate;
    ListViewItem.Items.Delete(ListViewItem.Tag);
    ListViewItem.EndUpdate;

    ChangeTabActionListViewItem.Execute;
  end;
end;

procedure TViewMenu.focusTecladoAlfaNumerico;
begin
  if TabControl.ActiveTab <> TabItemTecladoAlfaNumerico then
    ChangeTabActionTecladoAlfaNumerico.Execute;

  TThread.CreateAnonymousThread(
  procedure
  begin
    Sleep(300);
    TThread.Synchronize(nil,
      procedure
      begin
        FTecladoAlfaNumerico.EditValor.SetFocus;
      end);
  end).Start;
end;

procedure TViewMenu.focusTecladoNumerico;
begin
  if TabControl.ActiveTab <> TabItemTecladoNumerico then
    ChangeTabActionTecladoNumerico.Execute;

  TThread.CreateAnonymousThread(
  procedure
  begin
    Sleep(300);
    TThread.Synchronize(nil,
      procedure
      begin
        FTecladoNumerico.EditValor.SetFocus;
      end);
  end).Start;
end;

procedure TViewMenu.FormCreate(Sender: TObject);
begin
  FDataAtualizacao := Date;
  FormatSettings.DecimalSeparator := ',';
  FormatSettings.ThousandSeparator := '.';

  actionComanda;
  actionItem;

  TabControl.ActiveTab := TabItemMenu;

  LabelFuncionarioMenu.Text := EmptyStr;
  FNomeFuncionario := EmptyStr;
  FCodigoMesa := '0';
  FCodigoTag := '0';

  ImageMaisOpcoesComanda.Visible := False;
  ImageMaisOpcoesItem.Visible := False;

{$IFDEF MSWINDOWS}
  ViewMenu.WindowState := TWindowState.wsMaximized;
{$ENDIF}
  TVariaveis.GetInstancia.WidthScreen := Self.Width;

{
  FTecladoNumerico := TFormTecladoNumerico.Create(Self);
  FTecladoNumerico.LabelAcaoConfirmar.OnClick := botaoConfirmarTecladoNumerico;
  FTecladoNumerico.LabelAcaoVoltar.OnClick := botaoVoltarTecladoNumerico;
  FTecladoNumerico.LabelAcaoListar.OnClick := botaoListarTecladoNumerico;
  FTecladoNumerico.Label11.OnClick := botaoAcaoTecladoNumerico;

  embeddForm(RectangleTecladoNumerico, FTecladoNumerico);

  FTecladoAlfaNumerico := TFormTecladoAlfaNumerico.Create(Self);
  FTecladoAlfaNumerico.LabelAcaoConfirmar.OnClick := botaoConfirmarTecladoAlfaNumerico;
  FTecladoAlfaNumerico.LabelAcaoVoltar.OnClick := botaoVoltarTecladoAlfaNumerico;
}
  //embeddForm(RectangleTecladoAlfaNumerico, FTecladoAlfaNumerico);
end;

procedure TViewMenu.FormDestroy(Sender: TObject);
begin
  FActionSheetComanda.DisposeOf;
  FActionSheetItem.DisposeOf;
end;

procedure TViewMenu.FormResize(Sender: TObject);
begin
  if Assigned(FTecladoNumerico) then
    FTecladoNumerico.ajustaTela;

  if Assigned(FTecladoAlfaNumerico) then
    FTecladoAlfaNumerico.ajustaTela;
end;

procedure TViewMenu.FormShow(Sender: TObject);
begin
  LabelMenu.Text := 'Pedidos - Ver.: ' + FVersaoApp + ' - ' + FPlataforma;
  DM.Ler;
  atualizarTabelas;
end;

procedure TViewMenu.gravarAcompanhamentos;
var
  i: integer;
  txt: TListItemText;
  LValorUnitarioString: string;
  LObservacao: string;
  LCodigoProduto: string;
  LNomeProduto: string;
  LCodigoReduzido: string;
  LCodigoBarra: string;
  LUnidadeProduto: string;
  LValorUnitario: double;
  LQuantidade: string;

begin
  for i:= 0 to ListViewAcompanhamentos.Items.Count-1 do
  begin
    if ListViewAcompanhamentos.Items[i].Checked then
    begin
      LObservacao := '';

      txt := TListItemText(ListViewAcompanhamentos.Items[i].Objects.FindDrawable('Text6'));
      LCodigoProduto := txt.Text;

      txt := TListItemText(ListViewAcompanhamentos.Items[i].Objects.FindDrawable('Text2'));
      LNomeProduto := txt.Text;

      txt := TListItemText(ListViewAcompanhamentos.Items[i].Objects.FindDrawable('Text8'));
      LCodigoReduzido := txt.Text;

      txt := TListItemText(ListViewAcompanhamentos.Items[i].Objects.FindDrawable('Text7'));
      LCodigoBarra := txt.Text;

      txt := TListItemText(ListViewAcompanhamentos.Items[i].Objects.FindDrawable('Text11'));
      LUnidadeProduto := txt.Text;

      txt := TListItemText(ListViewAcompanhamentos.Items[i].Objects.FindDrawable('Text10'));
      LValorUnitarioString := txt.Text;

      LValorUnitarioString := StringReplace(LValorUnitarioString, '.', '', [rfReplaceAll]);
      LValorUnitario := StrToFloat(LValorUnitarioString);

      LQuantidade := '1';

      DM.inserirMTItensPHP(FCodigoFuncionario, FNomeFuncionario, FCodigoComanda, FCodigoMesa, FCodigoTag, LCodigoProduto,
        LCodigoBarra, LCodigoReduzido, LNomeProduto, LQuantidade, LValorUnitario, LObservacao);
    end;
  end;
end;

procedure TViewMenu.gravarAdicionais;
var
  i: integer;
  txt: TListItemText;
  LValorUnitarioString: string;
  LObservacao: string;
  LCodigoProduto: string;
  LNomeProduto: string;
  LCodigoReduzido: string;
  LCodigoBarra: string;
  LUnidadeProduto: string;
  LValorUnitario: double;
  LQuantidade: string;

begin
  for i:= 0 to ListViewAdicionais.Items.Count-1 do
  begin
    if ListViewAdicionais.Items[i].Checked then
    begin
      LObservacao := '';

      txt := TListItemText(ListViewAdicionais.Items[i].Objects.FindDrawable('Text6'));
      LCodigoProduto := txt.Text;

      txt := TListItemText(ListViewAdicionais.Items[i].Objects.FindDrawable('Text2'));
      LNomeProduto := txt.Text;

      txt := TListItemText(ListViewAdicionais.Items[i].Objects.FindDrawable('Text8'));
      LCodigoReduzido := txt.Text;

      txt := TListItemText(ListViewAdicionais.Items[i].Objects.FindDrawable('Text7'));
      LCodigoBarra := txt.Text;

      txt := TListItemText(ListViewAdicionais.Items[i].Objects.FindDrawable('Text11'));
      LUnidadeProduto := txt.Text;

      txt := TListItemText(ListViewAdicionais.Items[i].Objects.FindDrawable('Text10'));
      LValorUnitarioString := txt.Text;

      LValorUnitarioString := StringReplace(LValorUnitarioString, '.', '', [rfReplaceAll]);
      LValorUnitario := StrToFloat(LValorUnitarioString);

      LQuantidade := '1';

      DM.inserirMTItensPHP(FCodigoFuncionario, FNomeFuncionario, FCodigoComanda, FCodigoMesa, FCodigoTag, LCodigoProduto,
        LCodigoBarra, LCodigoReduzido, LNomeProduto, LQuantidade, LValorUnitario, LObservacao);
    end;
  end;
end;

procedure TViewMenu.gravarItem;
begin
  FQuantidade := '1';

  DM.inserirMTItensPHP(FCodigoFuncionario, FNomeFuncionario, FCodigoComanda, FCodigoMesa, FCodigoTag, FCodigoProduto,
    FCodigoBarra, FCodigoReduzido, FNomeProduto, FQuantidade, FValorUnitario, FObservacao);

  //FCodigoProduto := EmptyStr;
  FNomeProduto := EmptyStr;
  FCodigoBarra := EmptyStr;
  FCodigoReduzido := EmptyStr;
  FUnidadeProduto := EmptyStr;
  FValorUnitario := 0;
  FObservacao := EmptyStr;
  FQuantidade := EmptyStr;
end;

procedure TViewMenu.ImageAtualizarClick(Sender: TObject);
begin
  atualizarTabelas;
end;

procedure TViewMenu.ImageConfiguracoesClick(Sender: TObject);
begin
  tecladoNumericoSenhaConfiguracao;
end;

procedure TViewMenu.ImageNovaComandaClick(Sender: TObject);
begin
  FTelaAnterior := EmptyStr;
  FCodigoMesa := EmptyStr;
  FCodigoTag := EmptyStr;
  FQtdeItens := 0;
  FValorTotal := 0;

  tecladoNumericoComanda;
end;

procedure TViewMenu.ImageNovoItemClick(Sender: TObject);
begin
  FCodigoItem := EmptyStr;
  FObservacao := EmptyStr;
  FQuantidade := EmptyStr;

  tecladoNumericoItem;
end;

procedure TViewMenu.ImageProximoAcompanhamentosClick(Sender: TObject);
begin
  carregaListViewAdicional;
end;

procedure TViewMenu.ImageProximoAdicionaisClick(Sender: TObject);
begin
  gravarAcompanhamentos;
  gravarAdicionais;
  gravarItem;
  carregaListViewItem(FCodigoComanda);
end;

procedure TViewMenu.ImageVoltarAcompanhamentosClick(Sender: TObject);
begin
  carregaListViewItem(FCodigoComanda);
end;

procedure TViewMenu.ImageVoltarAdicionaisClick(Sender: TObject);
begin
  ChangeTabActionListViewAcompanhamento.Execute;
end;

procedure TViewMenu.ImageVoltarComandaClick(Sender: TObject);
begin
  ChangeTabActionMenu.Execute;
end;

procedure TViewMenu.ImageVoltarConfiguracaoClick(Sender: TObject);
begin
  ChangeTabActionMenu.Execute;
end;

procedure TViewMenu.ImageVoltarFuncionarioClick(Sender: TObject);
begin
  tecladoNumericoFuncionario;
end;

procedure TViewMenu.ImageVoltarItemClick(Sender: TObject);
begin
  if FTelaAnterior = 'ListViewComanda' then
  begin
    imprimirComanda(FNomeFuncionario, FCodigoComanda);
    ChangeTabActionListViewComanda.Execute;
  end
  else
    tecladoNumericoItem;
end;

procedure TViewMenu.ImageVoltarPedidoClick(Sender: TObject);
begin
  ChangeTabActionMenu.Execute;
end;

procedure TViewMenu.ImageVoltarProdutoClick(Sender: TObject);
begin
  if (FTecladoAlfaNumerico.FFuncaoDoTeclado = 'TecladoAlfaNumericoProdutoMenu') then
    ChangeTabActionMenu.Execute
  else if (FTecladoAlfaNumerico.FFuncaoDoTeclado = 'TecladoAlfaNumericoProdutoItem') then
    tecladoNumericoItem;
end;

procedure TViewMenu.imprimirComanda(ANomeFuncionario, ACodigoComanda: string);
var
  LThread: TThread;

begin
  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      try
        if ACodigoComanda <> '' then
          DM.imprimirMTComandaPHP(ANomeFuncionario, ACodigoComanda);
      except
      end;
    end);

  LThread.start;
end;

procedure TViewMenu.insereListaAcompanhamento;
begin
  with DM.mtAcompanhamentos do
  begin
    if not(IsEmpty) then
    begin
      First;

      ListViewAcompanhamentos.BeginUpdate;
      try
        while not eof do
        begin
          try
            inserirItemListViewAcompanhamento;
          finally
            Next;
          end;
        end;
      finally
        ListViewAcompanhamentos.EndUpdate;
      end;
    end
    else
      tecladoNumericoQuantidade;
  end;
end;

procedure TViewMenu.insereListaAdicional;
begin
  with DM.mtAdicionais do
  begin
    if not(IsEmpty) then
    begin
      First;

      ListViewAdicionais.BeginUpdate;
      try
        while not eof do
        begin
          try
            inserirItemListViewAdicional;
          finally
            Next;
          end;
        end;
      finally
        ListViewAdicionais.EndUpdate;
      end;
    end;
  end;
end;

procedure TViewMenu.insereListaComanda;
begin
  ListViewComanda.BeginUpdate;
  with DM.mtComandas do
  begin
    if not(IsEmpty) then
    begin
      First;

      while not eof do
      begin
        try
          inserirItemListViewComanda;
        finally
          Next;
        end;
      end;
    end;
  end;
  ListViewComanda.EndUpdate;
end;

procedure TViewMenu.insereListaFuncionario;
begin
  ListViewFuncionario.BeginUpdate;
  with DM.mtFuncionarios do
  begin
    if not(IsEmpty) then
    begin
      First;

      while not eof do
      begin
        try
          inserirItemListViewFuncionario;
        finally
          Next;
        end;
      end;
    end;
  end;
  ListViewFuncionario.EndUpdate;
end;

procedure TViewMenu.insereListaItem;
begin
  FValorTotal := 0;
  FQtdeItens := 0;

  with DM.mtItens do
  begin
    if not(IsEmpty) then
    begin
      First;

      ListViewItem.BeginUpdate;
      try
        while not eof do
        begin
          try
            FValorTotal := FValorTotal + FieldByName('valor_total').AsFloat;
            FQtdeItens := FQtdeItens + 1;

            inserirItemListViewItem;
          finally
            Next;
          end;
        end;
      finally
        ListViewItem.EndUpdate;
      end;
    end;
  end;

  LabelValor.Text := 'R$ ' + formataFloatStr2(FValorTotal) + ' - Qtde: ' + FQtdeItens.ToString;
end;

procedure TViewMenu.insereListaPedido;
begin
  ListViewPedido.BeginUpdate;
  ListViewPedido.ScrollTo(0);
  ListViewPedido.Items.Clear;
  ListViewPedido.EndUpdate;

  ListViewPedido.BeginUpdate;
  with DM.mtPedidos do
  begin
    if not(IsEmpty) then
    begin
      First;

      while not eof do
      begin
        try
          inserirItemListViewPedido;
        finally
          Next;
        end;
      end;
    end;
  end;
  ListViewPedido.EndUpdate;
end;

procedure TViewMenu.insereListaProduto;
begin
  ListViewProduto.BeginUpdate;
  with DM.mtProdutos do
  begin
    if not(IsEmpty) then
    begin
      First;

      while not eof do
      begin
        try
          inserirItemListViewProduto;
        finally
          Next;
        end;
      end;
    end;
  end;
  ListViewProduto.EndUpdate;
end;

procedure TViewMenu.inserirItemListViewAcompanhamento;
var
  LItem: TListViewItem;

begin
  LItem := ListViewAcompanhamentos.Items.Add;
  LItem.TagString := DM.mtAcompanhamentos.FieldByName('descricao_produto').AsString;
  LItem.Tag := DM.mtAcompanhamentos.FieldByName('codigo_produto').AsInteger;

  atualizarItemListViewAcompanhamento(LItem, True);
end;

procedure TViewMenu.inserirItemListViewAdicional;
var
  LItem: TListViewItem;

begin
  LItem := ListViewAdicionais.Items.Add;
  LItem.TagString := DM.mtAdicionais.FieldByName('descricao_produto').AsString;
  LItem.Tag := DM.mtAdicionais.FieldByName('codigo_produto').AsInteger;

  atualizarItemListViewAdicional(LItem, True);
end;

procedure TViewMenu.inserirItemListViewComanda;
var
  LItem: TListViewItem;

begin
  LItem := ListViewComanda.Items.Add;
  LItem.Tag := DM.mtComandas.FieldByName('codigo_comanda').AsInteger;

  atualizarItemListViewComanda(LItem, True, ImageMaisOpcoesComanda);
end;

procedure TViewMenu.inserirItemListViewFuncionario;
var
  LItem: TListViewItem;

begin
  LItem := ListViewFuncionario.Items.Add;
  LItem.Tag := DM.mtFuncionarios.FieldByName('codigo_funcionario').AsInteger;

  atualizarItemListViewFuncionario(LItem, True);
end;

procedure TViewMenu.inserirItemListViewItem;
var
  LItem: TListViewItem;

begin
  LItem := ListViewItem.Items.Add;
  LItem.Tag := DM.mtItens.FieldByName('item_venda').AsInteger;

  atualizarItemListViewItem(LItem, True, ImageMaisOpcoesItem);
end;

procedure TViewMenu.inserirItemListViewPedido;
var
  LItem: TListViewItem;

begin
  LItem := ListViewPedido.Items.Add;
  LItem.Tag := DM.mtPedidos.FieldByName('codigo_comanda').AsInteger;

  atualizarItemListViewPedido(LItem, True);
end;

procedure TViewMenu.inserirItemListViewProduto;
var
  LItem: TListViewItem;

begin
  LItem := ListViewProduto.Items.Add;
  LItem.TagString := DM.mtProdutos.FieldByName('descricao_produto').AsString;
  LItem.Tag := DM.mtProdutos.FieldByName('codigo_produto').AsInteger;

  atualizarItemListViewProduto(LItem, True);
end;

procedure TViewMenu.ListViewAcompanhamentosItemClick(const Sender: TObject; const AItem: TListViewItem);
var
  txt: TListItemText;
  LValorUnitario: string;
  i: Integer;
  x: Integer;

begin
  x := 0;
  for i := 0 to ListViewAcompanhamentos.Items.Count - 1 do
    if ListViewAcompanhamentos.Items.Checked[i] then
      inc(x);

  if AItem.Checked then
    AItem.Checked := False
  else
  begin
    if (DM.mtAcompanhamentos.RecordCount > 0) and (DM.mtAcompanhamentos.FieldByName('quantidade_acompanhamento').AsInteger > x)
    then
      AItem.Checked := not AItem.Checked;
  end;

  ListViewAcompanhamentosUpdateObjects(Sender, AItem);

  { if (FTecladoAlfaNumerico.FFuncaoDoTeclado = 'TecladoAlfaNumericoProdutoItem') then
    begin
    if TListView(Sender).Selected <> nil then
    begin
    FObservacao := '';

    txt := TListItemText(AItem.Objects.FindDrawable('Text6'));
    FCodigoProduto := txt.Text;

    txt := TListItemText(AItem.Objects.FindDrawable('Text2'));
    FNomeProduto := txt.Text;

    txt := TListItemText(AItem.Objects.FindDrawable('Text8'));
    FCodigoReduzido := txt.Text;

    txt := TListItemText(AItem.Objects.FindDrawable('Text7'));
    FCodigoBarra := txt.Text;

    txt := TListItemText(AItem.Objects.FindDrawable('Text11'));
    FUnidadeProduto := txt.Text;

    txt := TListItemText(AItem.Objects.FindDrawable('Text10'));
    LValorUnitario := txt.Text;

    LValorUnitario := StringReplace(LValorUnitario, '.', '', [rfReplaceAll]);
    FValorUnitario := StrToFloat(LValorUnitario);

    insereListaAcompanhamento;
    // tecladoNumericoQuantidade;
    end;
    end; }
end;

procedure TViewMenu.ListViewAcompanhamentosUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
var
  AListItemBitmap: TListItemImage;
  AColor: TAlphaColor;

begin
  atualizarItemListViewAcompanhamento(AItem, False);

  AListItemBitmap := AItem.Objects.FindObjectT<TListItemImage>('Image13');
  AListItemBitmap.Visible := AItem.Checked;
  AListItemBitmap.Bitmap := TBitmap.Create(40, 40);
  AListItemBitmap.Bitmap.Clear(TAlphaColorRec.Blue);
  AListItemBitmap.OwnsBitmap := True;

  {if Assigned(AListItemBitmap) then
  begin
    if AItem.Checked then
    begin
      AListItemBitmap.Bitmap := TBitmap.Create(40, 40);
      try
        AColor := TAlphaColors.Blue
      except
        AColor := TAlphaColorRec.Null;
      end;
      AListItemBitmap.Bitmap.Clear(AColor);
    end
    else
    begin
      AListItemBitmap.Bitmap := TBitmap.Create(40, 40);
      try
        AColor := TAlphaColors.White
      except
        AColor := TAlphaColorRec.Null;
      end;
      AListItemBitmap.Bitmap.Clear(AColor);
    end;
  end;}
end;

procedure TViewMenu.ListViewAdicionaisItemClick(const Sender: TObject; const AItem: TListViewItem);
var
  txt: TListItemText;
  LValorUnitario: string;
  i: Integer;
  x: Integer;

begin
  x := 0;
  for i := 0 to ListViewAdicionais.Items.Count - 1 do
    if ListViewAdicionais.Items.Checked[i] then
      inc(x);

  if AItem.Checked then
    AItem.Checked := False
  else
  begin
    if (DM.mtAdicionais.RecordCount > 0) and (DM.mtAdicionais.FieldByName('quantidade_acompanhamento').AsInteger > x) then
      AItem.Checked := not AItem.Checked;
  end;

  ListViewAdicionaisUpdateObjects(Sender, AItem);

  { if (FTecladoAlfaNumerico.FFuncaoDoTeclado = 'TecladoAlfaNumericoProdutoItem') then
    begin
    if TListView(Sender).Selected <> nil then
    begin
    FObservacao := '';

    txt := TListItemText(AItem.Objects.FindDrawable('Text6'));
    FCodigoProduto := txt.Text;

    txt := TListItemText(AItem.Objects.FindDrawable('Text2'));
    FNomeProduto := txt.Text;

    txt := TListItemText(AItem.Objects.FindDrawable('Text8'));
    FCodigoReduzido := txt.Text;

    txt := TListItemText(AItem.Objects.FindDrawable('Text7'));
    FCodigoBarra := txt.Text;

    txt := TListItemText(AItem.Objects.FindDrawable('Text11'));
    FUnidadeProduto := txt.Text;

    txt := TListItemText(AItem.Objects.FindDrawable('Text10'));
    LValorUnitario := txt.Text;

    LValorUnitario := StringReplace(LValorUnitario, '.', '', [rfReplaceAll]);
    FValorUnitario := StrToFloat(LValorUnitario);

    insereListaAcompanhamento;
    // tecladoNumericoQuantidade;
    end;
    end; }
end;

procedure TViewMenu.ListViewAdicionaisUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
var
  AListItemBitmap: TListItemImage;
  AColor: TAlphaColor;

begin
  atualizarItemListViewAdicional(AItem, False);

  AListItemBitmap := AItem.Objects.FindObjectT<TListItemImage>('Image13');
  AListItemBitmap.Visible := AItem.Checked;
  AListItemBitmap.Bitmap := TBitmap.Create(40, 40);
  AListItemBitmap.Bitmap.Clear(TAlphaColorRec.Blue);
  AListItemBitmap.OwnsBitmap := True;

  {if Assigned(AListItemBitmap) then
  begin
    if AItem.Checked then
    begin
      AListItemBitmap.Bitmap := TBitmap.Create(40, 40);
      try
        AColor := StringToAlphaColor('claBlue');
      except
        AColor := TAlphaColorRec.Null;
      end;
      AListItemBitmap.Bitmap.Clear(AColor);
    end
    else
    begin
      AListItemBitmap.Bitmap := TBitmap.Create(40, 40);
      try
        AColor := StringToAlphaColor('claWhite');
      except
        AColor := TAlphaColorRec.Null;
      end;
      AListItemBitmap.Bitmap.Clear(AColor);
    end;
  end;}
end;

procedure TViewMenu.ListViewComandaItemClickEx(const Sender: TObject; ItemIndex: Integer; const LocalClickPos: TPointF;
const ItemObject: TListItemDrawable);
var
  txt: TListItemText;
  Item: TListViewItem;

begin
  if TListView(Sender).Selected <> nil then
  begin
    ListViewComanda.Tag := ItemIndex;
    Item := TListView(Sender).Items[ItemIndex];

    txt := TListItemText(Item.Objects.FindDrawable('Text3'));
    FCodigoComanda := txt.Text;

    txt := TListItemText(Item.Objects.FindDrawable('Text4'));
    try
      FCodigoMesa := txt.Text;
      if VarIsNull(FCodigoMesa) or (FCodigoMesa = '') then
        FCodigoMesa := '0';
    except
      FCodigoMesa := '0';
    end;

    txt := TListItemText(Item.Objects.FindDrawable('Text12'));
    try
      FCodigoTag := txt.Text;
      if VarIsNull(FCodigoTag) or (FCodigoTag = '') then
        FCodigoTag := '0';
    except
      FCodigoTag := '0';
    end;

    txt := TListItemText(Item.Objects.FindDrawable('Text9'));
    try
      FBloqueio := txt.Text;
    except
      FBloqueio := '0';
    end;

    if ItemObject is TListItemImage then
    begin
      if (TListItemImage(ItemObject).Name = 'image1') then
        FActionSheetComanda.ShowMenu;
    end
    else
    begin
      try
        FCodigoTag := DM.consultarTagPHP(FCodigoComanda);
      except
        FCodigoTag := '0';
      end;

        if (FControlaTag = 'S') {and (FCodigoTag = '-1')} then
        begin
          FListViewComandaClick := True;
          tecladoNumericoTag;
        end
        else
        begin
          FTelaAnterior := 'ListViewComanda';
          carregaListViewItem(FCodigoComanda);
        end;
    end;

    // tecladoNumericoItem;
  end;
end;

procedure TViewMenu.ListViewComandaUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
begin
  atualizarItemListViewComanda(AItem, False, ImageMaisOpcoesComanda);
end;

procedure TViewMenu.ListViewFuncionarioItemClick(const Sender: TObject; const AItem: TListViewItem);
var
  txt: TListItemText;

begin
  if TListView(Sender).Selected <> nil then
  begin
    txt := TListItemText(AItem.Objects.FindDrawable('Text4'));
    FCodigoFuncionario := txt.Text;

    txt := TListItemText(AItem.Objects.FindDrawable('Text2'));
    FNomeFuncionario := txt.Text;

    tecladoNumericoComanda;
  end;
end;

procedure TViewMenu.ListViewFuncionarioUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
begin
  atualizarItemListViewFuncionario(AItem, False);
end;

procedure TViewMenu.ListViewItemItemClickEx(const Sender: TObject; ItemIndex: Integer; const LocalClickPos: TPointF;
const ItemObject: TListItemDrawable);
var
  txt: TListItemText;
  Item: TListViewItem;

begin
  if TListView(Sender).Selected <> nil then
  begin
    ListViewItem.Tag := ItemIndex;

    Item := TListView(Sender).Items[ItemIndex];

    txt := TListItemText(Item.Objects.FindDrawable('Text21'));
    FCodigoItem := txt.Text;

    txt := TListItemText(Item.Objects.FindDrawable('Text16'));
    FObservacao := txt.Text;

    if ItemObject is TListItemImage then
    begin
      if (TListItemImage(ItemObject).Name = 'image1') then
        FActionSheetItem.ShowMenu;
    end;
  end;
end;

procedure TViewMenu.ListViewItemUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
begin
  atualizarItemListViewItem(AItem, False, ImageMaisOpcoesItem);
end;

procedure TViewMenu.ListViewPedidoItemClick(const Sender: TObject; const AItem: TListViewItem);
var
  txt: TListItemText;

begin
  if TListView(Sender).Selected <> nil then
  begin
    txt := TListItemText(AItem.Objects.FindDrawable('Text3'));
    FCodigoComanda := txt.Text;

    LabelMensagem.Text := 'Chamar a comanda [' + FCodigoComanda + ']?';
    ChangeTabActionConfirmacao.Execute;
  end;
end;

procedure TViewMenu.ListViewPedidoUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
begin
  atualizarItemListViewPedido(AItem, False);
end;

procedure TViewMenu.ListViewProdutoItemClick(const Sender: TObject; const AItem: TListViewItem);
var
  txt: TListItemText;
  LValorUnitario: string;

begin
  if (FTecladoAlfaNumerico.FFuncaoDoTeclado = 'TecladoAlfaNumericoProdutoItem') then
  begin
    if TListView(Sender).Selected <> nil then
    begin
      FObservacao := '';

      txt := TListItemText(AItem.Objects.FindDrawable('Text6'));
      FCodigoProduto := txt.Text;

      txt := TListItemText(AItem.Objects.FindDrawable('Text2'));
      FNomeProduto := txt.Text;

      txt := TListItemText(AItem.Objects.FindDrawable('Text8'));
      FCodigoReduzido := txt.Text;

      txt := TListItemText(AItem.Objects.FindDrawable('Text7'));
      FCodigoBarra := txt.Text;

      txt := TListItemText(AItem.Objects.FindDrawable('Text11'));
      FUnidadeProduto := txt.Text;

      txt := TListItemText(AItem.Objects.FindDrawable('Text10'));
      LValorUnitario := txt.Text;

      LValorUnitario := StringReplace(LValorUnitario, '.', '', [rfReplaceAll]);
      FValorUnitario := StrToFloat(LValorUnitario);

      carregaListViewAcompanhamento;
    end;
  end;
end;

procedure TViewMenu.ListViewProdutoUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
begin
  atualizarItemListViewAcompanhamento(AItem, False);
end;

procedure TViewMenu.RectangleBotaoComandaClick(Sender: TObject);
begin
  if FNomeFuncionario <> '' then
    tecladoNumericoComanda
  else
    tecladoNumericoFuncionario;
end;

procedure TViewMenu.RectangleBotaoFuncionarioClick(Sender: TObject);
begin
  tecladoNumericoFuncionario;
end;

procedure TViewMenu.RectangleBotaoProdutoClick(Sender: TObject);
begin
  tecladoAlfaNumericoProdutoMenu;
end;

procedure TViewMenu.RectangleComandaDigitoVerificadorClick(Sender: TObject);
begin
  if LabelComandaDigitoVerificador.Text = 'digito verificador off' then
    LabelComandaDigitoVerificador.Text := 'digito verificador on'
  else
    LabelComandaDigitoVerificador.Text := 'digito verificador off';
end;

procedure TViewMenu.RectangleConfirmacaoNaoClick(Sender: TObject);
begin
  ChangeTabActionMenu.Execute;
end;

procedure TViewMenu.RectangleConfirmacaoSimClick(Sender: TObject);
begin
  DM.alterarPedidoProntoPHP(FCodigoComanda, FNomeFuncionario);
  ChangeTabActionMenu.Execute;
end;

procedure TViewMenu.RectangleConfirmarConfiguracaoClick(Sender: TObject);
begin
  TVariaveis.GetInstancia.ServidorREST := LabelEndereco.Text;
  TVariaveis.GetInstancia.PortaREST := LabelPorta.Text.ToInteger;
  TVariaveis.GetInstancia.Contexto := LabelContexto.Text;

  if LabelProtocolo.Text = 'https on' then
    TVariaveis.GetInstancia.ProtocoloREST := 'https'
  else
    TVariaveis.GetInstancia.ProtocoloREST := 'http';

  if LabelTecladoFisico.Text = 'teclado off' then
    TVariaveis.GetInstancia.TecladoFisicoAtivado := False
  else
    TVariaveis.GetInstancia.TecladoFisicoAtivado := True;

  if LabelComandaDigitoVerificador.Text = 'digito verificador off' then
    TVariaveis.GetInstancia.ComandaComDigitoVerificador := False
  else
    TVariaveis.GetInstancia.ComandaComDigitoVerificador := True;

  if LabelExcluirItemComanda.Text = 'digitar senha para excluir on' then
    TVariaveis.GetInstancia.ExcluirItemOuComanda := True
  else
    TVariaveis.GetInstancia.ExcluirItemOuComanda := False;

  ChangeTabActionMenu.Execute;
  DM.Gravar;
  DM.Ler;
  // validarLogin;
end;

procedure TViewMenu.RectangleContextoClick(Sender: TObject);
begin
  tecladoAlfaNumericoContexto;
end;

procedure TViewMenu.RectangleCozinhaClick(Sender: TObject);
begin
  tecladoNumericoPedido;
end;

procedure TViewMenu.RectangleEnderecoClick(Sender: TObject);
begin
  tecladoAlfaNumericoEnderecoServidor;
end;

procedure TViewMenu.RectangleExcluirItemComandaClick(Sender: TObject);
begin
  if LabelExcluirItemComanda.Text = 'digitar senha para excluir off' then
    LabelExcluirItemComanda.Text := 'digitar senha para excluir on'
  else
    LabelExcluirItemComanda.Text := 'digitar senha para excluir off';
end;

procedure TViewMenu.RectanglePortaClick(Sender: TObject);
begin
  tecladoNumericoPortaServidor;
end;

procedure TViewMenu.RectangleProtocoloClick(Sender: TObject);
begin
  if LabelProtocolo.Text = 'https on' then
    LabelProtocolo.Text := 'https off'
  else
    LabelProtocolo.Text := 'https on';
end;

procedure TViewMenu.RectangleTecladoFisicoClick(Sender: TObject);
begin
  if LabelTecladoFisico.Text = 'teclado off' then
    LabelTecladoFisico.Text := 'teclado on'
  else
    LabelTecladoFisico.Text := 'teclado off';
end;

procedure TViewMenu.TabControlChange(Sender: TObject);
begin
  if TabControl.ActiveTab = TabItemTecladoNumerico then
    focusTecladoNumerico
  else if TabControl.ActiveTab = TabItemTecladoAlfaNumerico then
    focusTecladoAlfaNumerico;
end;

procedure TViewMenu.tecladoAlfaNumerico;
begin
  if not Assigned(FTecladoAlfaNumerico) then
  begin
    FTecladoAlfaNumerico := TFormTecladoAlfaNumerico.Create(Application);
    FTecladoAlfaNumerico.LabelAcaoConfirmar.OnClick := botaoConfirmarTecladoAlfaNumerico;
    FTecladoAlfaNumerico.LabelAcaoVoltar.OnClick := botaoVoltarTecladoAlfaNumerico;

    embeddForm(RectangleTecladoAlfaNumerico, FTecladoAlfaNumerico);
  end;
end;

procedure TViewMenu.tecladoAlfaNumericoAlterarObservacaoItem;
begin
  tecladoAlfaNumerico;

  FTecladoAlfaNumerico.FFuncaoDoTeclado := 'TecladoAlfaNumericoAlterarObservacaoItem';
  FTecladoAlfaNumerico.LabelResultado.Text := EmptyStr;
  FTecladoAlfaNumerico.LabelValor.Text := FObservacao;

  FTecladoAlfaNumerico.ajustaForm;
  focusTecladoAlfaNumerico;

  //ChangeTabActionTecladoAlfaNumerico.Execute;
  //if FTecladoAlfaNumerico.FTecladoFisico then
  //  FTecladoAlfaNumerico.EditValor.SetFocus;
end;

procedure TViewMenu.tecladoAlfaNumericoContexto;
begin
  tecladoAlfaNumerico;

  FTecladoAlfaNumerico.FFuncaoDoTeclado := 'TecladoAlfaNumericoContexto';
  FTecladoAlfaNumerico.LabelResultado.Text := EmptyStr;
  FTecladoAlfaNumerico.LabelValor.Text := LabelContexto.Text;

  FTecladoAlfaNumerico.ajustaForm;
  focusTecladoAlfaNumerico;

  //ChangeTabActionTecladoAlfaNumerico.Execute;
  //if FTecladoAlfaNumerico.FTecladoFisico then
  //  FTecladoAlfaNumerico.EditValor.SetFocus;
end;

procedure TViewMenu.tecladoAlfaNumericoEnderecoServidor;
begin
  tecladoAlfaNumerico;

  FTecladoAlfaNumerico.FFuncaoDoTeclado := 'TecladoAlfaNumericoEnderecoServidor';
  FTecladoAlfaNumerico.LabelResultado.Text := EmptyStr;
  FTecladoAlfaNumerico.LabelValor.Text := LabelEndereco.Text;

  FTecladoAlfaNumerico.ajustaForm;
  focusTecladoAlfaNumerico;

  //ChangeTabActionTecladoAlfaNumerico.Execute;
  //if FTecladoAlfaNumerico.FTecladoFisico then
  //  FTecladoAlfaNumerico.EditValor.SetFocus;
end;

procedure TViewMenu.tecladoAlfanumericoObservacao;
begin
  tecladoAlfaNumerico;

  FTecladoAlfaNumerico.FFuncaoDoTeclado := 'TecladoAlfaNumericoObservacao';
  FTecladoAlfaNumerico.LabelResultado.Text := EmptyStr;
  FTecladoAlfaNumerico.LabelValor.Text := FObservacao;

  FTecladoAlfaNumerico.ajustaForm;
  focusTecladoAlfaNumerico;

  //ChangeTabActionTecladoAlfaNumerico.Execute;
  //if FTecladoAlfaNumerico.FTecladoFisico then
  //  FTecladoAlfaNumerico.EditValor.SetFocus;
end;

procedure TViewMenu.tecladoAlfaNumericoObservacaoQuantidade;
begin
  tecladoAlfaNumerico;

  FTecladoAlfaNumerico.FFuncaoDoTeclado := 'TecladoAlfaNumericoObservacaoQuantidade';
  FTecladoAlfaNumerico.LabelTitulo.Text := 'informe a observação';
  FTecladoAlfaNumerico.LabelResultado.Text := EmptyStr;
  FTecladoAlfaNumerico.LabelValor.Text := FObservacao;

  FTecladoAlfaNumerico.ajustaForm;
  focusTecladoAlfaNumerico;

  //ChangeTabActionTecladoAlfaNumerico.Execute;
  //if FTecladoAlfaNumerico.FTecladoFisico then
  //  FTecladoAlfaNumerico.EditValor.SetFocus;
end;

procedure TViewMenu.tecladoAlfaNumericoProdutoItem;
begin
  tecladoAlfaNumerico;

  FTecladoAlfaNumerico.FFuncaoDoTeclado := 'TecladoAlfaNumericoProdutoItem';
  FTecladoAlfaNumerico.LabelTitulo.Text := 'informe o produto';
  FTecladoAlfaNumerico.LabelResultado.Text := EmptyStr;
  FTecladoAlfaNumerico.LabelValor.Text := EmptyStr;

  FTecladoAlfaNumerico.ajustaForm;
  focusTecladoAlfaNumerico;

  //ChangeTabActionTecladoAlfaNumerico.Execute;
  //if FTecladoAlfaNumerico.FTecladoFisico then
  //  FTecladoAlfaNumerico.EditValor.SetFocus;
end;

procedure TViewMenu.tecladoAlfaNumericoProdutoMenu;
begin
  tecladoAlfaNumerico;

  FTecladoAlfaNumerico.FFuncaoDoTeclado := 'TecladoAlfaNumericoProdutoMenu';
  FTecladoAlfaNumerico.LabelTitulo.Text := 'informe o produto';
  FTecladoAlfaNumerico.LabelResultado.Text := EmptyStr;
  FTecladoAlfaNumerico.LabelValor.Text := EmptyStr;

  FTecladoAlfaNumerico.ajustaForm;
  focusTecladoAlfaNumerico;

  //ChangeTabActionTecladoAlfaNumerico.Execute;
  //if FTecladoAlfaNumerico.FTecladoFisico then
  //  FTecladoAlfaNumerico.EditValor.SetFocus;
end;

procedure TViewMenu.tecladoNumerico;
begin
  if not Assigned(FTecladoNumerico) then
  begin
    FTecladoNumerico := TFormTecladoNumerico.Create(Application);
    FTecladoNumerico.LabelAcaoConfirmar.OnClick := botaoConfirmarTecladoNumerico;
    FTecladoNumerico.LabelAcaoVoltar.OnClick := botaoVoltarTecladoNumerico;
    FTecladoNumerico.LabelAcaoListar.OnClick := botaoListarTecladoNumerico;
    FTecladoNumerico.Label11.OnClick := botaoAcaoTecladoNumerico;

    embeddForm(RectangleTecladoNumerico, FTecladoNumerico);
  end;
end;

procedure TViewMenu.tecladoNumericoAlterarComanda;
begin
  tecladoNumerico;

  FTecladoNumerico.FFuncaoDoTeclado := 'TecladoNumericoAlterarComanda';
  FTecladoNumerico.LabelResultado.Text := 'Comanda atual: ' + FCodigoComanda;
  FTecladoNumerico.LabelValor.Text := EmptyStr;

  FTecladoNumerico.ajustaForm;
  focusTecladoNumerico;

  //ChangeTabActionTecladoNumerico.Execute;
  //if FTecladoNumerico.FTecladoFisico then
  //  FTecladoNumerico.EditValor.SetFocus;
end;

procedure TViewMenu.tecladoNumericoAlterarComandaItem;
begin
  tecladoNumerico;

  FTecladoNumerico.FFuncaoDoTeclado := 'TecladoNumericoAlterarComandaItem';
  FTecladoNumerico.LabelResultado.Text := 'Comanda atual: ' + FCodigoComanda;
  FTecladoNumerico.LabelValor.Text := EmptyStr;

  FTecladoNumerico.ajustaForm;
  focusTecladoNumerico;

  //ChangeTabActionTecladoNumerico.Execute;
  //if FTecladoNumerico.FTecladoFisico then
  //  FTecladoNumerico.EditValor.SetFocus;
end;

procedure TViewMenu.tecladoNumericoAlterarMesa;
begin
  tecladoNumerico;

  FTecladoNumerico.FFuncaoDoTeclado := 'TecladoNumericoAlterarMesa';
  FTecladoNumerico.LabelResultado.Text := 'Mesa atual: ' + FCodigoMesa;
  FTecladoNumerico.LabelValor.Text := EmptyStr;

  FTecladoNumerico.ajustaForm;
  focusTecladoNumerico;

  //ChangeTabActionTecladoNumerico.Execute;
  //if FTecladoNumerico.FTecladoFisico then
  //  FTecladoNumerico.EditValor.SetFocus;
end;

procedure TViewMenu.tecladoNumericoComanda;
begin
  FTelaAnterior := '';

  tecladoNumerico;

  FTecladoNumerico.FFuncaoDoTeclado := 'TecladoNumericoComanda';
  FTecladoNumerico.LabelResultado.Text := FNomeFuncionario;
  FTecladoNumerico.LabelValor.Text := EmptyStr;

  FTecladoNumerico.ajustaForm;
  focusTecladoNumerico;

  //ChangeTabActionTecladoNumerico.Execute;
  //if FTecladoNumerico.FTecladoFisico then
  //  FTecladoNumerico.EditValor.SetFocus;
end;

procedure TViewMenu.tecladoNumericoFuncionario;
begin
  tecladoNumerico;

  FTecladoNumerico.FFuncaoDoTeclado := 'TecladoNumericoFuncionario';
  FTecladoNumerico.LabelResultado.Text := EmptyStr;
  FTecladoNumerico.LabelValor.Text := EmptyStr;

  FTecladoNumerico.ajustaForm;
  focusTecladoNumerico;

  //ChangeTabActionTecladoNumerico.Execute;
  //if FTecladoNumerico.FTecladoFisico then
  //  FTecladoNumerico.EditValor.SetFocus;
end;

procedure TViewMenu.tecladoNumericoItem;
begin
  tecladoNumerico;

  FTecladoNumerico.FFuncaoDoTeclado := 'TecladoNumericoItem';
  FTecladoNumerico.LabelResultado.Text := EmptyStr;
  FTecladoNumerico.LabelValor.Text := EmptyStr;

  FTecladoNumerico.ajustaForm;
  focusTecladoNumerico;

  //ChangeTabActionTecladoNumerico.Execute;
  //if FTecladoNumerico.FTecladoFisico then
  //  FTecladoNumerico.EditValor.SetFocus;
end;

procedure TViewMenu.tecladoNumericoMesa;
begin
  tecladoNumerico;

  FTecladoNumerico.FFuncaoDoTeclado := 'TecladoNumericoMesa';
  FTecladoNumerico.LabelResultado.Text := EmptyStr;
  FTecladoNumerico.LabelValor.Text := EmptyStr;

  FTecladoNumerico.ajustaForm;
  focusTecladoNumerico;

  //ChangeTabActionTecladoNumerico.Execute;
  //if FTecladoNumerico.FTecladoFisico then
  //  FTecladoNumerico.EditValor.SetFocus;
end;

procedure TViewMenu.tecladoNumericoPedido;
begin
  tecladoNumerico;

  FTecladoNumerico.FFuncaoDoTeclado := 'TecladoNumericoPedidoPronto';
  FTecladoNumerico.LabelResultado.Text := EmptyStr;
  FTecladoNumerico.LabelValor.Text := EmptyStr;

  FTecladoNumerico.ajustaForm;
  focusTecladoNumerico;

  //ChangeTabActionTecladoNumerico.Execute;
  //if FTecladoNumerico.FTecladoFisico then
  //  FTecladoNumerico.EditValor.SetFocus;
end;

procedure TViewMenu.tecladoNumericoPortaServidor;
begin
  tecladoNumerico;

  FTecladoNumerico.FFuncaoDoTeclado := 'TecladoNumericoPortaServidor';
  FTecladoNumerico.LabelResultado.Text := EmptyStr;
  FTecladoNumerico.LabelValor.Text := LabelPorta.Text;

  FTecladoNumerico.ajustaForm;
  focusTecladoNumerico;

  //ChangeTabActionTecladoNumerico.Execute;
  //if FTecladoNumerico.FTecladoFisico then
  //  FTecladoNumerico.EditValor.SetFocus;
end;

procedure TViewMenu.tecladoNumericoQuantidade;
begin
  tecladoNumerico;

  FTecladoNumerico.FFuncaoDoTeclado := 'TecladoNumericoQuantidade';
  FTecladoNumerico.LabelResultado.Text := FNomeProduto;
  FTecladoNumerico.LabelValor.Text := FQuantidade;
  FTecladoNumerico.FUnidadeProduto := FUnidadeProduto;
  FTecladoNumerico.FObservacao := FObservacao;

  FTecladoNumerico.ajustaForm;
  focusTecladoNumerico;

  //ChangeTabActionTecladoNumerico.Execute;
  //if FTecladoNumerico.FTecladoFisico then
  //  FTecladoNumerico.EditValor.SetFocus;
end;

procedure TViewMenu.tecladoNumericoSenhaAlterarComanda;
begin
  tecladoNumerico;

  FTecladoNumerico.FFuncaoDoTeclado := 'TecladoNumericoSenhaAlterarComanda';
  FTecladoNumerico.LabelResultado.Text := EmptyStr;
  FTecladoNumerico.LabelValor.Text := EmptyStr;

  FTecladoNumerico.ajustaForm;
  focusTecladoNumerico;

  //ChangeTabActionTecladoNumerico.Execute;
  //if FTecladoNumerico.FTecladoFisico then
  //  FTecladoNumerico.EditValor.SetFocus;
end;

procedure TViewMenu.tecladoNumericoSenhaAlterarComandaItem;
begin
  tecladoNumerico;

  FTecladoNumerico.FFuncaoDoTeclado := 'TecladoNumericoSenhaAlterarComandaItem';
  FTecladoNumerico.LabelResultado.Text := EmptyStr;
  FTecladoNumerico.LabelValor.Text := EmptyStr;

  FTecladoNumerico.ajustaForm;
  focusTecladoNumerico;

  //ChangeTabActionTecladoNumerico.Execute;
  //if FTecladoNumerico.FTecladoFisico then
  //  FTecladoNumerico.EditValor.SetFocus;
end;

procedure TViewMenu.tecladoNumericoSenhaConfiguracao;
begin
  tecladoNumerico;

  FTecladoNumerico.FFuncaoDoTeclado := 'TecladoNumericoSenhaConfiguracao';
  FTecladoNumerico.LabelResultado.Text := EmptyStr;
  FTecladoNumerico.LabelValor.Text := EmptyStr;

  FTecladoNumerico.ajustaForm;
  focusTecladoNumerico;

  //ChangeTabActionTecladoNumerico.Execute;
  //if FTecladoNumerico.FTecladoFisico then
  //  FTecladoNumerico.EditValor.SetFocus;
end;

procedure TViewMenu.tecladoNumericoSenhaExcluirComanda;
begin
  tecladoNumerico;

  FTecladoNumerico.FFuncaoDoTeclado := 'TecladoNumericoSenhaExcluirComanda';
  FTecladoNumerico.LabelResultado.Text := EmptyStr;
  FTecladoNumerico.LabelValor.Text := EmptyStr;

  FTecladoNumerico.ajustaForm;
  focusTecladoNumerico;

  //ChangeTabActionTecladoNumerico.Execute;
  //if FTecladoNumerico.FTecladoFisico then
  //  FTecladoNumerico.EditValor.SetFocus;
end;

procedure TViewMenu.tecladoNumericoSenhaExcluirItem;
begin
  tecladoNumerico;

  FTecladoNumerico.FFuncaoDoTeclado := 'TecladoNumericoSenhaExcluirItem';
  FTecladoNumerico.LabelResultado.Text := EmptyStr;
  FTecladoNumerico.LabelValor.Text := EmptyStr;

  FTecladoNumerico.ajustaForm;
  focusTecladoNumerico;

  //ChangeTabActionTecladoNumerico.Execute;
  //if FTecladoNumerico.FTecladoFisico then
  //  FTecladoNumerico.EditValor.SetFocus;
end;

procedure TViewMenu.tecladoNumericoTag;
begin
  tecladoNumerico;

  FTecladoNumerico.FFuncaoDoTeclado := 'TecladoNumericoTag';
  FTecladoNumerico.LabelResultado.Text := EmptyStr;

  if (FCodigoTag = '-1')  then
    FTecladoNumerico.LabelValor.Text := EmptyStr
  else
    FTecladoNumerico.LabelValor.Text := FCodigoTag;

  FTecladoNumerico.ajustaForm;
  focusTecladoNumerico;

  //ChangeTabActionTecladoNumerico.Execute;
  //if FTecladoNumerico.FTecladoFisico then
  //  FTecladoNumerico.EditValor.SetFocus;
end;

procedure TViewMenu.TimerAtualizacaoTimer(Sender: TObject);
begin
  if TabControl.ActiveTab = TabItemMenu then
    ImageAtualizarClick(Sender);
end;

{procedure TViewMenu.validarLogin;
var
  LThread: TThread;

begin
  TLoading.Show(ViewMenu, 'Aguarde, efetuando login...');

  LThread := TThread.CreateAnonymousThread(
    procedure
    var
      LBody: TJSONObject;
      LBaseURL: string;
      LContexto: string;
    begin
      LContexto := TVariaveis.GetInstancia.Contexto;
      LBaseURL := TVariaveis.GetInstancia.BaseURL;
      LBody := TJSONObject.Create;

      try
        LBody.AddPair('usuario', LContexto);
        LBody.AddPair('senha', 'mysoftsistemas');
        TVariaveis.GetInstancia.Token := DM.Login(LBaseURL, LBody);
      finally
        LBody.DisposeOf;
      end;
    end);

  LThread.OnTerminate := validarLoginFim;
  LThread.start;
end;

procedure TViewMenu.validarLoginFim(Sender: TObject);
var
  ex: TObject;

begin
  Sleep(100);
  TLoading.Hide;

  ex := TThread(Sender).FatalException;
  try
    if Assigned(TThread(Sender).FatalException) then
    begin
      ShowMessage('Erro conectando ao servidor.' + #13 + 'Verifique o endereço do servidor e o contexto informado!' + #13 +
        Exception(ex).Message);

      ImageAtualizar.Enabled := False;
      RectangleBotaoFuncionario.Enabled := False;
      RectangleBotaoComanda.Enabled := False;
      RectangleBotaoProduto.Enabled := False;
      RectangleCozinha.Enabled := False;

      ChangeTabActionMenu.Execute;
    end
    else
    begin
      ImageAtualizar.Enabled := True;
      RectangleBotaoFuncionario.Enabled := True;
      RectangleBotaoComanda.Enabled := True;
      RectangleBotaoProduto.Enabled := True;
      RectangleCozinha.Enabled := True;

      atualizarTabelas;
    end;
  finally
    // ex.DisposeOf;
  end;
end;}

end.
