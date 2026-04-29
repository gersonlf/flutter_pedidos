unit Form.Configuracao;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts,

  Singleton.Variaveis;

type
  TFormConfiguracao = class(TForm)
    LayoutBase: TLayout;
    Rectangle1: TRectangle;
    Label1: TLabel;
    Layout1: TLayout;
    RoundRectConfirmar: TRoundRect;
    LabelConfirmar: TLabel;
    Layout2: TLayout;
    Label2: TLabel;
    RectangleEndereco: TRectangle;
    LabelEndereco: TLabel;
    Layout3: TLayout;
    Label3: TLabel;
    RectanglePorta: TRectangle;
    LabelPorta: TLabel;
    Layout4: TLayout;
    Label4: TLabel;
    RectangleContexto: TRectangle;
    LabelContexto: TLabel;
    Layout5: TLayout;
    Label5: TLabel;
    RectangleProtocolo: TRectangle;
    LabelProtocolo: TLabel;
    Layout6: TLayout;
    Label6: TLabel;
    RectangleTecladoFisico: TRectangle;
    LabelTecladoFisico: TLabel;
    Layout7: TLayout;
    Label7: TLabel;
    RectangleComandaDigitoVerificador: TRectangle;
    LabelComandaDigitoVerificador: TLabel;
    Layout8: TLayout;
    Label8: TLabel;
    RectangleExcluirItemComanda: TRectangle;
    LabelExcluirItemComanda: TLabel;
    procedure RectangleComandaDigitoVerificadorClick(Sender: TObject);
    procedure RectangleExcluirItemComandaClick(Sender: TObject);
    procedure RectangleProtocoloClick(Sender: TObject);
    procedure RectangleTecladoFisicoClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ajustaForm;
  end;

var
  FormConfiguracao: TFormConfiguracao;

implementation

{$R *.fmx}
{ TFormConfiguracao }

procedure TFormConfiguracao.ajustaForm;
begin
  TVariaveis.GetInstancia.TelaAtiva := 'TFormConfiguracao';
end;

procedure TFormConfiguracao.RectangleComandaDigitoVerificadorClick(Sender: TObject);
begin
  if LabelComandaDigitoVerificador.Text = 'digito verificador off' then
    LabelComandaDigitoVerificador.Text := 'digito verificador on'
  else
    LabelComandaDigitoVerificador.Text := 'digito verificador off';
end;

procedure TFormConfiguracao.RectangleExcluirItemComandaClick(Sender: TObject);
begin
  if LabelExcluirItemComanda.Text = 'digitar senha para excluir off' then
    LabelExcluirItemComanda.Text := 'digitar senha para excluir on'
  else
    LabelExcluirItemComanda.Text := 'digitar senha para excluir off';
end;

procedure TFormConfiguracao.RectangleProtocoloClick(Sender: TObject);
begin
  if LabelProtocolo.Text = 'https on' then
    LabelProtocolo.Text := 'https off'
  else
    LabelProtocolo.Text := 'https on';
end;

procedure TFormConfiguracao.RectangleTecladoFisicoClick(Sender: TObject);
begin
  if LabelTecladoFisico.Text = 'teclado off' then
    LabelTecladoFisico.Text := 'teclado on'
  else
    LabelTecladoFisico.Text := 'teclado off';
end;

end.
