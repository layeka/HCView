{*******************************************************}
{                                                       }
{               HCView V1.0  作者：荆通                 }
{                                                       }
{      本代码遵循BSD协议，你可以加入QQ群 649023932      }
{            来获取更多的技术交流 2018-5-4              }
{                                                       }
{            表格单元格内各类对象管理单元               }
{                                                       }
{*******************************************************}

unit HCTableCellData;

interface

uses
  Windows, HCRichData, HCCustomData, HCCommon;

type
  THCTableCellData = class(THCRichData)
  private
    FActive: Boolean;
  protected
    function GetHeight: Cardinal; override;
    procedure _FormatReadyParam(const AStartItemNo: Integer;
      var APrioDrawItemNo: Integer; var APos: TPoint); override;
    procedure SetActive(const Value: Boolean);
  public
    //constructor Create; override;
    /// <summary> 清除并返回为处理分页比净高增加的高度(为重新格式化时后面计算偏移用) </summary>
    function ClearFormatExtraHeight: Integer;
    // 用于表格切换编辑的单元格
    property Active: Boolean read FActive write SetActive;
  end;

implementation

uses
  HCRectItem, HCStyle; // debug用

{ THCTableCellData }

function THCTableCellData.ClearFormatExtraHeight: Integer;
var
  i, vFmtOffset, vFormatIncHight: Integer;
begin
  Result := 0;
  vFmtOffset := 0;
  for i := 1 to DrawItems.Count - 1 do
  begin
    if DrawItems[i].LineFirst then
    begin
      if DrawItems[i].Rect.Top <> DrawItems[i - 1].Rect.Bottom then
      begin
        vFmtOffset := DrawItems[i].Rect.Top - DrawItems[i - 1].Rect.Bottom;
        if vFmtOffset > Result then
          Result :=  vFmtOffset;
      end;
    end;

    OffsetRect(DrawItems[i].Rect, 0, -vFmtOffset);

    if Items[DrawItems[i].ItemNo].StyleNo < THCStyle.RsNull then  // RectItem如表格，在格式化时有行和行中间的偏移，新格式化时要恢复，由分页函数再处理新格式化后的偏移
    begin
      vFormatIncHight := (Items[DrawItems[i].ItemNo] as THCCustomRectItem).ClearFormatExtraHeight;
      DrawItems[i].Rect.Bottom := DrawItems[i].Rect.Bottom - vFormatIncHight;
    end;
  end;
end;

function THCTableCellData.GetHeight: Cardinal;
begin
  Result := inherited GetHeight;
  if DrawItems.Count > 0 then
    Result := Result + DrawItems[0].Rect.Top;
end;

procedure THCTableCellData.SetActive(const Value: Boolean);
begin
  if FActive <> Value then
    FActive := Value;

  if not FActive then
  begin
    if Self.MouseDownItemNo >= 0 then
      Self.Items[Self.MouseDownItemNo].Active := False;
    Self.DisSelect;
    Self.Initialize;
    Style.UpdateInfoRePaint;
  end;
end;

procedure THCTableCellData._FormatReadyParam(const AStartItemNo: Integer;
  var APrioDrawItemNo: Integer; var APos: TPoint);
begin
  { 和父类不同，表格因为涉及跨页时有些DrawItem增加了偏移，所以重新格式化时
    起始DrawItem正好是上次跨页有偏移的，会影响本次的位置计算，所以表格格式化时
    全部从0开始，如果将来此函数不需要此处处理，则将父类中的此函数取消虚方法 }
  {APrioDrawItemNo := -1;
  APos.X := 0;
  APos.Y := 0;
  DrawItems.Clear; }
  inherited _FormatReadyParam(AStartItemNo, APrioDrawItemNo, APos);
end;

end.
