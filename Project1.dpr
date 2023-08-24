library Project1;

{ Wichtiger Hinweis zur DLL-Speicherverwaltung: ShareMem muss die erste
  Unit in der USES-Klausel Ihrer Bibliothek UND in der USES-Klausel Ihres Projekts
  sein (wählen Sie "Projekt, Quelltext anzeigen"), wenn Ihre DLL Prozeduren oder Funktionen
  exportiert, die Strings als Parameter oder Funktionsergebnisse übergeben. Dies
  gilt für alle Strings, die an oder von Ihrer DLL übergeben werden, auch für solche,
  die in Records und Klassen verschachtelt sind. ShareMem ist die Interface-Unit für
  den gemeinsamen BORLNDMM.DLL-Speichermanager, der zusammen mit Ihrer DLL
  weitergegeben werden muss. Übergeben Sie String-Informationen mit PChar- oder ShortString-
  Parametern, um die Verwendung von BORLNDMM.DLL zu vermeiden.

  Wichtiger Hinweis zur Verwendung der VCL: Wenn diese DLL implizit geladen wird
  und die in einem Unit-Initialisierungsabschnitt erstellte TWicImage/TImageCollection-Komponente
  verwendet, dann muss Vcl.WicImageInit in die USES-Klausel
  der Bibliothek aufgenommen werden. }

uses
  Winapi.Windows,
  Vcl.Clipbrd,
  System.SysUtils,
  System.Classes,
  database in 'src\database.pas',
  databases in 'src\databases.pas';

{$R *.res}

type
  CBool = (cFalse = 0, cTrue = 1);

const
  DLL_PROCESS_DETACH = 0;

var
  RealDllProc: TDLLProc;
  Databases: TDatabases;
  LastMessage: array[0..255] of Char;

function StrResult(const S: String): Pointer;
var
  i: 0..255;
begin
  Result := @LastMessage;
  for i := 0 to 254 do
    if i < Length(S) then
      LastMessage[i] := S[i+1]
    else
      LastMessage[i] := #0;
end;

procedure Initialize;
begin
  OutputDebugString(PChar('Initialize, res: ' + IntToHex(Int64(@StrResult))));
  Databases := TDatabases.Create;
end;

procedure Finalize();
begin
  OutputDebugString(PChar('Finalize'));
  Databases.Free;
end;

procedure FakeDllProc(Reason: Integer); stdcall;
begin
  if Reason = DLL_PROCESS_DETACH then Finalize;
  RealDllProc(Reason);
end;

// Exported functions

function AddDatabase: Pointer; stdcall;
begin
  Result := StrResult(Databases.CreateDatabase(TDbMode.local));
end;

function AddRemoteDatabase: Pointer; stdcall;
begin
  Result := StrResult(Databases.CreateDatabase(TDbMode.remote));
end;

function SetUsername(DatabaseId: Pointer; Username: Pointer): CBool; stdcall;
var
  Database: TDatabase;
begin
  if Databases.GetDatabaseById(WideCharToString(DatabaseId), Database) then
  begin
    Database.Username := WideCharToString(Username);
    exit(cTrue);
  end;
  exit(cFalse);
end;

function SetPassword(DatabaseId: Pointer; Password: Pointer): CBool; stdcall;
var
  Database: TDatabase;
begin
  
  if Databases.GetDatabaseById(WideCharToString(DatabaseId), Database) then
  begin
    Database.Password := WideCharToString(Password);
    exit(cTrue);
  end;
  exit(cFalse);
end;

function SetHost(DatabaseId: Pointer; Host: Pointer): CBool; stdcall;
var
  Database: TDatabase;
begin
  Clipboard.AsText := IntToHex(Int64(Host));
  OutputDebugString(PChar('SetHost, res: ' + WideCharToString(Host)));
  while true do;
  if Databases.GetDatabaseById(WideCharToString(DatabaseId), Database) then
  begin
    Database.RemoteHost := WideCharToString(Host);
    exit(cTrue);
  end;
  exit(cFalse);
end;

function Connect(DatabaseId: Pointer): CBool; stdcall;
var
  Database: TDatabase;
begin
  if Databases.GetDatabaseById(WideCharToString(DatabaseId), Database) then
  begin
    if Database.Connect() then exit(cTrue);
  end;
  exit(cFalse);
end;

function CloseDatabase(DatabaseId: Pointer): CBool; stdcall;
begin
  if Databases.CloseDatabase(WideCharToString(DatabaseId)) then
    exit(cTrue);
  exit(cFalse);
end;

exports
  AddDatabase,
  AddRemoteDatabase,
  SetUsername,
  SetPassword,
  SetHost,
  Connect,
  CloseDatabase;

begin
  Initialize;

  // Replace the DLLProc with our own
  RealDllProc := DllProc;
  DllProc := @FakeDllProc;
end.
