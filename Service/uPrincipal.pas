unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, uFWConnection,
  IdExplicitTLSClientServerBase, IdFTP;

type
  TServiceConectorE10 = class(TService)
    procedure ServiceExecute(Sender: TService);
    procedure ServiceAfterInstall(Sender: TService);
    procedure ServicePause(Sender: TService; var Paused: Boolean);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceShutdown(Sender: TService);
    procedure ServiceAfterUninstall(Sender: TService);
    procedure ServiceContinue(Sender: TService; var Continued: Boolean);
  private
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
    function EnviaPedidos : Boolean;
    function EnviaProdutos : Boolean;
    function EnviaNotasFiscais : Boolean;
    function BuscaMDD : Boolean;
    function BuscaCONF : Boolean;
    function BuscaNumeroArquivo(Con : TFWConnection; Tipo : Integer) : Integer;
    { Public declarations }
  end;

var
  ServiceConectorE10: TServiceConectorE10;

implementation
uses
  uFuncoes,
  uConstantes,
  uBeanPedido,
  uBeanPedidoItens,
  uBeanProduto,
  uConexaoFTP,
  uBeanArquivosFTP,
  uBeanNOTAFISCAL,
  uBeanNotaFiscalItens,
  uBeanTransportadoras;
{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  ServiceConectorE10.Controller(CtrlCode);
end;

function TServiceConectorE10.BuscaCONF: Boolean;
var
  search_rec  : TSearchRec;
  FTP         : TConexaoFTP;
  Lista       : TStringList;
  CONF        : TStringList;
  I,
  J           : Integer;
  CON         : TFWConnection;
  PR          : TPRODUTO;
  NF          : TNOTAFISCAL;
  NI          : TNOTAFISCALITENS;
begin
  SaveLog('antes da conexao com FTP');
  FTP   := TConexaoFTP.Create;
  try
    FTP.BuscaCONF;
  finally
    FreeAndNil(FTP);
  end;

  SaveLog('Passou da conexao com FTP');

  CON    := TFWConnection.Create;
  NF     := TNOTAFISCAL.Create(CON);
  NI     := TNOTAFISCALITENS.Create(CON);
  PR     := TPRODUTO.Create(CON);
  try
    if FindFirst(DirArquivosFTP + '*.*', faAnyFile, search_rec) = 0 then begin
      CON.StartTransaction;
      SaveLog('Achou pelo menos 1!');
      try
        repeat
          if (search_rec.Attr <> faDirectory) and (Pos('CONF', search_rec.Name) > 0) then begin
            Lista    := TStringList.Create;
            CONF     := TStringList.Create;
            try
              Lista.LoadFromFile(DirArquivosFTP + search_rec.Name);
              for I := 0 to Pred(Lista.Count) do begin
                CONF.Delimiter       := ';';
                CONF.StrictDelimiter := True;
                CONF.DelimitedText   := Lista[I];
                if CONF.Count = 10 then begin
                  SaveLog('arquivo valido!');
                  PR.SelectList('codigoproduto = ' + QuotedStr(CONF[5]));
                  if PR.Count > 0 then begin
                    NF.SelectList('documento = ' + CONF[0] + ' and serie = ' + CONF[1] + ' and cnpjcpf = ' + QuotedStr(CONF[2]));
                    if NF.Count > 0 then begin
                      NI.SelectList('id_notafiscal = ' + TNOTAFISCAL(NF.Itens[0]).ID.asString + ' and id_produto = ' + TPRODUTO(PR.Itens[0]).ID.asString);
                      if NI.Count > 0 then begin
                        NI.ID.Value                := TNOTAFISCALITENS(NI.Itens[0]).ID.Value;
                        NI.QUANTIDADEREC.Value     := FormataNumeros(CONF[8]);
                        NI.QUANTIDADEAVA.Value     := FormataNumeros(CONF[9]);
                        NI.Update;

                        NI.ID.Value                := TNOTAFISCALITENS(NI.Itens[0]).ID_NOTAFISCAL.Value;
                        NI.Update;

                        NF.ID.Value                := TNOTAFISCAL(NF.Itens[0]).ID.Value;
                        NF.STATUS.Value            := 2;
                        NF.Update;
                      end;
                    end;
                  end;
                end else SaveLog('registro invalido ' + IntToStr(CONF.Count) +'   ' + CONF.Text);
              end;
              DeleteFile(DirArquivosFTP + search_rec.Name);
            finally
              FreeAndNil(Lista);
              FreeAndNil(CONF);
            end;
          end;
        until FindNext(search_rec) <> 0;
        CON.Commit;
      except
        on E : Exception do begin
          CON.Rollback;
          SaveLog('Erro ao bucar CONF: ' + E.Message);
        end;
      end;
      FindClose(search_rec);
    end;

  finally
    FreeAndNil(PR);
    FreeAndNil(NI);
    FreeAndNil(NF);
    FreeAndNil(CON);
  end;
end;

function TServiceConectorE10.BuscaMDD: Boolean;
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
begin
  SaveLog('antes da conexao com FTP');
  FTP   := TConexaoFTP.Create;
  try
    FTP.BuscaMDD;
  finally
    FreeAndNil(FTP);
  end;

  SaveLog('Passou da conexao com FTP');

  CON    := TFWConnection.Create;
  P      := TPEDIDO.Create(CON);
  PR     := TPRODUTO.Create(CON);
  PI     := TPEDIDOITENS.Create(CON);
  try
    if FindFirst(DirArquivosFTP + '*.*', faAnyFile, search_rec) = 0 then begin
      SaveLog('Tem arquivo MDD para enviar');
      CON.StartTransaction;
      try
        repeat
          if (search_rec.Attr <> faDirectory) and (Pos('MDD', search_rec.Name) > 0) then begin
            Lista    := TStringList.Create;
            MDD      := TStringList.Create;
            try
              Lista.LoadFromFile(DirArquivosFTP + search_rec.Name);
              for I := 0 to Pred(Lista.Count) do begin
                MDD.Delimiter       := ';';
                MDD.StrictDelimiter := True;
                MDD.DelimitedText   := Lista[I];
                if MDD.Count = 7 then begin
                  PR.SelectList('codigoproduto = ' + QuotedStr(MDD[2]));
                  if PR.Count > 0 then begin
                    P.SelectList('pedido = ' + QuotedStr(MDD[0]));
                    if P.Count > 0 then begin
                      PI.SelectList('id_pedido = ' + TPEDIDO(P.Itens[0]).ID.asString + ' and id_produto = ' + TPRODUTO(PR.Itens[0]).ID.asString);
                      if PI.Count > 0 then begin
                        PI.ID.Value           := TPEDIDOITENS(PI.Itens[0]).ID.Value;
                        PI.RECEBIDO.Value     := True;
                        PI.Update;

                        P.ID.Value            := TPEDIDO(P.Itens[0]).ID.Value;
                        P.STATUS.Value        := 3;
                        P.Update;
                      end else SaveLog('Nao achou o item do pedido!');
                    end else SaveLog('Nao achou o pedido!');
                  end else SaveLog('Nao achou o produto!');
                end else SaveLog('Arquivo invalido! ' + IntToStr(MDD.Count) + ' ' + MDD.Text);
              end;
              DeleteFile(DirArquivosFTP + search_rec.Name);
            finally
              FreeAndNil(Lista);
              FreeAndNil(MDD);
            end;
          end;
        until FindNext(search_rec) <> 0;
        CON.Commit;
      except
        on E : Exception do begin
          CON.Rollback;
          SaveLog('Erro ao bucar MDD: ' + E.Message);
        end;
      end;
      FindClose(search_rec);
    end;
  finally
    FreeAndNil(PI);
    FreeAndNil(PR);
    FreeAndNil(P);
    FreeAndNil(CON);
  end;
end;

function TServiceConectorE10.BuscaNumeroArquivo(Con : TFWConnection; Tipo : Integer) : Integer;
var
  AF : TARQUIVOSFTP;
begin
  AF   := TARQUIVOSFTP.Create(Con);
  try
    AF.TIPO.Value       := Tipo;
    AF.DATAENVIO.Value  := Now;
    AF.Insert;

    Result := AF.ID.Value;
  finally
    FreeAndNil(AF);
  end;
end;

function TServiceConectorE10.EnviaNotasFiscais: Boolean;
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
                  FormataData(TNOTAFISCAL(NF.Itens[I]).DATAEMISSAO.Value) + ';' +
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

function TServiceConectorE10.EnviaPedidos: Boolean;
var
  Con     : TFWConnection;
  P       : TPEDIDO;
  PI      : TPEDIDOITENS;
  PR      : TPRODUTO;
  T       : TTRANSPORTADORA;
  Lista   : TStringList;
  I,
  J,
  AFTP    : Integer;
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
        AFTP       := BuscaNumeroArquivo(Con, 2);
        for I := 0 to Pred(P.Count) do begin
          T.SelectList('id = ' + TPEDIDO(P.Itens[I]).ID_TRANSPORTADORA.asString);
          if T.Count > 0 then begin
            PI.SelectList('id_pedido = ' + TPEDIDO(p.Itens[i]).ID.asString);
            if PI.Count > 0 then begin
              for J := 0 to Pred(PI.Count) do begin
                PR.SelectList('id = ' + TPEDIDOITENS(PI.Itens[J]).ID_PRODUTO.asString);
                if PR.Count > 0 then begin
                  Lista.Add(TTRANSPORTADORA(T.Itens[0]).CNPJ.asString + ';' +
                    TPEDIDO(P.Itens[I]).PEDIDO.asString + ';' +
                    TPEDIDO(P.Itens[I]).VIAGEM.asString + ';' +
                    TPEDIDO(P.Itens[I]).SEQUENCIA.asString + ';' +
                    TTRANSPORTADORA(T.Itens[0]).CNPJ.asString + ';' +
                    TPRODUTO(PR.Itens[0]).CODIGOPRODUTO.asString + ';' +
                    TPRODUTO(PR.Itens[0]).UNIDADEDEMEDIDA.asString + ';' +
                    TPEDIDOITENS(PI.Itens[J]).QUANTIDADE.asString + ';' +
                    TPEDIDOITENS(PI.Itens[J]).VALOR_UNITARIO.asString + ';' +
                    TPEDIDO(P.Itens[I]).DEST_CNPJ.asString + ';' +
                    TPEDIDO(P.Itens[I]).DEST_NOME.asString + ';' +
                    TPEDIDO(P.Itens[I]).DEST_ENDERECO.asString + ';' +
                    TPEDIDO(P.Itens[I]).DEST_COMPLEMENTO.asString + ';' +
                    TPEDIDO(P.Itens[I]).DEST_CEP.asString + ';' +
                    TPEDIDO(P.Itens[I]).DEST_MUNICIPIO.asString + ';'
                  );
                end;
              end;
            end;
          end;
          P.ID.Value         := TPEDIDO(P.Itens[I]).ID.Value;
          P.ID_ARQUIVO.Value := AFTP;
          P.STATUS.Value     := 2;
          P.Update;
        end;
      end;
      if Lista.Count > 0 then begin
        if not DirectoryExists(DirArquivosFTP) then
          ForceDirectories(DirArquivosFTP);
        Lista.SaveToFile(DirArquivosFTP + 'SC' + IntToStr(AFTP) + '.txt');
      end;

      FTP     := TConexaoFTP.Create;
      try
        FTP.EnviarPedidos;
      finally
        FreeAndNil(FTP);
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
end;

function TServiceConectorE10.EnviaProdutos: Boolean;
var
  Con     : TFWConnection;
  FTP     : TConexaoFTP;
  PR      : TPRODUTO;
  I,
  AFTP    : Integer;
  Lista   : TStringList;
begin
  Con := TFWConnection.Create;
  PR  := TPRODUTO.Create(Con);
  try
    Con.StartTransaction;
    try
      PR.SelectList('status = 0');
      if PR.Count > 0 then begin
        SaveLog('Tem produtos para exportar');
        AFTP         := BuscaNumeroArquivo(Con, 0);
        Lista        := TStringList.Create;
        try
          for I := 0 to Pred(PR.Count) do begin
            Lista.Add(TPRODUTO(PR.Itens[I]).CODIGOPRODUTO.asString + ';' +
              TPRODUTO(PR.Itens[I]).DESCRICAOREDUZIDA.asString + ';' +
              TPRODUTO(PR.Itens[I]).DESCRICAO.asString + ';' +
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
          if Lista.Count > 0 then begin
            SaveLog('Tem algo na lista tio');
            Lista.SaveToFile(DirArquivosFTP + 'PROD' + PR.ID_ARQUIVO.asString + '.txt');
          end;
        finally
          FreeAndNil(Lista);
        end;
      end;

      Con.Commit;

      FTP := TConexaoFTP.Create;
      try
        FTP.EnviarProdutos;
      finally
        FreeAndNil(FTP);
      end;

    except
      on E : Exception do begin
        Con.Rollback;
        SaveLog('Erro ao Enviar Produtos : ' + E.Message);
      end;
    end;
  finally
    FreeAndNil(PR);
    FreeAndNil(Con);
  end;
end;

function TServiceConectorE10.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TServiceConectorE10.ServiceAfterInstall(Sender: TService);
begin
  SaveLog('Servi�o Instalado!');
end;

procedure TServiceConectorE10.ServiceAfterUninstall(Sender: TService);
begin
  SaveLog('Servi�o Desinstalado!');
end;

procedure TServiceConectorE10.ServiceContinue(Sender: TService;
  var Continued: Boolean);
begin
  Continued   := True;
  SaveLog('Servi�o Continuado');
end;

procedure TServiceConectorE10.ServiceExecute(Sender: TService);
var
  ConFTP : TConexaoFTP;
begin
  while not Self.Terminated do begin
    SaveLog('Enviar Produtos');
    EnviaProdutos;
    ServiceThread.ProcessRequests(False);
    SaveLog('Enviar NFs');
    EnviaNotasFiscais;
    ServiceThread.ProcessRequests(False);
    SaveLog('Buscar CONF');
    BuscaCONF;
    ServiceThread.ProcessRequests(False);
    SaveLog('Enviar Pedidos');
    EnviaPedidos;
    ServiceThread.ProcessRequests(False);
    SaveLog('Buscar MDD');
    BuscaMDD;
    ServiceThread.ProcessRequests(False);
    SaveLog('ProcessRequests');
    SaveLog('Sleep');
    Sleep(CONFIG_LOCAL.Sleep);
  end;
end;

procedure TServiceConectorE10.ServicePause(Sender: TService;
  var Paused: Boolean);
begin
  Paused     := True;
  SaveLog('Servi�o paralisado!');
end;

procedure TServiceConectorE10.ServiceShutdown(Sender: TService);
begin
  SaveLog('Servi�o ShutDown!');
end;

procedure TServiceConectorE10.ServiceStart(Sender: TService;
  var Started: Boolean);
var
 Con : TFWConnection;
begin
  Started := True;
  SaveLog('Servi�o iniciado!');
  try
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
      SaveLog('Erro ao iniciar Servi�o: ' + E.Message);
  end;
end;

procedure TServiceConectorE10.ServiceStop(Sender: TService;
  var Stopped: Boolean);
begin
  Stopped     := True;
  SaveLog('Servico Parado!');
end;

end.
