unit database;
interface

uses
  SysUtils,
  Classes,
  Data.DB,
  System.JSON,
  System.Generics.Collections,

  nxdb,
  nxsdServerEngine,
  nxsrServerEngine,
  nxreRemoteServerEngine,
  nxllTransport,
  nxseAutoComponent,
  nxsrSqlEngineBase,
  nxsqlEngine,
  nxtwWinsockTransport;

type
  TDbMode = (local, remote);

  TDatabase = class
  private
    FMode: TDbMode;

    FAliasPath: string;
    FAliasName: string;
    FRemoteHost: string;
    FUsername: string;
    FPassword: string;

    FTransport: TnxWinsockTransport;
    FRemoteServerEngine: TnxRemoteServerEngine;
    FServerEngine: TnxServerEngine;
    FSqlEngine: TnxSqlEngine;
    FDb: TnxDatabase;
    FSession: TnxSession;
    FQuery: TnxQuery;
  protected
    function FConnected: Boolean;
    
    function FConnect: Boolean;
    function FDisconnect: Boolean;
    
    procedure FSetAliasPath(value: string);
    procedure FSetAliasName(value: string);
    procedure FSetRemoteHost(value: string);
    procedure FSetUsername(value: string);
    procedure FSetPassword(value: string);

  public
    constructor Create(mode: TDbMode);
    destructor Destroy; override;

    function Execute(query: string; params: string = ''): string;

    property Connected: Boolean read FConnected;
    
    property AliasPath: string read FAliasPath write FSetAliasPath;
    property AliasName: string read FAliasName write FSetAliasName;
    property RemoteHost: string read FRemoteHost write FSetRemoteHost;
    property Username: string read FUsername write FSetUsername;
    property Password: string read FPassword write FSetPassword;

    function Connect: Boolean;
  end;

implementation

{ TDatabase }

constructor TDatabase.Create(mode: TDbMode);
begin
  self.FMode := mode;

  self.FSession := TnxSession.Create(nil);

  self.FDb := TnxDatabase.Create(nil);
  self.FDb.Session := self.FSession;

  case self.FMode of
    local:
    begin
      self.FServerEngine := TnxServerEngine.Create(nil);
      self.FSession.ServerEngine := self.FServerEngine;
      self.FSqlEngine := TnxSqlEngine.Create(nil);
      self.FServerEngine.SqlEngine := self.FSqlEngine;
    end;
    remote:
    begin
      self.FRemoteServerEngine := TnxRemoteServerEngine.Create(nil);
      self.FTransport := TnxWinsockTransport.Create(nil);
      self.FRemoteServerEngine.Transport := self.FTransport;
      self.FSession.ServerEngine := self.FRemoteServerEngine;
    end;
  end;

  self.FQuery := TnxQuery.Create(nil);
  self.FQuery.Database := self.FDb;
end;

destructor TDatabase.Destroy;
begin
  FDb.Free;
  FSession.Free;
  inherited;
end;

function TDatabase.FConnected: Boolean;
begin
  Result := self.FDb.Connected;
end;

function TDatabase.FConnect: Boolean;
begin
  if not self.FDb.Connected then
  begin
    case self.FMode of
      local:
      begin
        self.FDb.AliasPath := self.FAliasPath;
        if not DirectoryExists(self.FAliasPath) then
          ForceDirectories(self.FAliasPath);
      end;
      remote:
      begin
        self.FDb.AliasName := self.FAliasName;
        self.FTransport.ServerName := self.FRemoteHost;
        self.FSession.UserName := self.FUsername;
        self.FSession.Password := self.FPassword;
      end;
    end;

    self.FDb.Connect;
    Result := self.FDb.Connected;
  end
  else
    Result := False;
end;

function TDatabase.FDisconnect: Boolean;
begin
  if self.FDb.Connected then
  begin
    self.FDb.Close;
    Result := not self.FDb.Connected;
  end
  else
    Result := False;
end;

procedure TDatabase.FSetAliasName(value: string);
begin
  if (not self.FConnected) and (self.FMode = TDbMode.remote) then
    self.FAliasName := value;
end;

procedure TDatabase.FSetAliasPath(value: string);
begin
  if (not self.FConnected) and (self.FMode = TDbMode.local) then
    self.FAliasPath := value;
end;

procedure TDatabase.FSetPassword(value: string);
begin
  if (not self.FConnected) and (self.FMode = TDbMode.remote) then
    self.FPassword := value;
end;

procedure TDatabase.FSetRemoteHost(value: string);
begin
  if (not self.FConnected) and (self.FMode = TDbMode.remote) then
    self.FRemoteHost := value;
end;

procedure TDatabase.FSetUsername(value: string);
begin
  if (not self.FConnected) and (self.FMode = TDbMode.remote) then
    self.FUsername := value;
end;

function TDatabase.Execute(query: string; params: string = ''): string;
var
  AParsedParams: TJSONObject;
  AIParam: Integer;
  ANewParam: TParam;

  AResult: TJSONArray;
  ANewResultItem: TJSONObject;
begin
  AResult := TJSONArray.Create;

  // params
  self.FQuery.Params.Clear;
  if params <> '' then
  begin
    AParsedParams := TJSONObject.ParseJSONValue(params) as TJSONObject;
    if AParsedParams <> nil then
    begin
      // iterate through params
      for AIParam := 0 to AParsedParams.Count - 1 do
      begin
        ANewParam := self.FQuery.Params.AddParameter;
        ANewParam.Name := AParsedParams.Pairs[AIParam].JsonString.Value;
        ANewParam.Value := AParsedParams.Pairs[AIParam].JsonValue.Value;
      end;
      AParsedParams.Free;
    end;
  end;


  if self.Connected then
  begin
    self.FQuery.SQL.Text := query;
    self.FQuery.Open();

    if self.FQuery.Active then
    begin
      // get result
      self.FQuery.First;
      while not self.FQuery.Eof do
      begin
        ANewResultItem := TJSONObject.Create;
        for AIParam := 0 to self.FQuery.FieldCount - 1 do
          ANewResultItem.AddPair(self.FQuery.Fields[AIParam].FieldName, self.FQuery.Fields[AIParam].AsString);

        AResult.AddElement(ANewResultItem);
        self.FQuery.Next;
      end;
      self.FQuery.Close;
    end;
  end;
  
  Result := AResult.ToJSON;
  AResult.Free;
end;

function TDatabase.Connect: Boolean;
begin
  exit(self.FConnect());
end;

end.
