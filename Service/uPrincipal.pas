unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, uFWConnection,
  IdExplicitTLSClientServerBase, IdFTP, Vcl.ExtCtrls, FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait, FireDAC.Stan.Intf, FireDAC.Comp.UI, System.Win.ComObj;

type
  TServiceConectorE10 = class(TService)
    Timer1: TTimer;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    procedure ServiceExecute(Sender: TService);
    procedure ServiceAfterInstall(Sender: TService);
    procedure ServicePause(Sender: TService; var Paused: Boolean);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceShutdown(Sender: TService);
    procedure ServiceAfterUninstall(Sender: TService);
    procedure ServiceContinue(Sender: TService; var Continued: Boolean);
    procedure Timer1Timer(Sender: TObject);
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
    if FindFirst(DirArquivosFTP + '*.txt', faAnyFile, search_rec) = 0 then begin
      SaveLog('Achou pelo menos 1!');
      SetLength(NOTAENTRADA, 0);
      try
        try
          repeat
            if (search_rec.Attr <> faDirectory) and (Pos('CONF', search_rec.Name) > 0) then begin
              Deletar                    := True;
              Lista                      := TStringList.Create;
              CONF                       := TStringList.Create;
              try
                CON.StartTransaction;
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
                  CON.Commit;
                except
                  on E : Exception do begin
                    CON.Rollback;
                    SaveLog('Erro ao bucar CONF: ' + E.Message);
                  end;
                end;
              finally
                FreeAndNil(CONF);
                FreeAndNil(Lista);
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
      finally
        FindClose(search_rec);
      end;
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

  try
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
              MDD.Delimiter       := ';';
              MDD.StrictDelimiter := True;
              SaveLog('Antes de Carregar o Arquivo!');
              Lista.LoadFromFile(DirArquivosFTP + search_rec.Name);
              SaveLog('Depois de Carregar o Arquivo!');
              if Lista.Count > 0 then begin
                SaveLog('Arquivo não esta Vazio!');
                for I := 0 to Pred(Lista.Count) do begin
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
                  end else SaveLog('Linha com tamanho inválido!');
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
              end else SaveLog('Arquivo Vazio!');
            finally
              FreeAndNil(Lista);
              FreeAndNil(MDD);
            end;
          end else SaveLog('Arquivo não é um MDD!');
        until (FindNext(search_rec) <> 0);
      finally
        FindClose(search_rec);
      end;
    end;
  except
    on E : Exception do
      SaveLog('Ocorreu algum erro ao verificar arquivos locais, Erro: ' + E.Message);
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
begin
  Timer1.Enabled := True;
  try
  while not Self.Terminated do
    ServiceThread.ProcessRequests(True);
  finally
    Timer1.Enabled := False;
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

procedure TServiceConectorE10.Timer1Timer(Sender: TObject);
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
    Sleep(CONFIG_LOCAL.Sleep);
  finally
    SaveLog('Final do Execute do Timmer');
  end;
end;

end.
