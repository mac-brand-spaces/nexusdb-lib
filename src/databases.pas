unit databases;

interface

uses
  SysUtils,
  Classes,
  database;

type
  TDatabaseRec = record
    Id: string;
    Database: TDatabase;
  end;

  TDatabases = class
  private
    FDatabases: TArray<TDatabaseRec>;

    function NewId: String;
  public
    constructor Create;
    destructor Destroy; override;
    
    function GetDatabaseById(id: string; out database: TDatabase): Boolean;
    function CreateDatabase(mode: TDbMode): String;
    function CloseDatabase(id: string): Boolean;
  end;

implementation

{ TDatabases }

constructor TDatabases.Create;
begin
  inherited Create();
  self.FDatabases := [];
end;

destructor TDatabases.Destroy;
var
  database: TDatabaseRec;
begin
  for database in self.FDatabases do
  begin
    database.Database.Free;
  end;
  inherited;
end;

function TDatabases.CloseDatabase(id: string): Boolean;
var
  database: TDatabaseRec;
  index: Integer;
begin
  index := 0;
  for database in self.FDatabases do
  begin
    if database.Id = id then
    begin
      database.Database.Free;
      self.FDatabases[index] := self.FDatabases[Length(self.FDatabases) - 1];
      SetLength(self.FDatabases, Length(self.FDatabases) - 1);
      Exit(True);
    end;
    index := index + 1;
  end;
  Exit(False);
end;

function TDatabases.CreateDatabase(mode:TDbMode): String;
var
  database: TDatabaseRec;
begin
  database.Id := self.NewId;
  database.Database := TDatabase.Create(mode);
  self.FDatabases := self.FDatabases + [database];
  Exit(database.Id);
end;

function TDatabases.GetDatabaseById(id: string; out database: TDatabase): Boolean;
var
  databaseRec: TDatabaseRec;
begin
  for databaseRec in self.FDatabases do
  begin
    if databaseRec.Id = id then
    begin
      database := databaseRec.Database;
      Exit(True);
    end;
  end;
  Exit(False);
end;

function TDatabases.newId: String;
begin
  Result := GUIDToString(TGUID.NewGuid).ToLower().Remove(0, 1).Remove(36, 1);
end;

end.