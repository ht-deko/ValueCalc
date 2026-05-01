{*******************************************************}
{                                                       }
{         Integer 型用プロパティエディタユニット        }
{                                                       }
{*******************************************************}
unit uIntegerCalcPropEditor;

{$I 'ValueCalc.inc'}

interface

uses
  Windows, Messages, SysUtils, Classes,
  {$IFDEF USEMULTIEXP}
  TypInfo, uPropEditorHelper,
  {$ENDIF}
  DesignIntf, DesignEditors;

type
  TIntCalcPropEditor = class(TIntegerProperty)
  public
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
    function GetAttributes: TPropertyAttributes; override;
  end;

implementation

uses
  {$IFDEF USEFLOAT}
  uFloatCalc;
  {$ELSE}
  uIntegerCalc;
  {$ENDIF}

{ TIntCalcPropEditor }

function TIntCalcPropEditor.GetAttributes: TPropertyAttributes;
begin
  result := [paMultiSelect];
end;

function TIntCalcPropEditor.GetValue: string;
begin
  result := IntToStr(GetOrdValue);
end;

procedure TIntCalcPropEditor.SetValue(const Value: string);
{$IFDEF USEMULTIEXP}
var
  i: Integer;
{$ENDIF}
begin
  {$IFDEF USEFLOAT}
  with TFloatCalc.Create do
    try
      {$IFDEF USEMULTIEXP}
      for i:=0 to PropCount-1 do
        begin
          Component   := GetComponent(i) as TPersistent;
          SelectOrder := i;
          with PropList^[i] do
            SetOrdProp(Instance, PropInfo, Trunc(Execute(Value)));
        end;
      Modified;
      {$ELSE}
      {$IFDEF HASRTTI}
      Component   := GetComponent(0) as TPersistent;
      {$ENDIF}
      SelectOrder := 0;
      SetOrdValue(Trunc(Execute(Value)));
      {$ENDIF}
    finally
      Free;
    end;
  {$ELSE}
  with TIntegerCalc.Create do
    try
      {$IFDEF USEMULTIEXP}
      for i:=0 to PropCount-1 do
        begin
          Component   := GetComponent(i) as TPersistent;
          SelectOrder := i;
          with PropList^[i] do
            SetOrdProp(Instance, PropInfo, Execute(Value));
        end;
      Modified;
      {$ELSE}
      Component   := GetComponent(0) as TPersistent;
      SelectOrder := 0;
      SetOrdValue(Execute(Value));
      {$ENDIF}
    finally
      Free;
    end;
  {$ENDIF}
end;

end.
