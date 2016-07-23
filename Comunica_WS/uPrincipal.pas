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
    Timer1: TTimer;
    ImageList1: TImageList;
    lbmensagem: TLabel;
    btTeste: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btIniciarClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure btTesteClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Procedure IniciarPararLeitura;
    procedure GravarProdutos;
    procedure EnviarNFEntrada;
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
  uBeanPedido_Embarque;
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
//  WSFirst := TConexaoFirst.Create(False, '0344391764', '2q2C5oXjhfH2xEu');
//  try
////    Token := WSFirst.getToken;
//
//  finally
//    FreeAndNil(WSFirst);
//  end;
  EnviarNFEntrada;
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
  JSONObject := TJSONObject.Create;
  JSONArray  := TJSONArray.Create;
  ConexaoFirst := TConexaoFirst.Create(False, '0344391764', '2q2C5oXjhfH2xEu');
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
            jso.AddPair(TJSONPair.Create('dat_emis_nf', TNOTAFISCAL(NF.Itens[I]).DATAEMISSAO.asString));
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

      JSONObject.AddPair(TJSONPair.Create('', JSONArray));

      ConexaoFirst.NFEntrada(JSONObject);
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

procedure TfrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Timer1.Enabled := False;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
var
 Con : TFWConnection;
begin
  CONFIG_LOCAL.DirLog  := GetCurrentDir + '\Logs\';
  SaveLog('Servi�o iniciado!');
  try

    ImageList1.GetBitmap(0, btIniciar.Glyph);
    btIniciar.Caption := 'Iniciar Leitura';

    CarregarConexaoBD;

    CarregarConfigLocal;

    CON   := TFWConnection.Create;
    try
      SaveLog('Conectou no Banco de dados!');
    finally
      FreeAndNil(CON);
    end;
  except
    on E : Exception do
      SaveLog('Erro ao iniciar Aplicativo: ' + E.Message);
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
  ConexaoFirst := TConexaoFirst.Create(False, '0344391764', '2q2C5oXjhfH2xEu');
  try
    ConexaoFirst.getToken;
    P.SelectList('status = 0');
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
      jso.AddPair(TJSONPair.Create('item_deposit', TPRODUTO(P.Itens[I]).CODIGOPRODUTO.asString));
      jso.AddPair(TJSONPair.Create('pct_ipi', '0'));
      jso.AddPair(TJSONPair.Create('cod_cla_fisc', '0'));
      jso.AddPair(TJSONPair.Create('cat_item', '1'));

      JSONArray.Add(jso);
    end;

    JSONObject.AddPair(TJSONPair.Create('', JSONArray));

    ConexaoFirst.CadastrarProdutos(JSONObject);
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
    btIniciar.Glyph := nil;
    ImageList1.GetBitmap(1, btIniciar.Glyph);
    btIniciar.Caption := 'Parar Leitura';
    Timer1.Enabled    := True;
  end else begin
    btIniciar.Glyph := nil;
    ImageList1.GetBitmap(0, btIniciar.Glyph);
    btIniciar.Caption := 'Iniciar Leitura';
    Timer1.Enabled    := False;
  end;
end;

procedure TfrmPrincipal.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  lbmensagem.Caption  := 'Timer Rodando...';
  Application.ProcessMessages;
  SaveLog('In�cio do Execute do Timmer');
  try
    try
    except
     on E : Exception do
       SaveLog('Ocorreu algum erro na execu��o do processo no Timmer! Erro: ' + E.Message);
    end;
  finally
    SaveLog('Final do Execute do Timmer');
    lbmensagem.Caption  := 'Timer Parado';
    Application.ProcessMessages;
    Timer1.Enabled := True;
  end;
end;

end.
