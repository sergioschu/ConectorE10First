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
    constructor Create(Producao : Boolean); overload;
    destructor Destroy; override;

    function getToken : string;
    procedure Refresh;
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
uses
  uConstantes,
  uFuncoes;
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
  Request.Params.ParameterByIndex(2).Value        := JsonValue.ToJSON;
  Request.Params.ParameterByIndex(2).ContentType  := ctAPPLICATION_JSON;

  Result := False;
  Request.Timeout := 60000;
  try
    Request.Execute;
  except
    on E : Exception do begin
      ShowMessage(e.Message + sLineBreak + Response.JSONText);
    end;
  end;
//  Response.JSONText;

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

  if CONFIG_LOCAL.ID_DEPOSIT_FIRST <> EmptyStr then
    ID := CONFIG_LOCAL.ID_DEPOSIT_FIRST;
  if CONFIG_LOCAL.SECRET_KEY_FIRST <> EmptyStr then
    Key_Secret := CONFIG_LOCAL.SECRET_KEY_FIRST;
  if TOKEN_WS.TOKEN <> EmptyStr then begin
    if TOKEN_WS.DH_LOGIN + TOKEN_WS.SESSION_EXPIRES <= Now then
      Refresh;
    Token := TOKEN_WS.TOKEN;
  end else
    getToken;
end;

constructor TConexaoFirst.Create(Producao: Boolean);
begin
  if Producao then
    URLPrincipal := 'http://api.firstlog.com.br/'
  else
    URLPrincipal := 'http://apiteste.firstlog.com.br/';
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
  Client.BaseURL      := URLPrincipal;
  Request.Method      := rmPUT;
  Request.Resource    := 'carga/solicitar?deposit={deposit}&token={token}';

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
  Request.Params.ParameterByIndex(2).Value        := JsonValue.ToJSON;
  Request.Params.ParameterByIndex(2).ContentType  := ctAPPLICATION_JSON;

  Result := False;
  Request.Timeout := 60000;
  try
    Request.Execute;
  except
    on E : Exception do begin
      ShowMessage(e.Message + sLineBreak + Response.JSONText);
    end;
  end;

  ShowMessage(Response.JSONValue.Value);

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
  J: Integer;
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
          if Pair2.JsonString.Value = 'token' then
            TOKEN_WS.TOKEN          := Pair2.JsonValue.Value;
          if Pair2.JsonString.Value = 'refresh_token' then
            TOKEN_WS.REFRESH_TOKEN  := Pair2.JsonValue.Value;
          if Pair2.JsonString.Value = 'time' then
            TOKEN_WS.DH_LOGIN       := StrFirstToDateTime(Pair2.JsonValue.Value);
          if Pair2.JsonString.Value = 'session_expires' then
            TOKEN_WS.SESSION_EXPIRES:= StrToInt(Pair2.JsonValue.Value);
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
  Request.Params.ParameterByIndex(2).Value        := JsonValue.ToJSON;
  Request.Params.ParameterByIndex(2).ContentType  := ctAPPLICATION_JSON;

  Result := False;
  Request.Timeout := 60000;
  try
    Request.Execute;
  except
    on E : Exception do begin
      ShowMessage(e.Message + sLineBreak + Response.JSONText);
    end;
  end;
  Exit(Response.StatusCode = 200);
end;

procedure TConexaoFirst.Refresh;
var
  Pair1,
  Pair2 : TJSONPair;
  J: Integer;
  JsonValue : TJSONObject;
begin
  JsonValue := TJSONObject.Create;
  try
    JsonValue.AddPair(TJSONPair.Create('refresh_token', TOKEN_WS.REFRESH_TOKEN));
    Client.BaseURL    := URLPrincipal + 'refresh';
    Request.Method    := rmPOST;
    Request.Resource  := '{id_deposit}';

    Request.Params.Clear;
    Request.Params.AddItem;
    Request.Params.ParameterByIndex(0).Kind         := pkURLSEGMENT;
    Request.Params.ParameterByIndex(0).name         := 'id_deposit';
    Request.Params.ParameterByIndex(0).Value        := ID;
    Request.Params.AddItem;
    Request.Params.ParameterByIndex(1).Kind         := pkREQUESTBODY;
    Request.Params.ParameterByIndex(1).name         := 'refresh';
    Request.Params.ParameterByIndex(1).Value        := JsonValue.ToJSON;
    Request.Params.ParameterByIndex(1).ContentType  := ctAPPLICATION_JSON;

    Request.Execute;

    if Response.StatusCode = 200 then begin
      for Pair1 in TJSONObject(Response.JSONValue) do begin
        if Pair1.JsonString.Value = 'body' then begin
          for Pair2 in TJSONObject(Pair1.JsonValue) do begin
            if Pair2.JsonString.Value = 'token' then
              TOKEN_WS.TOKEN          := Pair2.JsonValue.Value;
            if Pair2.JsonString.Value = 'refresh_token' then
              TOKEN_WS.REFRESH_TOKEN  := Pair2.JsonValue.Value;
            if Pair2.JsonString.Value = 'time' then
              TOKEN_WS.DH_LOGIN       := StrFirstToDateTime(Pair2.JsonValue.Value);
            if Pair2.JsonString.Value = 'session_expires' then
              TOKEN_WS.SESSION_EXPIRES:= StrToInt(Pair2.JsonValue.Value);
          end;
        end;
      end;
    end;
  finally

  end;
end;

end.
