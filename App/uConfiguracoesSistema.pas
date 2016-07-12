unit uConfiguracoesSistema;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.ExtCtrls, Vcl.ComCtrls,
  System.IniFiles, Vcl.StdCtrls, Vcl.FileCtrl, Vcl.ImgList;

type
  TfrmConfiguracoesSistema = class(TForm)
    pnBotoesVisualizacao: TPanel;
    btSair: TSpeedButton;
    btSalvar: TSpeedButton;
    Panel2: TPanel;
    TabControl1: TTabControl;
    pnConfiguracoesLocais: TPanel;
    edDiretorioRelatorio: TButtonedEdit;
    Label1: TLabel;
    edDataBase: TLabeledEdit;
    edServer: TLabeledEdit;
    edUserName: TLabeledEdit;
    edPassword: TLabeledEdit;
    edCharSet: TLabeledEdit;
    edDriverID: TLabeledEdit;
    edPorta: TLabeledEdit;
    btConnection: TSpeedButton;
    edDiretorioLogs: TButtonedEdit;
    Label2: TLabel;
    edSenhaFTP: TLabeledEdit;
    edUsuarioFTP: TLabeledEdit;
    edSleepFTP: TLabeledEdit;
    edDirArquivosPDF: TButtonedEdit;
    Label3: TLabel;
    edDirFTP: TLabeledEdit;
    ImageList1: TImageList;
    procedure btSairClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edDiretorioRelatorioRightButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btSalvarClick(Sender: TObject);
    procedure btConnectionClick(Sender: TObject);
  private
    procedure CarregaConfiguracoes;
    procedure SalvaConfiguracoes;
    procedure TestarConexao;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmConfiguracoesSistema: TfrmConfiguracoesSistema;

implementation

uses
  uFuncoes,
  uConstantes,
  uFWConnection,
  uMensagem, Winapi.Messages;

{$R *.dfm}

procedure TfrmConfiguracoesSistema.btConnectionClick(Sender: TObject);
begin
  TestarConexao;
end;

procedure TfrmConfiguracoesSistema.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmConfiguracoesSistema.btSalvarClick(Sender: TObject);
begin
  if btSalvar.Tag = 0 then begin
    btSalvar.Tag := 1;
    try

      if not DirectoryExists(edDiretorioRelatorio.Text) then begin
        DisplayMsg(MSG_CONF, 'Diretório de Relatório não Encontrado!' + sLineBreak + 'Deseja Continuar?');
        if ResultMsgModal <> mrYes then
          Exit;
      end;

      //Se não tem Acrescenta a Barra no Final
      if edDirArquivosPDF.Text[Length(edDirArquivosPDF.Text)] <> '\' then
        edDirArquivosPDF.Text := edDirArquivosPDF.Text + '\';

      if not DirectoryExists(edDirArquivosPDF.Text) then begin
        DisplayMsg(MSG_WAR, 'Diretório de Arquivos PDF não Encontrado, Verifique!');
        Exit;
      end;

      SalvaConfiguracoes;

      DisplayMsg(MSG_CONF, 'Para aplicar as modificações é necessário Reiniciar a Aplicação!' + sLineBreak + 'Deseja Fechar Agora?');

      if ResultMsgModal = mrYes then
        Application.Terminate();

    finally
      btSalvar.Tag := 0;
    end;
  end;
end;

procedure TfrmConfiguracoesSistema.CarregaConfiguracoes;
begin
  edDataBase.Text           := CONEXAO.Database;
  edServer.Text             := CONEXAO.Server;
  edUserName.Text           := CONEXAO.User_Name;
  edPassword.Text           := CONEXAO.Password;
  edCharSet.Text            := CONEXAO.CharacterSet;
  edDriverID.Text           := CONEXAO.DriverID;
  edPorta.Text              := CONEXAO.Port;
  edDiretorioRelatorio.Text := CONFIG_LOCAL.DirRelatorios;
  edDiretorioLogs.Text      := CONFIG_LOCAL.DirLog;
  edDirFTP.Text             := CONFIG_LOCAL.FTPDir;
  edUsuarioFTP.Text         := CONFIG_LOCAL.FTPUsuario;
  edSenhaFTP.Text           := CONFIG_LOCAL.FTPSenha;
  edSleepFTP.Text           := IntToStr(CONFIG_LOCAL.Sleep);
  edDirArquivosPDF.Text     := CONFIG_LOCAL.DIR_ARQ_PDF;
end;

procedure TfrmConfiguracoesSistema.edDiretorioRelatorioRightButtonClick(
  Sender: TObject);
var
  Pasta : String;
begin
  SelectDirectory('Selecione um Diretório!', '', Pasta);

  if (Trim(Pasta) <> '') then begin
    if (Pasta[Length(Pasta)] <> '\') then
      Pasta := Pasta + '\';
    TButtonedEdit(Sender).Text := Pasta;
  end;
end;

procedure TfrmConfiguracoesSistema.FormCreate(Sender: TObject);
begin
  AjustaForm(Self);
end;

procedure TfrmConfiguracoesSistema.FormShow(Sender: TObject);
begin
  CarregaConfiguracoes
end;

procedure TfrmConfiguracoesSistema.SalvaConfiguracoes;
Var
  ArqINI : TIniFile;
begin

  ArqINI := TIniFile.Create(DirArqConf);

  try

    ArqINI.WriteString('CONFIGURACOES', 'DIR_RELATORIOS', edDiretorioRelatorio.Text);
    ArqINI.WriteString('CONFIGURACOES','DIR_LOGS', edDiretorioLogs.Text);
    ArqINI.WriteString('CONFIGURACOES','FTP_DIR', edDirFTP.Text);
    ArqINI.WriteString('CONFIGURACOES','FTP_USUARIO', edUsuarioFTP.Text);
    ArqINI.WriteString('CONFIGURACOES','FTP_SENHA', edSenhaFTP.Text);
    ArqINI.WriteInteger('CONFIGURACOES','FTP_SLEEP', StrToInt(edSleepFTP.Text));
    ArqINI.WriteString('CONFIGURACOES','DIR_ARQ_PDF', edDirArquivosPDF.Text);

    ArqINI.WriteString('CONEXAOBD', 'Database', edDataBase.Text);
    ArqINI.WriteString('CONEXAOBD', 'Server', edServer.Text);
    ArqINI.WriteString('CONEXAOBD', 'User_Name', edUserName.Text);
    ArqINI.WriteString('CONEXAOBD', 'password', edPassword.Text);
    ArqINI.WriteString('CONEXAOBD', 'CharacterSet', edCharSet.Text);
    ArqINI.WriteString('CONEXAOBD', 'DriverID', edDriverID.Text);
    ArqINI.WriteString('CONEXAOBD', 'Port', edPorta.Text);

    Close;

  finally
    FreeAndNil(ArqINI);
  end;

end;

procedure TfrmConfiguracoesSistema.TestarConexao;
Var
  FWC     : TFWConnection;
  CON_AUX : TDADOSCONEXAO;
begin

  CON_AUX := CONEXAO;

  CONEXAO.Database      := edDataBase.Text;
  CONEXAO.Server        := edServer.Text;
  CONEXAO.User_Name     := edUserName.Text;
  CONEXAO.Password      := edPassword.Text;
  CONEXAO.CharacterSet  := edCharSet.Text;
  CONEXAO.DriverID      := edDriverID.Text;
  CONEXAO.Port          := edPorta.Text;

  try
    try
      FWC := TFWConnection.Create;
      FreeAndNil(FWC);
      DisplayMsg(MSG_OK, 'Conexão ao BD Realizado com Sucesso!');
    except
      on E : Exception do begin
        DisplayMsg(MSG_WAR, 'Erro ao Conectar ao BD!', '', E.Message);
      end;
    end;
  finally
    CONEXAO := CON_AUX;
  end;

end;

end.
