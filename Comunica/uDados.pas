unit uDados;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, ufwConnection;

type
  TfrmDados = class(TForm)
    mnPrincipal: TMemo;
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function BuscaNumeroArquivo(Con : TFWConnection; Tipo : Integer) : Integer;
    procedure SaveLog(Texto : String);
  end;

var
  frmDados: TfrmDados;

implementation
uses
  uConexaoFTP,
  uBeanproduto,
  uBeanPedido,
  uBeanPedidoItens,
  uBeanTransportadoras,
  uBeanArquivosFTP,
  uBeanNotafiscal,
  uBeanNotafiscalItens,
  uConstantes;
{$R *.dfm}

procedure TfrmDados.FormShow(Sender: TObject);
begin
  Self.ClientHeight := Application.MainForm.ClientHeight - 2; //Cabeçalho form principal
  Self.ClientWidth  := Application.MainForm.ClientWidth;
  Self.Height       := Application.MainForm.ClientHeight - 66; //Cabeçalho form principal
  Self.Width        := Application.MainForm.ClientWidth;
  Self.Top          := Application.MainForm.Top   + Application.MainForm.BorderWidth + 47;
  Self.Left         := Application.MainForm.Left  + Application.MainForm.BorderWidth + 3;
end;

function TfrmDados.BuscaNumeroArquivo(Con: TFWConnection;
  Tipo: Integer): Integer;
begin

end;

procedure TfrmDados.SaveLog(Texto: String);
begin
  mnPrincipal.Lines.Add(DateTimeToStr(Now) + ' ' + Texto);
  Application.ProcessMessages;
end;

procedure TfrmDados.Timer1Timer(Sender: TObject);
begin
//  SaveLog('Início do Execute do Timmer');
//  try
//    try
//      SaveLog('Enviar Produtos');
//      EnviaProdutos;
//      SaveLog('Enviar NFs');
//      EnviaNotasFiscais;
//      SaveLog('Buscar CONF');
//      BuscaCONF;
//      SaveLog('Enviar Pedidos');
//      EnviaPedidos;
//      SaveLog('Buscar MDD');
//      BuscaMDD;
//      SaveLog('Antes do ProcessRequest');
//    except
//     on E : Exception do
//       SaveLog('Ocorreu algum erro na execução do processo no Timmer! Erro: ' + E.Message);
//    end;
//    SaveLog('Sleep');
//  finally
//    SaveLog('Final do Execute do Timmer');
//  end;
end;

end.
