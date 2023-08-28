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
  System.SysUtils,
  System.Classes,
  System.JSON,
  helper in 'src\helper.pas',
  database in 'src\database.pas',
  databases in 'src\databases.pas';

const
  DLL_PROCESS_DETACH = 0;

var
  RealDllProc: TDLLProc;
  Databases: TDatabases;

procedure Initialize;
begin
  Databases := TDatabases.Create;
end;

procedure Finalize();
begin
  if Assigned(Databases) then
    Databases.Free;
end;

procedure FakeDllProc(Reason: Integer); stdcall;
begin
  if Reason = DLL_PROCESS_DETACH then Finalize;
  RealDllProc(Reason);
end;

// Exported functions

function FreeString(S: PCStr16): CBool; stdcall;
begin
  CStr16.Free(S);
  Result := cTrue;
end;

function AddDatabase(aliasPath: PCStr16): PCStr16; stdcall;
var
  sId: string;
  database: TDatabase;
  json: TJsonObject;
begin
  json := TJsonObject.Create;
  json.AddPair('mode', 'local');
  json.AddPair('aliasPath', aliasPath^.ToString());
  // cretae database
  sId := Databases.CreateDatabase(TDbMode.local);
  json.AddPair('id', sId);
  if not Databases.GetDatabaseById(sId, database) then
  begin
    json.AddPair('error', 'this is a bug <3');
    json.AddPair('status', 'error');
  end
  else
  begin
    database.AliasPath := aliasPath^.ToString();

    try
      database.Connect();
      json.AddPair('status', 'connected');
    except
      on E: Exception do
      begin
        json.AddPair('error', E.Message);
        json.AddPair('status', 'error');
        Databases.CloseDatabase(sId);
      end;
    end;
  end;
  Result := CStr16.FromString(json.ToJSON);
  json.Free;
end;

function AddRemoteDatabase(host: PCStr16; aliasName: PCStr16; username: PCStr16; password: PCStr16): PCStr16; stdcall;
var
  sId: string;
  database: TDatabase;
  json: TJsonObject;
begin
  json := TJsonObject.Create;
  json.AddPair('mode', 'remote');
  json.AddPair('host', host^.ToString());
  json.AddPair('aliasName', aliasName^.ToString());
  json.AddPair('username', username^.ToString());
  // create database
  sId := Databases.CreateDatabase(TDbMode.remote);
  json.AddPair('id', sId);
  if not Databases.GetDatabaseById(sId, database) then
  begin
    json.AddPair('error', 'this is a bug <3');
    json.AddPair('status', 'error');
  end
  else
  begin
    database.AliasName := aliasName^.ToString();
    database.RemoteHost := host^.ToString();
    database.Username := username^.ToString();
    database.Password := password^.ToString();
    try
      database.Connect();
      json.AddPair('status', 'connected');
    except
      on E: Exception do
      begin
        json.AddPair('error', E.Message);
        json.AddPair('status', 'error');
        Databases.CloseDatabase(sId);
      end;
    end;
  end;
  Result := CStr16.FromString(json.ToJSON);
  json.Free;
end;

function CloseDatabase(DatabaseId: PCStr16): CBool; stdcall;
begin
  if Databases.CloseDatabase(DatabaseId^.ToString()) then
    exit(cTrue);
  exit(cFalse);
end;

function ExecuteSql(DatabaseId: PCStr16; sql: PCStr16; params: PCStr16 = nil): PCStr16; stdcall;
var
  database: TDatabase;
  json: TJsonObject;
  res: string;
begin
  json := TJsonObject.Create;

  if not Databases.GetDatabaseById(DatabaseId^.ToString(), database) then
  begin
    json.AddPair('error', 'Database not found');
    json.AddPair('status', 'error');
  end
  else
  begin
    try
      res := database.Execute(sql^.ToString(), params^.ToString());
      json.AddPair('result', TJsonValue.ParseJSONValue(res));
      json.AddPair('status', 'success');
    except
      on E: Exception do
      begin
        json.AddPair('error', E.Message);
        json.AddPair('status', 'error');
      end;
    end;
  end;

  Result := CStr16.FromString(json.ToJSON);
  json.Free;
end;


exports
  FreeString,
  AddDatabase,
  AddRemoteDatabase,
  ExecuteSql,
  CloseDatabase;

begin
  Initialize;

  // Replace the DLLProc with our own
  RealDllProc := DllProc;
  DllProc := @FakeDllProc;
end.
