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
    procedure SetClient(const Value: TRESTClient);
    procedure SetRequest(const Value: TRESTRequest);
    procedure SetResponse(const Value: TRESTResponse);
    procedure SetURLPrincipal(const Value: string);
  public
    constructor Create; overload;
    destructor Destroy; override;

    procedure getToken;
    procedure Refresh;
    function CadastrarProdutos(JsonValue : TJSONValue; out Status : Integer; out Mensagem : String) : Boolean;
    function NFEntrada(JsonValue : TJSONValue; out Status : Integer; out Mensagem : String) : Boolean;
    function EnviarPedidos(JsonValue : TJSONValue; out Status : Integer; out Mensagem : String) : Boolean;
  published
    property Client    : TRESTClient read FClient write SetClient;
    property Request   : TRESTRequest read FRequest write SetRequest;
    property Response  : TRESTResponse read FResponse write SetResponse;
    property URLPrincipal : string read FURLPrincipal write SetURLPrincipal;
end;

implementation
uses
  uConstantes,
  uFuncoes;
{ TConexaoFirst }

function TConexaoFirst.CadastrarProdutos(JsonValue: TJSONValue; out Status : Integer; out Mensagem : String): Boolean;
var
  Pair : TJSONPair;
begin
  Status   := 999;
  Mensagem := 'Montando dados da requisição!';

  Client.BaseURL    := URLPrincipal;
  Request.Method    := rmPUT;
  Request.Resource  := 'produtos/cadastrar?deposit={deposit}&token={token}';
  Request.Params.Clear;
  Request.Params.AddItem;
  Request.Params.ParameterByIndex(0).Kind         := pkURLSEGMENT;
  Request.Params.ParameterByIndex(0).name         := 'deposit';
  Request.Params.ParameterByIndex(0).Value        := TOKEN_WS.USER_ID;
  Request.Params.AddItem;
  Request.Params.ParameterByIndex(1).Kind         := pkURLSEGMENT;
  Request.Params.ParameterByIndex(1).name         := 'token';
  Request.Params.ParameterByIndex(1).Value        := TOKEN_WS.TOKEN;
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
      SaveLog('Erro na Função CadastrarProdutos, ' + E.Message + sLineBreak + Response.JSONText);
    end;
  end;

  if Response.JSONText <> EmptyStr then begin
    if Response.JSONValue is TJSONObject then begin
      for Pair in TJSONObject(Response.JSONValue) do begin
        if Pair.JsonString.Value = 'status' then
          Status := TJSONNumber(Pair.JsonValue).AsInt
        else if Pair.JsonString.Value = 'body' then
          Mensagem := Pair.JsonValue.Value;
      end;
    end;
  end;

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

  if Producao then
    URLPrincipal := 'http://api.firstlog.com.br/'
  else
    URLPrincipal := 'http://apiteste.firstlog.com.br/';

  getToken;

end;

destructor TConexaoFirst.Destroy;
begin
  FreeAndNil(FClient);
  FreeAndNil(FRequest);
  FreeAndNil(FResponse);
  inherited;
end;

function TConexaoFirst.EnviarPedidos(JsonValue: TJSONValue; out Status : Integer; out Mensagem : String): Boolean;
var
  Pair : TJSONPair;
begin
  Status   := 999;
  Mensagem := 'Montando dados da requisição!';

  Client.BaseURL      := URLPrincipal;
  Request.Method      := rmPUT;
  Request.Resource    := 'carga/solicitar?deposit={deposit}&token={token}';

  Request.Params.Clear;
  Request.Params.AddItem;
  Request.Params.ParameterByIndex(0).Kind         := pkURLSEGMENT;
  Request.Params.ParameterByIndex(0).name         := 'deposit';
  Request.Params.ParameterByIndex(0).Value        := TOKEN_WS.USER_ID;
  Request.Params.AddItem;
  Request.Params.ParameterByIndex(1).Kind         := pkURLSEGMENT;
  Request.Params.ParameterByIndex(1).name         := 'token';
  Request.Params.ParameterByIndex(1).Value        := TOKEN_WS.TOKEN;
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
    on E : Exception do
      SaveLog('Erro na Função EnviarPedidos, ' + E.Message + sLineBreak + Response.JSONText);
  end;

  if Response.JSONText <> EmptyStr then begin
    if Response.JSONValue is TJSONObject then begin
      for Pair in TJSONObject(Response.JSONValue) do begin
        if Pair.JsonString.Value = 'status' then
          Status := TJSONNumber(Pair.JsonValue).AsInt
        else if Pair.JsonString.Value = 'body' then
          Mensagem := Pair.JsonValue.Value;
      end;
    end;
  end;

  Exit(Response.StatusCode = 200);

end;

procedure TConexaoFirst.SetClient(const Value: TRESTClient);
begin
  FClient := Value;
end;

procedure TConexaoFirst.SetRequest(const Value: TRESTRequest);
begin
  FRequest := Value;
end;

procedure TConexaoFirst.SetResponse(const Value: TRESTResponse);
begin
  FResponse := Value;
end;

procedure TConexaoFirst.SetURLPrincipal(const Value: string);
begin
  FURLPrincipal := Value;
end;

procedure TConexaoFirst.getToken;
var
  Pair1,
  Pair2 : TJSONPair;
  J: Integer;
begin

  if Length(Trim(CONFIG_LOCAL.ID_DEPOSIT_FIRST)) = 0 then begin
    SaveLog('ID_DEPOSIT_FIRST Não informado nas Configurações, Verifique!');
    Exit;
  end;

  if Length(Trim(CONFIG_LOCAL.SECRET_KEY_FIRST)) = 0 then begin
    SaveLog('SECRET_KEY_FIRST Não informado nas Configurações, Verifique!');
    Exit;
  end;

  //Se Não tem Token ainda busca o Token, senão apenas faz o refresh
  if Length(Trim(TOKEN_WS.TOKEN)) = 0 then begin

    TOKEN_WS.STATUS_CODE  := 0;
    TOKEN_WS.USER_ID      := CONFIG_LOCAL.ID_DEPOSIT_FIRST;

    try

      Client.BaseURL      := URLPrincipal + 'auth';
      Request.Method      := rmPOST;
      Request.Resource    := '{id_deposit}';

      Request.Params.Clear;
      Request.Params.AddItem;
      Request.Params.ParameterByIndex(0).Kind   := pkURLSEGMENT;
      Request.Params.ParameterByIndex(0).name   := 'id_deposit';
      Request.Params.ParameterByIndex(0).Value  := CONFIG_LOCAL.ID_DEPOSIT_FIRST;
      Request.Params.AddItem;
      Request.Params.ParameterByIndex(1).Kind   := pkGETorPOST;
      Request.Params.ParameterByIndex(1).name   := 'secret_key';
      Request.Params.ParameterByIndex(1).Value  := CONFIG_LOCAL.SECRET_KEY_FIRST;

      Request.Execute;

      //Atualiza o status do Token com o Reultado
      TOKEN_WS.STATUS_CODE := Response.StatusCode;

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
    except
      On E : Exception do
        SaveLog('Erro no Procedimento getToken, ' + E.Message);
    end;
  end else begin
    if TOKEN_WS.DH_LOGIN + TOKEN_WS.SESSION_EXPIRES <= Now then
      Refresh;
  end;
end;

function TConexaoFirst.NFEntrada(JsonValue: TJSONValue; out Status : Integer; out Mensagem : String): Boolean;
var
  Pair : TJSONPair;
begin
  Status   := 999;
  Mensagem := 'Montando dados da requisição!';

  Client.BaseURL    := URLPrincipal;
  Request.Method    := rmPUT;
  Request.Resource  := 'armazem/entrada?deposit={deposit}&token={token}';

  Request.Params.Clear;
  Request.Params.AddItem;
  Request.Params.ParameterByIndex(0).Kind         := pkURLSEGMENT;
  Request.Params.ParameterByIndex(0).name         := 'deposit';
  Request.Params.ParameterByIndex(0).Value        := TOKEN_WS.USER_ID;
  Request.Params.AddItem;
  Request.Params.ParameterByIndex(1).Kind         := pkURLSEGMENT;
  Request.Params.ParameterByIndex(1).name         := 'token';
  Request.Params.ParameterByIndex(1).Value        := TOKEN_WS.TOKEN;
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
  if Response.JSONText <> EmptyStr then begin
    if Response.JSONValue is TJSONObject then begin
      for Pair in TJSONObject(Response.JSONValue) do begin
        if Pair.JsonString.Value = 'status' then
          Status := TJSONNumber(Pair.JsonValue).AsInt
        else if Pair.JsonString.Value = 'body' then
          Mensagem := Pair.JsonValue.Value;
      end;
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

  TOKEN_WS.STATUS_CODE  := 0;
  JsonValue             := TJSONObject.Create;

  try
    JsonValue.AddPair(TJSONPair.Create('refresh_token', TOKEN_WS.REFRESH_TOKEN));
    Client.BaseURL    := URLPrincipal + 'refresh';
    Request.Method    := rmPOST;
    Request.Resource  := '{id_deposit}';

    Request.Params.Clear;
    Request.Params.AddItem;
    Request.Params.ParameterByIndex(0).Kind         := pkURLSEGMENT;
    Request.Params.ParameterByIndex(0).name         := 'id_deposit';
    Request.Params.ParameterByIndex(0).Value        := TOKEN_WS.USER_ID;
    Request.Params.AddItem;
    Request.Params.ParameterByIndex(1).Kind         := pkREQUESTBODY;
    Request.Params.ParameterByIndex(1).name         := 'refresh';
    Request.Params.ParameterByIndex(1).Value        := JsonValue.ToJSON;
    Request.Params.ParameterByIndex(1).ContentType  := ctAPPLICATION_JSON;

    Request.Execute;

    //Atualiza o status do Token com o Reultado
    TOKEN_WS.STATUS_CODE := Response.StatusCode;

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
  except
    On E : Exception do
      SaveLog('Erro no Procedimento Refresh do Token, ' + E.Message);
  end;
end;

end.
