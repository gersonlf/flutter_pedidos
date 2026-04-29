unit List.Item;

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

procedure atualizarItemListViewItem(AItem: TListViewItem; AInserindo: boolean;
  AImagem: TImage);

implementation

procedure atualizarItemListViewItem(AItem: TListViewItem; AInserindo: boolean;
  AImagem: TImage);
var
  txt: TListItemText;
  img: TListItemImage;
  X: Integer;
  Y: Integer;

begin
  with AItem do
  begin
    X := 5;

    txt := TListItemText(Objects.FindDrawable('Text1'));
    with txt do
    begin
      Text := 'Qtde';
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Trailing;
      Font.Size := 10;
      Width := Trunc((Application.MainForm.Width - 10) / 3);
      Height := 10;
      PlaceOffset.X := X;
      PlaceOffset.Y := 10;
      Opacity := 0.7;
    end;

    txt := TListItemText(Objects.FindDrawable('Text2'));
    with txt do
    begin
      Text := 'Total R$';
      Align := TListItemAlign.Trailing;
      TextAlign := TTextAlign.Trailing;
      TextVertAlign := TTextAlign.Trailing;
      Font.Size := 10;
      Width := Trunc((Application.MainForm.Width - 10) / 3);
      Height := 10;
      PlaceOffset.X := X - 5;
      PlaceOffset.Y := 10;
      Opacity := 0.7;
    end;

    txt := TListItemText(Objects.FindDrawable('Text3'));
    with txt do
    begin
      Text := 'Unitario R$';
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

    Y := Trunc(txt.PlaceOffset.Y + txt.Height + 1);

    txt := TListItemText(Objects.FindDrawable('Text4'));
    with txt do
    begin
      if AInserindo then
        Text := formataFloatStr3(DM.mtItens.FieldByName('qtde_produto').AsFloat);
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Trailing;
      TextColor := $FF27408B;
      Font.Size := 18;
      Width := Trunc((Application.MainForm.Width - 10) / 3);
      Height := 20;
      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 1;
    end;

    txt := TListItemText(Objects.FindDrawable('Text5'));
    with txt do
    begin
      if AInserindo then
        Text := formataFloatStr2(DM.mtItens.FieldByName('valor_unitario').AsFloat
          * DM.mtItens.FieldByName('qtde_produto').AsFloat);
      Align := TListItemAlign.Trailing;
      TextAlign := TTextAlign.Trailing;
      TextVertAlign := TTextAlign.Trailing;
      TextColor := $FF27408B;

      Font.Size := 18;
      Width := Trunc((Application.MainForm.Width - 10) / 3);
      Height := 20;

      PlaceOffset.X := X - 5;
      PlaceOffset.Y := Y;
      Opacity := 1;
    end;

    txt := TListItemText(Objects.FindDrawable('Text6'));
    with txt do
    begin
      if AInserindo then
        Text := formataFloatStr2
          (DM.mtItens.FieldByName('valor_unitario').AsFloat);
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

    Y := Trunc(txt.PlaceOffset.Y + txt.Height + 10);

    txt := TListItemText(Objects.FindDrawable('Text7'));
    with txt do
    begin
      Text := 'Produto';
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Trailing;
      Font.Size := 10;
      Width := Trunc((Application.MainForm.Width - 10) / 3);
      Height := 10;
      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 0.7;
    end;

    txt := TListItemText(Objects.FindDrawable('Text8'));
    with txt do
    begin
      Text := 'Barra';
      Align := TListItemAlign.Trailing;
      TextAlign := TTextAlign.Trailing;
      TextVertAlign := TTextAlign.Trailing;
      Font.Size := 10;
      Width := Trunc((Application.MainForm.Width - 10) / 3);
      Height := 10;
      PlaceOffset.X := X - 5;
      PlaceOffset.Y := Y;
      Opacity := 0.7;
    end;

    txt := TListItemText(Objects.FindDrawable('Text9'));
    with txt do
    begin
      Text := 'Reduzido';
      Align := TListItemAlign.Center;
      TextAlign := TTextAlign.Center;
      TextVertAlign := TTextAlign.Trailing;
      Font.Size := 10;
      Width := Trunc((Application.MainForm.Width - 10) / 3);
      Height := 10;
      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 0.7;
    end;

    Y := Trunc(txt.PlaceOffset.Y + txt.Height + 1);

    txt := TListItemText(Objects.FindDrawable('Text10'));
    with txt do
    begin
      if AInserindo then
        Text := DM.mtItens.FieldByName('codigo_produto').AsString;
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Trailing;
      TextColor := $FF27408B;

      Font.Size := 18;
      Width := Trunc((Application.MainForm.Width - 10) / 3);
      Height := 20;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 1;
    end;

    txt := TListItemText(Objects.FindDrawable('Text11'));
    with txt do
    begin
      if AInserindo and (DM.mtItens.FieldByName('codigo_barra').AsString <>
        '0000000000000') then
        Text := DM.mtItens.FieldByName('codigo_barra').AsString;
      Align := TListItemAlign.Trailing;
      TextAlign := TTextAlign.Trailing;
      TextVertAlign := TTextAlign.Trailing;
      TextColor := $FF27408B;

      Font.Size := 18;
      Width := Trunc((Application.MainForm.Width - 10) / 3);
      Height := 20;

      PlaceOffset.X := X - 5;
      PlaceOffset.Y := Y;
      Opacity := 1;
    end;

    txt := TListItemText(Objects.FindDrawable('Text12'));
    with txt do
    begin
      if AInserindo and (DM.mtItens.FieldByName('codigo_reduzido').AsInteger > 0)
      then
        Text := DM.mtItens.FieldByName('codigo_reduzido').AsString;
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

    Y := Trunc(txt.PlaceOffset.Y + txt.Height + 10);

    txt := TListItemText(Objects.FindDrawable('Text13'));
    with txt do
    begin
      Text := 'Descrição';
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Trailing;

      Font.Size := 10;
      Width := Trunc((Application.MainForm.Width - 10) / 3);
      Height := 10;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 0.7;
    end;

    Y := Trunc(txt.PlaceOffset.Y + txt.Height + 1);

    txt := TListItemText(Objects.FindDrawable('Text14'));
    with txt do
    begin
      if AInserindo then
        Text := DM.mtItens.FieldByName('descricao_produto').AsString;
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Leading;

      Font.Size := 18;
      Width := Trunc(Application.MainForm.Width - 10);
      Height := 50;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 1;
      WordWrap := True;
      Trimming := TTextTrimming.None;
    end;

    Y := Trunc(txt.PlaceOffset.Y + txt.Height + 10);

    txt := TListItemText(Objects.FindDrawable('Text15'));
    with txt do
    begin
      Text := 'Observação';
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Trailing;
      Font.Size := 10;
      Width := Trunc((Application.MainForm.Width - 10) / 3);
      Height := 10;
      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 0.7;
    end;

    Y := Trunc(txt.PlaceOffset.Y + txt.Height + 1);

    txt := TListItemText(Objects.FindDrawable('Text16'));
    with txt do
    begin
      if AInserindo and not(DM.mtItens.FieldByName('observacao_item')
        .AsString.IsEmpty) then
        Text := DM.mtItens.FieldByName('observacao_item').AsString;
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Trailing;

      Font.Size := 12;
      Width := Trunc(Application.MainForm.Width - 10);
      Height := 16;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 1;
      Trimming := TTextTrimming.None;
    end;

    Y := Trunc(txt.PlaceOffset.Y + txt.Height + 10);

    txt := TListItemText(Objects.FindDrawable('Text17'));
    with txt do
    begin
      Text := 'Funcionário';
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Trailing;
      Font.Size := 10;
      Width := Trunc((Application.MainForm.Width - 10) / 3);
      Height := 10;
      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 0.7;
    end;

    Y := Trunc(txt.PlaceOffset.Y + txt.Height + 1);

    txt := TListItemText(Objects.FindDrawable('Text18'));
    with txt do
    begin
      if AInserindo then
        Text := DM.mtItens.FieldByName('nome_funcionario').AsString;
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Trailing;

      Font.Size := 12;
      Width := Trunc(Application.MainForm.Width - 10);
      Height := 16;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 1;
      WordWrap := True;
      Trimming := TTextTrimming.None;
    end;

    Y := Trunc(txt.PlaceOffset.Y + txt.Height + 1);

    txt := TListItemText(Objects.FindDrawable('Text19'));
    with txt do
    begin
      if AInserindo then
        Text := DM.mtItens.FieldByName('data_hora').AsString;
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Trailing;
      TextColor := $FFFF3030;

      Font.Size := 12;
      Width := Trunc(Application.MainForm.Width - 10);
      Height := 16;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 0.7;
    end;

    txt := TListItemText(Objects.FindDrawable('Text21'));
    with txt do
    begin
      if AInserindo then
        Text := DM.mtItens.FieldByName('item_venda').AsString;
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Trailing;
      TextColor := $FFFF3030;

      Font.Size := 12;
      Width := Trunc(Application.MainForm.Width - 10);
      Height := 16;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 0.7;
      Visible := False;
    end;

    Y := Trunc(txt.PlaceOffset.Y + txt.Height + 10);

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
