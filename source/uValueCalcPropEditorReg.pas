{*******************************************************}
{                                                       }
{       ValueCalc プロパティエディタ登録用ユニット      }
{                                                       }
{*******************************************************}
unit uValueCalcPropEditorReg;

{$I 'ValueCalc.inc'}

{$IFDEF IFENDNEEDFIX}
  {$LEGACYIFEND ON}
{$ENDIF}

interface

uses
  {$IFNDEF UNICODE}
  SysUtils, Classes,
  {$ENDIF}
  DesignIntf;

procedure Register; // <!> CAUTION <!> 'Register' procedure is case-sensitive.

implementation

uses
  uIntegerCalcPropEditor, // Integer Property Editor
  uInt64CalcPropEditor,   // Int64 Property Editor
  uFloatCalcPropEditor;   // Float Property Editor

procedure Register; // <!> CAUTION <!> 'Register' procedure is case-sensitive.
begin
  // Integer
  RegisterPropertyEditor(TypeInfo(ShortInt    ), nil       , '', TIntCalcPropEditor  ); // Signed 8-bit
  RegisterPropertyEditor(TypeInfo(SmallInt    ), nil       , '', TIntCalcPropEditor  ); // Signed 16-bit
  RegisterPropertyEditor(TypeInfo(LongInt     ), nil       , '', TIntCalcPropEditor  ); // Signed 32-bit
  RegisterPropertyEditor(TypeInfo(Integer     ), nil       , '', TIntCalcPropEditor  ); // Signed 32-bit
  {$IF Declared(NativeInt)}
  RegisterPropertyEditor(TypeInfo(NativeInt   ), nil       , '', TIntCalcPropEditor  ); // Signed 32 / 64-bit
  {$IFEND}
  RegisterPropertyEditor(TypeInfo(Byte        ), nil       , '', TIntCalcPropEditor  ); // Unsigned 8-bit
  RegisterPropertyEditor(TypeInfo(Word        ), nil       , '', TIntCalcPropEditor  ); // Unsigned 16-bit
  RegisterPropertyEditor(TypeInfo(LongWord    ), nil       , '', TIntCalcPropEditor  ); // Unsigned 32-bit
  RegisterPropertyEditor(TypeInfo(Cardinal    ), nil       , '', TIntCalcPropEditor  ); // Unsigned 32-bit
  {$IF Declared(NativeUInt)}
  RegisterPropertyEditor(TypeInfo(NativeUInt  ), nil       , '', TIntCalcPropEditor  ); // Unsigned 32 / 64-bit
  {$IFEND}

  // Int64
  RegisterPropertyEditor(TypeInfo(Int64       ), nil       , '', TInt64CalcPropEditor); // Signed 64-bit
  {$IF Declared(UInt64)}
  RegisterPropertyEditor(TypeInfo(UInt64      ), nil       , '', TInt64CalcPropEditor); // Unsigned 64-bit
  {$IFEND}

  // Float
  RegisterPropertyEditor(TypeInfo(Single      ), nil       , '', TFloatCalcPropEditor);
  RegisterPropertyEditor(TypeInfo(Double      ), nil       , '', TFloatCalcPropEditor);
  RegisterPropertyEditor(TypeInfo(Real        ), nil       , '', TFloatCalcPropEditor);
  RegisterPropertyEditor(TypeInfo(Extended    ), nil       , '', TFloatCalcPropEditor);
  RegisterPropertyEditor(TypeInfo(Comp        ), nil       , '', TFloatCalcPropEditor);
  RegisterPropertyEditor(TypeInfo(Currency    ), nil       , '', TFloatCalcPropEditor);
end;
end.
