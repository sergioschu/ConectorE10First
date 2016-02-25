unit uFWConnection;

interface

uses Classes,
  inifiles,
  System.SysUtils,
  FireDAC.Stan.Intf,
  FireDAC.Phys,
  FireDAC.Phys.PG,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.UI.Intf,
  Data.DB,
  FireDAC.Comp.Client;

type
  TFWConnection = class(TObject)
  private
    FFDConnection  : TFDConnection;
    FFDTransaction : TFDTransaction;
    function GetFDConnection: TFDConnection;
    procedure SetFDConnection(const Value: TFDConnection);
    procedure SetFDTransaction(const Value: TFDTransaction);
  publiC

    constructor Create;
    destructor Destroy; override;

    procedure Close;
    procedure StartTransaction;
    procedure Rollback;
    procedure Commit;

    property FDConnection : TFDConnection read GetFDConnection write SetFDConnection;
    property FDTransaction: TFDTransaction read FFDTransaction write SetFDTransaction;
  end;

implementation

uses
  uConstantes, uMensagem;

{ TFWConnection }

procedure TFWConnection.Close;
begin
  if FDConnection <> nil then begin
    FDConnection.Close;
  end;
end;

procedure TFWConnection.Commit;
begin
  try
    Self.GetFDConnection.Commit;
  except
    on E: Exception do
      raise EAbort.Create(E.message);
  end;
end;

constructor TFWConnection.Create;
begin

  try

    FDTransaction := TFDTransaction.Create(nil);
    FDTransaction.Name := 'TR_' + Self.ClassName;

    FDConnection  := TFDConnection.Create(nil);

    FDConnection.Params.Clear;
    FDConnection.Params.Add('Database=' + CONEXAO.Database);
    FDConnection.Params.Add('Server=' + CONEXAO.Server);
    FDConnection.Params.Add('User_Name=' + CONEXAO.User_Name);
    FDConnection.Params.Add('Password=' + CONEXAO.Password);
    FDConnection.Params.Add('CharacterSet=' + CONEXAO.CharacterSet);
    FDConnection.Params.Add('DriverID=' + CONEXAO.DriverID);
    FDConnection.Params.Add('Port=' + CONEXAO.Port);

    // conecta base principal
    FDConnection.LoginPrompt  := False;
    FDConnection.Connected    := True;

    FDTransaction.Connection  := FDConnection;

  except
    on E: Exception do begin
      raise Exception.Create(E.Message);
    end;
  end;
end;

destructor TFWConnection.Destroy;
begin
  if (FFDTransaction <> nil) then
    FreeAndNil(FFDTransaction);

  if (FFDConnection <> nil) then begin
    if FFDConnection.Connected then
      FFDConnection.Connected := False;
    FreeAndNil(FFDConnection);
  end;
end;

function TFWConnection.GetFDConnection: TFDConnection;
begin
  Result := FFDConnection;
end;

procedure TFWConnection.Rollback;
begin
  try
    FDTransaction.Rollback;
  except
    on E: Exception do
      raise EAbort.Create(E.message);
  end;
end;

procedure TFWConnection.SetFDConnection(const Value: TFDConnection);
begin
  FFDConnection := Value;
end;

procedure TFWConnection.SetFDTransaction(const Value: TFDTransaction);
begin
  FFDTransaction := Value;
end;

procedure TFWConnection.StartTransaction;
begin
  try
    Self.GetFDConnection.StartTransaction;
  except
    on E: Exception do
      raise EAbort.Create(E.message);
  end;
end;

end.
