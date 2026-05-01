{*******************************************************}
{                                                       }
{                   演算ユニット用定数                  }
{                                                       }
{*******************************************************}
unit uCalcConsts;

interface

uses
  {$IF CompilerVersion >= 21.0}
  DesignEditors;
  {$ELSE}
  TypInfo;
  {$IFEND}

const
  errRightBracket    = 'Missing right curly bracket';
  errSyntax          = 'Syntax error [%s]';
  errInvalidOperator = 'Invalid Operator [%s]';
  errInvalidValue    = 'Invalid Value [%s]';
  errArgumentMissing = 'Argument is missing';
  errDivisionByZero  = 'Division by zero';

type
  {$IF CompilerVersion >= 21.0}
  EDsgnPropError = EDesignPropertyError;
  {$ELSE}
  EDsgnPropError = EPropertyError;
  {$IFEND}

implementation

end.
