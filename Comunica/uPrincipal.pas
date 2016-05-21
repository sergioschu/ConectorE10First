unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, uFWConnection, System.IniFiles,
  Vcl.ExtCtrls, Vcl.Buttons, Vcl.ImgList;

type
  TfrmPrincipal = class(TForm)
    Panel1: TPanel;
    btIniciar: TBitBtn;
    Timer1: TTimer;
    ImageList1: TImageList;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btIniciarClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function BuscaNumeroArquivo(Con : TFWConnection; Tipo : Integer) : Integer;
    procedure SaveLog(Texto : String);
    procedure CarregarConexaoBD;
    procedure CarregarConfigLocal;
    function EnviaPedidos : Boolean;
    function EnviaProdutos : Boolean;
    function EnviaNotasFiscais : Boolean;
    function BuscaMDD : Boolean;
    function BuscaCONF : Boolean;
    Procedure IniciarPararLeitura;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation
uses
  uConexaoFTP,
  uBeanproduto,
  uBeanPedido,
  uBeanPedidoItens,
  uBeanTransportadoras,
  uBeanArquivosFTP,
  uBeanNotafiscal,
  uBeanNotafiscalItens,
  uConstantes,
  uDados;
{$R *.dfm}

{ TfrmPrincipal }

procedure TfrmPrincipal.btIniciarClick(Sender: TObject);
begin
  if btIniciar.Tag = 0 then begin
    try
      IniciarPararLeitura;
    finally
      btIniciar.Tag := 0;
    end;
  end;
end;

function TfrmPrincipal.BuscaCONF: Boolean;
var
  search_rec  : TSearchRec;
  FTP         : TConexaoFTP;
  Lista       : TStringList;
  CONF        : TStringList;
  I,
  J           : Integer;
  FWC         : TFWConnection;
  PR          : TPRODUTO;
  NF          : TNOTAFISCAL;
  NI          : TNOTAFISCALITENS;
  Deletar     : Boolean;
  NOTAENTRADA : array of TNOTAENTRADA;
  NOTAATUAL   : TNOTAENTRADA;
  Achou       : Boolean;
begin
  SaveLog('antes da conexao com FTP');
  FTP   := TConexaoFTP.Create;
  try
    FTP.BuscaCONF;
  finally
    FreeAndNil(FTP);
  end;

  SaveLog('Passou da conexao com FTP');

  if FindFirst(DirArquivosFTP + '*.txt', faAnyFile, search_rec) = 0 then begin
    SaveLog('Achou pelo menos 1!');
    SetLength(NOTAENTRADA, 0);
    try
      repeat
        if (search_rec.Attr <> faDirectory) and (Pos('CONF', search_rec.Name) > 0) then begin
          Deletar := True;

          Lista   := TStringList.Create;
          CONF    := TStringList.Create;

          FWC     := TFWConnection.Create;
          NF      := TNOTAFISCAL.Create(FWC);
          NI      := TNOTAFISCALITENS.Create(FWC);
          PR      := TPRODUTO.Create(FWC);

          try
            FWC.StartTransaction;
            try

              Lista.LoadFromFile(DirArquivosFTP + search_rec.Name);

              for I := 0 to Pred(Lista.Count) do begin
                if Length(Trim(Lista[I])) > 0 then begin
                  CONF.Delimiter       := ';';
                  CONF.StrictDelimiter := True;
                  CONF.DelimitedText   := Lista[I];
                  if CONF.Count = 11 then begin
                    SaveLog('arquivo valido!');
                    Achou := False;
                    for J := Low(NOTAENTRADA) to High(NOTAENTRADA) do begin
                      if (IntToStr(NOTAENTRADA[J].DOCUMENTO) = CONF[0]) and (IntToStr(NOTAENTRADA[J].SERIE) = CONF[1]) then begin
                        Achou := True;
                        NOTAATUAL.DOCUMENTO   := NOTAENTRADA[J].DOCUMENTO;
                        NOTAATUAL.SERIE       := NOTAENTRADA[J].SERIE;
                        NOTAATUAL.ID          := NOTAENTRADA[J].ID;
                        Break;
                      end;
                    end;

                    if not Achou then begin
                      NF.SelectList('documento = ' + CONF[0] + ' and serie = ' + CONF[1] + ' and status <= 1');
                      if NF.Count > 0 then begin
                        SetLength(NOTAENTRADA, Length(NOTAENTRADA) + 1);
                        NOTAENTRADA[High(NOTAENTRADA)].DOCUMENTO  := TNOTAFISCAL(NF.Itens[0]).DOCUMENTO.Value;
                        NOTAENTRADA[High(NOTAENTRADA)].SERIE      := TNOTAFISCAL(NF.Itens[0]).SERIE.Value;
                        NOTAENTRADA[High(NOTAENTRADA)].ID         := TNOTAFISCAL(NF.Itens[0]).ID.Value;

                        NOTAATUAL.DOCUMENTO := NOTAENTRADA[High(NOTAENTRADA)].DOCUMENTO;
                        NOTAATUAL.SERIE := NOTAENTRADA[High(NOTAENTRADA)].SERIE;
                        NOTAATUAL.ID := NOTAENTRADA[High(NOTAENTRADA)].ID;
                      end else begin
                        SaveLog('Nota Fiscal ' + CONF[0] + ' não encontrada ou já recebida!');
                        Deletar                        := False;
                        Break;
                      end;
                    end;

                    PR.SelectList('upper(codigoproduto) = ' + QuotedStr(UpperCase(CONF[5])));
                    if PR.Count > 0 then begin
                      NI.SelectList('ID_NOTAFISCAL = ' + IntToStr(NOTAATUAL.ID) + ' AND ID_PRODUTO = ' + TPRODUTO(PR.Itens[0]).ID.asString);
                      if NI.Count > 0 then begin
                        NI.ID.Value                := TNOTAFISCALITENS(NI.Itens[0]).ID.Value;
                        NI.QUANTIDADEREC.Value     := StrToFloat(CONF[8]);
                        NI.QUANTIDADEAVA.Value     := StrToFloat(CONF[9]);
                        NI.Update;
                      end else SaveLog('Produto ' + CONF[5] + ' não encontrado na nota!');
                    end else SaveLog('Produto não encontrado!');
                  end;
                end;
              end;

              for I := Low(NOTAENTRADA) to High(NOTAENTRADA) do begin
                NF.ID.Value                      := NOTAENTRADA[I].ID;
                NF.DATA_RECEBIDO.Value           := Now;
                NF.STATUS.Value                  := 2;
                NF.Update;
              end;

              if Deletar then
                DeleteFile(DirArquivosFTP + search_rec.Name);

              FWC.Commit;

            except
              on E : Exception do begin
                FWC.Rollback;
                SaveLog('Erro ao bucar CONF: ' + E.Message);
              end;
            end;
          finally
            FreeAndNil(CONF);
            FreeAndNil(Lista);
            FreeAndNil(NF);
            FreeAndNil(NI);
            FreeAndNil(PR);
            FreeAndNil(FWC);
          end;
        end;
      until FindNext(search_rec) <> 0;
    finally
      FindClose(search_rec);
    end;
  end;
end;

function TfrmPrincipal.BuscaMDD: Boolean;
var
  search_rec  : TSearchRec;
  FTP         : TConexaoFTP;
  Lista       : TStringList;
  MDD         : TStringList;
  I,
  J           : Integer;
  CON         : TFWConnection;
  PR          : TPRODUTO;
  P           : TPEDIDO;
  PI          : TPEDIDOITENS;
  Deletar,
  Achou       : Boolean;
  PEDIDOS     : array of TPEDIDOS;
  PEDIDOATUAL : TPEDIDOS;
  Arquivo     : String;
begin
  SaveLog('antes da conexao com FTP');
  FTP   := TConexaoFTP.Create;
  try
    FTP.BuscaMDD;
  finally
    FreeAndNil(FTP);
  end;

  SaveLog('Passou da conexao com FTP');

  if FindFirst(DirArquivosFTP + '*.txt', faAnyFile, search_rec) = 0 then begin
    SaveLog('Existe arquivo na pasta local, arquivo: ' + search_rec.Name);
    try
      repeat
        if (search_rec.Attr <> faDirectory) and (Pos('MDD', search_rec.Name) > 0) then begin
          SaveLog('Arquivo é um MDD');
          Lista   := TStringList.Create;
          MDD     := TStringList.Create;
          SetLength(PEDIDOS, 0);
          Deletar := True;
          try
            try
              MDD.Delimiter       := ';';
              MDD.StrictDelimiter := True;
              SaveLog('Antes de Carregar o Arquivo!');

              Lista.LoadFromFile(DirArquivosFTP + search_rec.Name);

              SaveLog('Depois de Carregar o Arquivo!');
              if Lista.Count > 0 then begin
                SaveLog('Arquivo não esta Vazio!');
                for I := 0 to Pred(Lista.Count) do begin
                  if Length(Trim(Lista[I])) > 0 then begin

                    SaveLog('Antes do Delimit');
                    MDD.DelimitedText   := Lista[I];

                    SaveLog('Depois do Delimit');
                    if MDD.Count = 7 then begin
                      SaveLog('MDD Válido!');
                      for J := 0 to Pred(Length(PEDIDOS)) do begin
                        if PEDIDOS[J].PEDIDO = MDD[2] then begin
                          SetLength(PEDIDOS[J].PRODUTOS, Length(PEDIDOS[J].PRODUTOS) + 1);
                          PEDIDOS[J].PRODUTOS[High(PEDIDOS[J].PRODUTOS)] := MDD[2];
                          Achou       := True;
                          SaveLog('Inserindo Itens no Pedido');
                          Break;
                        end;
                      end;
                      if not Achou then begin
                        SaveLog('Não Achou, Vamos incluir');
                        SetLength(PEDIDOS, Length(PEDIDOS) + 1);
                        SaveLog('Aumentou o tamanho do array');
                        PEDIDOS[High(PEDIDOS)].PEDIDO      := MDD[0];
                        PEDIDOS[High(PEDIDOS)].VOLUMES     := StrToIntDef(MDD[6], 1);
                        SaveLog('atribuiu os valores');

                        SetLength(PEDIDOS[High(PEDIDOS)].PRODUTOS, 1);
                        SaveLog('aumentou array de itens');
                        PEDIDOS[High(PEDIDOS)].PRODUTOS[0] := MDD[2];
                        SaveLog('Inseriu um Pedido no Array');
                      end;
                    end else
                      SaveLog('Linha com tamanho inválido!');
                  end;
                end;

                CON    := TFWConnection.Create;
                P      := TPEDIDO.Create(CON);
                PR     := TPRODUTO.Create(CON);
                PI     := TPEDIDOITENS.Create(CON);

                try
                  SaveLog('Percorrendo Array');
                  CON.StartTransaction;
                  try
                    for I := Low(PEDIDOS) to High(PEDIDOS) do begin
                      P.SelectList('pedido = ' + QuotedStr(PEDIDOS[I].PEDIDO) + ' and status <= 2');
                      if P.Count > 0 then begin
                        for J := Low(PEDIDOS[I].PRODUTOS) to High(PEDIDOS[I].PRODUTOS) do begin
                          PR.SelectList('upper(codigoproduto) = ' + QuotedStr(AnsiUpperCase(PEDIDOS[I].PRODUTOS[J])));
                          if PR.Count > 0 then begin
                            PI.SelectList('id_pedido = ' + TPEDIDO(P.Itens[0]).ID.asString + ' and id_produto = ' + TPRODUTO(PR.Itens[0]).ID.asString);
                            if PI.Count = 0 then begin
                              SaveLog('Produto não esta incluido no pedido!');
                              Deletar := False;
                            end;
                          end else begin
                            SaveLog('Produto ' + PEDIDOS[I].PRODUTOS[J] + ' não cadastrado!');
                            Deletar := False;
                          end;
                        end;

                        if Deletar then begin
                          P.ID.Value            := TPEDIDO(P.Itens[0]).ID.Value;
                          P.STATUS.Value        := 3;
                          P.DATA_RECEBIDO.Value := Now;
                          P.Update;
                        end;
                      end else begin
                        SaveLog('Pedido Não Encontrado ou já recebido!');
                        Deletar := False;
                      end;
                    end;

                    CON.Commit;

                  except
                    on E : Exception do begin
                      CON.Rollback;
                      SaveLog('Erro ao Salvar Dados, Erro: ' + E.Message);
                    end;
                  end;
                finally
                  FreeAndNil(P);
                  FreeAndNil(PR);
                  FreeAndNil(PI);
                  FreeAndNil(CON);
                end;

                if Deletar then
                  DeleteFile(DirArquivosFTP + search_rec.Name)
                else begin
                  Arquivo := DirArquivosFTP + search_rec.Name;
                  if CopyFile(PWidechar(Arquivo), PWidechar(DirArquivosFTP + 'Erros\' + search_rec.Name), false) then
                    DeleteFile(DirArquivosFTP + search_rec.Name);
                end;
              end else
                SaveLog('Arquivo Vazio!');
            except
              on E : Exception do
                SaveLog('Ocorreu algum erro ao tratar arquivos locais, Erro: ' + E.Message);
            end;
          finally
            FreeAndNil(Lista);
            FreeAndNil(MDD);
          end;
        end else
          SaveLog('Arquivo não é um MDD!');
      until (FindNext(search_rec) <> 0);
    finally
      FindClose(search_rec);
    end;
  end;
end;

function TfrmPrincipal.BuscaNumeroArquivo(Con: TFWConnection;
  Tipo: Integer): Integer;
var
  AF : TARQUIVOSFTP;
begin

  Result := 0;

  AF   := TARQUIVOSFTP.Create(Con);
  try
    try
      AF.ID.isNull        := True;
      AF.TIPO.Value       := Tipo;
      AF.DATAENVIO.Value  := Now;
      AF.Insert;

      Result := AF.ID.Value;
    except
      on E : exception do
        SaveLog('Erro ao buscar numero arquivo FTP. Erro: ' + E.Message);
    end;
  finally
    FreeAndNil(AF);
  end;
end;

procedure TfrmPrincipal.CarregarConexaoBD;
Var
  ArqINI : TIniFile;
begin

  ArqINI := TIniFile.Create(DirArqConf);
  try

    LOGIN.Usuario               := ArqINI.ReadString('LOGIN', 'USUARIO', '');
    LOGIN.LembrarUsuario        := ArqINI.ReadBool('LOGIN', 'LEMBRARUSUARIO', True);

    CONFIG_LOCAL.DirRelatorios  := ArqINI.ReadString('CONFIGURACOES', 'DIR_RELATORIOS', 'C:\ConectorE10First\Relatorios\');
    CONFIG_LOCAL.DirLog         := ArqINI.ReadString('CONFIGURACOES', 'DIR_LOGS', 'C:\ConectorE10First\Logs\');
    CONFIG_LOCAL.FTPUsuario     := ArqINI.ReadString('CONFIGURACOES', 'FTP_USUARIO', '');
    CONFIG_LOCAL.FTPSenha       := ArqINI.ReadString('CONFIGURACOES', 'FTP_SENHA', '');
    CONFIG_LOCAL.Sleep          := ArqINI.ReadInteger('CONFIGURACOES', 'FTP_SLEEP', 0);
  finally
    FreeAndNil(ArqINI);
  end;

end;

procedure TfrmPrincipal.CarregarConfigLocal;
Var
  ArqINI : TIniFile;
begin

  ArqINI := TIniFile.Create(DirArqConf);
  try

    CONEXAO.LibVendor     := ExtractFilePath(ParamStr(0)) + 'libpq.dll';
    CONEXAO.Database      := ArqINI.ReadString('CONEXAOBD', 'Database', '');
    CONEXAO.Server        := ArqINI.ReadString('CONEXAOBD', 'Server', 'localhost');
    CONEXAO.User_Name     := ArqINI.ReadString('CONEXAOBD', 'User_Name', '');
    CONEXAO.Password      := ArqINI.ReadString('CONEXAOBD', 'Password', '');
    CONEXAO.CharacterSet  := ArqINI.ReadString('CONEXAOBD', 'CharacterSet', 'UTF8');
    CONEXAO.DriverID      := ArqINI.ReadString('CONEXAOBD', 'DriverID', 'PG');
    CONEXAO.Port          := ArqINI.ReadString('CONEXAOBD', 'Port', '5432');

  finally
    FreeAndNil(ArqINI);
  end;

end;

function TfrmPrincipal.EnviaNotasFiscais: Boolean;
var
  Con     : TFWConnection;
  NF      : TNOTAFISCAL;
  NI      : TNOTAFISCALITENS;
  PR      : TPRODUTO;
  I,
  J,
  AFTP    : Integer;
  Lista   : TStringList;
  FTP     : TConexaoFTP;
begin
  Con   := TFWConnection.Create;
  NF    := TNOTAFISCAL.Create(Con);
  NI    := TNOTAFISCALITENS.Create(Con);
  PR    := TPRODUTO.Create(Con);
  Lista := TStringList.Create;
  try
    Con.StartTransaction;
    try
      NF.SelectList('status = 0');
      if NF.Count > 0 then begin
        SaveLog('Tem NF para exportar');
        AFTP    := BuscaNumeroArquivo(Con, 1);
        for I := 0 to Pred(NF.Count) do begin
          NI.SelectList('id_notafiscal = ' + TNOTAFISCAL(NF.Itens[I]).ID.asString);
          if NI.Count > 0 then begin
            for J := 0 to Pred(NI.Count) do begin
              PR.SelectList('id = ' + TNOTAFISCALITENS(NI.Itens[J]).ID_PRODUTO.asString);
              if PR.Count > 0 then begin
                Lista.Add(TNOTAFISCAL(NF.Itens[I]).DOCUMENTO.asString + ';' +
                  TNOTAFISCAL(NF.Itens[I]).SERIE.asString + ';' +
                  TNOTAFISCAL(NF.Itens[I]).CNPJCPF.asString + ';' +
                  FormatDateTime('yyyymmdd', TNOTAFISCAL(NF.Itens[I]).DATAEMISSAO.Value) + ';' +
                  TNOTAFISCAL(NF.Itens[I]).CFOP.asString + ';' +
                  IntToStr(J + 1) + ';' +
                  TPRODUTO(PR.Itens[0]).CODIGOPRODUTO.asString + ';' +
                  TNOTAFISCALITENS(NI.Itens[J]).QUANTIDADE.asString + ';' +
                  TNOTAFISCALITENS(NI.Itens[J]).VALORUNITARIO.asString + ';' +
                  TNOTAFISCALITENS(NI.Itens[J]).VALORTOTAL.asString + ';' +
                  TNOTAFISCAL(NF.Itens[I]).VALORTOTAL.asString + ';' +
                  TNOTAFISCAL(NF.Itens[I]).ESPECIE.asString + ';'
                );
              end;
            end;
            NF.ID.Value           := TNOTAFISCAL(NF.Itens[I]).ID.Value;
            NF.STATUS.Value       := 1;
            NF.ID_ARQUIVO.Value   := AFTP;
            NF.DATA_ENVIO.Value   := Now;
            NF.Update;
          end;
        end;
        if Lista.Count > 0 then begin
          SaveLog('Tem algo na lista!');
          Lista.SaveToFile(DirArquivosFTP + 'ARMZ' + NF.ID_ARQUIVO.asString + '.txt');
        end;
      end;

      Con.Commit;

      FTP := TConexaoFTP.Create;
      try
        FTP.EnviarNotasFiscais;
      finally
        FreeAndNil(FTP);
      end;
    except
      on E : Exception do begin
        Con.Rollback;
        SaveLog('Erro ao Enviar NF: ' +E.Message);
      end;
    end;
  finally
    FreeAndNil(NF);
    FreeAndNil(NI);
    FreeAndNil(PR);
    FreeAndNil(Con);
    FreeAndNil(Lista);
  end;
end;

function TfrmPrincipal.EnviaPedidos: Boolean;
var
  Con     : TFWConnection;
  P       : TPEDIDO;
  PI      : TPEDIDOITENS;
  PR      : TPRODUTO;
  T       : TTRANSPORTADORA;
  Lista   : TStringList;
  I,
  J       : Integer;
  FTP     : TConexaoFTP;
begin

  Con    := TFWConnection.Create;
  P      := TPEDIDO.Create(Con);
  PI     := TPEDIDOITENS.Create(Con);
  PR     := TPRODUTO.Create(Con);
  T      := TTRANSPORTADORA.Create(Con);
  Lista  := TStringList.Create;

  try
    Con.StartTransaction;
    try
      P.SelectList('status = 1');
      if P.Count > 0 then begin
        for I := 0 to Pred(P.Count) do begin
          Lista.Clear;

          T.SelectList('id = ' + TPEDIDO(P.Itens[I]).ID_TRANSPORTADORA.asString);
          if T.Count > 0 then begin
            PI.SelectList('id_pedido = ' + TPEDIDO(P.Itens[I]).ID.asString);
            if PI.Count > 0 then begin
              for J := 0 to Pred(PI.Count) do begin
                PR.SelectList('id = ' + TPEDIDOITENS(PI.Itens[J]).ID_PRODUTO.asString);
                if PR.Count > 0 then begin
                  Lista.Add(TTRANSPORTADORA(T.Itens[0]).CNPJ.asString + ';' +
                    TPEDIDO(P.Itens[I]).PEDIDO.asString + ';' +
                    TPEDIDO(P.Itens[I]).VIAGEM.asString + ';' +
                    TPEDIDO(P.Itens[I]).SEQUENCIA.asString + ';' +
                    TPRODUTO(PR.Itens[0]).CODIGOPRODUTO.asString + ';' +
                    TPRODUTO(PR.Itens[0]).UNIDADEDEMEDIDA.asString + ';' +
                    TPEDIDOITENS(PI.Itens[J]).QUANTIDADE.asString + ';' +
                    TPEDIDOITENS(PI.Itens[J]).VALOR_UNITARIO.asString + ';' +
                    TPEDIDO(P.Itens[I]).DEST_CNPJ.asString + ';' +
                    TPEDIDO(P.Itens[I]).DEST_NOME.asString + ';' +
                    TPEDIDO(P.Itens[I]).DEST_ENDERECO.asString + ';' +
                    TPEDIDO(P.Itens[I]).DEST_COMPLEMENTO.asString + ';' +
                    TPEDIDO(P.Itens[I]).DEST_CEP.asString + ';' +
                    TPEDIDO(P.Itens[I]).DEST_MUNICIPIO.asString + ';');
                end;
              end;
            end;
          end;

          P.ID.Value         := TPEDIDO(P.Itens[I]).ID.Value;
          P.ID_ARQUIVO.Value := BuscaNumeroArquivo(Con, 2);
          P.STATUS.Value     := 2;
          P.DATA_ENVIO.Value := Now;
          P.Update;

          if Lista.Count > 0 then begin
            if not DirectoryExists(DirArquivosFTP) then
              ForceDirectories(DirArquivosFTP);
            Lista.SaveToFile(DirArquivosFTP + 'SC' + P.ID_ARQUIVO.asString + '.txt');
          end;
        end;
      end;
      Con.Commit;
    except
      on E : Exception do begin
        Con.Rollback;
        SaveLog('Erro ao Enviar Pedido : ' + E.Message);
      end;
    end;
  finally
    FreeAndNil(PR);
    FreeAndNil(PI);
    FreeAndNil(P);
    freeAndNil(T);
    Freeandnil(Con);
    FreeAndNil(Lista);
  end;

  FTP     := TConexaoFTP.Create;
  try
    FTP.EnviarPedidos;
  finally
    FreeAndNil(FTP);
  end;
end;

function TfrmPrincipal.EnviaProdutos: Boolean;
var
  Con     : TFWConnection;
  FTP     : TConexaoFTP;
  PR      : TPRODUTO;
  I,
  AFTP,
  Quant   : Integer;
  Lista   : TStringList;
  Teste   : Boolean;
begin

  Con := TFWConnection.Create;
  PR  := TPRODUTO.Create(Con);

  try
    Con.StartTransaction;
    try
      Teste := True;
      while Teste do begin
        SaveLog('while');
        PR.SelectList('status = 0');
        SaveLog('select');
        Quant        := 1000;

        if PR.Count < Quant then begin
          Quant      := PR.Count;
          Teste      := False;
        end;

        if PR.Count > 0 then begin
          SaveLog('Tem produtos para exportar');
          AFTP         := BuscaNumeroArquivo(Con, 0);
          SaveLog('Buscou um codigo para o FTP');
          Lista        := TStringList.Create;
          SaveLog('Passou do create');
          try
            for I := 0 to Pred(Quant) do begin
              Lista.Add(TPRODUTO(PR.Itens[I]).CODIGOPRODUTO.asString + ';' +
                TPRODUTO(PR.Itens[I]).DESCRICAO.asString + ';' +
                TPRODUTO(PR.Itens[I]).DESCRICAOREDUZIDA.asString + ';' +
                TPRODUTO(PR.Itens[I]).DESCRICAOSKU.asString + ';' +
                TPRODUTO(PR.Itens[I]).DESCRICAOREDUZIDASKU.asString + ';' +
                TPRODUTO(PR.Itens[I]).QUANTIDADEPOREMBALAGEM.asString + ';' +
                TPRODUTO(PR.Itens[I]).UNIDADEDEMEDIDA.asString + ';' +
                TPRODUTO(PR.Itens[I]).CODIGOBARRAS.asString + ';' +
                TPRODUTO(PR.Itens[I]).ALTURAEMBALAGEM.asString + ';' +
                TPRODUTO(PR.Itens[I]).COMPRIMENTOEMBALAGEM.asString + ';' +
                TPRODUTO(PR.Itens[I]).LARGURAEMBALAGEM.asString + ';' +
                TPRODUTO(PR.Itens[I]).PESOEMBALAGEM.asString + ';' +
                TPRODUTO(PR.Itens[I]).PESOPRODUTO.asString + ';' +
                TPRODUTO(PR.Itens[I]).QUANTIDADECAIXASALTURAPALET.asString + ';' +
                TPRODUTO(PR.Itens[I]).QUANTIDADESCAIXASLASTROPALET.asString + ';' +
                TPRODUTO(PR.Itens[I]).ALIQUOTAIPI.asString + ';' +
                TPRODUTO(PR.Itens[I]).CLASSIFICACAOFISCAL.asString + ';' +
                TPRODUTO(PR.Itens[I]).CATEGORIAPRODUTO.asString + ';'
              );

              PR.ID.Value           := TPRODUTO(PR.Itens[I]).ID.Value;
              PR.STATUS.Value       := 1;
              PR.ID_ARQUIVO.Value   := AFTP;
              PR.Update;
            end;
            SaveLog('Passou do for');
            if Lista.Count > 0 then begin
              SaveLog('Tem algo na lista tio');
              Lista.SaveToFile(DirArquivosFTP + 'PROD' + IntToStr(AFTP) + '.txt');
              SaveLog('passou do salvar');
            end;
          finally
            FreeAndNil(Lista);
          end;
        end;
      end;
      Con.Commit;

      SaveLog('antes da conexao');

      FTP := TConexaoFTP.Create;
      try
        FTP.EnviarProdutos;
      finally
        FreeAndNil(FTP);
      end;
      SaveLog('depois da conexao');

    except
      on E : Exception do begin
        Con.Rollback;
        SaveLog('Erro ao Enviar Produtos : ' + E.Message);
      end;
    end;
  finally
    SaveLog('free');
    FreeAndNil(PR);
    FreeAndNil(Con);
  end;
end;

procedure TfrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Timer1.Enabled := False;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
var
 Con : TFWConnection;
begin
  CONFIG_LOCAL.DirLog  := GetCurrentDir + '\Logs\';
  SaveLog('Serviço iniciado!');
  try

    ImageList1.GetBitmap(0, btIniciar.Glyph);
    btIniciar.Caption := 'Iniciar Leitura';

    CarregarConexaoBD;

    CarregarConfigLocal;

    CON   := TFWConnection.Create;
    try
      SaveLog('Conectou no Banco de dados!');
    finally
      FreeAndNil(CON);
    end;
  except
    on E : Exception do
      SaveLog('Erro ao iniciar Aplicativo: ' + E.Message);
  end;
end;

procedure TfrmPrincipal.IniciarPararLeitura;
begin
  Timer1.Enabled := not Timer1.Enabled;

  if Timer1.Enabled then begin
    btIniciar.Glyph := nil;
    ImageList1.GetBitmap(1, btIniciar.Glyph);
    btIniciar.Caption := 'Parar Leitura';
  end else begin
    btIniciar.Glyph := nil;
    ImageList1.GetBitmap(0, btIniciar.Glyph);
    btIniciar.Caption := 'Iniciar Leitura';
  end;
end;

procedure TfrmPrincipal.SaveLog(Texto: String);
var
  ArquivoLog : TextFile;
  Caminho : string;
begin

  Caminho := CONFIG_LOCAL.DirLog + FormatDateTime('yyyymmdd', Now) + '.txt';

  if not DirectoryExists(CONFIG_LOCAL.DirLog) then
    ForceDirectories(CONFIG_LOCAL.DirLog);

  AssignFile(ArquivoLog, Caminho);

  if FileExists(Caminho) then
    Append(ArquivoLog)
  else
    Rewrite(ArquivoLog);

  try
    Writeln(ArquivoLog, DateTimeToStr(Now) + ' ' + Texto)
  finally
    CloseFile(ArquivoLog);
  end;
end;

procedure TfrmPrincipal.Timer1Timer(Sender: TObject);
begin
  SaveLog('Início do Execute do Timmer');
  try
    try
      SaveLog('Enviar Produtos');
      EnviaProdutos;
      SaveLog('Enviar NFs');
      EnviaNotasFiscais;
      SaveLog('Buscar CONF');
      BuscaCONF;
      SaveLog('Enviar Pedidos');
      EnviaPedidos;
      SaveLog('Buscar MDD');
      BuscaMDD;
      SaveLog('Antes do ProcessRequest');
    except
     on E : Exception do
       SaveLog('Ocorreu algum erro na execução do processo no Timmer! Erro: ' + E.Message);
    end;
    SaveLog('Sleep');
  finally
    IniciarPararLeitura;
    SaveLog('Final do Execute do Timmer');
  end;
end;

end.
