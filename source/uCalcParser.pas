{*******************************************************}
{                                                       }
{             演算用 Delphi / C++ 混合パーサー          }
{                                                       }
{*******************************************************}
unit uCalcParser;

interface

uses
  SysUtils;

type
  TCalcParser = class(TObject)
  private
    FBuffer: PChar;
    FSourcePtr, FOrgSourcePtr: PChar;
    FTokenPtr, FOrgTokenPtr: PChar;
    FToken: Char;
    FBufSize: Integer;
    function GetTokenString: string;
    function GetSourcePos: Integer;
    procedure SkipBlanks;
  public
    constructor Create(const S: String);
    destructor Destroy; override;
    function NextToken: Char;
    procedure BackupPtr;
    procedure RestorePtr;
    property SourcePos: Integer read GetSourcePos;
    property Token: Char read FToken;
    property TokenString: string read GetTokenString;
  end;

const
  ctoEOF        = Char(0);
  ctoSymbol     = Char(1);
  ctoString     = Char(2);
  ctoInteger    = Char(3);
  ctoFloat      = Char(4);
  ctoWString    = Char(5);
  ctoBracket    = Char(6);
  ctoComment    = Char(7);
  ctoAnk        = Char(8);
  ctoTab        = Char(9);
  ctoDBSymbol   = Char(11);
  ctoDBInt      = Char(12);
  ctoDBAlph     = Char(14);
  ctoDBHira     = Char(15);
  ctoDBKana     = Char(16);
  ctoDBKanji    = Char(17);
  ctoKanaSymbol = Char(18);
  ctoKana       = Char(19);
  ctoUrl        = Char(20);
  ctoMail       = Char(21);
  ctoOperator   = Char(100);

implementation


{$IFNDEF UNICODE}
function CharInSet(C: Char; const CharSet: TSysCharSet): Boolean;
begin
  result := (C in CharSet);
end;
{$ENDIF}

{ TCalcParser }

constructor TCalcParser.Create(const S: String);
begin
  FBufSize := Length(S) * SizeOf(PChar);
  FBuffer := AllocMem(FBufSize + SizeOf(PChar));
  if FBufSize > 0 then
    Move(S[1], FBuffer[0], FBufSize);
  FSourcePtr := FBuffer;
  FTokenPtr  := FBuffer;
  NextToken;
end;

destructor TCalcParser.Destroy;
begin
  FreeMem(FBuffer, FBufSize + SizeOf(PChar));
  inherited;
end;

function TCalcParser.GetSourcePos: Integer;
begin
  Result := FTokenPtr - FBuffer;
end;

function TCalcParser.GetTokenString: string;
begin
  SetString(Result, FTokenPtr, FSourcePtr - FTokenPtr);
end;

function TCalcParser.NextToken: Char;
var
  L, J: Integer;
  P, SavePtr: PChar;
  S: String;
begin
  SkipBlanks;
  P := FSourcePtr;
  FTokenPtr := P;
  Result := ctoEOF;

  // check eof
  {$IFDEF UNICODE}
  if CharInSet(P^, [#$0000]) then
  {$ELSE}
  if CharInSet(P^, [#$00]) then
  {$ENDIF}
    begin
      Result := ctoEOF;
      FSourcePtr := P;
      FToken := Result;
      Exit;
    end;

  // HexPrefix (Pascal)
  S := '$';
  L := Length(S);
  J := 1;
  SavePtr := P;
  while J <= L do
    if P^ = S[J] then
      if J = L then
        begin
          Inc(P);
          while CharInSet(P^, ['0'..'9', 'A'..'F', 'a'..'f']) do
            Inc(P);
          Result := ctoInteger;
          FSourcePtr := P;
          FToken := Result;
          Exit;
        end
      else
        begin
          Inc(P);
          Inc(J);
        end
    else
      begin
        P := SavePtr;
        Break;
      end;

  // HexPrefix (C++)
  if (P^ = '0') then
    begin
      Inc(P);
      case P^ of
        'x':
          begin
            Inc(P);
            while CharInSet(P^, ['0'..'9', 'A'..'F', 'a'..'f']) do
              Inc(P);
            Result := ctoInteger;
            FSourcePtr := P;
            FToken := Result;
            Exit;
          end;
      else
        Dec(P);
      end;
    end;

  // Operator
  if (P^ = '=') then
    begin
      Inc(P);
      { '==' (C++: Equal)}
      if (P^ = '=') then
        begin
          Inc(P);
          Result := ctoOperator;
          FSourcePtr := P;
          FToken := Result;
          Exit;
        end;
      Dec(P);
      Result := ctoOperator;
      FSourcePtr := P;
      FToken := Result;
      Exit;
    end;
  if (P^ = '<') then
    begin
      Inc(P);
      { '<=' (Less than)}
      if (P^ = '=') then
        begin
          Inc(P);
          Result := ctoOperator;
          FSourcePtr := P;
          FToken := Result;
          Exit;
        end
      { '<>' (Pascal: Not equal)}
      else if (P^ = '>') then
        begin
          Inc(P);
          Result := ctoOperator;
          FSourcePtr := P;
          FToken := Result;
          Exit;
        end
      { '<<' (C++: Shift left)}
      else if (P^ = '<') then
        begin
          Inc(P);
          Result := ctoOperator;
          FSourcePtr := P;
          FToken := Result;
          Exit;
        end;
      Dec(P);
    end;
  if (P^ = '>') then
    begin
      Inc(P);
      { '>=' (Greater than)}
      if (P^ = '=') then
        begin
          Inc(P);
          Result := ctoOperator;
          FSourcePtr := P;
          FToken := Result;
          Exit;
        end
      { '>>' (C++: Shift right)}
      else if (P^ = '>') then
        begin
          Inc(P);
          Result := ctoOperator;
          FSourcePtr := P;
          FToken := Result;
          Exit;
        end;
      Dec(P);
    end;
  if (P^ = '!') then
    begin
      Inc(P);
      { '!=' (C++: Not equal)}
      if (P^ = '=') then
        begin
          Inc(P);
          Result := ctoOperator;
          FSourcePtr := P;
          FToken := Result;
          Exit;
        end;
      Dec(P);
    end;
  if (P^ = '&') then
    begin
      Inc(P);
      { '&&' (C++: AND)}
      if (P^ = '&') then
        begin
          Inc(P);
          Result := ctoOperator;
          FSourcePtr := P;
          FToken := Result;
          Exit;
        end;
      Dec(P);
    end;
  if (P^ = '|') then
    begin
      Inc(P);
      { '||' (C++: OR)}
      if (P^ = '|') then
        begin
          Inc(P);
          Result := ctoOperator;
          FSourcePtr := P;
          FToken := Result;
          Exit;
        end;
      Dec(P);
    end;

  // normal token
  case P^ of
    {$IFDEF UNICODE}
    #$0001..#$001F:
    {$ELSE}
    #$01..#$1F:
    {$ENDIF}
      Inc(P);
    '0'..'9':
      begin
        Inc(P);
        while CharInSet(P^, ['0'..'9']) do
          Inc(P);
        Result := ctoInteger;
        case P^ of
          'e', 'E':
            begin
              Result := ctoFloat;
              Inc(P);
              case P^ of
                '+', '-':
                  begin
                    Inc(P);
                    while CharInSet(P^, ['0'..'9']) do
                      Inc(P);
                  end;
                '0'..'9':
                  begin
                    Inc(P);
                    while CharInSet(P^, ['0'..'9']) do
                      Inc(P);
                  end;
              end;
            end;
          '.':
            begin
              Result := ctoFloat;
              Inc(P);
              if not CharInSet(P^, ['0'..'9', 'e', 'E']) then
                Dec(P)
              else
                case P^ of
                  '0'..'9':
                    begin
                      Inc(P);
                      while CharInSet(P^, ['0'..'9']) do
                        Inc(P);
                      if CharInSet(P^, ['e', 'E']) then
                      begin
                        Inc(P);
                        case P^ of
                          '+', '-':
                            begin
                              Inc(P);
                              while CharInSet(P^, ['0'..'9']) do
                                Inc(P);
                            end;
                          '0'..'9':
                            begin
                              Inc(P);
                              while CharInSet(P^, ['0'..'9']) do
                                Inc(P);
                            end;
                        end;
                      end;
                    end;
                  'e', 'E':
                    begin
                      Inc(P);
                      case P^ of
                        '+', '-':
                          begin
                            Inc(P);
                            while CharInSet(P^, ['0'..'9']) do
                              Inc(P);
                          end;
                        '0'..'9':
                          begin
                            Inc(P);
                            while CharInSet(P^, ['0'..'9']) do
                              Inc(P);
                          end;
                      end;
                    end;
                end;
            end;
        end;
      end;
    'A'..'Z', '_', 'a'..'z':
      begin
        Inc(P);
        while CharInSet(P^, [ '0'..'9', 'A'..'Z', '_', 'a'..'z']) do
          Inc(P);
        Result := ctoAnk;
      end;
  else
    {$IFDEF UNICODE}
    if CharInSet(P^, [#$0000]) then
    {$ELSE}
    if CharInSet(P^, [#$00]) then
    {$ENDIF}
      Result := ctoEOF
    else
      begin
        Result := ctoSymbol;
        Inc(P);
      end;
  end;
  FSourcePtr := P;
  FToken := Result;
end;

procedure TCalcParser.BackupPtr;
begin
  FOrgSourcePtr := FSourcePtr;
  FOrgTokenPtr  := FTokenPtr;
end;

procedure TCalcParser.RestorePtr;
begin
  FSourcePtr := FOrgSourcePtr;
  FTokenPtr  := FOrgTokenPtr;
end;

procedure TCalcParser.SkipBlanks;
begin
  while True do
    begin
      case FSourcePtr^ of
        {$IFDEF UNICODE}
        #$0000, #$0021..#$FFFF:
        {$ELSE}
        #$00, #$21..#$FF:
        {$ENDIF}
          Exit;
      end;
      Inc(FSourcePtr);
    end;
end;

end.
