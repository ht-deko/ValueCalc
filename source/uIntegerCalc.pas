{*******************************************************}
{                                                       }
{               Integer Œ^—p ‰‰ŽZƒ†ƒjƒbƒg               }
{                                                       }
{*******************************************************}
unit uIntegerCalc;

{$I 'ValueCalc.inc'}

interface

uses
  {$IFDEF HASRTTI}
  Rtti, TypInfo,
  {$ENDIF}
  Classes, SysUtils, StrUtils, Math, DesignEditors, uCalcParser;

type
  TIntegerCalc = class(TObject)
  private
    FParser: TCalcParser;
    FSelectOrder: Integer;
    FComponent: TPersistent;
    procedure Check(S: string);
    function IsMatch(S: string): Boolean;
    function ProcessExpression: Integer;
    function ProcessFactor: Integer;
    function ProcessFunction: Integer;
    function ProcessNumeric: Integer;
    function ProcessRelation: Integer;
    function ProcessTerm: Integer;
    function ExecuteFloatRelation: Extended;
  public
    function Execute(const S: string): Integer; overload;
    function Execute(aParser: TCalcParser): Integer; overload;
    property Component: TPersistent read FComponent write FComponent;
    property SelectOrder: Integer read FSelectOrder write FSelectOrder;
  end;

implementation

uses
  uCalcConsts,
  uFloatCalc,
  uInt64Calc;

const
  FUNCTION_MAX = 6;
  FUNCTIONS: array [0..FUNCTION_MAX - 1] of string =
    ('ABS', 'CEIL', 'FLOOR', 'ROUND', 'SELECTORDER', 'TRUNC');

  FUNC_UNKNOWN     = -1;
  FUNC_ABS         =  0;
  FUNC_CEIL        =  1;
  FUNC_FLOOR       =  2;
  FUNC_ROUND       =  3;
  FUNC_SELECTORDER =  4;
  FUNC_TRUNC       =  5;

procedure TIntegerCalc.Check(S: string);
begin
  if not IsMatch(S) then
    raise EDsgnPropError.Create(errRightBracket)
end;

function TIntegerCalc.IsMatch(S: string): Boolean;
begin
  result := (AnsiCompareText(FParser.TokenString, s) = 0);
  if result then
    FParser.NextToken;
end;

function TIntegerCalc.ProcessExpression: Integer;
var
  Value: Integer;
begin
  Value := ProcessTerm;
  while True do
    begin
      if      IsMatch('+'  ) then
        Value := Value + ProcessTerm
      else if IsMatch('-'  ) then
        Value := Value - ProcessTerm
      else if IsMatch('or' ) or IsMatch('|') then
        Value := Value or ProcessTerm
      else if IsMatch('xor') or IsMatch('^') then
        Value := Value xor ProcessTerm
      else if IsMatch('||') then
        Value := Integer((Value or ProcessTerm) <> 0)
      else
        Break;
    end;
  result := Value;
end;

function TIntegerCalc.ProcessFactor: Integer;
var
  Value: Integer;
begin
  if IsMatch('(') then
    begin
      Value := ProcessRelation;
      Check(')');
    end
  else
    begin
      if IsMatch(')') then
        raise EDsgnPropError.Create(Format(errSyntax, [FParser.TokenString]))
      else if IsMatch('+') then
        Value := ProcessTerm
      else if IsMatch('-') then
        Value := - ProcessTerm
      else
        Value := ProcessNumeric;
    end;
  result := Value;
end;

function TIntegerCalc.ProcessFunction: Integer;
var
  FuncName: string;
  Value: Integer;
  Index: Integer;
begin
  Value := 0;
  FuncName := FParser.TokenString;
  Index := AnsiIndexText(FuncName, Functions);
  if Index = -1 then
    raise EDsgnPropError.Create(Format(errSyntax, [FParser.TokenString]))
  else
    begin
      FParser.NextToken;
      case Index of
        FUNC_UNKNOWN:
          raise EDsgnPropError.Create(Format(errSyntax, [FParser.TokenString]));
        FUNC_SELECTORDER:
          begin
            Value := FSelectOrder;
            if IsMatch('(') then
              Check(')');
          end;
      else
        if IsMatch('(') then
          begin
            try
              case Index of
                FUNC_ABS:
                  Value := Abs(ProcessRelation);
                FUNC_CEIL:
                  Value := Ceil(ExecuteFloatRelation);
                FUNC_FLOOR:
                  Value := Floor(ExecuteFloatRelation);
                FUNC_ROUND:
                  Value := Round(ExecuteFloatRelation);
                FUNC_TRUNC:
                  Value := Trunc(ExecuteFloatRelation);
              end;
            except
              on E: Exception do
                raise EDsgnPropError.Create(E.Message)
            end;
            Check(')');
          end
        else
          raise EDsgnPropError.Create(Format(errArgumentMissing, [FParser.TokenString]))
      end;
    end;
  result := Value;
end;

function TIntegerCalc.ProcessNumeric: Integer;
var
  Dmy: string;
  Value: Integer;
 {$IFDEF HASRTTI}
  PropName: string;
  function GetIntegerPropValue(aInstance: TObject; const aName: string; var aValue: Integer): Boolean;
    function _GetIntegerPropValue(aInstance: TObject; const aName: string; var aValue: Integer): Boolean;
    var
      Idx: Integer;
      dInstance: TObject;
      PropName, dName: string;
      Ctx: TRTTIConText;
      RProp: TRttiProperty;
      RType: TRttiType;
    begin
      result := False;
      Ctx := TRttiContext.Create;
      try
        Idx := Pos(String('.'), aName);
        if Idx > 0 then
          begin
            PropName := Copy(aName, 1, Idx-1);
            RType := Ctx.GetType(aInstance.ClassInfo);
            if not Assigned(RType) then
              Exit;
            RProp := RType.GetProperty(PropName);
            if not Assigned(RProp) then
              Exit;
            case RProp.PropertyType.TypeKind of
              tkClass:
                begin
                  dInstance := RProp.GetValue(aInstance).AsObject;
                  if Assigned(dInstance) then
                    begin
                      dName := Copy(aName, Idx+1, Length(aName));
                      result := _GetIntegerPropValue(dInstance, dName, aValue);
                    end;
                end;
            end;
          end
        else
          begin
            RType := Ctx.GetType(aInstance.ClassInfo);
            if not Assigned(RType) then
              Exit;
            RProp := RType.GetProperty(aName);
            if not Assigned(RProp) then
              Exit;
            case RProp.PropertyType.TypeKind of
              tkInteger,
              tkInt64:
                begin
                  result := True;
                  aValue := RProp.GetValue(aInstance).AsInteger;
                end;
            end;
          end;
      finally
        Ctx.Free;
      end;
    end;
  begin
    result := _GetIntegerPropValue(aInstance, aName, aValue);
  end;
  {$ENDIF}
begin
  Dmy := FParser.TokenString;
  case FParser.Token of
    ctoFloat:
      begin
        raise EDsgnPropError.Create(Format(errInvalidValue, [FParser.TokenString]))
      end;
    ctoInteger:
      begin
        Value := StrToIntDef(FParser.TokenString, 0);
        FParser.NextToken;
      end;
    ctoANK:
      begin
        {$IFDEF HASRTTI}
        FParser.BackupPtr;
        PropName := '';
        while (FParser.Token = ctoANK) or (FParser.TokenString = '.') do
          begin
            PropName := PropName + FParser.TokenString;
            FParser.NextToken;
          end;
        if not GetIntegerPropValue(FComponent, PropName, Value) then
          begin
            FParser.RestorePtr;
            Value := ProcessFunction;
          end;
        {$ELSE}
        Value := ProcessFunction;
        {$ENDIF}
      end
  else
    raise EDsgnPropError.Create(Format(errSyntax, [FParser.TokenString]))
  end;
  result := Value;
end;

function TIntegerCalc.ProcessRelation: Integer;
var
  Value: Integer;
begin
  Value := ProcessExpression;
  while True do
    begin
      if      IsMatch('=' ) or IsMatch('==') then
        Value := Integer(Value =  ProcessExpression)
      else if IsMatch('<>') or IsMatch('!=') then
        Value := Integer(Value <> ProcessExpression)
      else if IsMatch('<' ) then
        Value := Integer(Value <  ProcessExpression)
      else if IsMatch('<=') then
        Value := Integer(Value <= ProcessExpression)
      else if IsMatch('>' ) then
        Value := Integer(Value >  ProcessExpression)
      else if IsMatch('>=') then
        Value := Integer(Value >= ProcessExpression)
      else
        Break;
    end;
  result := Value;
end;

function TIntegerCalc.ProcessTerm: Integer;
var
  Value, dValue: Integer;
  Dmy: String;
begin
  Dmy := FParser.TokenString;
  if IsMatch('not') or IsMatch('~') then
    Value := not ProcessFactor
  else if IsMatch('!') then
    Value := Integer(ProcessFactor = 0)
  else
    Value := ProcessFactor;
  while True do
    begin
      if      IsMatch('*')   then
        Value := Value * ProcessFactor
      else if IsMatch('div') or IsMatch('/' ) then
        begin
          dValue := ProcessFactor;
          if dValue = 0 then
            raise EDsgnPropError.Create(Format(errDivisionByZero, [Dmy]))
          else
            Value := Value div dValue
        end
      else if IsMatch('mod') or IsMatch('%' ) then
        Value := Value mod ProcessFactor
      else if IsMatch('and') or IsMatch('&' ) then
        Value := Value and ProcessFactor
      else if IsMatch('shl') or IsMatch('<<') then
        Value := Value shl ProcessFactor
      else if IsMatch('shr') or IsMatch('>>') then
        Value := Value shr ProcessFactor
      else if IsMatch('&&' ) then
        Value := Integer((Value and ProcessFactor) <> 0)
      else if IsMatch('^') then
        raise EDsgnPropError.Create(Format(errInvalidOperator, [Dmy]))
      else
        Break;
    end;
  result := Value;
end;

function TIntegerCalc.Execute(const S: string): Integer;
begin
  FParser := TCalcParser.Create(S);
  try
    result := ProcessRelation;
  finally
    FParser.Free;
  end;
end;

function TIntegerCalc.Execute(aParser: TCalcParser): Integer;
var
  OrgParser: TCalcParser;
begin
  OrgParser := FParser;
  try
    FParser := aParser;
    result := ProcessRelation;
  finally
    FParser := OrgParser;
  end;
end;

function TIntegerCalc.ExecuteFloatRelation: Extended;
begin
  with TFloatCalc.Create do
    try
      Component   := FComponent;
      SelectOrder := FSelectOrder;
      result := Execute(FParser);
    finally
      Free;
    end;
end;
end.

