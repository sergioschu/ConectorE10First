unit uThreadIntegracaoWS;

interface

uses
  System.Classes, Winapi.ActiveX;

type
  ThreadIntegracaoWS = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
    procedure TrataWSFirst;
    procedure TrataWSKPL;
  end;

implementation

uses
  uConstantes,
  uFuncoes,
  uFuncoesWSFirst,
  System.SysUtils,
  uConexaoFirst;

{ ThreadIntegracaoWS }

procedure ThreadIntegracaoWS.Execute;
begin

  while not Terminated do begin

    Sleep(CONFIG_LOCAL.Sleep * 1000);

    TrataWSFirst;

    TrataWSKPL;

  end;
end;

procedure ThreadIntegracaoWS.TrataWSFirst;
begin

  EnviarProdutos;

end;

procedure ThreadIntegracaoWS.TrataWSKPL;
begin
  //Ainda não Implementado;
end;

end.
