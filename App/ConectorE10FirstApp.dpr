program ConectorE10FirstApp;

uses
  Vcl.Forms,
  Vcl.Controls,
  System.SysUtils,
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
  uBeanNotaFiscalItens in 'Beans\uBeanNotaFiscalItens.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;

  Application.CreateForm(TDMUtil, DMUtil);
  Application.CreateForm(TFrmLogin, FrmLogin);
  if FrmLogin.ShowModal = mrOk then begin

    FreeAndNil(FrmLogin);
    Application.CreateForm(TFrmPrincipal, FrmPrincipal);
    Application.Run;

  end else
    Application.Terminate; //Encerra a aplicação
end.
