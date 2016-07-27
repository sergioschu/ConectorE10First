unit uThreadIntegracaoWS;

interface

uses
  System.Classes;

type
  ThreadIntegracaoWS = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
    procedure TrataWSFirst;
    procedure TrataWSKPL;
    procedure BuscaToken;

  end;

implementation

uses
  uConstantes,
  uFuncoes,
  System.SysUtils,
  uConexaoFirst;

{ ThreadIntegracaoWS }

procedure ThreadIntegracaoWS.BuscaToken;
var
  WSFirst : TConexaoFirst;
begin

  if TOKEN_WS.STATUS_CODE = 200 then begin//SE FOR 200 APENAS PRECISA FAZER REFRESH

  end else begin
    WSFirst := TConexaoFirst.Create(False, CONFIG_LOCAL.ID_DEPOSIT_FIRST, CONFIG_LOCAL.SECRET_KEY_FIRST);
    try
      TOKEN_WS.TOKEN        := WSFirst.getToken;
      TOKEN_WS.STATUS_CODE  := 200;
    finally
      FreeAndNil(WSFirst);
    end;
  end;

end;

procedure ThreadIntegracaoWS.Execute;
begin

  while not Terminated do begin

    Sleep(1000);

    TrataWSFirst;

    TrataWSKPL;

  end;
end;

procedure ThreadIntegracaoWS.TrataWSFirst;
begin

  BuscaToken;

  if TOKEN_WS.STATUS_CODE = 200 then begin //Se tem Token trabalha com o WS First

  end;

end;

procedure ThreadIntegracaoWS.TrataWSKPL;
begin
  //Ainda não Implementado;
end;

end.
