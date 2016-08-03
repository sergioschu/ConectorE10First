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
    procedure TrataWS;
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

    TrataWS;

  end;
end;

procedure ThreadIntegracaoWS.TrataWS;
begin

  EnviarProdutos;

  EnviarPedidos;

  EnviarNFEntrada;

  BuscarMDD;

  BuscarCONF;
end;

end.
