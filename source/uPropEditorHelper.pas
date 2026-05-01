{*******************************************************}
{                                                       }
{     　  プロパティエディタクラスヘルパユニット        }
{                                                       }
{*******************************************************}
unit uPropEditorHelper;

{$I 'ValueCalc.inc'}

{$IFDEF IFENDNEEDFIX}
  {$LEGACYIFEND ON}
{$ENDIF}

interface

{$IFDEF USEMULTIEXP}
uses
  DesignEditors;

type
  TPropertyEditorHelper = class helper for TPropertyEditor
  private
    function GetPropList: PInstPropList; {$IF CompilerVersion < 31.0}inline;{$IFEND}
  public
    property PropList: PInstPropList read GetPropList;
  end;
{$ENDIF}

implementation

{$IFDEF USEMULTIEXP}
function TPropertyEditorHelper.GetPropList: PInstPropList;
begin
  with Self do
    Result := FPropList;
end;
{$ENDIF}

end.