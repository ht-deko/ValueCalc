{*******************************************************}
{                                                       }
{          Float 型用プロパティエディタユニット         }
{                                                       }
{*******************************************************}
unit uFloatCalcPropEditor;

{$I 'ValueCalc.inc'}

interface

uses
  Windows, Messages, SysUtils, Classes, TypInfo,
  {$IFDEF HASFMX}
  Rtti,
  {$ENDIF}
  {$IFDEF USEMULTIEXP}
  uPropEditorHelper,
  {$ENDIF}
  DesignIntf, DesignEditors;

type
  TFloatCalcPropEditor = class(TFloatProperty)
  public
    {$IFNDEF HASFMX}
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
    {$ENDIF}
    function GetAttributes: TPropertyAttributes; override;
  end;

implementation

uses
  uFloatCalc;

const
  Precisions: array[TFloatType] of Integer = (7, 15, 18, 18, 18);

{ TFloatCalcPropEditor }

function TFloatCalcPropEditor.GetAttributes: TPropertyAttributes;
begin
  result := [paMultiSelect];
end;

{$IFNDEF HASFMX}
function TFloatCalcPropEditor.GetValue: string;
begin
  result := FloatToStrF(GetFloatValue, ffGeneral, Precisions[GetTypeData(GetPropType)^.FloatType], 0);
end;

procedure TFloatCalcPropEditor.SetValue(const Value: string);
{$IFDEF USEMULTIEXP}
var
  i: Integer;
{$ENDIF}
begin
  with TFloatCalc.Create do
    try
      {$IFDEF USEMULTIEXP}
      for i:=0 to PropCount-1 do
        begin
          Component   := GetComponent(i) as TPersistent;
          SelectOrder := i;
          with PropList^[i] do
            SetFloatProp(Instance, PropInfo, Execute(Value));
        end;
      Modified;
      {$ELSE}
      Component   := GetComponent(0) as TPersistent;
      SelectOrder := 0;
      SetFloatValue(Execute(Value));
      {$ENDIF}
    finally
      Free;
    end;
end;
{$ENDIF}

{$IFDEF HASFMX}
// MEMO: Haven't been implemented as a method of the class.
procedure TFloatCalcPropEditor_SetValue(Self: TFloatCalcPropEditor; const Value: string);
{$IFDEF USEMULTIEXP}
var
  i: Integer;
{$ENDIF}
begin
  with TFloatCalc.Create do
    try
      {$IFDEF USEMULTIEXP}
      for i:=0 to Self.PropCount-1 do
        begin
          Component   := Self.GetComponent(i) as TPersistent;
          SelectOrder := i;
          with Self.PropList^[i] do
            SetFloatProp(Instance, PropInfo, Execute(Value));
        end;
      Self.Modified;
      {$ELSE}
      Component   := Self.GetComponent(0) as TPersistent;
      SelectOrder := 0;
      Self.SetFloatValue(Execute(Value));
      {$ENDIF}
    finally
      Free;
    end;
end;

type
  PVtable = ^TVtable;
  TVtable = array[0..MaxInt div SizeOf(Pointer) - 1] of Pointer;

var
  OrgSetValue: Pointer;

// MEMO: Replace the method in the VMT and specified method.
procedure ReplaceMethod(AType: TRttiType; const AMethodName: string;
  ANewMethodAddr: Pointer; out AOldMethodAddr: Pointer);
var
  meth: TRttiMethod;
  p: PPointer;
  oldProtect: Cardinal;
begin
  if ANewMethodAddr = nil then
    Exit;
  meth := AType.GetMethod(AMethodName);
  p := @PVtable(TRttiInstanceType(AType).MetaclassType)^[meth.VirtualIndex];
  AOldMethodAddr := p^;
  VirtualProtect(p, 4, PAGE_READWRITE, oldProtect);
  p^ := ANewMethodAddr;
  VirtualProtect(p, 4, oldProtect, oldProtect);
  FlushInstructionCache(GetCurrentProcess, p, 4);
end;

procedure HookFloatProp;
var
  ctx: TRttiContext;
  typ: TRttiType;
begin
  typ := ctx.FindType('FmxAnimationEditors.TFmxFloatProperty');
  if typ = nil then
    Exit;
  ReplaceMethod(typ, 'SetValue', @TFloatCalcPropEditor_SetValue, OrgSetValue);
end;

procedure UnhookFloatProp;
var
  ctx: TRttiContext;
  typ: TRttiType;
begin
  typ := ctx.FindType('FmxAnimationEditors.TFmxFloatProperty');
  if typ = nil then
    Exit;
  ReplaceMethod(typ, 'SetValue', OrgSetValue, OrgSetValue);
end;

initialization
  HookFloatProp;
finalization
  UnhookFloatProp;
{$ENDIF}
end.
