unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, uFWConnection, System.IniFiles,
  Vcl.ExtCtrls, Vcl.Buttons, Vcl.ImgList, System.DateUtils, System.StrUtils, System.JSON,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, uThreadIntegracaoWS;

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
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    IntegracaoWS  : ThreadIntegracaoWS;
    { Private declarations }
  public
    { Public declarations }
    Procedure IniciarPararLeitura;
    procedure PararIntegracao;
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

end;

procedure TfrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  PararIntegracao;
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

    PararIntegracao;

    btIniciar.Glyph := nil;
    ImageList1.GetBitmap(0, btIniciar.Glyph);
    btIniciar.Caption := 'Iniciar Leitura';
  end;
end;

procedure TfrmPrincipal.PararIntegracao;
begin
  if Assigned(IntegracaoWS) then begin

    DisplayMsg(MSG_WAIT, 'Finalizando Processo de Integração...');
    try

      IntegracaoWS.Terminate;

      if not IntegracaoWS.Suspended then
        IntegracaoWS.WaitFor;

      FreeAndNil(IntegracaoWS);
    finally
      DisplayMsgFinaliza;
    end;
  end;
end;

end.
