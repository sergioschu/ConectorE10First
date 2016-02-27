unit uConexaoFTP;

interface
uses IdFTP, System.SysUtils, System.Classes;
type
  TConexaoFTP = Class
  private
    FFTP: TIdFTP;
    FConnected: Boolean;
    procedure SetFTP(const Value: TIdFTP);
    procedure SetConnected(const Value: Boolean);
    procedure Login;
    procedure Logout;
  published
    property FTP : TIdFTP read FFTP write SetFTP;
    property Connected : Boolean read FConnected write SetConnected;
  public
    constructor Create;
    procedure EnviarPedidos(Texto : String; Numero : Integer);
    destructor Destroy; override;
  End;
implementation
uses uConstantes;
{ TConexaoFTP }

constructor TConexaoFTP.Create;
begin
  inherited;
  FFTP      := TIdFTP.Create(nil);
end;

destructor TConexaoFTP.Destroy;
begin
  FFTP.Disconnect;
  FreeAndNil(FFTP);
  inherited;
end;

procedure TConexaoFTP.EnviarPedidos(Texto: String; Numero: Integer);
var
  Stream : TStream;
begin
  FFTP.ChangeDir('SC');
  Login;
  FFTP.Put(Texto, '');

end;

procedure TConexaoFTP.Login;
begin
  if FFTP.Connected then Logout;
  FFTP.Host        := 'ftp.firstlog.com.br';
  FFTP.Username    := CONFIG_LOCAL.FTPUsuario;
  FFTP.Password    := CONFIG_LOCAL.FTPSenha;
  FFTP.Connect;
end;

procedure TConexaoFTP.Logout;
begin
  FFTP.Disconnect;
end;

procedure TConexaoFTP.SetConnected(const Value: Boolean);
begin
  FConnected := Value;
end;

procedure TConexaoFTP.SetFTP(const Value: TIdFTP);
begin
  FFTP := Value;
end;

end.
