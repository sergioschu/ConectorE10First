unit uLogin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.jpeg,
  Vcl.StdCtrls, IniFiles, Vcl.Buttons;

type
  TFrmLogin = class(TForm)
    pnLogin: TPanel;
    pnConfig: TPanel;
    IMFundo: TImage;
    pnDadosLogin: TPanel;
    edUsuario: TEdit;
    edSenha: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    cbLembrarUsuario: TCheckBox;
    btEntrar: TBitBtn;
    btCancelar: TBitBtn;
    lbMensagemLogin: TLabel;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    edNome: TEdit;
    GroupBox4: TGroupBox;
    Panel1: TPanel;
    Label3: TLabel;
    Edit1: TEdit;
    Panel2: TPanel;
    Label4: TLabel;
    edServidor: TEdit;
    GroupBox5: TGroupBox;
    cbBancos: TComboBox;
    GroupBox6: TGroupBox;
    Panel3: TPanel;
    SpeedButton1: TSpeedButton;
    Panel4: TPanel;
    edCaminho: TEdit;
    pnRodape: TPanel;
    btConfirmar: TBitBtn;
    btFechar: TBitBtn;
    procedure EntrarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    Tentativas  : Smallint;
  public
    { Public declarations }
  end;

var
  FrmLogin: TFrmLogin;

implementation

uses
  uFuncoes,
  uConstantes,
  uMensagem;

{$R *.dfm}

procedure TFrmLogin.EntrarClick(Sender: TObject);
Var
  ArqINI : TIniFile;
begin
  if (Length(Trim(edUsuario.Text)) = 0) then begin

    DisplayMsg(MSG_WAR, 'O campo "Usuário" deve ser preenchido!');

    if edUsuario.CanFocus then
       edUsuario.SetFocus;
    Exit;

  end;

  if (Length(Trim(edSenha.Text)) = 0) then begin

    DisplayMsg(MSG_WAR, 'O campo "Senha" deve ser preenchido!');

    if edSenha.CanFocus then
       edSenha.SetFocus;

    Exit;

  end;

  if ValidaUsuario(edUsuario.Text, edSenha.Text) then begin

    ArqINI := TIniFile.Create(DirArqConf);
    try
      ArqINI.WriteBool('LOGIN', 'LEMBRARUSUARIO', cbLembrarUsuario.Checked);

      if cbLembrarUsuario.Checked then
        ArqINI.WriteString('LOGIN', 'USUARIO', edUsuario.Text)
      else
        ArqINI.WriteString('LOGIN', 'USUARIO', '');

    finally
      FreeAndNil(ArqINI);
    end;

    ModalResult := mrOk;

  end else begin

    lbMensagemLogin.Caption := 'Usuário/Senha Inválido!';

    inc(Tentativas); //Incrementa em 1 o valor da variável tentativas

    if Tentativas < 3 then begin

      if edSenha.CanFocus then begin
        edSenha.SetFocus;
        edSenha.SelectAll;
      end;

    end else begin
       ModalResult := mrCancel;
    end;
  end;

end;

procedure TFrmLogin.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ( Key = VK_ESCAPE) then
    Close;
end;

procedure TFrmLogin.FormShow(Sender: TObject);
begin

  if FileExists(DirInstall + 'Imagens\Fundo.jpg') then
    IMFundo.Picture.LoadFromFile(DirInstall + 'Imagens\Fundo.jpg');

  pnDadosLogin.Left := (Self.Width - pnDadosLogin.Width) div 2;
  pnDadosLogin.Top  := (Self.Height - pnDadosLogin.Height) div 2;

  edUsuario.Text            := LOGIN.Usuario;
  cbLembrarUsuario.Checked  := LOGIN.LembrarUsuario;
  edSenha.Clear;

  if Length(Trim(edUsuario.Text)) = 0 then begin
    if edUsuario.CanFocus then
      edUsuario.SetFocus;
  end else begin
    if edSenha.CanFocus then
      edSenha.SetFocus;
  end;
end;

end.
