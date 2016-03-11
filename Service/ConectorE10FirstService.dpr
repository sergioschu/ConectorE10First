program ConectorE10FirstService;

uses
  Vcl.SvcMgr,
  uPrincipal in 'uPrincipal.pas' {ServiceConectorE10: TService},
  uFWConnection in '..\App\uFWConnection.pas',
  uBeanUsuario in '..\App\Beans\uBeanUsuario.pas',
  uBeanUsuario_Permissao in '..\App\Beans\uBeanUsuario_Permissao.pas',
  uConstantes in '..\App\Units\uConstantes.pas',
  uDomains in '..\App\Diversos\uDomains.pas',
  uFWPersistence in '..\App\Diversos\uFWPersistence.pas',
  uBeanNotaFiscal in '..\App\Beans\uBeanNotaFiscal.pas',
  uBeanNotaFiscalItens in '..\App\Beans\uBeanNotaFiscalItens.pas',
  uBeanPedido in '..\App\Beans\uBeanPedido.pas',
  uBeanPedidoItens in '..\App\Beans\uBeanPedidoItens.pas',
  uBeanProduto in '..\App\Beans\uBeanProduto.pas',
  uConexaoFTP in 'uConexaoFTP.pas',
  uFuncoes in '..\App\Units\uFuncoes.pas',
  uBeanArquivosFTP in '..\App\Beans\uBeanArquivosFTP.pas';

{$R *.RES}

begin
  // Windows 2003 Server requires StartServiceCtrlDispatcher to be
  // called before CoRegisterClassObject, which can be called indirectly
  // by Application.Initialize. TServiceApplication.DelayInitialize allows
  // Application.Initialize to be called from TService.Main (after
  // StartServiceCtrlDispatcher has been called).
  //
  // Delayed initialization of the Application object may affect
  // events which then occur prior to initialization, such as
  // TService.OnCreate. It is only recommended if the ServiceApplication
  // registers a class object with OLE and is intended for use with
  // Windows 2003 Server.
  //
  // Application.DelayInitialize := True;
  //
  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.CreateForm(TServiceConectorE10, ServiceConectorE10);
  Application.Run;
end.
