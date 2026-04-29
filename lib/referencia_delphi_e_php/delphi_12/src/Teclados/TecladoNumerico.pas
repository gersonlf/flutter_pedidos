unit TecladoNumerico;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.Diagnostics,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts,
  FMX.Ani,

  Util.MyEdit,
  Util.Funcao,
  Singleton.Variaveis,
  Service.DM;

var
  FRelogio: TStopwatch;
  FUltimoFiltroMs: UInt64;

type
  TFormTecladoNumerico = class(TForm)
    LayoutBase: TLayout;
    StyleBookTecladoNumerico: TStyleBook;
    RectangleFundo: TRectangle;
    RectangleTeclado: TRectangle;
    LayoutTeclado: TLayout;
    Layout01: TLayout;
    Rectangle01: TRectangle;
    Label01: TLabel;
    Rectangle02: TRectangle;
    Label02: TLabel;
    Rectangle03: TRectangle;
    Label03: TLabel;
    Layout04: TLayout;
    Rectangle10: TRectangle;
    Label10: TLabel;
    Rectangle00: TRectangle;
    Label00: TLabel;
    Rectangle11: TRectangle;
    Label11: TLabel;
    CircleObservacaoItem: TCircle;
    Layout03: TLayout;
    Rectangle07: TRectangle;
    Label07: TLabel;
    Rectangle08: TRectangle;
    Label08: TLabel;
    Rectangle09: TRectangle;
    Label09: TLabel;
    Layout02: TLayout;
    Rectangle04: TRectangle;
    Label04: TLabel;
    Rectangle05: TRectangle;
    Label05: TLabel;
    Rectangle06: TRectangle;
    Label06: TLabel;
    LayoutAcao02: TLayout;
    RectangleAcao04: TRectangle;
    LabelAcaoVoltar: TLabel;
    RectangleAcao05: TRectangle;
    LabelAcaoConfirmar: TLabel;
    LayoutAcao01: TLayout;
    RectangleAcao01: TRectangle;
    LabelAcaoLimpar: TLabel;
    RectangleAcao02: TRectangle;
    LabelAcaoListar: TLabel;
    RectangleAcao03: TRectangle;
    LabelAcao03: TLabel;
    RectangleResultado: TRectangle;
    LabelResultado: TLabel;
    RectangleTitulo: TRectangle;
    LabelTitulo: TLabel;
    LayoutValor: TLayout;
    LabelValor: TLabel;
    EditValor: TEdit;
    Label1: TLabel;
    procedure Label01Click(Sender: TObject);
    procedure LabelAcaoLimparClick(Sender: TObject);
    procedure LabelAcao03Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EditValorKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FTecladoSenha: boolean;

    // cache das teclas e controle de debounce
    FTeclas: array[0..11] of TRectangle;

    // NOVO: controle de ciclo de vida/debounce
    FEncerrando: Boolean;
    FUltimoFocusTick: UInt64;

    procedure setarCor;
    procedure teclaDel;
    procedure teclaNumero(AObject: TObject);
    procedure animarLabel(ALabel: TObject);
    procedure filtrarFuncionario(AFiltro: string);
    procedure filtrarProduto(AFiltro: string);
    procedure focus;

    // handlers rápidos (mouse/teclado)
    procedure BotaoNumeroMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure BotaoNumeroMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure BotaoDelMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure EditValorKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure EditValorTyping(Sender: TObject);

    // helpers
    function PodeFiltrarAgora(IntervaloMs: cardinal = 100): Boolean;
    procedure SetLabelTextSafe(ALabel: TLabel; const S: string);
    procedure SetEditTextSafe(AEdit: TEdit; const S: string);

    // NOVO: desmontar handlers no destroy (higiene extra)
    procedure UnwireHandlers;
  protected
    procedure FormDestroy(Sender: TObject); // NOVO
  public
    { Public declarations }
    FTecladoFisico: boolean;
    FValorRetorno: string;
    FSenhaRetorno: string;

    FCodigoProduto: string;
    FNomeProduto: string;
    FCodigoBarra: string;
    FCodigoReduzido: string;
    FDescricaoProduto: string;
    FValorUnitario: double;
    FUnidadeProduto: string;
    FObservacao: string;

    FTeclaDecimal: boolean;

    FFuncaoDoTeclado: string;
    procedure ajustaForm;
    procedure ajustaTela;
  end;

var
  FormTecladoNumerico: TFormTecladoNumerico;

implementation

{$R *.fmx}

function AgoraMs: UInt64;
begin
  Result := FRelogio.ElapsedMilliseconds; // UInt64
end;

{ ===================== Helpers ===================== }

procedure TFormTecladoNumerico.SetLabelTextSafe(ALabel: TLabel; const S: string);
begin
  if Assigned(ALabel) and (ALabel.Text <> S) then
    ALabel.Text := S;
end;

procedure TFormTecladoNumerico.SetEditTextSafe(AEdit: TEdit; const S: string);
begin
  if Assigned(AEdit) and (AEdit.Text <> S) then
    AEdit.Text := S;
end;

function TFormTecladoNumerico.PodeFiltrarAgora(IntervaloMs: cardinal): Boolean;
var
  t: UInt64;
begin
  t := AgoraMs;
  Result := (t - FUltimoFiltroMs) >= IntervaloMs;
  if Result then
    FUltimoFiltroMs := t;
end;

{ ===================== Ajustes de UI ===================== }

procedure TFormTecladoNumerico.ajustaForm;
begin
  FTecladoFisico := TVariaveis.GetInstancia.TecladoFisicoAtivado;

  FTecladoSenha := False;
  FTeclaDecimal := False;

  LabelAcaoListar.Text := EmptyStr;
  Label10.Text := EmptyStr;
  Label11.Text := EmptyStr;

  if FFuncaoDoTeclado = 'TecladoNumericoAlterarComanda' then
  begin
    LabelTitulo.Text := 'informe a nova comanda';
    LabelValor.Text := EmptyStr;
    FValorRetorno := EmptyStr;
    FSenhaRetorno := EmptyStr;
    FUnidadeProduto := EmptyStr;
    FObservacao := EmptyStr;
  end
  else if FFuncaoDoTeclado = 'TecladoNumericoAlterarComandaItem' then
  begin
    LabelTitulo.Text := 'informe a nova comanda';
    LabelValor.Text := EmptyStr;
    FValorRetorno := EmptyStr;
    FSenhaRetorno := EmptyStr;
    FUnidadeProduto := EmptyStr;
    FObservacao := EmptyStr;
  end
  else if FFuncaoDoTeclado = 'TecladoNumericoAlterarMesa' then
  begin
    LabelTitulo.Text := 'informe a nova mesa';
    LabelValor.Text := EmptyStr;
    FValorRetorno := EmptyStr;
    FSenhaRetorno := EmptyStr;
    FUnidadeProduto := EmptyStr;
    FObservacao := EmptyStr;
  end
  else if FFuncaoDoTeclado = 'TecladoNumericoComanda' then
  begin
    LabelTitulo.Text := 'informe a comanda';
    LabelValor.Text := EmptyStr;
    FValorRetorno := EmptyStr;
    FSenhaRetorno := EmptyStr;
    FUnidadeProduto := EmptyStr;
    FObservacao := EmptyStr;
    LabelAcaoListar.Text := 'listar';
  end
  else if FFuncaoDoTeclado = 'TecladoNumericoFuncionario' then
  begin
    LabelTitulo.Text := 'informe o funcionário';
    LabelResultado.Text := EmptyStr;
    LabelValor.Text := EmptyStr;
    FValorRetorno := EmptyStr;
    FSenhaRetorno := EmptyStr;
    FUnidadeProduto := EmptyStr;
    FObservacao := EmptyStr;
    LabelAcaoListar.Text := 'listar';
  end
  else if FFuncaoDoTeclado = 'TecladoNumericoItem' then
  begin
    LabelTitulo.Text := 'informe o produto';
    LabelResultado.Text := EmptyStr;
    LabelValor.Text := EmptyStr;
    FValorRetorno := EmptyStr;
    FSenhaRetorno := EmptyStr;
    FUnidadeProduto := EmptyStr;
    FObservacao := EmptyStr;
    LabelAcaoListar.Text := 'listar';

    Rectangle11.Fill.Color := TAlphaColorRec.Gold;
    Label11.Text := 'abc';
    Label11.TextSettings.Font.Size := 16;
  end
  else if FFuncaoDoTeclado = 'TecladoNumericoMesa' then
  begin
    LabelTitulo.Text := 'informe a mesa';
    LabelResultado.Text := EmptyStr;
    LabelValor.Text := EmptyStr;
    FValorRetorno := EmptyStr;
    FSenhaRetorno := EmptyStr;
    FUnidadeProduto := EmptyStr;
    FObservacao := EmptyStr;
  end
  else if FFuncaoDoTeclado = 'TecladoNumericoTag' then
  begin
    LabelTitulo.Text := 'informe a tag';
    LabelResultado.Text := EmptyStr;
    FValorRetorno := EmptyStr;
    FSenhaRetorno := EmptyStr;
    FUnidadeProduto := EmptyStr;
    FObservacao := EmptyStr;
  end
  else if FFuncaoDoTeclado = 'TecladoNumericoPedidoPronto' then
  begin
    LabelTitulo.Text := 'informe a comanda';
    LabelResultado.Text := EmptyStr;
    LabelValor.Text := EmptyStr;
    FValorRetorno := EmptyStr;
    FSenhaRetorno := EmptyStr;
    FUnidadeProduto := EmptyStr;
    FObservacao := EmptyStr;
    LabelAcaoListar.Text := 'listar';
  end
  else if FFuncaoDoTeclado = 'TecladoNumericoPortaServidor' then
  begin
    LabelTitulo.Text := 'informe a porta do servidor';
    LabelResultado.Text := EmptyStr;
    FSenhaRetorno := EmptyStr;
    FUnidadeProduto := EmptyStr;
    FObservacao := EmptyStr;
  end
  else if FFuncaoDoTeclado = 'TecladoNumericoQuantidade' then
  begin
    LabelTitulo.Text := 'informe a quantidade';
    FSenhaRetorno := EmptyStr;

    Rectangle11.Fill.Color := TAlphaColorRec.Gold;
    Label11.Text := 'obs';
    Label11.TextSettings.Font.Size := 16;
  end
  else if (FFuncaoDoTeclado = 'TecladoNumericoSenhaConfiguracao') or
          (FFuncaoDoTeclado = 'TecladoNumericoSenhaExcluirComanda') or
          (FFuncaoDoTeclado = 'TecladoNumericoSenhaExcluirItem') or
          (FFuncaoDoTeclado = 'TecladoNumericoSenhaAlterarComanda') or
          (FFuncaoDoTeclado = 'TecladoNumericoSenhaAlterarComandaItem') then
  begin
    LabelTitulo.Text := 'informe a senha';
    LabelResultado.Text := EmptyStr;
    LabelValor.Text := EmptyStr;
    FValorRetorno := EmptyStr;
    FSenhaRetorno := EmptyStr;
    FUnidadeProduto := EmptyStr;
    FObservacao := EmptyStr;
    FTecladoSenha := True;
  end;

  EditValor.Visible := FTecladoFisico;
  LabelValor.Visible := not FTecladoFisico;

  EditValor.Password := FTecladoSenha;

  if FUnidadeProduto = 'KG' then
    FTeclaDecimal := True
  else
    FTeclaDecimal := False;

  if FTeclaDecimal then
  begin
    Label10.Text := ',';
    Label10.TextSettings.Font.Size := 30;
  end
  else
    Label10.Text := '';

  CircleObservacaoItem.Visible := FObservacao <> '';
  CircleObservacaoItem.Position.Y := 5;
  CircleObservacaoItem.Position.X := 5;

  setarCor;

  // foco assíncrono com debounce/flag
  focus;

  // sincroniza o edit/label com valor inicial (se houver)
  SetEditTextSafe(EditValor, LabelValor.Text);
  FValorRetorno := LabelValor.Text;
end;

procedure TFormTecladoNumerico.ajustaTela;
var
  i: integer;
begin
  // label usado para depuração
  Label1.Visible := False;

{$IFNDEF MSWINDOWS}
  RectangleFundo.Width := Application.MainForm.Width;
  RectangleFundo.Height := Application.MainForm.Height;
  LayoutBase.Scale.X := 0.95;
  LayoutBase.Scale.Y := 0.95;
{$ENDIF}
{$IFDEF MSWINDOWS}
  RectangleFundo.Width := Application.MainForm.Width;
  RectangleFundo.Height := Application.MainForm.Height;

  if RectangleFundo.Width > 700 then
  begin
    LayoutBase.Scale.X := 0.70;
    LayoutBase.Scale.Y := 0.70;
  end
  else
  begin
    LayoutBase.Scale.X := 0.70;
    LayoutBase.Scale.Y := 0.70;
  end;
{$ENDIF}
  i := trunc(RectangleFundo.Height / 9 + 0.5);

  LayoutBase.Align := TAlignLayout.Center;
  RectangleFundo.Align := TAlignLayout.Center;

  RectangleResultado.Height := i;
  RectangleTitulo.Height := i;
  LayoutValor.Height := i;
  Layout01.Height := i;
  Layout02.Height := i;
  Layout03.Height := i;
  Layout04.Height := i;
  LayoutAcao01.Height := i;
  LayoutAcao02.Height := i;

  // foco assíncrono (sem travar)
  focus;
end;

procedure TFormTecladoNumerico.animarLabel(ALabel: TObject);
var
  L: TLabel;
begin
  if not (ALabel is TLabel) then Exit;
  L := TLabel(ALabel);

  // evita empilhar animações e evitar vazamentos de TFloatAnimation
  TAnimator.StopPropertyAnimation(L, 'Margins.Top');

  TAnimator.AnimateFloat(L, 'Margins.Top', -8, 0.1);
  TAnimator.AnimateFloatDelay(L, 'Margins.Top', 0, 0.1, 0.1);
end;

{ ===================== Handlers de digitação ===================== }

procedure TFormTecladoNumerico.EditValorKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  case Key of
    vkReturn:
      begin
        Key := 0;
        if Assigned(LabelAcaoConfirmar.OnClick) then
          LabelAcaoConfirmar.OnClick(LabelAcaoConfirmar);
      end;
    vkBack:
      begin
        Key := 0;
        teclaDel;
      end;
  end;
end;

procedure TFormTecladoNumerico.EditValorTyping(Sender: TObject);
begin
  FValorRetorno := EditValor.Text;
  FSenhaRetorno := EditValor.Text;

  if (FFuncaoDoTeclado = 'TecladoNumericoFuncionario') and (Length(FValorRetorno) >= 1) then
  begin
    //if PodeFiltrarAgora(100) then
      filtrarFuncionario(FValorRetorno);
  end
  else if (FFuncaoDoTeclado = 'TecladoNumericoItem') and (Length(FValorRetorno) >= 1) then
  begin
    //if PodeFiltrarAgora(100) then
      filtrarProduto(FValorRetorno);
  end;
end;

procedure TFormTecladoNumerico.EditValorKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if (KeyChar = ',') and ((Sender as TEdit).Text.Contains(',') or (not FTeclaDecimal)) then
    KeyChar := #0
  else if (Key = vkReturn) then
  begin
    Key := 0;
    if Assigned(LabelAcaoConfirmar.OnClick) then
      LabelAcaoConfirmar.OnClick(LabelAcaoConfirmar);
  end;
end;

{ ===================== Filtragens ===================== }

procedure TFormTecladoNumerico.filtrarFuncionario(AFiltro: string);
begin
  if (DM.filtrarMTFuncionarios(AFiltro)) and (DM.mtFuncionarios.RecordCount > 0) and (AFiltro <> EmptyStr) then
  begin
    SetLabelTextSafe(LabelResultado, DM.mtFuncionarios.FieldByName('nome_funcionario').AsString);
    LabelResultado.Tag := DM.mtFuncionarios.FieldByName('codigo_funcionario').AsInteger;
  end
  else
  begin
    SetLabelTextSafe(LabelResultado, '');
    LabelResultado.Tag := 0;
  end;
end;

procedure TFormTecladoNumerico.filtrarProduto(AFiltro: string);
var
  S: string;
begin
  if (DM.filtrarMTProdutos(AFiltro, False)) and (DM.mtProdutos.RecordCount > 0) and (AFiltro <> EmptyStr) then
  begin
    S := DM.mtProdutos.FieldByName('descricao_produto').AsString + #13 +
         FormatFloat('#,##0.00', DM.mtProdutos.FieldByName('valor_unitario').AsFloat);
    SetLabelTextSafe(LabelResultado, S);
    LabelResultado.Tag := DM.mtProdutos.FieldByName('codigo_produto').AsInteger;
    LabelResultado.TagString := DM.mtProdutos.FieldByName('codigo_barra').AsString;

    FCodigoProduto    := DM.mtProdutos.FieldByName('codigo_produto').AsString;
    FNomeProduto      := DM.mtProdutos.FieldByName('descricao_produto').AsString;
    FCodigoBarra      := DM.mtProdutos.FieldByName('codigo_barra').AsString;
    FCodigoReduzido   := DM.mtProdutos.FieldByName('codigo_reduzido').AsString;
    FDescricaoProduto := DM.mtProdutos.FieldByName('descricao_produto').AsString;
    FValorUnitario    := DM.mtProdutos.FieldByName('valor_unitario').AsFloat;
    FUnidadeProduto   := UpperCase(DM.mtProdutos.FieldByName('unidade_produto').AsString);
  end
  else
  begin
    SetLabelTextSafe(LabelResultado, '');
    LabelResultado.Tag := 0;
    LabelResultado.TagString := EmptyStr;

    FCodigoProduto := '0';
    FCodigoBarra := '';
    FCodigoReduzido := '0';
    FDescricaoProduto := '';
    FValorUnitario := 0;
    FUnidadeProduto := '';
  end;

  DM.limparFiltroProduto;
end;

{ ===================== Foco com debounce e flag de encerramento ===================== }

procedure TFormTecladoNumerico.focus;
var
  t: UInt64;
begin
  // debounce para não enfileirar dezenas de closures
  t := AgoraMs;
  if (t - FUltimoFocusTick) < 80 then
    Exit;
  FUltimoFocusTick := t;

  TThread.ForceQueue(nil,
    procedure
    begin
      if FEncerrando or (csDestroying in ComponentState) then Exit;
      if Assigned(EditValor) and EditValor.Visible and EditValor.Enabled and EditValor.CanFocus then
        EditValor.SetFocus;
    end);
end;

{ ===================== Ciclo de vida ===================== }

procedure TFormTecladoNumerico.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
end;

procedure TFormTecladoNumerico.FormCreate(Sender: TObject);
begin
  FRelogio := TStopwatch.StartNew;  // garante AgoraMs > 0
  FUltimoFiltroMs := 0;
  FUltimoFocusTick := 0;
  FEncerrando := False;

  // Cache das teclas para setarCor rápido
  FTeclas[0]  := Rectangle00;
  FTeclas[1]  := Rectangle01;
  FTeclas[2]  := Rectangle02;
  FTeclas[3]  := Rectangle03;
  FTeclas[4]  := Rectangle04;
  FTeclas[5]  := Rectangle05;
  FTeclas[6]  := Rectangle06;
  FTeclas[7]  := Rectangle07;
  FTeclas[8]  := Rectangle08;
  FTeclas[9]  := Rectangle09;
  FTeclas[10] := Rectangle10;
  FTeclas[11] := Rectangle11;

  // Eventos rápidos para números (MouseDown/Up)
  Label00.OnMouseDown := BotaoNumeroMouseDown; Label00.OnMouseUp := BotaoNumeroMouseUp;
  Label01.OnMouseDown := BotaoNumeroMouseDown; Label01.OnMouseUp := BotaoNumeroMouseUp;
  Label02.OnMouseDown := BotaoNumeroMouseDown; Label02.OnMouseUp := BotaoNumeroMouseUp;
  Label03.OnMouseDown := BotaoNumeroMouseDown; Label03.OnMouseUp := BotaoNumeroMouseUp;
  Label04.OnMouseDown := BotaoNumeroMouseDown; Label04.OnMouseUp := BotaoNumeroMouseUp;
  Label05.OnMouseDown := BotaoNumeroMouseDown; Label05.OnMouseUp := BotaoNumeroMouseUp;
  Label06.OnMouseDown := BotaoNumeroMouseDown; Label06.OnMouseUp := BotaoNumeroMouseUp;
  Label07.OnMouseDown := BotaoNumeroMouseDown; Label07.OnMouseUp := BotaoNumeroMouseUp;
  Label08.OnMouseDown := BotaoNumeroMouseDown; Label08.OnMouseUp := BotaoNumeroMouseUp;
  Label09.OnMouseDown := BotaoNumeroMouseDown; Label09.OnMouseUp := BotaoNumeroMouseUp;
  Label10.OnMouseDown := BotaoNumeroMouseDown; Label10.OnMouseUp := BotaoNumeroMouseUp; // vírgula quando aplicável
  Label11.OnMouseDown := BotaoNumeroMouseDown; Label11.OnMouseUp := BotaoNumeroMouseUp; // abc/obs quando aplicável

  // Ações
  LabelAcaoLimpar.OnMouseDown := BotaoDelMouseDown; // limpar tudo
  LabelAcao03.OnMouseDown     := BotaoDelMouseDown; // backspace

  // Teclado físico
  EditValor.OnKeyDown := EditValorKeyDown;
  EditValor.OnTyping  := EditValorTyping;

  // garante que o OnDestroy esteja ligado (se não estiver no .fmx)
  Self.OnDestroy := FormDestroy;

  ajustaTela;
end;

procedure TFormTecladoNumerico.FormDestroy(Sender: TObject);
begin
  // marca que o form está destruindo, para closures pendentes não acessarem controles
  FEncerrando := True;

  // PARA TENTAR EVITAR LEAKS DE ANIMAÇÃO EM ABORT/DESTROY
  TAnimator.StopPropertyAnimation(Self, '');
  if Assigned(LabelValor) then TAnimator.StopPropertyAnimation(LabelValor, '');
  if Assigned(LabelResultado) then TAnimator.StopPropertyAnimation(LabelResultado, '');
  if Assigned(LabelTitulo) then TAnimator.StopPropertyAnimation(LabelTitulo, '');

  // Higiene: desregistrar handlers (opcional, mas ajuda em cenários complexos)
  UnwireHandlers;
end;

procedure TFormTecladoNumerico.UnwireHandlers;
begin
  // labels numéricas
  Label00.OnMouseDown := nil; Label00.OnMouseUp := nil;
  Label01.OnMouseDown := nil; Label01.OnMouseUp := nil;
  Label02.OnMouseDown := nil; Label02.OnMouseUp := nil;
  Label03.OnMouseDown := nil; Label03.OnMouseUp := nil;
  Label04.OnMouseDown := nil; Label04.OnMouseUp := nil;
  Label05.OnMouseDown := nil; Label05.OnMouseUp := nil;
  Label06.OnMouseDown := nil; Label06.OnMouseUp := nil;
  Label07.OnMouseDown := nil; Label07.OnMouseUp := nil;
  Label08.OnMouseDown := nil; Label08.OnMouseUp := nil;
  Label09.OnMouseDown := nil; Label09.OnMouseUp := nil;
  Label10.OnMouseDown := nil; Label10.OnMouseUp := nil;
  Label11.OnMouseDown := nil; Label11.OnMouseUp := nil;

  // ações
  LabelAcaoLimpar.OnMouseDown := nil;
  LabelAcao03.OnMouseDown := nil;

  // teclado físico
  EditValor.OnKeyDown := nil;
  EditValor.OnTyping := nil;
end;

{ ===================== Clicks antigos (compat.) ===================== }

procedure TFormTecladoNumerico.Label01Click(Sender: TObject);
begin
  // mantido apenas por compatibilidade
end;

procedure TFormTecladoNumerico.LabelAcao03Click(Sender: TObject);
begin
  // mantido apenas por compatibilidade
end;

procedure TFormTecladoNumerico.LabelAcaoLimparClick(Sender: TObject);
begin
  FValorRetorno := EmptyStr;
  FSenhaRetorno := EmptyStr;

  SetEditTextSafe(EditValor, EmptyStr);
  SetLabelTextSafe(LabelValor, EmptyStr);

  focus;
end;

{ ===================== Cores ===================== }

procedure TFormTecladoNumerico.setarCor;
var
  i: integer;
  Cor: TAlphaColor;
begin
  if FTecladoSenha then
    Cor := TAlphaColors.Lightgray
  else if (FFuncaoDoTeclado = 'TecladoNumericoQuantidade') then
    Cor := TAlphaColors.Salmon
  else if (FFuncaoDoTeclado = 'TecladoNumericoComanda') or
          (FFuncaoDoTeclado = 'TecladoNumericoPedidoPronto') or
          (FFuncaoDoTeclado = 'TecladoNumericoAlterarComanda') or
          (FFuncaoDoTeclado = 'TecladoNumericoAlterarComandaItem') then
    Cor := TAlphaColors.Mediumseagreen
  else if (FFuncaoDoTeclado = 'TecladoNumericoMesa') or
          (FFuncaoDoTeclado = 'TecladoNumericoAlterarMesa') then
    Cor := TAlphaColors.Hotpink
  else if (FFuncaoDoTeclado = 'TecladoNumericoTag') then
    Cor := TAlphaColors.Brown
  else if (FFuncaoDoTeclado = 'TecladoNumericoFuncionario') then
    Cor := TAlphaColors.Lightsalmon
  else
    Cor := TAlphaColors.Royalblue;

  for i := 0 to 11 do
    if Assigned(FTeclas[i]) then
      FTeclas[i].Fill.Color := Cor;

  RectangleTitulo.Fill.Color := Cor;

  if (FFuncaoDoTeclado = 'TecladoNumericoItem') or (FFuncaoDoTeclado = 'TecladoNumericoQuantidade') then
    Rectangle11.Fill.Color := TAlphaColors.Gold;
end;

{ ===================== Edição (del/números) ===================== }

procedure TFormTecladoNumerico.teclaDel;
var
  S: string;
begin
  if FTecladoFisico then
  begin
    S := EditValor.Text;

    if S.Length > 1 then
      Delete(S, S.Length, 1)
    else
      S := EmptyStr;

    SetEditTextSafe(EditValor, S);

    if FTecladoSenha then
      FSenhaRetorno := S;

{$IFNDEF ANDROID}
    EditValor.SelStart := S.Length + 1;
{$ENDIF}
    FValorRetorno := S;
  end
  else
  begin
    if FTecladoSenha then
    begin
      S := FSenhaRetorno;

      if S.Length > 1 then
        Delete(S, S.Length, 1)
      else
        S := EmptyStr;

      FSenhaRetorno := S;
      FValorRetorno := S;

      SetLabelTextSafe(LabelValor, StringOfChar('*', S.Length));
    end
    else
    begin
      S := LabelValor.Text;

      if S.Length > 1 then
        Delete(S, S.Length, 1)
      else
        S := EmptyStr;

      FValorRetorno := S;
      SetLabelTextSafe(LabelValor, S);
    end;
  end;
end;

procedure TFormTecladoNumerico.teclaNumero(AObject: TObject);
var
  T: string;
  S: string;
begin
  if not (AObject is TLabel) then
    Exit;

  T := TLabel(AObject).Text;

  if FTecladoFisico then
  begin
    if FTecladoSenha then
      S := FSenhaRetorno
    else
      S := EditValor.Text;

    if FTeclaDecimal and (T = ',') and S.Contains(',') then
    begin
      // ignora vírgula duplicada
    end
    else if FTeclaDecimal and (T = ',') and (S = '') then
      S := '0,'
    else
      S := S + T;

    SetEditTextSafe(EditValor, S);

    if FTecladoSenha then
      FSenhaRetorno := S;

{$IFNDEF ANDROID}
    EditValor.SelStart := S.Length + 1;
{$ENDIF}
    FValorRetorno := S;
  end
  else
  begin
    if (T = 'obs') or (T = 'abc') then
      Exit;

    if FTecladoSenha then
      S := FSenhaRetorno
    else
      S := LabelValor.Text;

    if FTeclaDecimal and (T = ',') and S.Contains(',') then
    begin
      // ignora vírgula duplicada
    end
    else if FTeclaDecimal and (T = ',') and (S = '') then
      S := '0,'
    else
      S := S + T;

    if FTecladoSenha then
    begin
      FSenhaRetorno := S;
      FValorRetorno := S;
      SetLabelTextSafe(LabelValor, StringOfChar('*', S.Length));
    end
    else
    begin
      FValorRetorno := S;
      SetLabelTextSafe(LabelValor, S);
    end;
  end;
end;

{ ===================== Mouse ===================== }

procedure TFormTecladoNumerico.BotaoNumeroMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  R: TRectangle;
begin
  if (Sender is TLabel) and (TLabel(Sender).Parent is TRectangle) then
  begin
    R := TRectangle(TLabel(Sender).Parent);
    R.Fill.Color := TAlphaColorRec.Darkgray;
  end;

  teclaNumero(Sender);

  if (FFuncaoDoTeclado = 'TecladoNumericoFuncionario') and (Length(FValorRetorno) >= 1) then
  begin
    if PodeFiltrarAgora(100) then
      filtrarFuncionario(FValorRetorno);
  end
  else if (FFuncaoDoTeclado = 'TecladoNumericoItem') and (Length(FValorRetorno) >= 1) then
  begin
    if PodeFiltrarAgora(100) then
      filtrarProduto(FValorRetorno);
  end;
end;

procedure TFormTecladoNumerico.BotaoNumeroMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  // restaura cor padrão
  setarCor;
end;

procedure TFormTecladoNumerico.BotaoDelMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  teclaDel;

  if (FFuncaoDoTeclado = 'TecladoNumericoFuncionario') then
  begin
    if PodeFiltrarAgora(100) then
      filtrarFuncionario(LabelValor.Text);
  end
  else if (FFuncaoDoTeclado = 'TecladoNumericoItem') then
  begin
    if PodeFiltrarAgora(100) then
      filtrarProduto(LabelValor.Text);
  end;
end;

end.

