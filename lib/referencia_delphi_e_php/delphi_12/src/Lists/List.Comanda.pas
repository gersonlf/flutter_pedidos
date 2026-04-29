unit List.Comanda;

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

procedure atualizarItemListViewComanda(AItem: TListViewItem;
  AInserindo: boolean; AImagem: TImage);

implementation

procedure atualizarItemListViewComanda(AItem: TListViewItem;
  AInserindo: boolean; AImagem: TImage);
var
  LListItemText: TListItemText;
  img: TListItemImage;
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

    LListItemText := TListItemText(Objects.FindDrawable('Text2'));
    with LListItemText do
    begin
      if AInserindo and (DM.mtComandas.FieldByName('codigo_mesa').AsInteger > 0) then
        Text := 'Mesa';
      Align := TListItemAlign.Trailing;
      TextAlign := TTextAlign.Trailing;
      TextVertAlign := TTextAlign.Trailing;

      Font.Size := 10;
      Width := Trunc((Application.MainForm.Width - 10) / 2);
      Height := 10;

      PlaceOffset.X := X - 5;
      PlaceOffset.Y := 10;
      Opacity := 0.7;
    end;

    LListItemText := TListItemText(Objects.FindDrawable('Text11'));
    with LListItemText do
    begin
      if AInserindo and (DM.mtComandas.FieldByName('codigo_tag').AsInteger > 0) then
        Text := 'Tag';

      Align := TListItemAlign.Center;
      TextAlign := TTextAlign.Center;
      TextVertAlign := TTextAlign.Trailing;

      Font.Size := 10;
      Width := Trunc((Application.MainForm.Width - 10) / 3);
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
        Text := DM.mtComandas.FieldByName('codigo_comanda').AsString;
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Leading;
      TextColor := $FF27408B;

      Font.Size := 18;
      Width := Trunc((Application.MainForm.Width - 10) / 2);
      Height := 20;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 1;
    end;

    LListItemText := TListItemText(Objects.FindDrawable('Text4'));
    with LListItemText do
    begin
      if AInserindo and (DM.mtComandas.FieldByName('codigo_mesa').AsInteger > 0) then
        Text := DM.mtComandas.FieldByName('codigo_mesa').AsString;

      Align := TListItemAlign.Trailing;
      TextAlign := TTextAlign.Trailing;
      TextVertAlign := TTextAlign.Leading;
      TextColor := $FF27408B;

      Font.Size := 18;
      Width := Trunc((Application.MainForm.Width - 10) / 2);
      Height := 20;

      PlaceOffset.X := X - 5;
      PlaceOffset.Y := Y;
      Opacity := 1;
    end;

    LListItemText := TListItemText(Objects.FindDrawable('Text12'));
    with LListItemText do
    begin
      if AInserindo and (DM.mtComandas.FieldByName('codigo_tag').AsInteger > 0) then
        Text := DM.mtComandas.FieldByName('codigo_tag').AsString;

      Align := TListItemAlign.Center;
      TextAlign := TTextAlign.Center;
      TextVertAlign := TTextAlign.Trailing;
      TextColor := $FF27408B;

      Font.Size := 18;
      Width := Trunc((Application.MainForm.Width - 10) / 3);
      Height := 20;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 1;
    end;

    Y := Trunc(LListItemText.PlaceOffset.Y + LListItemText.Height + 10);

    LListItemText := TListItemText(Objects.FindDrawable('Text5'));
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

    LListItemText := TListItemText(Objects.FindDrawable('Text6'));
    with LListItemText do
    begin
      if AInserindo then
        Text := DM.mtComandas.FieldByName('nome_funcionario').AsString;
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Leading;

      Font.Size := 18;
      Width := Trunc((Application.MainForm.Width - 10) / 2);
      Height := 50;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 1;
      WordWrap := True;
      Trimming := TTextTrimming.None;
    end;

    Y := Trunc(LListItemText.PlaceOffset.Y + LListItemText.Height + 10);

    LListItemText := TListItemText(Objects.FindDrawable('Text7'));
    with LListItemText do
    begin
      Text := 'Data/Hora';
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

    LListItemText := TListItemText(Objects.FindDrawable('Text8'));
    with LListItemText do
    begin
      if AInserindo then
        Text := DM.mtComandas.FieldByName('data_hora').AsString;
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Leading;
      TextColor := $FFFF3030;

      Font.Size := 12;
      Width := Trunc((Application.MainForm.Width - 10) / 2);
      Height := 16;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 0.7;
    end;

    LListItemText := TListItemText(Objects.FindDrawable('Text9'));
    with LListItemText do
    begin
      if AInserindo then
        Text := DM.mtComandas.FieldByName('bloqueio').AsString;
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Leading;
      TextColor := $FFFF3030;

      Font.Size := 12;
      Width := Trunc((Application.MainForm.Width - 10) / 2);
      Height := 16;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 0.7;
      Visible := False;
    end;

    Y := Trunc(LListItemText.PlaceOffset.Y + LListItemText.Height + 10);

    img := TListItemImage(Objects.FindDrawable('image1'));
    img.Bitmap := AImagem.Bitmap;
    with img do
    begin
      Align := TListItemAlign.Trailing;

      Width := 50;
      Height := 50;

      PlaceOffset.X := 5;
      PlaceOffset.Y := Y - 60;
      Opacity := 0.9;
    end;

    Height := Y;
  end;
end;

end.
