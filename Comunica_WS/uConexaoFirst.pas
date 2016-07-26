unit uConexaoFirst;

interface
uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IPPeerClient, REST.Client,
  Data.Bind.Components, Data.Bind.ObjectScope, Vcl.StdCtrls, System.JSON,
  REST.Authenticator.Simple, REST.Types;

type
    TConexaoFirst = class
  private
    FRequest: TRESTRequest;
    FResponse: TRESTResponse;
    FClient: TRESTClient;
    FURLPrincipal: string;
    FID: string;
    FKey_Secret: string;
    FToken: string;
    procedure SetClient(const Value: TRESTClient);
    procedure SetRequest(const Value: TRESTRequest);
    procedure SetResponse(const Value: TRESTResponse);
    procedure SetURLPrincipal(const Value: string);

    procedure SetID(const Value: string);
    procedure SetKey_Secret(const Value: string);
    procedure SetToken(const Value: string);
  public
    constructor Create(); overload;
    constructor Create(Producao : Boolean; ID_Empresa : String; Secret_Key : String); overload;
    destructor Destroy; override;

    function getToken : string;
    function CadastrarProdutos(JsonValue : TJSONValue) : Boolean;
    function NFEntrada(JsonValue : TJSONValue) : Boolean;
    function EnviarPedidos(JsonValue : TJSONValue) : Boolean;
  published
    property Client    : TRESTClient read FClient write SetClient;
    property Request   : TRESTRequest read FRequest write SetRequest;
    property Response  : TRESTResponse read FResponse write SetResponse;
    property URLPrincipal : string read FURLPrincipal write SetURLPrincipal;
    property ID : string read FID write SetID;
    property Key_Secret : string read FKey_Secret write SetKey_Secret;
    property Token : string read FToken write SetToken;
end;

implementation

{ TConexaoFirst }

function TConexaoFirst.CadastrarProdutos(JsonValue: TJSONValue): Boolean;
var
  Pair1,
  Pair2 : TJSONPair;
begin
  Client.BaseURL    := URLPrincipal;
  Request.Method    := rmPUT;
  Request.Resource  := 'produtos/cadastrar?deposit={deposit}&token={token}';

  Request.Params.Clear;
  Request.Params.AddItem;
  Request.Params.ParameterByIndex(0).Kind         := pkURLSEGMENT;
  Request.Params.ParameterByIndex(0).name         := 'deposit';
  Request.Params.ParameterByIndex(0).Value        := ID;
  Request.Params.AddItem;
  Request.Params.ParameterByIndex(1).Kind         := pkURLSEGMENT;
  Request.Params.ParameterByIndex(1).name         := 'token';
  Request.Params.ParameterByIndex(1).Value        := Token;
  Request.Params.AddItem;
  Request.Params.ParameterByIndex(2).Kind         := pkREQUESTBODY;
  Request.Params.ParameterByIndex(2).name         := 'produtos';
  Request.Params.ParameterByIndex(2).Value        := JsonValue.Value;

  Result := False;
  Request.Execute;

  Exit(Response.StatusCode = 200);
end;

constructor TConexaoFirst.Create;
begin
  inherited;
  Client            := TRESTClient.Create(nil);
  Request           := TRESTRequest.Create(nil);
  Response          := TRESTResponse.Create(nil);

  Request.Client    := Client;
  Request.Response  := Response;
end;

constructor TConexaoFirst.Create(Producao: Boolean; ID_Empresa: String; Secret_Key : String);
begin
  if Producao then
    URLPrincipal := 'http://api.firstlog.com.br/'
  else
    URLPrincipal := 'http://apiteste.firstlog.com.br/';
  if ID_Empresa <> EmptyStr then
    ID := ID_Empresa;
  if Secret_Key <> EmptyStr then
    Key_Secret := Secret_Key;
  Create;
end;

destructor TConexaoFirst.Destroy;
begin
  FreeAndNil(FClient);
  FreeAndNil(FRequest);
  FreeAndNil(FResponse);
  inherited;
end;

function TConexaoFirst.EnviarPedidos(JsonValue: TJSONValue): Boolean;
var
  Pair1,
  Pair2 : TJSONPair;
begin
  Client.BaseURL    := URLPrincipal;
  Request.Method    := rmPUT;
  Request.Resource  := 'carga/solicitar?deposit={deposit}&token={token}';

  Request.Params.Clear;
  Request.Params.AddItem;
  Request.Params.ParameterByIndex(0).Kind         := pkURLSEGMENT;
  Request.Params.ParameterByIndex(0).name         := 'deposit';
  Request.Params.ParameterByIndex(0).Value        := ID;
  Request.Params.AddItem;
  Request.Params.ParameterByIndex(1).Kind         := pkURLSEGMENT;
  Request.Params.ParameterByIndex(1).name         := 'token';
  Request.Params.ParameterByIndex(1).Value        := Token;
  Request.Params.AddItem;
  Request.Params.ParameterByIndex(2).Kind         := pkREQUESTBODY;
  Request.Params.ParameterByIndex(2).name         := 'pedidos';
  Request.Params.ParameterByIndex(2).Value        := JsonValue.Value;

  Result := False;
  Request.Execute;

//  ShowMessage(Response.JSONText);

  Exit(Response.StatusCode = 200);
end;

procedure TConexaoFirst.SetClient(const Value: TRESTClient);
begin
  FClient := Value;
end;

procedure TConexaoFirst.SetID(const Value: string);
begin
  FID := Value;
end;

procedure TConexaoFirst.SetKey_Secret(const Value: string);
begin
  FKey_Secret := Value;
end;

procedure TConexaoFirst.SetRequest(const Value: TRESTRequest);
begin
  FRequest := Value;
end;

procedure TConexaoFirst.SetResponse(const Value: TRESTResponse);
begin
  FResponse := Value;
end;

procedure TConexaoFirst.SetToken(const Value: string);
begin
  FToken := Value;
end;

procedure TConexaoFirst.SetURLPrincipal(const Value: string);
begin
  FURLPrincipal := Value;
end;

function TConexaoFirst.getToken: string;
var
  Pair1,
  Pair2 : TJSONPair;
begin
  Client.BaseURL    := URLPrincipal + 'auth';
  Request.Method    := rmPOST;
  Request.Resource  := '{id_deposit}';

  Request.Params.Clear;
  Request.Params.AddItem;
  Request.Params.ParameterByIndex(0).Kind   := pkURLSEGMENT;
  Request.Params.ParameterByIndex(0).name   := 'id_deposit';
  Request.Params.ParameterByIndex(0).Value  := ID;
  Request.Params.AddItem;
  Request.Params.ParameterByIndex(1).Kind   := pkGETorPOST;
  Request.Params.ParameterByIndex(1).name   := 'secret_key';
  Request.Params.ParameterByIndex(1).Value  := Key_Secret;

  Result := EmptyStr;
  Request.Execute;

  if Response.StatusCode = 200 then begin
    for Pair1 in TJSONObject(Response.JSONValue) do begin
      if Pair1.JsonString.Value = 'body' then begin
        for Pair2 in TJSONObject(Pair1.JsonValue) do begin
          if Pair2.JsonString.Value = 'token' then begin
            Token  := Pair2.JsonValue.Value;
            Result := Pair2.JsonValue.Value;
            Break;
          end;
        end;
      end;
    end;
  end;
end;

function TConexaoFirst.NFEntrada(JsonValue: TJSONValue): Boolean;
var
  Pair1,
  Pair2 : TJSONPair;
begin
  Client.BaseURL    := URLPrincipal;
  Request.Method    := rmPUT;
  Request.Resource  := 'armazem/entrada?deposit={deposit}&token={token}';

  Request.Params.Clear;
  Request.Params.AddItem;
  Request.Params.ParameterByIndex(0).Kind         := pkURLSEGMENT;
  Request.Params.ParameterByIndex(0).name         := 'deposit';
  Request.Params.ParameterByIndex(0).Value        := ID;
  Request.Params.AddItem;
  Request.Params.ParameterByIndex(1).Kind         := pkURLSEGMENT;
  Request.Params.ParameterByIndex(1).name         := 'token';
  Request.Params.ParameterByIndex(1).Value        := Token;
  Request.Params.AddItem;
  Request.Params.ParameterByIndex(2).Kind         := pkREQUESTBODY;
  Request.Params.ParameterByIndex(2).name         := 'notas';
  Request.Params.ParameterByIndex(2).Value        := JsonValue.Value;

  Result := False;
  Request.Execute;

  Exit(Response.StatusCode = 200);
end;

end.
