unit uRedefinirSenha;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls;

type
  TFrmRedefinirSenha = class(TForm)
    pnFields: TPanel;
    pnBotoes: TPanel;
    pnAjusteBotoes2: TPanel;
    Label3: TLabel;
    edConfirmarNovaSenha: TEdit;
    Label4: TLabel;
    edNovaSenha: TEdit;
    edSenhaAtual: TEdit;
    Label1: TLabel;
    btGravar: TBitBtn;
    btCancelar: TBitBtn;
    procedure btCancelarClick(Sender: TObject);
    procedure btGravarClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmRedefinirSenha: TFrmRedefinirSenha;

implementation

uses
  uFWConnection,
  uBeanUsuario,
  uMensagem,
  uConstantes,
  uFuncoes;

{$R *.dfm}

procedure TFrmRedefinirSenha.btCancelarClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmRedefinirSenha.btGravarClick(Sender: TObject);
Var
  FWC : TFWConnection;
  USU : TUSUARIO;
begin

  ModalResult := mrNone;

  FWC := TFWConnection.Create;
  USU := TUSUARIO.Create(FWC);
  try
    try
      USU.SelectList('ID = ' + IntToStr(USUARIO.CODIGO));
      if USU.Count > 0 then begin

        if Trim(Criptografa(TUSUARIO(USU.Itens[0]).SENHA.Value, 'D')) = Trim(edSenhaAtual.Text) then begin

          if Trim(edNovaSenha.Text) = EmptyStr then begin
            DisplayMsg(MSG_WAR, 'Senha está vazia, Verifique!');
            if edNovaSenha.CanFocus then
              edNovaSenha.SetFocus;
            Exit;
          end;

          if edNovaSenha.Text <> edConfirmarNovaSenha.Text then begin
            DisplayMsg(MSG_WAR, 'Senha de Confirmação não confere, Verifique!');
            if edConfirmarNovaSenha.CanFocus then
              edConfirmarNovaSenha.SetFocus;
            Exit;
          end;

          USU.ID.Value      := USUARIO.CODIGO;
          USU.SENHA.Value   := Criptografa(edNovaSenha.Text, 'E');
          USU.Update;

          FWC.Commit;

          ModalResult := mrOk;

        end else begin
          DisplayMsg(MSG_WAR, 'Senha Atual não Confere!');
          if edSenhaAtual.CanFocus then
            edSenhaAtual.SetFocus;
          Exit;
        end;

      end else begin
        DisplayMsg(MSG_WAR, 'Usuário ' + IntToStr(USUARIO.CODIGO) + ' não Localizado!');
      end;

    except
      on E : Exception do begin
        FWC.Rollback;
        DisplayMsg(MSG_ERR, 'Erro ao gravar redefinição de Senha, Verifique!', '', E.Message);
      end;
    end;
  finally
    FreeAndNil(USU);
    FreeAndNil(FWC);
  end;
end;

procedure TFrmRedefinirSenha.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE : Close;
  end;
end;

end.
