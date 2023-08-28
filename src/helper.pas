unit helper;

interface

type
  CBool = (cFalse = 0, cTrue = 1);  // must be 8 Bit long

  PCStr16 = ^CStr16;
  CStr16 = record
    p: Pointer;
    len: Int64;
    function ToString: string;
    class function FromString(const s: string): PCStr16; static;
    class function Free(p: PCStr16): boolean; static;
  end;

implementation

uses
  System.SysUtils;

{ CStr16 }

class function CStr16.FromString(const s: string): PCStr16;
var
  rec: PCStr16;
  PStr: Pointer;
  i: integer;
begin
  GetMem(rec, SizeOf(CStr16));
  rec^.len := Length(s);
  GetMem(PStr, rec^.len * 2);
  rec^.p := PStr;
  for i := 1 to rec^.len do
  begin
    PWord(PStr)^ := Ord(s[i]);
    Inc(PWord(PStr));
  end;
  Result := rec;
end;

function CStr16.ToString: string;
begin
  SetString(Result, PChar(p), len);
end;

class function CStr16.Free(p: PCStr16): boolean;
begin
  if p <> nil then
  begin
    if p^.p <> nil then
      FreeMem(p^.p);
    FreeMem(p);
  end;
  Result := True;
end;

end.