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
  uBeanTransportadoras in '..\App\Beans\uBeanTransportadoras.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
