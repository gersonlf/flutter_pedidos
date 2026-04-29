unit TecladoAlfaNumerico;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Layouts,
  FMX.Ani,

  System.Diagnostics,        // TStopwatch (debounce cross-platform)
  Singleton.Variaveis;

type
  TFormTecladoAlfaNumerico = class(TForm)
    LayoutBase: TLayout;
    RectangleFundo: TRectangle;
    RectangleTeclado: TRectangle;
    RectangleTitulo: TRectangle;
    LabelTitulo: TLabel;
    LayoutValor: TLayout;
    LabelValor: TLabel;
    EditValor: TEdit;
    LayoutTeclado: TLayout;
    Layout01: TLayout;
    Rectangle01: TRectangle;
    Label01: TLabel;
    Rectangle02: TRectangle;
    Label02: TLabel;
    Rectangle03: TRectangle;
    Label03: TLabel;
    Rectangle04: TRectangle;
    Label04: TLabel;
    Rectangle10: TRectangle;
    Label10: TLabel;
    Rectangle09: TRectangle;
    Label09: TLabel;
    Rectangle08: TRectangle;
    Label08: TLabel;
    Rectangle07: TRectangle;
    Label07: TLabel;
    Rectangle06: TRectangle;
    Label06: TLabel;
    Rectangle05: TRectangle;
    Label05: TLabel;
    LayoutAcao01: TLayout;
    RectangleAcao01: TRectangle;
    LabelAcaoLimpar: TLabel;
    RectangleAcao02: TRectangle;
    LabelAcao02: TLabel;
    RectangleAcao03: TRectangle;
    LabelAcao03: TLabel;
    Layout04: TLayout;
    Rectangle31: TRectangle;
    Label31: TLabel;
    Rectangle32: TRectangle;
    Label32: TLabel;
    Rectangle33: TRectangle;
    Label33: TLabel;
    Rectangle34: TRectangle;
    Label34: TLabel;
    RectangleSpace04: TRectangle;
    Rectangle30: TRectangle;
    Label30: TLabel;
    Rectangle38: TRectangle;
    Label38: TLabel;
    Rectangle37: TRectangle;
    Label37: TLabel;
    Rectangle36: TRectangle;
    Label36: TLabel;
    Rectangle35: TRectangle;
    Label35: TLabel;
    RectangleSpace03: TRectangle;
    Layout03: TLayout;
    Rectangle21: TRectangle;
    Label21: TLabel;
    Rectangle22: TRectangle;
    Label22: TLabel;
    Rectangle23: TRectangle;
    Label23: TLabel;
    Rectangle24: TRectangle;
    Label24: TLabel;
    RectangleSpace02: TRectangle;
    Rectangle29: TRectangle;
    Label29: TLabel;
    Rectangle28: TRectangle;
    Label28: TLabel;
    Rectangle27: TRectangle;
    Label27: TLabel;
    Rectangle26: TRectangle;
    Label26: TLabel;
    Rectangle25: TRectangle;
    Label25: TLabel;
    RectangleSpace01: TRectangle;
    Layout02: TLayout;
    Rectangle11: TRectangle;
    Label11: TLabel;
    Rectangle12: TRectangle;
    Label12: TLabel;
    Rectangle13: TRectangle;
    Label13: TLabel;
    Rectangle14: TRectangle;
    Label14: TLabel;
    Rectangle20: TRectangle;
    Label20: TLabel;
    Rectangle19: TRectangle;
    Label19: TLabel;
    Rectangle18: TRectangle;
    Label18: TLabel;
    Rectangle17: TRectangle;
    Label17: TLabel;
    Rectangle16: TRectangle;
    Label16: TLabel;
    Rectangle15: TRectangle;
    Label15: TLabel;
    LayoutAcao02: TLayout;
    RectangleAcao04: TRectangle;
    LabelAcaoVoltar: TLabel;
    RectangleAcao05: TRectangle;
    LabelAcaoConfirmar: TLabel;
    RectangleResultado: TRectangle;
    LabelResultado: TLabel;
    StyleBookTecladoAlfanumerico: TStyleBook;
    procedure FormCreate(Sender: TObject);
    procedure EditValorKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure Label01Click(Sender: TObject);
    procedure LabelAcaoLimparClick(Sender: TObject);
    procedure LabelAcao02Click(Sender: TObject);
    procedure LabelAcao03Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    // ===== novos campos p/ performance e ciclo de vida =====
    FTeclas: array[1..38] of TRectangle; // cache das teclas "Rectangle01..38"
    FRelogio: TStopwatch;                 // relógio para debounce
    FUltimoFiltroMs: UInt64;              // marcador do último filtro (ms)

    FEncerrando: Boolean;                 // evita closures/animações no destroy
    FUltimoFocusTick: UInt64;             // debounce do foco

    procedure setarCor;
    procedure teclaDel;
    procedure teclaNumero(AObject: TObject);
    procedure animarLabel(ALabel: TObject);
    procedure focus;

    // Handlers mais responsivos
    procedure BotaoTeclaMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure BotaoTeclaMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure BotaoDelMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);

    procedure EditValorKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure EditValorTyping(Sender: TObject);

    // Helpers
    function AgoraMs: UInt64; inline;
    function PodeFiltrarAgora(IntervaloMs: cardinal = 100): Boolean;
    procedure SetLabelTextSafe(ALabel: TLabel; const S: string);
    procedure SetEditTextSafe(AEdit: TEdit; const S: string);

    // Higiene opcional: "desregistrar" handlers no destroy
    procedure UnwireHandlers;
  protected
    procedure FormDestroy(Sender: TObject); // NOVO
  public
    { Public declarations }
    FTecladoFisico: boolean;
    FValorRetorno: string;
    FSenhaRetorno: string;
    FTeclaDecimal: boolean;

    FFuncaoDoTeclado: string;

    procedure ajustaForm;
    procedure ajustaTela;
  end;

var
  FormTecladoAlfaNumerico: TFormTecladoAlfaNumerico;

implementation

{$R *.fmx}

{ ===== Helpers ===== }

procedure TFormTecladoAlfaNumerico.SetLabelTextSafe(ALabel: TLabel; const S: string);
begin
  if Assigned(ALabel) and (ALabel.Text <> S) then
    ALabel.Text := S;
end;

procedure TFormTecladoAlfaNumerico.SetEditTextSafe(AEdit: TEdit; const S: string);
begin
  if Assigned(AEdit) and (AEdit.Text <> S) then
    AEdit.Text := S;
end;

function TFormTecladoAlfaNumerico.AgoraMs: UInt64;
begin
  Result := FRelogio.ElapsedMilliseconds;
end;

function TFormTecladoAlfaNumerico.PodeFiltrarAgora(IntervaloMs: cardinal): Boolean;
var
  t: UInt64;
begin
  t := AgoraMs;
  Result := (t - FUltimoFiltroMs) >= IntervaloMs;
  if Result then
    FUltimoFiltroMs := t;
end;

{ ===== Ajustes de UI ===== }

procedure TFormTecladoAlfaNumerico.ajustaForm;
begin
  FTecladoFisico := TVariaveis.GetInstancia.TecladoFisicoAtivado;
  FSenhaRetorno := EmptyStr;
  FTeclaDecimal := False;

  if FFuncaoDoTeclado = 'TecladoAlfaNumericoObservacao' then
    LabelTitulo.Text := 'informe a observacao'
  else if FFuncaoDoTeclado = 'TecladoAlfaNumericoAlterarObservacaoItem' then
    LabelTitulo.Text := 'informe a observacao'
  else if FFuncaoDoTeclado = 'TecladoAlfaNumericoContexto' then
    LabelTitulo.Text := 'informe o contexto'
  else if FFuncaoDoTeclado = 'TecladoAlfaNumericoEnderecoServidor' then
    LabelTitulo.Text := 'informe o endereco do servidor'
  else if FFuncaoDoTeclado = 'TecladoAlfaNumericoObservacaoQuantidade' then
    LabelTitulo.Text := 'informe a observação'
  else if FFuncaoDoTeclado = 'TecladoAlfaNumericoProdutoItem' then
    LabelTitulo.Text := 'informe o produto'
  else if FFuncaoDoTeclado = 'TecladoAlfaNumericoProdutoMenu' then
    LabelTitulo.Text := 'informe o produto';

  EditValor.Visible := FTecladoFisico;
  LabelValor.Visible := not FTecladoFisico;

  SetEditTextSafe(EditValor, LabelValor.Text);
  FValorRetorno := LabelValor.Text;

  setarCor;

  // foco sem Sleep/thread
  focus;
end;

procedure TFormTecladoAlfaNumerico.ajustaTela;
var
  i: integer;
begin
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

  focus;
end;

procedure TFormTecladoAlfaNumerico.animarLabel(ALabel: TObject);
var
  L: TLabel;
begin
  if not (ALabel is TLabel) then Exit;
  L := TLabel(ALabel);

  // evita empilhar animações (e possíveis leaks de TFloatAnimation)
  TAnimator.StopPropertyAnimation(L, 'Margins.Top');

  TAnimator.AnimateFloat(L, 'Margins.Top', -8, 0.1);
  TAnimator.AnimateFloatDelay(L, 'Margins.Top', 0, 0.1, 0.1);
end;

{ ===== Digitação rápida (teclado físico) ===== }

procedure TFormTecladoAlfaNumerico.EditValorKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
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

procedure TFormTecladoAlfaNumerico.EditValorTyping(Sender: TObject);
begin
  FValorRetorno := EditValor.Text;
  // se quiser gatilhos de busca/auto-complete, use debounce aqui:
  // if (Length(FValorRetorno) >= 3) and PodeFiltrarAgora(100) then ...
end;

procedure TFormTecladoAlfaNumerico.EditValorKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  // Mantido por compatibilidade; o fluxo principal está em OnKeyDown/OnTyping
  FValorRetorno := EditValor.Text;

  if (KeyChar = ',') and ((Sender as TEdit).Text.Contains(',') or (not FTeclaDecimal)) then
    KeyChar := #0
  else if (Key = vkReturn) then
  begin
    Key := 0;
    if Assigned(LabelAcaoConfirmar.OnClick) then
      LabelAcaoConfirmar.OnClick(LabelAcaoConfirmar);
  end;
end;

{ ===== Foco rápido (sem Sleep) com debounce e flag ===== }

procedure TFormTecladoAlfaNumerico.focus;
var
  t: UInt64;
begin
  // Debounce p/ não enfileirar várias closures
  t := AgoraMs;
  if (t - FUltimoFocusTick) < 80 then Exit;
  FUltimoFocusTick := t;

  TThread.ForceQueue(nil,
    procedure
    begin
      if FEncerrando or (csDestroying in ComponentState) then Exit;
      if EditValor.Visible and EditValor.Enabled and EditValor.CanFocus then
        EditValor.SetFocus;
    end);
end;

{ ===== FormCreate: cache e ligações de eventos rápidos ===== }

procedure TFormTecladoAlfaNumerico.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
end;

procedure TFormTecladoAlfaNumerico.FormCreate(Sender: TObject);
  procedure BindLabel(const L: TLabel);
  begin
    if Assigned(L) then
    begin
      L.OnMouseDown := BotaoTeclaMouseDown;
      L.OnMouseUp   := BotaoTeclaMouseUp;
    end;
  end;
begin
  // relógio p/ debounce
  FRelogio := TStopwatch.StartNew;
  FUltimoFiltroMs := 0;

  // flags de ciclo de vida
  FEncerrando := False;
  FUltimoFocusTick := 0;

  // cache das teclas (1..38). Guarde só as que existem na sua tela:
  FTeclas[1]  := Rectangle01;  FTeclas[2]  := Rectangle02;  FTeclas[3]  := Rectangle03;  FTeclas[4]  := Rectangle04;
  FTeclas[5]  := Rectangle05;  FTeclas[6]  := Rectangle06;  FTeclas[7]  := Rectangle07;  FTeclas[8]  := Rectangle08;
  FTeclas[9]  := Rectangle09;  FTeclas[10] := Rectangle10;  FTeclas[11] := Rectangle11;  FTeclas[12] := Rectangle12;
  FTeclas[13] := Rectangle13;  FTeclas[14] := Rectangle14;  FTeclas[15] := Rectangle15;  FTeclas[16] := Rectangle16;
  FTeclas[17] := Rectangle17;  FTeclas[18] := Rectangle18;  FTeclas[19] := Rectangle19;  FTeclas[20] := Rectangle20;
  FTeclas[21] := Rectangle21;  FTeclas[22] := Rectangle22;  FTeclas[23] := Rectangle23;  FTeclas[24] := Rectangle24;
  FTeclas[25] := Rectangle25;  FTeclas[26] := Rectangle26;  FTeclas[27] := Rectangle27;  FTeclas[28] := Rectangle28;
  FTeclas[29] := Rectangle29;  FTeclas[30] := Rectangle30;  FTeclas[31] := Rectangle31;  FTeclas[32] := Rectangle32;
  FTeclas[33] := Rectangle33;  FTeclas[34] := Rectangle34;  FTeclas[35] := Rectangle35;  FTeclas[36] := Rectangle36;
  FTeclas[37] := Rectangle37;  FTeclas[38] := Rectangle38;

  // Nomes de rótulos das teclas (bind MouseDown/Up)
  BindLabel(Label01); BindLabel(Label02); BindLabel(Label03); BindLabel(Label04);
  BindLabel(Label05); BindLabel(Label06); BindLabel(Label07); BindLabel(Label08);
  BindLabel(Label09); BindLabel(Label10); BindLabel(Label11); BindLabel(Label12);
  BindLabel(Label13); BindLabel(Label14); BindLabel(Label15); BindLabel(Label16);
  BindLabel(Label17); BindLabel(Label18); BindLabel(Label19); BindLabel(Label20);
  BindLabel(Label21); BindLabel(Label22); BindLabel(Label23); BindLabel(Label24);
  BindLabel(Label25); BindLabel(Label26); BindLabel(Label27); BindLabel(Label28);
  BindLabel(Label29); BindLabel(Label30); BindLabel(Label31); BindLabel(Label32);
  BindLabel(Label33); BindLabel(Label34); BindLabel(Label35); BindLabel(Label36);
  BindLabel(Label37); BindLabel(Label38);
  // Espaços (se tiver Label dentro, pode bindar também — aqui foquei nas teclas com texto)

  // Ações
  LabelAcaoLimpar.OnMouseDown := BotaoDelMouseDown; // limpar tudo
  LabelAcao03.OnMouseDown     := BotaoDelMouseDown; // backspace (del)

  // Teclado físico
  EditValor.OnKeyDown := EditValorKeyDown;
  EditValor.OnTyping  := EditValorTyping;

  // garante que o OnDestroy esteja ligado (caso não esteja no .fmx)
  Self.OnDestroy := FormDestroy;

  ajustaTela;
end;

procedure TFormTecladoAlfaNumerico.FormDestroy(Sender: TObject);
begin
  // marca que o form está destruindo, para closures pendentes não acessarem controles
  FEncerrando := True;

  // evita leaks de TFloatAnimation em cenários de fechamento rápido
  TAnimator.StopPropertyAnimation(Self, '');
  if Assigned(LabelValor) then TAnimator.StopPropertyAnimation(LabelValor, '');
  if Assigned(LabelResultado) then TAnimator.StopPropertyAnimation(LabelResultado, '');
  if Assigned(LabelTitulo) then TAnimator.StopPropertyAnimation(LabelTitulo, '');

  // Higiene opcional: desregistrar handlers
  UnwireHandlers;
end;

procedure TFormTecladoAlfaNumerico.UnwireHandlers;
begin
  // ações
  LabelAcaoLimpar.OnMouseDown := nil;
  LabelAcao03.OnMouseDown := nil;

  // teclado físico
  EditValor.OnKeyDown := nil;
  EditValor.OnTyping  := nil;

  // teclas (labels) — zere somente se necessário
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
  Label12.OnMouseDown := nil; Label12.OnMouseUp := nil;
  Label13.OnMouseDown := nil; Label13.OnMouseUp := nil;
  Label14.OnMouseDown := nil; Label14.OnMouseUp := nil;
  Label15.OnMouseDown := nil; Label15.OnMouseUp := nil;
  Label16.OnMouseDown := nil; Label16.OnMouseUp := nil;
  Label17.OnMouseDown := nil; Label17.OnMouseUp := nil;
  Label18.OnMouseDown := nil; Label18.OnMouseUp := nil;
  Label19.OnMouseDown := nil; Label19.OnMouseUp := nil;
  Label20.OnMouseDown := nil; Label20.OnMouseUp := nil;
  Label21.OnMouseDown := nil; Label21.OnMouseUp := nil;
  Label22.OnMouseDown := nil; Label22.OnMouseUp := nil;
  Label23.OnMouseDown := nil; Label23.OnMouseUp := nil;
  Label24.OnMouseDown := nil; Label24.OnMouseUp := nil;
  Label25.OnMouseDown := nil; Label25.OnMouseUp := nil;
  Label26.OnMouseDown := nil; Label26.OnMouseUp := nil;
  Label27.OnMouseDown := nil; Label27.OnMouseUp := nil;
  Label28.OnMouseDown := nil; Label28.OnMouseUp := nil;
  Label29.OnMouseDown := nil; Label29.OnMouseUp := nil;
  Label30.OnMouseDown := nil; Label30.OnMouseUp := nil;
  Label31.OnMouseDown := nil; Label31.OnMouseUp := nil;
  Label32.OnMouseDown := nil; Label32.OnMouseUp := nil;
  Label33.OnMouseDown := nil; Label33.OnMouseUp := nil;
  Label34.OnMouseDown := nil; Label34.OnMouseUp := nil;
  Label35.OnMouseDown := nil; Label35.OnMouseUp := nil;
  Label36.OnMouseDown := nil; Label36.OnMouseUp := nil;
  Label37.OnMouseDown := nil; Label37.OnMouseUp := nil;
  Label38.OnMouseDown := nil; Label38.OnMouseUp := nil;
end;

{ ===== Compat: OnClick antigos (se o .fmx tiver) ===== }

procedure TFormTecladoAlfaNumerico.Label01Click(Sender: TObject);
begin
  // compat — o fluxo principal agora é no OnMouseDown
  // teclaNumero(Sender);
end;

procedure TFormTecladoAlfaNumerico.LabelAcao02Click(Sender: TObject);
begin
  // espaço (pode manter via click ou migrar p/ OnMouseDown)
  if FTecladoFisico then
  begin
    FValorRetorno := EditValor.Text + ' ';
    SetEditTextSafe(EditValor, FValorRetorno);
  end
  else
  begin
    FValorRetorno := LabelValor.Text + ' ';
    SetLabelTextSafe(LabelValor, FValorRetorno);
  end;
end;

procedure TFormTecladoAlfaNumerico.LabelAcao03Click(Sender: TObject);
begin
  // teclaDel;
end;

procedure TFormTecladoAlfaNumerico.LabelAcaoLimparClick(Sender: TObject);
begin
  FSenhaRetorno := EmptyStr;
  FValorRetorno := EmptyStr;
  SetLabelTextSafe(LabelValor, EmptyStr);
  SetEditTextSafe(EditValor, EmptyStr);
end;

{ ===== setarCor otimizado (sem FindComponent) ===== }

procedure TFormTecladoAlfaNumerico.setarCor;
var
  i: integer;
  Cor: TAlphaColor;
begin
  if (FFuncaoDoTeclado = 'TecladoAlfaNumericoObservacao') or
     (FFuncaoDoTeclado = 'TecladoAlfaNumericoAlterarObservacaoItem') then
    Cor := TAlphaColors.Gray
  else
    Cor := TAlphaColors.Royalblue;

  for i := Low(FTeclas) to High(FTeclas) do
    if Assigned(FTeclas[i]) then
      FTeclas[i].Fill.Color := Cor;

  RectangleTitulo.Fill.Color := Cor;
end;

{ ===== edição sem latência ===== }

procedure TFormTecladoAlfaNumerico.teclaDel;
var
  S: string;
begin
  if FTecladoFisico then
  begin
    S := EditValor.Text;
    if S <> '' then
      Delete(S, Length(S), 1);
    SetEditTextSafe(EditValor, S);
    if FFuncaoDoTeclado = 'senha' then
      FSenhaRetorno := S;
{$IFNDEF ANDROID}
    EditValor.SelStart := S.Length + 1;
{$ENDIF}
    FValorRetorno := S;
  end
  else
  begin
    if FFuncaoDoTeclado = 'senha' then
    begin
      S := FSenhaRetorno;
      if S <> '' then
        Delete(S, Length(S), 1);
      FSenhaRetorno := S;
      FValorRetorno := S;
      SetLabelTextSafe(LabelValor, StringOfChar('*', S.Length));
    end
    else
    begin
      S := LabelValor.Text;
      if S <> '' then
        Delete(S, Length(S), 1);
      FValorRetorno := S;
      SetLabelTextSafe(LabelValor, S);
    end;
  end;
end;

procedure TFormTecladoAlfaNumerico.teclaNumero(AObject: TObject);
var
  T, S: string;
begin
  if not (AObject is TLabel) then
    Exit;

  T := TLabel(AObject).Text;

  if FTecladoFisico then
  begin
    if FFuncaoDoTeclado = 'senha' then
      S := FSenhaRetorno
    else
      S := EditValor.Text;

    if FTeclaDecimal and (T = ',') and S.Contains(',') then
      // ignora vírgula duplicada
    else if FTeclaDecimal and (T = ',') and (S = '') then
      S := '0,'
    else
      S := S + T;

    SetEditTextSafe(EditValor, S);
    if FFuncaoDoTeclado = 'senha' then
      FSenhaRetorno := S;
{$IFNDEF ANDROID}
    EditValor.SelStart := S.Length + 1;
{$ENDIF}
    FValorRetorno := S;
  end
  else
  begin
    if FFuncaoDoTeclado = 'senha' then
      S := FSenhaRetorno
    else
      S := LabelValor.Text;

    if FTeclaDecimal and (T = ',') and S.Contains(',') then
      // ignora vírgula duplicada
    else if FTeclaDecimal and (T = ',') and (S = '') then
      S := '0,'
    else
      S := S + T;

    if FFuncaoDoTeclado = 'senha' then
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

{ ===== MouseDown/Up mais responsivos que OnClick ===== }

procedure TFormTecladoAlfaNumerico.BotaoTeclaMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  R: TRectangle;
begin
  // darken no botão
  if (Sender is TLabel) and (TLabel(Sender).Parent is TRectangle) then
  begin
    R := TRectangle(TLabel(Sender).Parent);
    R.Fill.Color := TAlphaColorRec.Darkgray;
  end;

  teclaNumero(Sender);
end;

procedure TFormTecladoAlfaNumerico.BotaoTeclaMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  // restaura o tema atual sem precisar guardar cor antiga
  setarCor;
end;

procedure TFormTecladoAlfaNumerico.BotaoDelMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  teclaDel;
end;

end.

