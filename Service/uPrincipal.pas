unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs;

type
  TServiceConectorE10 = class(TService)
    procedure ServiceExecute(Sender: TService);
  private
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
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

function TServiceConectorE10.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TServiceConectorE10.ServiceExecute(Sender: TService);
begin
  while Self.Terminated do begin
    ServiceThread.ProcessRequests(False);
  end;
end;

end.
