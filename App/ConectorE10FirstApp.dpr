program ConectorE10FirstApp;

uses
  Vcl.Forms,
  Vcl.Controls,
  System.SysUtils,
  MidasLib,
  uPrincipal in 'uPrincipal.pas' {frmPrincipal},
  uLogin in 'uLogin.pas' {FrmLogin},
  uMensagem in 'Diversos\uMensagem.pas' {frmMensagem},
  uConstantes in 'Units\uConstantes.pas',
  uFuncoes in 'Units\uFuncoes.pas',
  uFWConnection in 'uFWConnection.pas',
  uBeanUsuario in 'Beans\uBeanUsuario.pas',
  uBeanUsuario_Permissao in 'Beans\uBeanUsuario_Permissao.pas',
  uDomains in 'Diversos\uDomains.pas',
  uFWPersistence in 'Diversos\uFWPersistence.pas',
  uRedefinirSenha in 'uRedefinirSenha.pas' {FrmRedefinirSenha},
  uConfiguracoesSistema in 'uConfiguracoesSistema.pas' {frmConfiguracoesSistema},
  uCadastroUsuario in 'Cadastros\uCadastroUsuario.pas' {FrmCadastroUsuario},
  uDMUtil in 'Diversos\uDMUtil.pas' {DMUtil: TDataModule},
  uBeanProduto in 'Beans\uBeanProduto.pas',
  uCadastroProdutos in 'Cadastros\uCadastroProdutos.pas' {frmCadastroProdutos},
  uNotaFiscal in 'uNotaFiscal.pas' {frmNotaFiscal},
  uBeanNotaFiscal in 'Beans\uBeanNotaFiscal.pas',
  uBeanPedido in 'Beans\uBeanPedido.pas',
  uBeanPedidoItens in 'Beans\uBeanPedidoItens.pas',
  uBeanNotaFiscalItens in 'Beans\uBeanNotaFiscalItens.pas',
  uManutencaoPedidos in 'uManutencaoPedidos.pas' {FrmManutencaoPedidos},
  uFaturamentodePedidos in 'uFaturamentodePedidos.pas' {FrmFaturamentodePedidos},
  uCadastroTransportadora in 'Cadastros\uCadastroTransportadora.pas' {frmCadastroTransportadora},
  uBeanTransportadoras in 'Beans\uBeanTransportadoras.pas',
  uRelDivergencias in 'uRelDivergencias.pas' {frmRelDivergencias},
  uRelTempoResposta in 'uRelTempoResposta.pas' {frmRelTempoResposta},
  uRelCodigoRastreio in 'uRelCodigoRastreio.pas' {frmRelCodigoRastreio},
  uSeleciona in 'uSeleciona.pas' {frmSeleciona},
  uBeanPedido_Cancelamento in 'Beans\uBeanPedido_Cancelamento.pas',
  uRelCancelamentoPedido in 'uRelCancelamentoPedido.pas' {frmRelCancelamentoPedido},
  uRelRetornoForadoPrazo in 'uRelRetornoForadoPrazo.pas' {frmRelRetornoForadoPrazo},
  uBeanPedido_NotaFiscal in 'Beans\uBeanPedido_NotaFiscal.pas',
  uPedidosNotaFiscal in 'uPedidosNotaFiscal.pas' {FrmPedidosNotaFiscal},
  uRelNotaFiscalPedido in 'uRelNotaFiscalPedido.pas' {frmRelNotaFiscalPedido},
  uRelPedidosSemNF in 'uRelPedidosSemNF.pas' {frmRelPedidosSemNF};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  ReportMemoryLeaksOnShutdown   := True;

  Application.CreateForm(TDMUtil, DMUtil);
  Application.CreateForm(TFrmLogin, FrmLogin);
  if FrmLogin.ShowModal = mrOk then begin

    FreeAndNil(FrmLogin);
    Application.CreateForm(TFrmPrincipal, FrmPrincipal);
    Application.Run;

  end else
    Application.Terminate; //Encerra a aplicação
end.
