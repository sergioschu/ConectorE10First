unit uConexaoFTP;

interface
uses IdFTP, System.SysUtils, System.Classes, IdFTPCommon, IdFTPList;
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
    procedure BuscaMDD;
    procedure BuscaCONF;
    procedure EnviarPedidos;
    procedure EnviarNotasFiscais;
    procedure EnviarPDF;
    destructor Destroy; override;
  End;
implementation
uses uConstantes, ufuncoes, uBeanArquivosFTP;
{ TConexaoFTP }

procedure TConexaoFTP.BuscaCONF;
var
  I : Integer;
begin
  SaveLog('Busca Arquivos de Confirmação de NF de Compra!');
  try
    FFTP.ChangeDir('conf');
    FFTP.List;
    for I := 0 to Pred(FFTP.DirectoryListing.Count) do begin
      if FFTP.DirectoryListing.Items[I].ItemType = ditFile then begin
        FFTP.Get(FFTP.DirectoryListing.Items[I].FileName, DirArquivosFTP + FFTP.DirectoryListing.Items[I].FileName);
        FFTP.Delete(FFTP.DirectoryListing.Items[I].FileName);
      end;
    end;
    FFTP.ChangeDirUp;
  except
    on E : Exception do begin
      SaveLog('Erro ao buscar arquivos de Confirmação de NF de Compra! ' + E.Message);
    end;
  end;
end;

procedure TConexaoFTP.BuscaMDD;
var
  I : Integer;
begin
  SaveLog('Dentro do BuscaMDD');
  try
    FFTP.ChangeDir('mdd');
    FFTP.List;
    for I := 0 to Pred(FFTP.DirectoryListing.Count) do begin
      if FFTP.DirectoryListing.Items[I].ItemType = ditFile then begin
        if not FileExists(DirArquivosFTP + FFTP.DirectoryListing.Items[I].FileName) then
          FFTP.Get(FFTP.DirectoryListing.Items[I].FileName, DirArquivosFTP + FFTP.DirectoryListing.Items[I].FileName);
        FFTP.Delete(FFTP.DirectoryListing.Items[I].FileName);
      end;
    end;
    FFTP.ChangeDirUp;
  except
    on E : Exception do begin
      SaveLog('Erro ao buscar MDD: ' + E.Message);
    end;
  end;
end;

constructor TConexaoFTP.Create;
begin
  inherited;
  FFTP              := TIdFTP.Create(nil);
  FFTP.Passive      := True;
  FFTP.TransferType := ftBinary;
  FFTP.ListenTimeout:= 60000;
  SaveLog('Antes do Login!');
  Login;
  SaveLog('Depois do Login!');
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
  SaveLog('Enviando Notas Fiscais');
  try
    FFTP.ChangeDir('armz');
    FFTP.ChangeDir('receb');
    if FindFirst(DirArquivosFTP + '*.txt', faAnyFile, search_rec) = 0 then begin
      try
        repeat
          if (search_rec.Attr <> faDirectory) and (Pos('ARMZ', search_rec.Name) > 0) then begin
            SaveLog('Antes do upload!');
            FFTP.Put(DirArquivosFTP + search_rec.Name, search_rec.Name);
            SaveLog('Passou do upload!');
            DeleteFile(DirArquivosFTP + search_rec.Name);
          end;
        until FindNext(search_rec) <> 0;

      finally
        FindClose(search_rec);
      end;
    end;
    FFTP.ChangeDirUp;
    FFTP.ChangeDirUp;
  except
    on E : Exception do begin
      SaveLog('Erro ao Enviar Notas Fiscais! ' + E.Message);
    end;
  end;
end;

procedure TConexaoFTP.EnviarPedidos;
var
  search_rec: TSearchRec;
begin
  SaveLog('Enviando Pedidos');
  try
    FFTP.ChangeDir('sc');
    FFTP.ChangeDir('receb');

    if FindFirst(DirArquivosFTP + '*.txt', faAnyFile, search_rec) = 0 then begin
      try
        repeat
          if (search_rec.Attr <> faDirectory) and (Pos('SC', search_rec.Name) > 0) then begin
            FFTP.Put(DirArquivosFTP + search_rec.Name, search_rec.Name);
            DeleteFile(DirArquivosFTP + search_rec.Name);
          end;
        until FindNext(search_rec) <> 0;
      finally
        FindClose(search_rec);
      end;
    end;
    FFTP.ChangeDirUp;
    FFTP.ChangeDirUp;
  except
    on E : Exception do begin
      SaveLog('Erro ao Enviar Pedidos! ' + E.Message);
    end;
  end;
end;

procedure TConexaoFTP.EnviarProdutos;
var
  search_rec: TSearchRec;
begin
  SaveLog('Enviando arquivo de Produtos!');
  try
    FFTP.ChangeDir('prod');
    FFTP.ChangeDir('receb');
    if FindFirst(DirArquivosFTP + '*.txt', faAnyFile, search_rec) = 0 then begin
      try
        repeat
          if (search_rec.Attr <> faDirectory) and (Pos('PROD', search_rec.Name) > 0) then begin
            FFTP.Put(DirArquivosFTP + search_rec.Name, search_rec.Name);
            SaveLog('Passou do upload!');
            DeleteFile(DirArquivosFTP + search_rec.Name);
            SaveLog('Deletar arquivo!');
          end;
        until FindNext(search_rec) <> 0;
      finally
        FindClose(search_rec);
      end;
    end;
    FFTP.ChangeDirUp;
    FFTP.ChangeDirUp;
  except
    on E : Exception do begin
      SaveLog('Erro ao enviar produtos! ' + E.Message);
    end;
  end;
end;

procedure TConexaoFTP.EnviarPDF;
var
  SR : TSearchRec;
begin
  SaveLog('Enviando PDF!');
  try
    FFTP.ChangeDir('PDF');
    if FindFirst(DirArquivosFTP + '*.pdf', faAnyFile, SR) = 0 then begin
      try
        repeat
          if (SR.Attr <> faDirectory) then begin
            if (Pos('-nfe.pdf', SR.Name) > 0) then begin
              FFTP.Put(DirArquivosFTP + SR.Name, SR.Name);
              SaveLog('Passou do upload!');
              DeleteFile(DirArquivosFTP + SR.Name);
              SaveLog('Deletar arquivo!');
            end else
              SaveLog('Não tem -nfe.pdf');
          end;
        until FindNext(SR) <> 0;
      finally
        FindClose(SR);
      end;
    end;
    FFTP.ChangeDirUp;
  except
    on E : Exception do begin
      SaveLog('Erro ao enviar PDF! ' + E.Message);
    end;
  end;
end;

procedure TConexaoFTP.Login;
begin
  try
    FFTP.Host        := 'ftp.firstlog.com.br';
    FFTP.Username    := CONFIG_LOCAL.FTPUsuario;
    FFTP.Password    := CONFIG_LOCAL.FTPSenha;
    FFTP.Connect;
    Connected        := True;
  except
    on E : Exception do begin
      SaveLog('Erro ao Conectar no FTP: ' + E.Message);
      Connected      := False;
    end;
  end;
end;

procedure TConexaoFTP.Logout;
begin
  FFTP.Disconnect;
  Connected  := False;
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
