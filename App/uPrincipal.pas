unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ExtCtrls;

type
  TfrmPrincipal = class(TForm)
    IMFundo: TImage;
    MainMenu1: TMainMenu;
    Cadastros1: TMenuItem;
    Usuario1: TMenuItem;
    Configuraes1: TMenuItem;
    ConfigGerais1: TMenuItem;
    RedefinirSenha: TMenuItem;
    miSair: TMenuItem;
    Produtos1: TMenuItem;
    procedure miSairClick(Sender: TObject);
    procedure ConfigGerais1Click(Sender: TObject);
    procedure RedefinirSenhaClick(Sender: TObject);
    procedure Usuario1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure Produtos1Click(Sender: TObject);
  private
    { Private declarations }
  public
    procedure DefinirPermissoes;
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

uses
  uMensagem,
  uConstantes,
  uFuncoes,
  uRedefinirSenha,
  uConfiguracoesSistema,
  uCadastroUsuario,
  uCadastroProdutos;

{$R *.dfm}

procedure TfrmPrincipal.ConfigGerais1Click(Sender: TObject);
begin
  try
    if frmConfiguracoesSistema = nil then
      frmConfiguracoesSistema := TfrmConfiguracoesSistema.Create(Self);
    frmConfiguracoesSistema.ShowModal;
  finally
    FreeAndNil(frmConfiguracoesSistema);
  end;
end;

procedure TfrmPrincipal.DefinirPermissoes;
begin
  RedefinirSenha.Visible  := False; //Usuário 0 é Administrador e não tem Cadastro
  if USUARIO.CODIGO > 0 then begin
    DefinePermissaoMenu(MainMenu1);
    miSair.Visible          := True;
  end;
end;

procedure TfrmPrincipal.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (Key = VK_F11) then begin
    DESIGNREL       := not DESIGNREL;
    if DESIGNREL then
      DisplayMsg(MSG_INF, 'Design de Relatórios Ativado!')
    else
      DisplayMsg(MSG_INF, 'Design de Relatórios Desativado!');
  end;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  if FileExists(DirInstall + 'Imagens\Fundo.jpg') then
    IMFundo.Picture.LoadFromFile(DirInstall + 'Imagens\Fundo.jpg');

  CarregaArrayMenus(MainMenu1);

  DefinirPermissoes;

  CriarComandoSequenciaMenu(MainMenu1);

  Caption := 'Sistema CrossAbacos - Usuário: ' + IntToStr(USUARIO.CODIGO) + ' - ' + USUARIO.NOME;
end;

procedure TfrmPrincipal.miSairClick(Sender: TObject);
begin
  DisplayMsg(MSG_CONF, 'Deseja realmente sair do sistema?', 'Sair do Sistema');

  if (ResultMsgModal = mrYes) then
    Close;
end;

procedure TfrmPrincipal.Produtos1Click(Sender: TObject);
begin
  try
    if frmCadastroProdutos = nil then
      frmCadastroProdutos := TfrmCadastroProdutos.Create(Self);
    frmCadastroProdutos.ShowModal;
  finally
    FreeAndNil(frmCadastroProdutos);
  end;
end;

procedure TfrmPrincipal.RedefinirSenhaClick(Sender: TObject);
begin
  try
    if FrmRedefinirSenha = nil then
      FrmRedefinirSenha := TFrmRedefinirSenha.Create(Self);
    FrmRedefinirSenha.ShowModal;
  finally
    FreeAndNil(FrmRedefinirSenha);
  end;
end;

procedure TfrmPrincipal.Usuario1Click(Sender: TObject);
begin
  try
    if FrmCadastroUsuario = nil then
      FrmCadastroUsuario := TFrmCadastroUsuario.Create(Self);
    FrmCadastroUsuario.ShowModal;
  finally
    FreeAndNil(FrmCadastroUsuario);
  end;
end;

end.
