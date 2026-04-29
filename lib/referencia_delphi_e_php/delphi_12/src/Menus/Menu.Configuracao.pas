unit Menu.Configuracao;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.TabControl, System.Actions, FMX.ActnList,

  Service.Configuracao,
  Singleton.Variaveis,
  Util.Funcao,

  Form.Configuracao,

  TecladoAlfaNumerico,
  TecladoNumerico;

type
  TMenuConfiguracao = class(TForm)
    TabControl: TTabControl;
    TabItemBase: TTabItem;
    RectangleBase: TRectangle;
    TabItemTecladoNumerico: TTabItem;
    TabItemTecladoAlfaNumerico: TTabItem;
    RectangleTecladoAlfaNumerico: TRectangle;
    RectangleTecladoNumerico: TRectangle;
    ActionList: TActionList;
    ChangeTabActionMenu: TChangeTabAction;
    ChangeTabActionTecladoAlfaNumerico: TChangeTabAction;
    ChangeTabActionTecladoNumerico: TChangeTabAction;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FTelaConfiguracao: TFormConfiguracao;
    FTecladoAlfaNumerico: TFormTecladoAlfaNumerico;
    FTecladoNumerico: TFormTecladoNumerico;

    procedure botaoConfirmar(Sender: TObject);
    procedure botaoVoltar(Sender: TObject);

    procedure carregaViewMenu;

    procedure tecladoAlfaNumericoIP(Sender: TObject);
    procedure tecladoAlfaNumericoContexto(Sender: TObject);
    procedure tecladoNumericoPorta(Sender: TObject);

    procedure lerConfiguracao;
    procedure gravarConfiguracao;
  public
    { Public declarations }
    procedure ajustaForm;
  end;

var
  MenuConfiguracao: TMenuConfiguracao;

implementation

{$R *.fmx}

uses
  View.Menu;

procedure TMenuConfiguracao.ajustaForm;
begin
  TVariaveis.GetInstancia.TelaAnterior := TVariaveis.GetInstancia.TelaAtiva;
  TVariaveis.GetInstancia.TelaAtiva := 'TMenuConfiguracao';
end;

procedure TMenuConfiguracao.botaoConfirmar(Sender: TObject);
begin
  if (TVariaveis.GetInstancia.TelaAtiva = 'TMenuConfiguracao') then
    carregaViewMenu
  else if (TVariaveis.GetInstancia.TelaAtiva = 'TFormConfiguracao') then
    carregaViewMenu
  else if (TVariaveis.GetInstancia.TelaAtiva = 'TFormTecladoAlfaNumerico') then
  begin
    if (FTecladoAlfaNumerico.FFuncaoDoTeclado = 'configuracao') and
      (FTecladoAlfaNumerico.FValorRetorno <> '') and
      (FTecladoAlfaNumerico.LabelTitulo.Text = 'informe o ip do servidor') then
      FTelaConfiguracao.LabelEndereco.Text := FTecladoAlfaNumerico.FValorRetorno
    else if (FTecladoAlfaNumerico.FFuncaoDoTeclado = 'configuracao') and
      (FTecladoAlfaNumerico.FValorRetorno <> '') and
      (FTecladoAlfaNumerico.LabelTitulo.Text = 'informe o contexto') then
      FTelaConfiguracao.LabelContexto.Text := FTecladoAlfaNumerico.FValorRetorno;

    ajustaForm;
    ChangeTabActionMenu.Execute;
  end
  else if (TVariaveis.GetInstancia.TelaAtiva = 'TFormTecladoNumerico') then
  begin
    if (FTecladoNumerico.FFuncaoDoTeclado = 'configuracao') and
      (FTecladoNumerico.FValorRetorno <> '') and
      (FTecladoNumerico.LabelTitulo.Text = 'informe a porta do servidor') then
      FTelaConfiguracao.LabelPorta.Text := FTecladoNumerico.FValorRetorno;
    ajustaForm;
    ChangeTabActionMenu.Execute;
  end;
end;

procedure TMenuConfiguracao.botaoVoltar(Sender: TObject);
begin
  ajustaForm;

  if (TVariaveis.GetInstancia.TelaAtiva = 'TMenuConfiguracao') then
    ChangeTabActionMenu.Execute
  else if (TVariaveis.GetInstancia.TelaAtiva = 'TFormTecladoAlfaNumerico') then
  begin
    if (FTecladoAlfaNumerico.FFuncaoDoTeclado = 'configuracao') then
      ChangeTabActionMenu.Execute;
  end
  else if (TVariaveis.GetInstancia.TelaAtiva = 'TFormTecladoNumerico') then
  begin
    if (FTecladoNumerico.FFuncaoDoTeclado = 'configuracao') then
      ChangeTabActionMenu.Execute;
  end;
end;

procedure TMenuConfiguracao.carregaViewMenu;
begin
  gravarConfiguracao;

  ajustaForm;
  if not Assigned(ViewMenu) then
    Application.CreateForm(TViewMenu, ViewMenu);

  Application.MainForm := ViewMenu;
  //ViewMenu.validarLogin;
  ViewMenu.Show;

  MenuConfiguracao.TabControl.ActiveTab := TabItemBase;
  MenuConfiguracao.Close;
end;

procedure TMenuConfiguracao.FormCreate(Sender: TObject);
begin
{$IFDEF MSWINDOWS}
//  MenuConfiguracao.Width := 800;
//  MenuConfiguracao.Height := 600;
//  MenuConfiguracao.Top := ViewMenu.Top;
//  MenuConfiguracao.Left := ViewMenu.Left;

  MenuConfiguracao.WindowState := TWindowState.wsMaximized;
{$ENDIF}
  FTelaConfiguracao := TFormConfiguracao.Create(Self);
  FTelaConfiguracao.RoundRectConfirmar.OnClick := botaoConfirmar;
  FTelaConfiguracao.RectangleEndereco.OnClick := tecladoAlfaNumericoIP;
  FTelaConfiguracao.RectangleContexto.OnClick := tecladoAlfaNumericoContexto;
  FTelaConfiguracao.RectanglePorta.OnClick := tecladoNumericoPorta;

  FTecladoAlfaNumerico := TFormTecladoAlfaNumerico.Create(Self);
  FTecladoAlfaNumerico.LabelAcaoConfirmar.OnClick := botaoConfirmar;
  FTecladoAlfaNumerico.LabelAcaoVoltar.OnClick := botaoVoltar;

  FTecladoNumerico := TFormTecladoNumerico.Create(Self);
  FTecladoNumerico.LabelAcaoConfirmar.OnClick := botaoConfirmar;
  FTecladoNumerico.LabelAcaoVoltar.OnClick := botaoVoltar;

  embeddForm(RectangleBase, FTelaConfiguracao);
  embeddForm(RectangleTecladoAlfaNumerico, FTecladoAlfaNumerico);
  embeddForm(RectangleTecladoNumerico, FTecladoNumerico);

  TabControl.ActiveTab := TabItemBase;
end;

procedure TMenuConfiguracao.FormShow(Sender: TObject);
begin
  FTelaConfiguracao.ajustaForm;
  ChangeTabActionMenu.Execute;

  lerConfiguracao;
end;

procedure TMenuConfiguracao.gravarConfiguracao;
begin
  TVariaveis.GetInstancia.ServidorREST := FTelaConfiguracao.LabelEndereco.Text;
  TVariaveis.GetInstancia.PortaREST := StrToInt(FTelaConfiguracao.LabelPorta.Text);
  TVariaveis.GetInstancia.Contexto := FTelaConfiguracao.LabelContexto.Text;

  if FTelaConfiguracao.LabelProtocolo.Text = 'https on' then
    TVariaveis.GetInstancia.ProtocoloREST := 'https'
  else
    TVariaveis.GetInstancia.ProtocoloREST := 'http';

  if FTelaConfiguracao.LabelTecladoFisico.Text = 'teclado on' then
    TVariaveis.GetInstancia.TecladoFisicoAtivado := True
  else
    TVariaveis.GetInstancia.TecladoFisicoAtivado := False;

  if FTelaConfiguracao.LabelComandaDigitoVerificador.Text = 'digito verificador on' then
    TVariaveis.GetInstancia.ComandaComDigitoVerificador := True
  else
    TVariaveis.GetInstancia.ComandaComDigitoVerificador := False;

  if FTelaConfiguracao.LabelExcluirItemComanda.Text = 'digitar senha para excluir on' then
    TVariaveis.GetInstancia.ExcluirItemOuComanda := True
  else
    TVariaveis.GetInstancia.ExcluirItemOuComanda := False;

  ServiceConfiguracao.Gravar;
end;

procedure TMenuConfiguracao.lerConfiguracao;
begin
  ServiceConfiguracao.Ler;

  FTelaConfiguracao.LabelEndereco.Text := TVariaveis.GetInstancia.ServidorREST;
  FTelaConfiguracao.LabelPorta.Text := IntToStr(TVariaveis.GetInstancia.PortaREST);
  FTelaConfiguracao.LabelContexto.Text := TVariaveis.GetInstancia.Contexto;

  if TVariaveis.GetInstancia.ProtocoloREST = 'https' then
    FTelaConfiguracao.LabelProtocolo.Text := 'https on'
  else
    FTelaConfiguracao.LabelProtocolo.Text := 'https off';

  if TVariaveis.GetInstancia.TecladoFisicoAtivado then
    FTelaConfiguracao.LabelTecladoFisico.Text := 'teclado on'
  else
    FTelaConfiguracao.LabelTecladoFisico.Text := 'teclado off';

  if TVariaveis.GetInstancia.ComandaComDigitoVerificador then
    FTelaConfiguracao.LabelComandaDigitoVerificador.Text := 'digito verificador on'
  else
    FTelaConfiguracao.LabelComandaDigitoVerificador.Text := 'digito verificador off';

  if TVariaveis.GetInstancia.ExcluirItemOuComanda then
    FTelaConfiguracao.LabelExcluirItemComanda.Text := 'digitar senha para excluir on'
  else
    FTelaConfiguracao.LabelExcluirItemComanda.Text := 'digitar senha para excluir off';
end;

procedure TMenuConfiguracao.tecladoAlfaNumericoContexto(Sender: TObject);
begin
  FTecladoAlfaNumerico.FFuncaoDoTeclado := 'configuracao';
  FTecladoAlfaNumerico.LabelTitulo.Text := 'informe o contexto';
  FTecladoAlfaNumerico.LabelResultado.Text := 'Configuração';
  FTecladoAlfaNumerico.LabelValor.Text := FTelaConfiguracao.LabelContexto.Text;
  FTecladoAlfaNumerico.LabelResultado.Text := EmptyStr;
  FTecladoAlfaNumerico.FTecladoFisico := TVariaveis.GetInstancia.TecladoFisicoAtivado;
  FTecladoAlfaNumerico.ajustaForm;
  ChangeTabActionTecladoAlfaNumerico.Execute;
  if FTecladoAlfaNumerico.FTecladoFisico then
    FTecladoAlfaNumerico.EditValor.SetFocus;
end;

procedure TMenuConfiguracao.tecladoAlfaNumericoIP(Sender: TObject);
begin
  FTecladoAlfaNumerico.FFuncaoDoTeclado := 'configuracao';
  FTecladoAlfaNumerico.LabelTitulo.Text := 'informe o ip do servidor';
  FTecladoAlfaNumerico.LabelResultado.Text := 'Configuração';
  FTecladoAlfaNumerico.LabelValor.Text := FTelaConfiguracao.LabelEndereco.Text;
  FTecladoAlfaNumerico.LabelResultado.Text := EmptyStr;
  FTecladoAlfaNumerico.FTecladoFisico := TVariaveis.GetInstancia.TecladoFisicoAtivado;
  FTecladoAlfaNumerico.ajustaForm;
  ChangeTabActionTecladoAlfaNumerico.Execute;
  if FTecladoAlfaNumerico.FTecladoFisico then
    FTecladoAlfaNumerico.EditValor.SetFocus;
end;

procedure TMenuConfiguracao.tecladoNumericoPorta(Sender: TObject);
begin
  FTecladoNumerico.FFuncaoDoTeclado := 'configuracao';
  FTecladoNumerico.LabelTitulo.Text := 'informe a porta do servidor';
  FTecladoNumerico.LabelResultado.Text := 'Configuração';
  FTecladoNumerico.LabelValor.Text := FTelaConfiguracao.LabelPorta.Text;
  FTecladoNumerico.FValorRetorno := EmptyStr;
  FTecladoNumerico.FSenhaRetorno := EmptyStr;
  FTecladoNumerico.FTecladoFisico := TVariaveis.GetInstancia.TecladoFisicoAtivado;
  FTecladoNumerico.FTeclaDecimal := False;
  FTecladoNumerico.ajustaForm;
  ChangeTabActionTecladoNumerico.Execute;
  if FTecladoNumerico.FTecladoFisico then
    FTecladoNumerico.EditValor.SetFocus;
end;

end.
