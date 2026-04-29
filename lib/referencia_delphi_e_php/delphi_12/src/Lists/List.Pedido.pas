unit List.Pedido;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Actions,
  System.JSON,

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
  Util.Funcao,

  Singleton.Variaveis,
  Service.DM,

  FMX.Ani,
  FMX.ListView.Adapters.Base,
  FMX.Edit;

    procedure atualizarItemListViewPedido(AItem: TListViewItem;
      AInserindo: boolean);

implementation

procedure atualizarItemListViewPedido(AItem: TListViewItem;
AInserindo: boolean);
var
  LListItemText: TListItemText;
  X: Integer;
  Y: Integer;

begin
  with AItem do
  begin
    X := 5;

    LListItemText := TListItemText(Objects.FindDrawable('Text1'));
    with LListItemText do
    begin
      Text := 'Comanda';
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Trailing;

      Font.Size := 10;
      Width := Trunc((Application.MainForm.Width - 10) / 2);
      Height := 10;

      PlaceOffset.X := X;
      PlaceOffset.Y := 10;
      Opacity := 0.7;
    end;

    Y := Trunc(LListItemText.PlaceOffset.Y + LListItemText.Height + 1);

    LListItemText := TListItemText(Objects.FindDrawable('Text3'));
    with LListItemText do
    begin
      if AInserindo then
        Text := DM.mtPedidos.FieldByName('codigo_comanda').AsString;
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Leading;
      TextColor := $FF27408B;

      Font.Size := 36;
      Width := Trunc((Application.MainForm.Width - 10) / 2);
      Height := 56;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 1;
    end;

    Y := Trunc(LListItemText.PlaceOffset.Y + LListItemText.Height + 10);

    Height := Y;
  end;
end;

end.
