unit Util.MyEdit;
interface
uses
  FMX.Edit, FMX.Controls;

type
  TEdit = class(FMX.Edit.TEdit)
  protected
    procedure AdjustFixedSize(const Ref: TControl); override;
  end;

implementation
uses
  FMX.Types;

procedure TEdit.AdjustFixedSize(const Ref: TControl);
begin
  SetAdjustType(TAdjustType.None);
end;

end.
