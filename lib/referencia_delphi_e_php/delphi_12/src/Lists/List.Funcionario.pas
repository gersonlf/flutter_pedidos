unit List.Funcionario;

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

    procedure atualizarItemListViewFuncionario(AItem: TListViewItem;
      AInserindo: boolean);

implementation

procedure atualizarItemListViewFuncionario(AItem: TListViewItem;
AInserindo: boolean);
var
  LListItemText: TListItemText;
  Y: Integer;
  X: Integer;

begin
  with AItem do
  begin
    X := 5;
    Y := 10;

    LListItemText := TListItemText(Objects.FindDrawable('Text1'));
    with LListItemText do
    begin
      Text := 'Funcionário';
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Trailing;

      Font.Size := 10;
      Width := Trunc((Application.MainForm.Width - 10) / 2);
      Height := 10;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 0.7;
    end;

    Y := Trunc(LListItemText.PlaceOffset.Y + LListItemText.Height + 1);

    LListItemText := TListItemText(Objects.FindDrawable('Text2'));
    with LListItemText do
    begin
      if AInserindo then
        Text := DM.mtFuncionarios.FieldByName('nome_funcionario').AsString;
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Leading;

      Font.Size := 18;
      Width := Trunc(Application.MainForm.Width - 10);
      Height := 50;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 1;
    end;

    Y := Trunc(LListItemText.PlaceOffset.Y + LListItemText.Height + 10);

    LListItemText := TListItemText(Objects.FindDrawable('Text3'));
    with LListItemText do
    begin
      Text := 'Código';
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Trailing;

      Font.Size := 10;
      Width := Trunc((Application.MainForm.Width - 10) / 2);
      Height := 10;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 0.7;
    end;

    Y := Trunc(LListItemText.PlaceOffset.Y + LListItemText.Height + 1);

    LListItemText := TListItemText(Objects.FindDrawable('Text4'));
    with LListItemText do
    begin
      if AInserindo then
        Text := DM.mtFuncionarios.FieldByName('codigo_funcionario').AsString;
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Leading;
      TextColor := $FF27408B;

      Font.Size := 18;
      Width := Trunc(Application.MainForm.Width - 10);
      Height := 20;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 1;
    end;

    Y := Trunc(LListItemText.PlaceOffset.Y + LListItemText.Height + 10);
    Height := Y;
  end;
end;

end.
