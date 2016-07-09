program ConectorE10FirstComunicador;

uses
  Vcl.Forms,
  uPrincipal in 'uPrincipal.pas' {Form1},
  uConexaoFTP in '..\Service\uConexaoFTP.pas',
  uFuncoes in '..\App\Units\uFuncoes.pas',
  uBeanArquivosFTP in '..\App\Beans\uBeanArquivosFTP.pas',
  uDomains in '..\App\Diversos\uDomains.pas',
  uFWPersistence in '..\App\Diversos\uFWPersistence.pas',
  uFWConnection in '..\App\uFWConnection.pas',
  uBeanUsuario in '..\App\Beans\uBeanUsuario.pas',
  uBeanUsuario_Permissao in '..\App\Beans\uBeanUsuario_Permissao.pas',
  uBeanNotaFiscal in '..\App\Beans\uBeanNotaFiscal.pas',
  uBeanNotaFiscalItens in '..\App\Beans\uBeanNotaFiscalItens.pas',
  uBeanPedido in '..\App\Beans\uBeanPedido.pas',
  uBeanPedidoItens in '..\App\Beans\uBeanPedidoItens.pas',
  uBeanProduto in '..\App\Beans\uBeanProduto.pas',
  uConstantes in '..\App\Units\uConstantes.pas',
  uBeanTransportadoras in '..\App\Beans\uBeanTransportadoras.pas',
  uBeanPedido_NotaFiscal in '..\App\Beans\uBeanPedido_NotaFiscal.pas',
  uMensagem in '..\App\Diversos\uMensagem.pas' {frmMensagem},
  uBeanPedido_Cancelamento in '..\App\Beans\uBeanPedido_Cancelamento.pas',
  uDMUtil in '..\App\Diversos\uDMUtil.pas' {DMUtil: TDataModule},
  uSeleciona in '..\App\uSeleciona.pas' {frmSeleciona},
  uBeanPedido_Embarque in '..\App\Beans\uBeanPedido_Embarque.pas';

{$R *.res}

begin

  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDMUtil, DMUtil);
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
