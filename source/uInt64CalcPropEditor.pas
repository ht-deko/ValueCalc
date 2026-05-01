{*******************************************************}
{                                                       }
{          Int64 型用プロパティエディタユニット         }
{                                                       }
{*******************************************************}
unit uInt64CalcPropEditor;

{$I 'ValueCalc.inc'}

interface

uses
  Windows, Messages, SysUtils, Classes,
  {$IFDEF USEMULTIEXP}
  TypInfo, uPropEditorHelper,
  {$ENDIF}
  DesignIntf, DesignEditors;

type
  TInt64CalcPropEditor = class(TInt64Property)
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
  uInt64Calc;
  {$ENDIF}

{ TInt64CalcPropEditor }

function TInt64CalcPropEditor.GetAttributes: TPropertyAttributes;
begin
  result := [paMultiSelect];
end;

function TInt64CalcPropEditor.GetValue: string;
begin
  result := IntToStr(GetInt64Value);
end;

procedure TInt64CalcPropEditor.SetValue(const Value: string);
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
            SetInt64Prop(Instance, PropInfo, Trunc(Execute(Value)));
        end;
      Modified;
      {$ELSE}
      Component   := GetComponent(0) as TPersistent;
      SelectOrder := 0;
      SetInt64Value(Trunc(Execute(Value)));
      {$ENDIF}
    finally
      Free;
    end;
  {$ELSE}
  with TInt64Calc.Create do
    try
      {$IFDEF USEMULTIEXP}
      for i:=0 to PropCount-1 do
        begin
          Component   := GetComponent(i) as TPersistent;
          SelectOrder := i;
          with PropList^[i] do
            SetInt64Prop(Instance, PropInfo, Execute(Value));
        end;
      Modified;
      {$ELSE}
      Component   := GetComponent(0) as TPersistent;
      SelectOrder := 0;
      SetInt64Value(Execute(Value));
      {$ENDIF}
    finally
      Free;
    end;
  {$ENDIF}
end;

end.
