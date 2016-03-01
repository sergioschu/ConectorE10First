unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
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
    function BuscaMDD : Boolean;
    function BuscaCONF : Boolean;
    procedure SaveLog(Msg: String);
    { Public declarations }
  end;

var
  ServiceConectorE10: TServiceConectorE10;

implementation
uses
  uFuncoes,
  uConstantes,
  uFWConnection,
  uBeanPedido,
  uBeanPedidoItens,
  uBeanProduto,
  uConexaoFTP;
{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  ServiceConectorE10.Controller(CtrlCode);
end;

function TServiceConectorE10.BuscaCONF: Boolean;
begin
//implementar
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
  PI          : TPEDIDOITENS;
begin
  FTP   := TConexaoFTP.Create;
  try
    FTP.BuscaMDD;
  finally
    FreeAndNil(FTP);
  end;

  CON    := TFWConnection.Create;
  PR     := TPRODUTO.Create(CON);
  PI     := TPEDIDOITENS.Create(CON);
  try
    if FindFirst(DirArquivosFTP + '*.*', faAnyFile, search_rec) = 0 then begin
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
                  PR.SelectList('codigoproduto = ' + MDD[2]);
                  if PR.Count > 0 then begin
                    PI.SelectList('id_pedido = ' + MDD[0] + ' and id_produto = ' + TPRODUTO(PR.Itens[0]).ID.asString);
                    if PI.Count > 0 then begin
                      PI.ID.Value           := TPEDIDOITENS(PI.Itens[0]).ID.Value;
                      PI.RECEBIDO.Value     := True;
                      PI.Update;
                    end;
                  end;
                end;
              end;
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
    FreeAndNil(CON);
  end;
end;

function TServiceConectorE10.EnviaPedidos: Boolean;
var
  Con     : TFWConnection;
  P       : TPEDIDO;
  PI      : TPEDIDOITENS;
  PR      : TPRODUTO;
  Lista   : TStringList;
  I,
  J       : Integer;
  FTP     : TConexaoFTP;
begin
  Con    := TFWConnection.Create;
  P      := TPEDIDO.Create(Con);
  PI     := TPEDIDOITENS.Create(Con);
  PR     := TPRODUTO.Create(Con);
  Lista  := TStringList.Create;
  try
    Con.StartTransaction;
    try
      P.SelectList(' not enviado');
      if P.Count > 0 then begin
        for I := 0 to Pred(P.Count) do begin
          PI.SelectList('id_pedido = ' + TPEDIDO(p.Itens[i]).ID.asString);
          if PI.Count > 0 then begin
            for J := 0 to Pred(PI.Count) do begin
              PR.SelectList('id_produto = ' + TPEDIDOITENS(PI.Itens[J]).ID_PRODUTO.asString);
              if PR.Count > 0 then begin
                Lista.Add(TPEDIDO(P.Itens[I]).TRANSP_CNPJ.asString + ';' +
                  TPEDIDO(P.Itens[I]).PEDIDO.asString + ';' +
                  TPEDIDO(P.Itens[I]).VIAGEM.asString + ';' +
                  TPEDIDO(P.Itens[I]).SEQUENCIA.asString + ';' +
                  TPEDIDO(P.Itens[I]).TRANSP_CNPJ.asString + ';' +
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
          P.ID.Value       := TPEDIDO(P.Itens[I]).ID.Value;
          P.ENVIADO.Value  := True;
          P.Update;
        end;
      end;
      if Lista.Count > 0 then begin
        if not DirectoryExists(DirArquivosFTP) then
          ForceDirectories(DirArquivosFTP);
        Lista.SaveToFile(DirArquivosFTP + 'SC.txt');
        FTP     := TConexaoFTP.Create;
        try
          FTP.EnviarPedidos;
        finally
          FreeAndNil(FTP);
        end;
      end;
      Con.Commit;
    except
      on E : Exception do begin
        Con.Rollback;
        SaveLog('Erro ao Enviar Pedido : ' + E.Message);
        Exit;
      end;
    end;

  finally
    FreeAndNil(PR);
    FreeAndNil(PI);
    FreeAndNil(P);
    Freeandnil(Con);
    FreeAndNil(Lista);
  end;
end;

function TServiceConectorE10.EnviaProdutos: Boolean;
var
  Con     : TFWConnection;
  FTP     : TConexaoFTP;
  PR      : TPRODUTO;
  I       : Integer;
  Lista   : TStringList;
begin
  Con := TFWConnection.Create;
  PR  := TPRODUTO.Create(Con);
  try
    Con.StartTransaction;
    try
      PR.SelectList('not status');
      if PR.Count > 0 then begin
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

            PR.ID.Value       := TPRODUTO(PR.Itens[I]).ID.Value;
            PR.STATUS.Value   := True;
            PR.Update;
          end;
          if Lista.Count > 0 then begin
            Lista.SaveToFile(DirArquivosFTP + 'PROD.txt');
            FTP := TConexaoFTP.Create;
            try
              FTP.EnviarProdutos;
            finally
              FreeAndNil(FTP);
            end;
          end;
        finally
          FreeAndNil(Lista);
        end;
      end;
      Con.Commit;
    except
      on E : Exception do begin
        Con.Rollback;
        SaveLog('Erro ao Enviar Produtos : ' + E.Message);
        Exit;
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

procedure TServiceConectorE10.SaveLog(Msg: String);
Var
  Log : TStringList;
  ArqLog  : String;
begin
  ArqLog  := 'C:\ConectorE10First\Log.txt';
  try
    Log := TStringList.Create;
    try
      if FileExists(ArqLog) then
        Log.LoadFromFile(ArqLog);
      Log.Add(DateTimeToStr(Now) + ' ' + Msg)

    except
      on E : Exception do
        Log.Add('Erro.: ' + E.Message);

    end;
  finally
    Log.SaveToFile(ArqLog);
    FreeAndNil(Log);
  end;
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
//    SaveLog('Serviço em Execução!');
    BuscaMDD;
    ServiceThread.ProcessRequests(False);
    Sleep(5000);
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

  CarregarConexaoBD;

  CON   := TFWConnection.Create;
  try
    SaveLog('Conectou no Banco de dados!');
  finally
    FreeAndNil(CON);
  end;
end;

procedure TServiceConectorE10.ServiceStop(Sender: TService;
  var Stopped: Boolean);
begin
  Stopped     := True;
  SaveLog('Servico Parado!');
end;

end.
