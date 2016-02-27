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

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  ServiceConectorE10.Controller(CtrlCode);
end;

function TServiceConectorE10.EnviaPedidos: Boolean;
begin

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
    Log.Free;
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
begin
  Started := True;
  SaveLog('Serviço iniciado!');
end;

procedure TServiceConectorE10.ServiceStop(Sender: TService;
  var Stopped: Boolean);
begin
  Stopped     := True;
  SaveLog('Servico Parado!');
end;

end.
