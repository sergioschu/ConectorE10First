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
    procedure EnviarProdutos;
    procedure EnviarPedidos;
    procedure EnviarNotasFiscais;
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

procedure TConexaoFTP.EnviarNotasFiscais;
var
  search_rec: TSearchRec;
begin
  if FindFirst(DirArquivosFTP, faAnyFile, search_rec) = 0 then begin
    repeat
      if (search_rec.Attr <> faDirectory) and (Pos('ARMZ', search_rec.Name) > 0) then begin
        Login;
        FFTP.ChangeDir('ARMZ');
        FFTP.Put(DirArquivosFTP + search_rec.Name, search_rec.Name);
        DeleteFile(DirArquivosFTP + search_rec.Name);
      end;
    until FindNext(search_rec) <> 0;

    FindClose(search_rec);
  end;
end;

procedure TConexaoFTP.EnviarPedidos;
var
  search_rec: TSearchRec;
begin
  if FindFirst(DirArquivosFTP, faAnyFile, search_rec) = 0 then begin
    repeat
      if (search_rec.Attr <> faDirectory) and (Pos('SC', search_rec.Name) > 0) then begin
        Login;
        FFTP.ChangeDir('SC');
        FFTP.Put(DirArquivosFTP + search_rec.Name, search_rec.Name);
        DeleteFile(DirArquivosFTP + search_rec.Name);
      end;
    until FindNext(search_rec) <> 0;

    FindClose(search_rec);
  end;
end;

procedure TConexaoFTP.EnviarProdutos;
var
  search_rec: TSearchRec;
begin
  if FindFirst(DirArquivosFTP, faAnyFile, search_rec) = 0 then begin
    repeat
      if (search_rec.Attr <> faDirectory) and (Pos('PROD', search_rec.Name) > 0) then begin
        Login;
        FFTP.ChangeDir('PROD');
        FFTP.Put(DirArquivosFTP + search_rec.Name, search_rec.Name);
        DeleteFile(DirArquivosFTP + search_rec.Name);
      end;
    until FindNext(search_rec) <> 0;

    FindClose(search_rec);
  end;
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
