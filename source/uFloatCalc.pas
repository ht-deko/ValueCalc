{*******************************************************}
{                                                       }
{                Float 型用 演算ユニット                }
{                                                       }
{*******************************************************}
unit uFloatCalc;

{$I 'ValueCalc.inc'}

interface

uses
  {$IFDEF HASRTTI}
  Rtti, TypInfo,
  {$ENDIF}
  Classes, SysUtils, StrUtils, Math, DesignEditors, uCalcParser;

type
  TFloatCalc = class(TObject)
  private
    FParser: TCalcParser;
    FSelectOrder: Integer;
    FComponent: TPersistent;
    procedure Check(S: string);
    function IsMatch(S: string): Boolean;
    function ProcessExpression: Extended;
    function ProcessFactor: Extended;
    function ProcessFunction: Extended;
    function ProcessNumeric: Extended;
    function ProcessRelation: Extended;
    function ProcessTerm: Extended;
    function ExecuteIntegerRelation: Integer;
  public
    function Execute(const S: string): Extended; overload;
    function Execute(aParser: TCalcParser): Extended; overload;
    property Component: TPersistent read FComponent write FComponent;
    property SelectOrder: Integer read FSelectOrder write FSelectOrder;
  end;

implementation

uses
  uCalcConsts,
  uIntegerCalc,
  uInt64Calc;

const
  FUNCTION_MAX = 47;
  FUNCTIONS: array [0..FUNCTION_MAX - 1] of string =
    ('ABS', 'ARCCOS', 'ARCCOSH', 'ARCCOT', 'ARCCOTH', 'ARCCSC', 'ARCCSCH',
     'ARCSEC', 'ARCSECH', 'ARCSIN', 'ARCSINH', 'ARCTAN', 'ARCTANH', 'COS',
     'COSH', 'COT', 'COTAN', 'COTH', 'CSC', 'CSCH', 'CYCLETODEG', 'CYCLETOGRAD',
     'CYCLETORAD', 'DEGTOCYCLE', 'DEGTOGRAD', 'DEGTORAD', 'GRADTOCYCLE',
     'GRADTODEG', 'GRADTORAD','EXP', 'FLOAT', 'INT', 'LN', 'LNXP1', 'LOG10',
     'LOG2', 'PI', 'SEC', 'SECANT', 'SECHH', 'SELECTORDER', 'SIN', 'SINH',
     'SQR', 'SQRT', 'TAN', 'TANH');

  FUNC_UNKNOWN     = -1;
  FUNC_ABS         =  0;
  FUNC_ARCCOS      =  1;
  FUNC_ARCCOSH     =  2;
  FUNC_ARCCOT      =  3;
  FUNC_ARCCOTH     =  4;
  FUNC_ARCCSC      =  5;
  FUNC_ARCCSCH     =  6;
  FUNC_ARCSEC      =  7;
  FUNC_ARCSECH     =  8;
  FUNC_ARCSIN      =  9;
  FUNC_ARCSINH     = 10;
  FUNC_ARCTAN      = 11;
  FUNC_ARCTANH     = 12;
  FUNC_COS         = 13;
  FUNC_COSH        = 14;
  FUNC_COT         = 15;
  FUNC_COTAN       = 16;
  FUNC_COTH        = 17;
  FUNC_CSC         = 18;
  FUNC_CSCH        = 19;
  FUNC_CYCLETODEG  = 20;
  FUNC_CYCLETOGRAD = 21;
  FUNC_CYCLETORAD  = 22;
  FUNC_DEGTOCYCLE  = 23;
  FUNC_DEGTOGRAD   = 24;
  FUNC_DEGTORAD    = 25;
  FUNC_GRADTOCYCLE = 26;
  FUNC_GRADTODEG   = 27;
  FUNC_GRADTORAD   = 28;
  FUNC_EXP         = 29;
  FUNC_FLOAT       = 30;
  FUNC_INT         = 31;
  FUNC_LN          = 32;
  FUNC_LNXP1       = 33;
  FUNC_LOG10       = 34;
  FUNC_LOG2        = 35;
  FUNC_PI          = 36;
  FUNC_SEC         = 37;
  FUNC_SECANT      = 38;
  FUNC_SECH        = 39;
  FUNC_SELECTORDER = 40;
  FUNC_SIN         = 41;
  FUNC_SINH        = 42;
  FUNC_SQR         = 43;
  FUNC_SQRT        = 44;
  FUNC_TAN         = 45;
  FUNC_TANH        = 46;

procedure TFloatCalc.Check(S: string);
begin
  if not IsMatch(S) then
    raise EDsgnPropError.Create(errRightBracket)
end;

function TFloatCalc.IsMatch(S: string): Boolean;
begin
  result := (AnsiCompareText(FParser.TokenString, s) = 0);
  if result then
    FParser.NextToken;
end;

function TFloatCalc.ProcessFactor: Extended;
var
  Value: Extended;
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

function TFloatCalc.ProcessFunction: Extended;
var
  FuncName: string;
  Value: Extended;
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
        FUNC_PI:
          begin
            Value := Pi;
            if IsMatch('(') then
              Check(')');
          end;
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
                FUNC_ARCCOS:
                  Value := ArcCos(ProcessRelation);
                FUNC_ARCCOSH:
                  Value := ArcCosh(ProcessRelation);
                FUNC_ARCCOT:
                  Value := ArcCot(ProcessRelation);
                FUNC_ARCCOTH:
                  Value := ArcCotH(ProcessRelation);
                FUNC_ARCCSC:
                  Value := ArcCsc(ProcessRelation);
                FUNC_ARCCSCH:
                  Value := ArcCscH(ProcessRelation);
                FUNC_ARCSEC:
                  Value := ArcSec(ProcessRelation);
                FUNC_ARCSECH:
                  Value := ArcSecH(ProcessRelation);
                FUNC_ARCSIN:
                  Value := ArcSin(ProcessRelation);
                FUNC_ARCSINH:
                  Value := ArcSinh(ProcessRelation);
                FUNC_ARCTAN:
                  Value := ArcTan(ProcessRelation);
                FUNC_ARCTANH:
                  Value := ArcTanh(ProcessRelation);
                FUNC_COS:
                  Value := Cos(ProcessRelation);
                FUNC_COSH:
                  Value := Cosh(ProcessRelation);
                FUNC_COT:
                  Value := Cot(ProcessRelation);
                FUNC_COTAN:
                  Value := Cotan(ProcessRelation);
                FUNC_COTH:
                  Value := CotH(ProcessRelation);
                FUNC_CSC:
                  Value := Csc(ProcessRelation);
                FUNC_CSCH:
                  Value := CscH(ProcessRelation);
                FUNC_CYCLETODEG:
                  Value := CycleToDeg(ProcessRelation);
                FUNC_CYCLETOGRAD:
                  Value := CycleToGrad(ProcessRelation);
                FUNC_CYCLETORAD:
                  Value := CycleToRad(ProcessRelation);
                FUNC_DEGTOCYCLE:
                  Value := DegToCycle(ProcessRelation);
                FUNC_DEGTOGRAD:
                  Value := DegToGrad(ProcessRelation);
                FUNC_DEGTORAD:
                  Value := DegToRad(ProcessRelation);
                FUNC_GRADTOCYCLE:
                  Value := GradToCycle(ProcessRelation);
                FUNC_GRADTODEG:
                  Value := GradToDeg(ProcessRelation);
                FUNC_GRADTORAD:
                  Value := GradToRad(ProcessRelation);
                FUNC_EXP:
                  Value := Exp(ProcessRelation);
                FUNC_FLOAT:
                  Value := ExecuteIntegerRelation;
                FUNC_INT:
                  Value := Int(ProcessRelation);
                FUNC_LN:
                  Value := Ln(ProcessRelation);
                FUNC_LNXP1:
                  Value := LnXP1(ProcessRelation);
                FUNC_LOG10:
                  Value := Log10(ProcessRelation);
                FUNC_LOG2:
                  Value := Log2(ProcessRelation);
                FUNC_SEC:
                  Value := Sec(ProcessRelation);
                FUNC_SECANT:
                  Value := Secant(ProcessRelation);
                FUNC_SECH:
                  Value := SecH(ProcessRelation);
                FUNC_SIN:
                  Value := Sin(ProcessRelation);
                FUNC_SINH:
                  Value := Sinh(ProcessRelation);
                FUNC_SQR:
                  Value := Sqr(ProcessRelation);
                FUNC_SQRT:
                  Value := Sqrt(ProcessRelation);
                FUNC_TAN:
                  Value := Tan(ProcessRelation);
                FUNC_TANH:
                  Value := Tanh(ProcessRelation);
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

function TFloatCalc.ProcessExpression: Extended;
var
  Value: Extended;
  Dmy: string;
begin
  Value := ProcessTerm;
  while True do
    begin
      Dmy := FParser.TokenString;
      if      IsMatch('+'  ) then
        Value := Value + ProcessTerm
      else if IsMatch('-'  ) then
        Value := Value - ProcessTerm
      {$IFDEF USESTRICTEXP}
      else if IsMatch('or' ) or IsMatch('|' ) or
              IsMatch('xor') or IsMatch('||')then
        raise EDsgnPropError.Create(Format(errInvalidOperator, [Dmy]))
      {$ELSE}
      else if IsMatch('or' ) or IsMatch('|') then
        Value := Trunc(Value) or  Trunc(ProcessTerm)
      else if IsMatch('xor') then
        Value := Trunc(Value) xor Trunc(ProcessTerm)
      else if IsMatch('||' ) then
        Value := Integer((Trunc(Value) or Trunc(ProcessTerm)) <> 0)
      {$ENDIF}
      else
        Break;
    end;
  result := Value;
end;

function TFloatCalc.ProcessNumeric: Extended;
var
  Dmy: string;
  Value: Extended;
 {$IFDEF HASRTTI}
  PropName: string;
  function GetFloatPropValue(aInstance: TObject; const aName: string; var aValue: Extended): Boolean;
    function _GetFloatPropValue(aInstance: TObject; const aName: string; var aValue: Extended): Boolean;
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
                      result := _GetFloatPropValue(dInstance, dName, aValue);
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
              tkInteger:
                begin
                  result := True;
                  aValue := RProp.GetValue(aInstance).AsInteger;
                end;
              tkInt64:
                begin
                  result := True;
                  aValue := RProp.GetValue(aInstance).AsInt64;
                end;
              tkFloat:
                begin
                  result := True;
                  aValue := RProp.GetValue(aInstance).AsExtended;
                end;
            end;
          end;
      finally
        Ctx.Free;
      end;
    end;
  begin
    result := _GetFloatPropValue(aInstance, aName, aValue);
  end;
  {$ENDIF}
begin
  Dmy := FParser.TokenString;
  case FParser.Token of
    ctoInteger:
      begin
        Value := StrToIntDef(FParser.TokenString, 0);
        FParser.NextToken;
      end;
    ctoFloat:
      begin
        Value := StrToFloatDef(FParser.TokenString, 0);
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
        if not GetFloatPropValue(FComponent, PropName, Value) then
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

function TFloatCalc.ProcessRelation: Extended;
var
  {$IFDEF USESTRICTEXP}
  Dmy: string;
  {$ENDIF}
  Value: Extended;
begin
  {$IFDEF USESTRICTEXP}
  Dmy := FParser.TokenString;
  {$ENDIF}
  Value := ProcessExpression;
  while True do
    begin
      if      IsMatch('=')  or IsMatch('==') then
        Value := Integer(Value =  ProcessExpression)
      else if IsMatch('<>') or IsMatch('!=') then
        Value := Integer(Value <> ProcessExpression)
      else if IsMatch('<')  then
        Value := Integer(Value <  ProcessExpression)
      else if IsMatch('<=') then
        Value := Integer(Value <= ProcessExpression)
      else if IsMatch('>')  then
        Value := Integer(Value >  ProcessExpression)
      else if IsMatch('>=') then
        Value := Integer(Value >= ProcessExpression)
      else
        Break;
    end;
  result := Value;
end;

function TFloatCalc.ProcessTerm: Extended;
var
  Dmy: string;
  Value, dValue: Extended;
begin
  Dmy := FParser.TokenString;
  if IsMatch('not') or IsMatch('~') then
    {$IFDEF USESTRICTEXP}
    raise EDsgnPropError.Create(Format(errSyntax, [Dmy]))
    {$ELSE}
    Value := not Trunc(ProcessFactor)
    {$ENDIF}
  else if IsMatch('!') then
    {$IFDEF USESTRICTEXP}
    raise EDsgnPropError.Create(Format(errSyntax, [Dmy]))
    {$ELSE}
    Value := Integer((Trunc(ProcessFactor)) = 0)
    {$ENDIF}
  else
    Value := ProcessFactor;
  while True do
    begin
      Dmy := FParser.TokenString;
      if      IsMatch('*') then
        Value := Value * ProcessFactor
      else if IsMatch('/') then
        begin
          dValue := ProcessFactor;
          if IsZero(dValue) then
            raise EDsgnPropError.Create(Format(errDivisionByZero, [Dmy]))
          else
            Value := Value / dValue;
        end
      else if IsMatch('^') then
        Value := Power(Value, ProcessFactor)
      {$IFDEF USESTRICTEXP}
      else if IsMatch('div') or
              IsMatch('mod') or IsMatch('%' ) or
              IsMatch('and') or IsMatch('&' ) or
              IsMatch('shl') or IsMatch('<<') or
              IsMatch('shr') or IsMatch('>>') or
                                IsMatch('&&') then
        raise EDsgnPropError.Create(Format(errInvalidOperator, [Dmy]))
      {$ELSE}
      else if IsMatch('div') then
        begin
          dValue := ProcessFactor;
          if Trunc(dValue) = 0 then
            raise EDsgnPropError.Create(Format(errDivisionByZero, [Dmy]))
          else
            Value := Trunc(Value) div Trunc(dValue);
        end
      else if IsMatch('mod') or IsMatch('%' ) then
        Value := Trunc(Value) mod Trunc(ProcessFactor)
      else if IsMatch('and') or IsMatch('&' ) then
        Value := Trunc(Value) and Trunc(ProcessFactor)
      else if IsMatch('shl') or IsMatch('<<') then
        Value := Trunc(Value) shl Trunc(ProcessFactor)
      else if IsMatch('shr') or IsMatch('>>') then
        Value := Trunc(Value) shr Trunc(ProcessFactor)
      else if                   IsMatch('&&') then
        Value := Integer((Trunc(Value) and Trunc(ProcessFactor)) <> 0)
      {$ENDIF}
      else
        Break;
    end;
  result := Value;
end;

function TFloatCalc.Execute(const S: string): Extended;
begin
  FParser := TCalcParser.Create(S);
  try
    result := ProcessRelation;
  finally
    FParser.Free;
  end;
end;

function TFloatCalc.Execute(aParser: TCalcParser): Extended;
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

function TFloatCalc.ExecuteIntegerRelation: Integer;
begin
  with TIntegerCalc.Create do
    try
      Component   := FComponent;
      SelectOrder := FSelectOrder;
      result := Execute(FParser);
    finally
      Free;
    end;
end;

end.

