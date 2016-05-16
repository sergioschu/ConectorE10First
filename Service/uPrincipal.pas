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

  CON    := TFWConnection.Create;
  NF     := TNOTAFISCAL.Create(CON);
  NI     := TNOTAFISCALITENS.Create(CON);
  PR     := TPRODUTO.Create(CON);
  try
    if FindFirst(DirArquivosFTP + '*.*', faAnyFile, search_rec) = 0 then begin
      CON.StartTransaction;
      SaveLog('Achou pelo menos 1!');
      SetLength(NOTAENTRADA, 0);
      try
        repeat
          if (search_rec.Attr <> faDirectory) and (Pos('CONF', search_rec.Name) > 0) then begin
            Deletar                    := True;
            Lista                      := TStringList.Create;
            CONF                       := TStringList.Create;
            try
              Lista.LoadFromFile(DirArquivosFTP + search_rec.Name);
              for I := 0 to Pred(Lista.Count) do begin
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
              for I := Low(NOTAENTRADA) to High(NOTAENTRADA) do begin
                NF.ID.Value                      := NOTAENTRADA[I].ID;
                NF.DATA_RECEBIDO.Value           := Now;
                NF.STATUS.Value                  := 2;
                NF.Update;
              end;
              if Deletar then
                DeleteFile(DirArquivosFTP + search_rec.Name);
            except
              on E : Exception do begin
                CON.Rollback;
                SaveLog('Erro ao bucar CONF: ' + E.Message);
              end;
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
  Deletar,
  Achou       : Boolean;
  PEDIDOS     : array of TPEDIDOS;
  PEDIDOATUAL : TPEDIDOS;
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
            SetLength(PEDIDOS, 0);
            try
              Lista.LoadFromFile(DirArquivosFTP + search_rec.Name);
              Deletar               := True;
              for I := 0 to Pred(Lista.Count) do begin
                MDD.Delimiter       := ';';
                MDD.StrictDelimiter := True;
                MDD.DelimitedText   := Lista[I];
                if MDD.Count = 7 then begin
                  for J := Low(PEDIDOS) to High(PEDIDOS) do begin
                    if PEDIDOS[J].PEDIDO = MDD[2] then begin
                      PEDIDOATUAL := PEDIDOS[I];
                      Achou       := True;
                      Break;
                    end;
                  end;

                  if not Achou then begin
                    P.SelectList('pedido = ' + QuotedStr(MDD[0]) + ' and status <= 2');
                    if P.Count > 0 then begin
                      SetLength(PEDIDOS, Length(PEDIDOS) + 1);
                      PEDIDOS[High(PEDIDOS)].PEDIDO := TPEDIDO(P.Itens[0]).PEDIDO.Value;
                      PEDIDOS[High(PEDIDOS)].ID     := TPEDIDO(P.Itens[0]).ID.Value;

                      PEDIDOATUAL                   := PEDIDOS[High(PEDIDOS)];
                    end else begin
                      SaveLog('Pedido ' + MDD[0] + ' já recebido ou nao existe!');
                      Deletar                       := False;
                      Break;
                    end;
                  end;

                  PR.SelectList('codigoproduto = ' + QuotedStr(MDD[2]));
                  if PR.Count > 0 then begin
                    PI.SelectList('id_pedido = ' + IntToStr(PEDIDOATUAL.ID) + ' and id_produto = ' + TPRODUTO(PR.Itens[0]).ID.asString);
                    if PI.Count > 0 then begin
                      PI.ID.Value           := TPEDIDOITENS(PI.Itens[0]).ID.Value;
                      PI.RECEBIDO.Value     := True;
                      PI.Update;
                    end else begin
                      SaveLog('Nao achou o item ' + MDD[2] + ' do pedido!');
                      Deletar               := False;
                      Break;
                    end;
                  end else begin
                    SaveLog('Nao achou o produto ' + MDD[2] + '!');
                    Deletar                     := False;
                    Break;
                  end;
                end else begin
                  SaveLog('Arquivo invalido! ' + IntToStr(MDD.Count) + ' ' + MDD.Text);
                  Deletar                       := False;
                  Break;
                end;
              end;
              for I := Low(PEDIDOS) to High(PEDIDOS) do begin
                P.ID.Value                      := PEDIDOS[I].ID;
                P.STATUS.Value                  := 3;
                P.DATA_RECEBIDO.Value           := Now;
                P.Update;
              end;
              if Deletar then
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
        for I := 0 to Pred(P.Count) do begin
          AFTP       := BuscaNumeroArquivo(Con, 2);
          Lista.Clear;

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
          P.DATA_ENVIO.Value := Now;
          P.Update;
          if Lista.Count > 0 then begin
            if not DirectoryExists(DirArquivosFTP) then
              ForceDirectories(DirArquivosFTP);
            Lista.SaveToFile(DirArquivosFTP + 'SC' + IntToStr(AFTP) + '.txt');
          end;
        end;
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

function TServiceConectorE10.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TServiceConectorE10.ServiceAfterInstall(Sender: TService);
begin
  SaveLog('Serviço Instalado!');
end;

procedure TServiceConectorE10.ServiceAfterUninstall(Sender: TService);
begin
  SaveLog('Serviço Desinstalado!');
end;

procedure TServiceConectorE10.ServiceContinue(Sender: TService;
  var Continued: Boolean);
begin
  Continued   := True;
  SaveLog('Serviço Continuado');
end;

procedure TServiceConectorE10.ServiceExecute(Sender: TService);
var
  ConFTP : TConexaoFTP;
begin
  while not Self.Terminated do begin
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
    ServiceThread.ProcessRequests(False);
    SaveLog('Sleep');
    Sleep(CONFIG_LOCAL.Sleep);
  end;
end;

procedure TServiceConectorE10.ServicePause(Sender: TService;
  var Paused: Boolean);
begin
  Paused     := True;
  SaveLog('Serviço paralisado!');
end;

procedure TServiceConectorE10.ServiceShutdown(Sender: TService);
begin
  SaveLog('Serviço ShutDown!');
end;

procedure TServiceConectorE10.ServiceStart(Sender: TService;
  var Started: Boolean);
var
 Con : TFWConnection;
begin
  Started := True;
  SaveLog('Serviço iniciado!');
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
      SaveLog('Erro ao iniciar Serviço: ' + E.Message);
  end;
end;

procedure TServiceConectorE10.ServiceStop(Sender: TService;
  var Stopped: Boolean);
begin
  Stopped     := True;
  SaveLog('Servico Parado!');
end;

end.
