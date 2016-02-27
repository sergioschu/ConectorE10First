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
  uBeanProduto;
{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  ServiceConectorE10.Controller(CtrlCode);
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
begin
  Con    := TFWConnection.Create;
  P      := TPEDIDO.Create(Con);
  PI     := TPEDIDOITENS.Create(Con);
  PR     := TPRODUTO.Create(Con);
  Lista  := TStringList.Create;
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
begin
  while not Self.Terminated do begin
    SaveLog('Serviço em Execução!');
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
