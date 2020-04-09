unit SQLite3Utils;

interface

uses
  Windows, SysUtils;

function StrToUTF8(const S: WideString): AnsiString;
function UTF8ToStr(const S: PAnsiChar; const Len: Integer = -1): WideString;
function QuotedStr(const S: WideString): WideString;
function FloatToSQLStr(Value: Extended): WideString;

implementation

function StrToUTF8(const S: WideString): AnsiString;
begin
  Result := UTF8Encode(S);
end;

function UTF8ToStr(const S: PAnsiChar; const Len: Integer): WideString;
var
  UTF8Str: AnsiString;
begin
  if Len < 0 then
  begin
    Result := UTF8ToString(S);
  end
  else if Len > 0 then
  begin
    SetLength(UTF8Str, Len);
    Move(S^, UTF8Str[1], Len);
    Result := UTF8ToString(UTF8Str);
  end
  else
    Result := '';
end;

function QuotedStr(const S: WideString): WideString;
const
  Quote = #39;
var
  I: Integer;
begin
  Result := S;
  for I  := Length(Result) downto 1 do
    if Result[I] = Quote then
      Insert(Quote, Result, I);
  Result := Quote + Result + Quote;
end;

function FloatToSQLStr(Value: Extended): WideString;
begin
  FormatSettings.DecimalSeparator := '.';
  Result                          := FloatToStr(Value, FormatSettings);
end;

end.
