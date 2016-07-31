unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, uFWConnection, System.IniFiles,
  Vcl.ExtCtrls, Vcl.Buttons, Vcl.ImgList, System.DateUtils, System.StrUtils, System.JSON;

type
  TfrmPrincipal = class(TForm)
    Panel1: TPanel;
    btIniciar: TBitBtn;
    ImageList1: TImageList;
    btTeste: TBitBtn;
    lbmensagem: TLabel;
    procedure FormShow(Sender: TObject);
    procedure btIniciarClick(Sender: TObject);
    procedure btTesteClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Procedure IniciarPararLeitura;
    procedure EnviarNFEntrada;
    procedure EnviarPedido;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

uses
  uFuncoes,
  uBeanproduto,
  uBeanPedido,
  uBeanPedidoItens,
  uBeanTransportadoras,
  uBeanArquivosFTP,
  uBeanNotafiscal,
  uBeanNotafiscalItens,
  uBeanPedido_Notafiscal,
  uConstantes,
  uConexaoFirst,
  uBeanPedido_Embarque,
  uThreadIntegracaoWS,
  uBeanRequisicoesFirst,
  uBeanReq_Itens,
  uMensagem;
{$R *.dfm}

{ TfrmPrincipal }

procedure TfrmPrincipal.btIniciarClick(Sender: TObject);
begin
  if btIniciar.Tag = 0 then begin
    try
      IniciarPararLeitura;
    finally
      btIniciar.Tag := 0;
    end;
  end;
end;

procedure TfrmPrincipal.btTesteClick(Sender: TObject);
var
  WSFirst : TConexaoFirst;
begin
  WSFirst := TConexaoFirst.Create;
  try
    WSFirst.getToken;
  finally
    FreeAndNil(WSFirst);
  end;
  //GravarProdutos;
  //EnviarNFEntrada;
//  EnviarPedido;
end;

procedure TfrmPrincipal.EnviarNFEntrada;
var
  FW         : TFWConnection;
  NF         : TNOTAFISCAL;
  NI         : TNOTAFISCALITENS;
  P          : TPRODUTO;
  I          : Integer;
  JSONArray  : TJSONArray;
  jso        : TJSONObject;
  ConexaoFirst: TConexaoFirst;
  J: Integer;

  REQ : TREQUISICOESFIRST;
  RD  : TREQ_ITENS;
  Cod_Retorno : Integer;
  Dsc_Retorno : string;
begin
  FW := TFWConnection.Create;
  NF := TNOTAFISCAL.Create(FW);
  NI := TNOTAFISCALITENS.Create(FW);
  P  := TPRODUTO.Create(FW);
  REQ:= TREQUISICOESFIRST.Create(FW);
  RD := TREQ_ITENS.Create(FW);

  JSONArray     := TJSONArray.Create;
  ConexaoFirst  := TConexaoFirst.Create;

  try
    FW.StartTransaction;
    try
      NF.SelectList('status = 0', 'id limit 100');
      if NF.Count > 0 then begin
        REQ.ID.isNull             := True;
        REQ.DATAHORA.Value        := Now;
        REQ.COD_STATUS.Value      := 900;
        REQ.DSC_STATUS.Value      := 'Criando dados da Requisição';
        REQ.TIPOREQUISICAO.Value  := TIPOREQUISICAOFIRST[rfArmz];
        REQ.Insert;

        for I := 0 to Pred(NF.Count) do begin
          NI.SelectList('id_notafiscal = ' + TNOTAFISCAL(NF.Itens[I]).ID.asString);
          for J := 0 to Pred(NI.Count) do begin
            P.SelectList('id = ' + TNOTAFISCALITENS(NI.Itens[J]).ID_PRODUTO.asString);
            if P.Count > 0 then begin
              jso := TJSONObject.Create;

              jso.AddPair(TJSONPair.Create('num_nf', TNOTAFISCAL(NF.Itens[I]).DOCUMENTO.asString));
              jso.AddPair(TJSONPair.Create('ser_nf', TNOTAFISCAL(NF.Itens[I]).SERIE.asString));
              jso.AddPair(TJSONPair.Create('dat_emis_nf', DateTimeToStrFirst(TNOTAFISCAL(NF.Itens[I]).DATAEMISSAO.Value)));
              jso.AddPair(TJSONPair.Create('num_seq', TNOTAFISCALITENS(NI.Itens[J]).SEQUENCIA.asString));
              jso.AddPair(TJSONPair.Create('cod_item', TPRODUTO(P.Itens[0]).CODIGOPRODUTO.asString));
              jso.AddPair(TJSONPair.Create('qtd_declarad_nf', TNOTAFISCALITENS(NI.Itens[J]).QUANTIDADE.asString));
              jso.AddPair(TJSONPair.Create('pre_unit_nf', TNOTAFISCALITENS(NI.Itens[J]).VALORUNITARIO.asString));
              jso.AddPair(TJSONPair.Create('val_liquido_item', TNOTAFISCALITENS(NI.Itens[J]).VALORTOTAL.asString));
              jso.AddPair(TJSONPair.Create('val_tot_nf_d', TNOTAFISCAL(NF.Itens[I]).VALORTOTAL.asString));

              JSONArray.Add(jso);

              RD.ID.isNull            := True;
              RD.ID_REQUISICOES.Value := REQ.ID.Value;
              RD.ID_DADOS.Value       := TNOTAFISCAL(NF.Itens[I]).ID.Value;
              RD.Insert;
            end;
          end;
        end;

        ConexaoFirst.NFEntrada(JSONArray, Cod_Retorno, Dsc_Retorno);
        REQ.COD_STATUS.Value := Cod_Retorno;
        REQ.DSC_STATUS.Value := Dsc_Retorno;
        REQ.Update;
        if REQ.COD_STATUS.Value = 200 then begin
          for I := 0 to Pred(NF.Count) do begin
            NF.ID.Value     := TNOTAFISCAL(NF.Itens[I]).ID.Value;
            NF.STATUS.Value := 1;
            NF.Update;
          end;
        end;
      end;
      FW.Commit;
    except
      on E : Exception do begin
        FW.Rollback;
        DisplayMsg(MSG_WAR, 'Ocorreu um erro ao enviar NF de Entrada!', '', E.Message);
      end;
    end;
  finally
    FreeAndNil(JSONArray);
    FreeAndNil(P);
    FreeAndNil(NF);
    FreeAndNil(NI);
    FreeAndNil(REQ);
    FreeAndNil(RD);
    FreeAndNil(FW);
    FreeAndNil(ConexaoFirst);
  end;
end;

procedure TfrmPrincipal.EnviarPedido;
var
  //Conexao
  FW         : TFWConnection;
  //Classes do Bando de Dados
  P          : TPEDIDO;
  PI         : TPEDIDOITENS;
  T          : TTRANSPORTADORA;
  PR         : TPRODUTO;
  //Json
  JSONArray  : TJSONArray;
  JSONObject,
  jso        : TJSONObject;
  //Conexao First
  ConexaoFirst: TConexaoFirst;

  I          : Integer;
  J: Integer;
  //Log do Envio de Dados
  REQ : TREQUISICOESFIRST;
  RD  : TREQ_ITENS;
  Cod_Retorno : Integer;
  Dsc_Retorno : string;
begin
  FW := TFWConnection.Create;

  REQ := TREQUISICOESFIRST.Create(FW);
  RD  := TREQ_ITENS.Create(FW);

  P  := TPEDIDO.Create(FW);
  PI := TPEDIDOITENS.Create(FW);
  PR := TPRODUTO.Create(FW);
  T  := TTRANSPORTADORA.Create(FW);
  JSONObject := TJSONObject.Create;
  JSONArray  := TJSONArray.Create;
  ConexaoFirst := TConexaoFirst.Create;
  try
    FW.StartTransaction;
    try
      P.SelectList('status = 1', 'id limit 100');
      if P.Count > 0 then begin
        REQ.ID.isNull             := True;
        REQ.DATAHORA.Value        := Now;
        REQ.COD_STATUS.Value      := 900;
        REQ.DSC_STATUS.Value      := 'Criando dados da Requisição';
        REQ.TIPOREQUISICAO.Value  := TIPOREQUISICAOFIRST[rfSc];
        REQ.Insert;

        for I := 0 to Pred(P.Count) do begin
          PI.SelectList('id_pedido = ' + TPEDIDO(P.Itens[I]).ID.asString);
          for J := 0 to Pred(PI.Count) do begin
            PR.SelectList('id = ' + TPEDIDOITENS(PI.Itens[J]).ID_PRODUTO.asString);
            T.SelectList('id = ' + TPEDIDO(P.Itens[I]).ID_TRANSPORTADORA.asString);
            if (PR.Count > 0) and (T.Count > 0) then begin
              jso := TJSONObject.Create;

              jso.AddPair(TJSONPair.Create('cnpj_tran', TTRANSPORTADORA(T.Itens[0]).CNPJ.asString));
              jso.AddPair(TJSONPair.Create('pedido', TPEDIDO(P.Itens[I]).PEDIDO.asString));
              jso.AddPair(TJSONPair.Create('num_viagem', TPEDIDO(P.Itens[I]).VIAGEM.asString));
              jso.AddPair(TJSONPair.Create('sequencial_embarq', TPEDIDO(P.Itens[I]).SEQUENCIA.asString));
              jso.AddPair(TJSONPair.Create('item', TPRODUTO(PR.Itens[0]).CODIGOPRODUTO.asString));
              jso.AddPair(TJSONPair.Create('unid_medida', TPRODUTO(PR.Itens[0]).UNIDADEDEMEDIDA.asString));
              jso.AddPair(TJSONPair.Create('qtd_original_docum', TPEDIDOITENS(PI.Itens[J]).QUANTIDADE.asString));
              jso.AddPair(TJSONPair.Create('val_unit', TPEDIDOITENS(PI.Itens[J]).VALOR_UNITARIO.asString));
              jso.AddPair(TJSONPair.Create('cnpj_cpf_destinat', TPEDIDO(P.Itens[I]).DEST_CNPJ.asString));
              jso.AddPair(TJSONPair.Create('nom_destinat', TPEDIDO(P.Itens[I]).DEST_NOME.asString));
              jso.AddPair(TJSONPair.Create('ende_dest', TPEDIDO(P.Itens[I]).DEST_ENDERECO.asString));
              jso.AddPair(TJSONPair.Create('compl_endereco', TPEDIDO(P.Itens[I]).DEST_COMPLEMENTO.asString));
              jso.AddPair(TJSONPair.Create('cep', TPEDIDO(P.Itens[I]).DEST_CEP.asString));

              JSONArray.Add(jso);

              RD.ID.isNull            := True;
              RD.ID_REQUISICOES.Value := REQ.ID.Value;
              RD.ID_DADOS.Value       := TPEDIDO(P.Itens[I]).ID.Value;
              RD.Insert;
            end;
          end;
        end;

        ConexaoFirst.EnviarPedidos(JSONArray, Cod_Retorno, Dsc_Retorno);
        REQ.COD_STATUS.Value := Cod_Retorno;
        REQ.DSC_STATUS.Value := Dsc_Retorno;
        REQ.Update;
        if REQ.COD_STATUS.Value = 200 then begin
          for I := 0 to Pred(P.Count) do begin
            P.ID.Value     := TPEDIDO(P.Itens[I]).ID.Value;
            P.STATUS.Value := 2;
            P.Update;
          end;
        end;
      end;
      FW.Commit;
    except
      on E : Exception do begin
        FW.Rollback;
        DisplayMsg(MSG_WAR, 'Ocorreu algum erro no envio de pedidos!', E.Message);
      end;
    end;
  finally
    FreeAndNil(JSONArray);
    //FreeAndNil(JSONObject);
    FreeAndNil(P);
    FreeAndNil(PR);
    FreeAndNil(PI);
    FreeAndNil(T);
    FreeAndNil(REQ);
    FreeAndNil(RD);
    FreeAndNil(FW);
    FreeAndNil(ConexaoFirst);
  end;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
var
 Con : TFWConnection;
begin
  CONFIG_LOCAL.DirLog  := GetCurrentDir + '\Logs\';

  try

    ImageList1.GetBitmap(0, btIniciar.Glyph);
    btIniciar.Caption := 'Iniciar Leitura';

    CarregarConexaoBD;

    CarregarConfigLocal;

  except
    on E : Exception do
      SaveLog('Erro ao iniciar Comunicador WS: ' + E.Message);
  end;
end;

procedure TfrmPrincipal.IniciarPararLeitura;
begin
  if btIniciar.Caption = 'Iniciar Leitura' then begin
    IntegracaoWS := ThreadIntegracaoWS.Create(True);
    IntegracaoWS.Start;

    btIniciar.Glyph := nil;
    ImageList1.GetBitmap(1, btIniciar.Glyph);
    btIniciar.Caption := 'Parar Leitura';

  end else begin
    if Assigned(IntegracaoWS) then begin
      IntegracaoWS.Terminate;
      if not IntegracaoWS.Suspended then
        IntegracaoWS.WaitFor;
      FreeAndNil(IntegracaoWS);
    end;
    btIniciar.Glyph := nil;
    ImageList1.GetBitmap(0, btIniciar.Glyph);
    btIniciar.Caption := 'Iniciar Leitura';
  end;
end;

end.
