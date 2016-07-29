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
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Procedure IniciarPararLeitura;
    procedure GravarProdutos;
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
  uThreadIntegracaoWS;
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
  Token   : string;
begin
  WSFirst := TConexaoFirst.Create(False);
  try
    Token := WSFirst.getToken;
  finally
    FreeAndNil(WSFirst);
  end;
//  GravarProdutos;
//  EnviarNFEntrada;
  EnviarPedido;
end;

procedure TfrmPrincipal.EnviarNFEntrada;
var
  FW         : TFWConnection;
  NF         : TNOTAFISCAL;
  NI         : TNOTAFISCALITENS;
  P          : TPRODUTO;
  I          : Integer;
  JSONArray  : TJSONArray;
  JSONObject,
  jso        : TJSONObject;
  ConexaoFirst: TConexaoFirst;
  J: Integer;
begin
  FW := TFWConnection.Create;
  NF := TNOTAFISCAL.Create(FW);
  NI := TNOTAFISCALITENS.Create(FW);
  P  := TPRODUTO.Create(FW);

  JSONObject    := TJSONObject.Create;
  JSONArray     := TJSONArray.Create;
  ConexaoFirst  := TConexaoFirst.Create(False);

  try
    ConexaoFirst.getToken;
    NF.SelectList('status = 0');
    if NF.Count > 0 then begin
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
          end;
        end;
      end;

//      JSONObject.AddPair(TJSONPair.Create('', JSONArray));

      ConexaoFirst.NFEntrada(JSONArray);
    end;
  finally
    FreeAndNil(JSONArray);
    //FreeAndNil(JSONObject);
    FreeAndNil(P);
    FreeAndNil(NF);
    FreeAndNil(NI);
    FreeAndNil(FW);
    FreeAndNil(ConexaoFirst);
  end;
end;

procedure TfrmPrincipal.EnviarPedido;
var
  FW         : TFWConnection;
  P          : TPEDIDO;
  PI         : TPEDIDOITENS;
  T          : TTRANSPORTADORA;
  PR         : TPRODUTO;
  I          : Integer;
  JSONArray  : TJSONArray;
  JSONObject,
  jso        : TJSONObject;
  ConexaoFirst: TConexaoFirst;
  J: Integer;
begin
  FW := TFWConnection.Create;
  P  := TPEDIDO.Create(FW);
  PI := TPEDIDOITENS.Create(FW);
  PR := TPRODUTO.Create(FW);
  T  := TTRANSPORTADORA.Create(FW);
  JSONObject := TJSONObject.Create;
  JSONArray  := TJSONArray.Create;
  ConexaoFirst := TConexaoFirst.Create(False);
  try
    ConexaoFirst.getToken;
    P.SelectList('status = 1');
    if P.Count > 0 then begin
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
          end;
        end;
      end;

//      JSONObject.AddPair(TJSONPair.Create('', JSONArray));

      ConexaoFirst.EnviarPedidos(JSONArray);
    end;
  finally
    FreeAndNil(JSONArray);
    //FreeAndNil(JSONObject);
    FreeAndNil(P);
    FreeAndNil(PR);
    FreeAndNil(PI);
    FreeAndNil(T);
    FreeAndNil(FW);
    FreeAndNil(ConexaoFirst);
  end;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  IntegracaoWS := ThreadIntegracaoWS.Create(True);
  IntegracaoWS.FreeOnTerminate := False;
end;

procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
  if Assigned(IntegracaoWS) then begin
    IntegracaoWS.Terminate;
    if not IntegracaoWS.Suspended then
      IntegracaoWS.WaitFor;
    FreeAndNil(IntegracaoWS);
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

procedure TfrmPrincipal.GravarProdutos;
var
  FW         : TFWConnection;
  P          : TPRODUTO;
  I          : Integer;
  JSONArray  : TJSONArray;
  JSONObject,
  jso        : TJSONObject;
  ConexaoFirst: TConexaoFirst;
begin
  FW := TFWConnection.Create;
  P  := TPRODUTO.Create(FW);
  JSONObject := TJSONObject.Create;
  JSONArray  := TJSONArray.Create;
  ConexaoFirst := TConexaoFirst.Create(False);
  try
    repeat
      P.SelectList('status = 0', 'codigoproduto limit 500');
      FW.StartTransaction;
      for I := 0 to Pred(P.Count) do begin
        jso := TJSONObject.Create;

        jso.AddPair(TJSONPair.Create('item_deposit', TPRODUTO(P.Itens[I]).CODIGOPRODUTO.asString));
        jso.AddPair(TJSONPair.Create('den_item', TPRODUTO(P.Itens[I]).DESCRICAO.asString));
        jso.AddPair(TJSONPair.Create('den_item_reduz', TPRODUTO(P.Itens[I]).DESCRICAOREDUZIDA.asString));
        jso.AddPair(TJSONPair.Create('des_sku', TPRODUTO(P.Itens[I]).DESCRICAOSKU.asString));
        jso.AddPair(TJSONPair.Create('des_reduz_sku', TPRODUTO(P.Itens[I]).DESCRICAOREDUZIDASKU.asString));
        jso.AddPair(TJSONPair.Create('qtd_item', TPRODUTO(P.Itens[I]).QUANTIDADEPOREMBALAGEM.asString));
        jso.AddPair(TJSONPair.Create('cod_unid_med', TPRODUTO(P.Itens[I]).UNIDADEDEMEDIDA.asString));
        jso.AddPair(TJSONPair.Create('cod_barras', TPRODUTO(P.Itens[I]).CODIGOBARRAS.asString));
        jso.AddPair(TJSONPair.Create('altura', TPRODUTO(P.Itens[I]).ALTURAEMBALAGEM.asString));
        jso.AddPair(TJSONPair.Create('comprimento', TPRODUTO(P.Itens[I]).COMPRIMENTOEMBALAGEM.asString));
        jso.AddPair(TJSONPair.Create('largura', TPRODUTO(P.Itens[I]).LARGURAEMBALAGEM.asString));
        jso.AddPair(TJSONPair.Create('peso_bruto', TPRODUTO(P.Itens[I]).PESOEMBALAGEM.asString));
        jso.AddPair(TJSONPair.Create('pes_unit', TPRODUTO(P.Itens[I]).PESOPRODUTO.asString));
        jso.AddPair(TJSONPair.Create('qtd_caixa_altura', TPRODUTO(P.Itens[I]).QUANTIDADECAIXASALTURAPALET.asString));
        jso.AddPair(TJSONPair.Create('qtd_caixa_lastro', TPRODUTO(P.Itens[I]).QUANTIDADESCAIXASLASTROPALET.asString));
        jso.AddPair(TJSONPair.Create('pct_ipi', '0'));
        jso.AddPair(TJSONPair.Create('cod_cla_fisc', '0'));
        jso.AddPair(TJSONPair.Create('cat_item', '1'));

        JSONArray.Add(jso);
        P.ID.Value     := TPRODUTO(P.Itens[I]).ID.Value;
        P.STATUS.Value := 1;
        P.Update;
      end;

      FW.Commit;

      ConexaoFirst.CadastrarProdutos(JSONArray);
    until P.Count = 0;
  finally
    FreeAndNil(JSONArray);
    FreeAndNil(P);
    FreeAndNil(FW);
    FreeAndNil(ConexaoFirst);
  end;
end;

procedure TfrmPrincipal.IniciarPararLeitura;
begin
  if btIniciar.Caption = 'Iniciar Leitura' then begin
    if Assigned(IntegracaoWS) then begin
        IntegracaoWS.Resume;
    end;
    btIniciar.Glyph := nil;
    ImageList1.GetBitmap(1, btIniciar.Glyph);
    btIniciar.Caption := 'Parar Leitura';

  end else begin
    if Assigned(IntegracaoWS) then begin
      IntegracaoWS.Suspend;
      if not IntegracaoWS.Suspended then
        IntegracaoWS.WaitFor;
    end;
    btIniciar.Glyph := nil;
    ImageList1.GetBitmap(0, btIniciar.Glyph);
    btIniciar.Caption := 'Iniciar Leitura';
  end;
end;

end.
