unit List.Produto;

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

procedure atualizarItemListViewProduto(AItem: TListViewItem;
  AInserindo: boolean);

implementation

procedure atualizarItemListViewProduto(AItem: TListViewItem;
  AInserindo: boolean);
var
  txt: TListItemText;
  X: Integer;
  Y: Integer;

begin
  with AItem do
  begin
    X := 5;
    Y := 10;

    txt := TListItemText(Objects.FindDrawable('Text1'));
    with txt do
    begin
      Text := 'Produto';
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

    Y := Trunc(txt.PlaceOffset.Y + txt.Height + 1);

    txt := TListItemText(Objects.FindDrawable('Text2'));
    with txt do
    begin
      if AInserindo then
        Text := DM.mtProdutos.FieldByName('descricao_produto').AsString;
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

    Y := Trunc(txt.PlaceOffset.Y + txt.Height + 10);

    txt := TListItemText(Objects.FindDrawable('Text3'));
    with txt do
    begin
      Text := 'Codigo';
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

    txt := TListItemText(Objects.FindDrawable('Text4'));
    with txt do
    begin
      Text := 'Barra';
      Align := TListItemAlign.Trailing;
      TextAlign := TTextAlign.Trailing;
      TextVertAlign := TTextAlign.Trailing;

      Font.Size := 10;
      Width := Trunc((Application.MainForm.Width - 10) / 3);
      Height := 10;

      PlaceOffset.X := 0;
      PlaceOffset.Y := Y;
      Opacity := 0.7;
    end;

    txt := TListItemText(Objects.FindDrawable('Text5'));
    with txt do
    begin
      Text := 'Reduzido';
      Align := TListItemAlign.Center;
      TextAlign := TTextAlign.Center;
      TextVertAlign := TTextAlign.Trailing;

      Font.Size := 10;
      Width := Trunc((Application.MainForm.Width - 10) / 3);
      Height := 10;

      PlaceOffset.X := -5;
      PlaceOffset.Y := Y;
      Opacity := 0.7;
    end;

    Y := Trunc(txt.PlaceOffset.Y + txt.Height + 1);

    txt := TListItemText(Objects.FindDrawable('Text6'));
    with txt do
    begin
      if AInserindo then
        Text := DM.mtProdutos.FieldByName('codigo_produto').AsString;
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Leading;
      TextColor := $FF27408B;

      Font.Size := 18;
      Width := Trunc((Application.MainForm.Width - 10) / 3);
      Height := 20;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 1;
    end;

    txt := TListItemText(Objects.FindDrawable('Text7'));
    with txt do
    begin
      if AInserindo and (DM.mtProdutos.FieldByName('codigo_barra').AsString <>
        '0000000000000') then
        Text := DM.mtProdutos.FieldByName('codigo_barra').AsString;
      Align := TListItemAlign.Trailing;
      TextAlign := TTextAlign.Trailing;
      TextVertAlign := TTextAlign.Leading;
      TextColor := $FF27408B;

      Font.Size := 18;
      Width := Trunc((Application.MainForm.Width - 10) / 3);
      Height := 20;

      PlaceOffset.X := 0;
      PlaceOffset.Y := Y;
      Opacity := 1;
    end;

    txt := TListItemText(Objects.FindDrawable('Text8'));
    with txt do
    begin
      if AInserindo and (DM.mtProdutos.FieldByName('codigo_reduzido')
        .AsInteger > 0) then
        Text := DM.mtProdutos.FieldByName('codigo_reduzido').AsString;
      Align := TListItemAlign.Center;
      TextAlign := TTextAlign.Center;
      TextVertAlign := TTextAlign.Leading;
      TextColor := $FF27408B;

      Font.Size := 18;
      Width := Trunc((Application.MainForm.Width - 10) / 3);
      Height := 20;

      PlaceOffset.X := -5;
      PlaceOffset.Y := Y;
      Opacity := 1;
    end;

    Y := Trunc(txt.PlaceOffset.Y + txt.Height + 10);

    txt := TListItemText(Objects.FindDrawable('Text9'));
    with txt do
    begin
      Text := 'Preço';
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

    txt := TListItemText(Objects.FindDrawable('Text12'));
    with txt do
    begin
      Text := 'Unidade';
      Align := TListItemAlign.Trailing;
      TextAlign := TTextAlign.Trailing;
      TextVertAlign := TTextAlign.Trailing;

      Font.Size := 10;
      Width := Trunc((Application.MainForm.Width - 10) / 3);
      Height := 10;

      PlaceOffset.X := 0;
      PlaceOffset.Y := Y;
      Opacity := 0.7;
    end;

    Y := Trunc(txt.PlaceOffset.Y + txt.Height + 1);

    txt := TListItemText(Objects.FindDrawable('Text10'));
    with txt do
    begin
      if AInserindo then
        Text := formataFloatStr2
          (DM.mtProdutos.FieldByName('valor_unitario').AsFloat);
      Align := TListItemAlign.Leading;
      TextAlign := TTextAlign.Leading;
      TextVertAlign := TTextAlign.Leading;
      TextColor := $FFFF3030;

      Font.Size := 18;
      Width := Trunc((Application.MainForm.Width - 10) / 3);
      Height := 20;

      PlaceOffset.X := X;
      PlaceOffset.Y := Y;
      Opacity := 0.7;
    end;

    txt := TListItemText(Objects.FindDrawable('Text11'));
    with txt do
    begin
      if AInserindo then
        Text := DM.mtProdutos.FieldByName('unidade_produto').AsString;;
      Align := TListItemAlign.Trailing;
      TextAlign := TTextAlign.Trailing;
      TextVertAlign := TTextAlign.Leading;
      TextColor := $FF27408B;

      Font.Size := 18;
      Width := Trunc((Application.MainForm.Width - 10) / 3);
      Height := 20;

      PlaceOffset.X := 0;
      PlaceOffset.Y := Y;
      Opacity := 1;
    end;

    Y := Trunc(txt.PlaceOffset.Y + txt.Height + 10);
    Height := Y;
  end;
end;

end.
