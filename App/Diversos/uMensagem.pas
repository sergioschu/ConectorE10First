unit uMensagem;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, ImgList, keyboard;

Type
  eMSG = (MSG_ERR, MSG_WAR, MSG_INF, MSG_WAIT, MSG_CONF, MSG_OK, MSG_PASSWORD,
          MSG_INPUT_TEXT, MSG_INPUT_INT, MSG_INPUT_CURR);

type
  TfrmMensagem = class(TForm)
    pnFundo: TPanel;
    pnMsgExtendida: TPanel;
    mmMsgExtendida: TMemo;
    imMsgStatus: TImage;
    pnTiraAlerta: TPanel;
    Panel1: TPanel;
    btNao: TBitBtn;
    btOk: TBitBtn;
    btSim: TBitBtn;
    Bevel1: TBevel;
    lbDetalhes: TLabel;
    Bevel2: TBevel;
    ilDetalhes: TImageList;
    btDetalhes: TSpeedButton;
    ilMsgStatus: TImageList;
    Bevel3: TBevel;
    ilBotoes: TImageList;
    lbMsg: TLabel;
    edEdit: TEdit;
    btTeclado: TSpeedButton;
    procedure lbDetalhesClick(Sender: TObject);
    procedure btSimClick(Sender: TObject);
    procedure btNaoClick(Sender: TObject);
    procedure btOkClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure btTecladoClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    iMsgTypeNo : eMSG;
    function RemoveControlChars(const InputStr: String): String;
  public
  end;

  function  DisplayMsg(const MsgTypeNo: eMSG; MsgText: String; Titulo: String = ''; MsgExtendida: String = ''): TForm;
  Procedure DisplayMsgFinaliza;

var
  frmMensagem         : TfrmMensagem;
  kbTeclado           : TTouchKeyboard;
  ResultMsgModal      : TModalResult;
  ResultMsgInputText  : String;
  ResultMsgInputInt   : Integer;
  ResultMsgInputCurr  : Currency;

implementation

{$R *.dfm}

uses uFuncoes, uConstantes;

function DisplayMsg(const MsgTypeNo: eMSG; MsgText: String; Titulo: String = ''; MsgExtendida: String = ''): TForm;

begin
  DisplayMsgFinaliza;

  frmMensagem := TfrmMensagem.Create(Application);
  try
    MsgText       := frmMensagem.RemoveControlChars(MsgText);
    Titulo        := frmMensagem.RemoveControlChars(Titulo);
    MsgExtendida  := frmMensagem.RemoveControlChars(MsgExtendida);

    frmMensagem.iMsgTypeNo                := MsgTypeNo;
    frmMensagem.pnMsgExtendida.Visible    := False;
    frmMensagem.ClientHeight              := 276;
    ResultMsgModal                        := mrCancel;
    frmMensagem.btDetalhes.Visible        := ((MsgTypeNo in [MSG_ERR, MSG_WAR, MSG_INF, MSG_OK, MSG_CONF]) and (MsgExtendida <> ''));
    frmMensagem.lbDetalhes.Visible        := ((MsgTypeNo in [MSG_ERR, MSG_WAR, MSG_INF, MSG_OK, MSG_CONF]) and (MsgExtendida <> ''));
    frmMensagem.btSim.Visible             := (MsgTypeNo = MSG_CONF);
    frmMensagem.btNao.Visible             := (MsgTypeNo in [MSG_CONF, MSG_PASSWORD, MSG_INPUT_TEXT, MSG_INPUT_INT, MSG_INPUT_CURR]);
    frmMensagem.btOk.Visible              := (MsgTypeNo <> MSG_CONF);
    frmMensagem.edEdit.Visible            := (MsgTypeNo in [MSG_PASSWORD, MSG_INPUT_TEXT, MSG_INPUT_INT, MSG_INPUT_CURR]);
    frmMensagem.btTeclado.Visible         := (MsgTypeNo in [MSG_PASSWORD, MSG_INPUT_TEXT, MSG_INPUT_INT, MSG_INPUT_CURR]);
    frmMensagem.lbMsg.Caption             := MsgText;
    frmMensagem.mmMsgExtendida.Text       := MsgExtendida;

    case MsgTypeNo of
      MSG_ERR :   begin
                    frmMensagem.Caption               := 'ERRO';
                    frmMensagem.pnTiraAlerta.Caption  := 'ERRO';
                    frmMensagem.pnTiraAlerta.Color    := clRed;
                    frmMensagem.ilMsgStatus.GetBitmap(1, frmMensagem.imMsgStatus.Picture.Bitmap);
                    frmMensagem.btOk.Caption          := '&Fechar';
                    frmMensagem.ilBotoes.GetBitmap(2, frmMensagem.btOk.Glyph);
                  end;
      MSG_WAR :   begin
                    frmMensagem.Caption               := 'ATENÇÃO';
                    frmMensagem.pnTiraAlerta.Caption  := 'ATENÇÃO';
                    frmMensagem.pnTiraAlerta.Color    := $003E9EFF;
                    frmMensagem.ilMsgStatus.GetBitmap(0, frmMensagem.imMsgStatus.Picture.Bitmap);
                    frmMensagem.btOk.Caption          := '&Fechar';
                    frmMensagem.ilBotoes.GetBitmap(2, frmMensagem.btOk.Glyph);
                  end;
      MSG_INF :   begin
                    frmMensagem.Caption               := 'INFORMAÇÃO';
                    frmMensagem.pnTiraAlerta.Caption  := 'INFORMAÇÃO';
                    frmMensagem.pnTiraAlerta.Color    := $00E17100;
                    frmMensagem.ilMsgStatus.GetBitmap(3, frmMensagem.imMsgStatus.Picture.Bitmap);
                    frmMensagem.ilBotoes.GetBitmap(2, frmMensagem.btOk.Glyph);
                  end;
      MSG_WAIT :  begin
                    frmMensagem.Caption               := 'AGUARDE';
                    frmMensagem.pnTiraAlerta.Caption  := 'AGUARDE';
                    frmMensagem.pnTiraAlerta.Color    := $00E17100;
                    frmMensagem.ilMsgStatus.GetBitmap(5, frmMensagem.imMsgStatus.Picture.Bitmap);
                    frmMensagem.btOk.Caption          := 'Aguarde...';
                    frmMensagem.btOk.OnClick          := nil;
                    frmMensagem.btOk.Glyph            := nil;
                    frmMensagem.ilBotoes.GetBitmap(0, frmMensagem.btOk.Glyph);
                  end;
      MSG_CONF :  begin
                    frmMensagem.Caption               := 'CONFIRMAÇÃO';
                    frmMensagem.pnTiraAlerta.Caption  := 'CONFIRMAÇÃO';
                    frmMensagem.pnTiraAlerta.Color    := $00E17100;
                    frmMensagem.ilMsgStatus.GetBitmap(2, frmMensagem.imMsgStatus.Picture.Bitmap);
                    frmMensagem.ilBotoes.GetBitmap(3, frmMensagem.btSim.Glyph);
                    frmMensagem.ilBotoes.GetBitmap(1, frmMensagem.btNao.Glyph);
                  end;
      MSG_OK :    begin
                    frmMensagem.Caption               := 'SUCESSO';
                    frmMensagem.pnTiraAlerta.Caption  := 'SUCESSO';
                    frmMensagem.pnTiraAlerta.Color    := clGreen;
                    frmMensagem.ilMsgStatus.GetBitmap(4, frmMensagem.imMsgStatus.Picture.Bitmap);
                    frmMensagem.btOk.Caption          := '&OK';
                    frmMensagem.ilBotoes.GetBitmap(3, frmMensagem.btOk.Glyph);
                  end;
      MSG_PASSWORD:begin
                    frmMensagem.Caption               := 'DIGITE A SENHA DE LIBERAÇÃO';
                    frmMensagem.pnTiraAlerta.Caption  := 'SENHA DE LIBERAÇÃO';
                    frmMensagem.pnTiraAlerta.Color    := clGray;
                    frmMensagem.ilMsgStatus.GetBitmap(6, frmMensagem.imMsgStatus.Picture.Bitmap);
                    frmMensagem.btNao.Caption         := '&OK';
                    frmMensagem.ilBotoes.GetBitmap(3, frmMensagem.btNao.Glyph);
                    frmMensagem.btNao.Default         := True;
                    frmMensagem.btNao.Cancel          := False;
                    frmMensagem.btNao.ModalResult     := mrOK;
                    frmMensagem.btOk.Caption          := '&Fechar';
                    frmMensagem.ilBotoes.GetBitmap(2, frmMensagem.btOk.Glyph);
                    frmMensagem.btOk.Default          := False;
                    frmMensagem.btOk.Cancel           := True;
                    frmMensagem.EdEdit.PasswordChar   := '*';
                  end;
      MSG_INPUT_TEXT,
      MSG_INPUT_INT,
      MSG_INPUT_CURR
                : begin
                    frmMensagem.Caption               := 'INSIRA UM VALOR';
                    frmMensagem.pnTiraAlerta.Caption  := 'INSIRA UM VALOR';
                    frmMensagem.pnTiraAlerta.Color    := $00F59D25;
                    frmMensagem.ilMsgStatus.GetBitmap(7, frmMensagem.imMsgStatus.Picture.Bitmap);
                    frmMensagem.btNao.Caption         := '&OK';
                    frmMensagem.ilBotoes.GetBitmap(3, frmMensagem.btNao.Glyph);
                    frmMensagem.btNao.Default         := True;
                    frmMensagem.btNao.Cancel          := False;
                    frmMensagem.btNao.ModalResult     := mrOK;
                    frmMensagem.btOk.Caption          := '&Fechar';
                    frmMensagem.ilBotoes.GetBitmap(2, frmMensagem.btOk.Glyph);
                    frmMensagem.btOk.Default          := False;
                    frmMensagem.btOk.Cancel           := True;
                    frmMensagem.EdEdit.PasswordChar   := #0;
                  end;
    end;

    if (Titulo <> '') then begin
      frmMensagem.Caption               := Titulo;
      frmMensagem.pnTiraAlerta.Caption  := Titulo;
    end;

    if (MsgTypeNo <> MSG_WAIT) then
      frmMensagem.ShowModal
    else
      frmMensagem.Show;

    Application.ProcessMessages;
  finally
    if (MsgTypeNo <> MSG_WAIT) then
      FreeAndNil(frmMensagem);
  end;

  Result := frmMensagem;
end;

procedure DisplayMsgFinaliza;
  var
    I : Integer;
begin
  for I := Application.ComponentCount -1 downto 0 do
    if (Application.Components[I] <> Nil) and (Copy(Application.Components[I].Name, 1, 11) = 'frmMensagem') then
      Application.Components[I].Free;
end;

procedure TfrmMensagem.btNaoClick(Sender: TObject);
begin
  case iMsgTypeNo of
    MSG_INPUT_TEXT  : begin
                        ResultMsgInputText  := edEdit.Text;
                        ResultMsgModal      := mrOk;
                      end;
    MSG_INPUT_INT   : begin
                        try
                          ResultMsgInputInt   := StrToInt(edEdit.Text);
                          ResultMsgModal      := mrOk;
                        except
                          on E:Exception do begin
                            ResultMsgModal    := mrNone;
                            ModalResult       := mrNone;
                            lbMsg.Caption     := 'Insira um valor numérico inteiro válido!';
                            lbMsg.Font.Color  := clRed;
                            edEdit.SetFocus;
                          end;
                        end;
                      end;
    MSG_INPUT_CURR  : begin
                        try
                          ResultMsgInputCurr  := StrToCurr(edEdit.Text);
                          ResultMsgModal      := mrOk;
                        except
                          on E:Exception do begin
                            ResultMsgModal    := mrNone;
                            ModalResult       := mrNone;
                            lbMsg.Caption     := 'Insira um valor numérico real válido!';
                            lbMsg.Font.Color  := clRed;
                            edEdit.SetFocus;
                          end;
                        end;
                      end;
    else begin
      ResultMsgModal  := mrNo;
      Close;
    end;
  end;
end;

procedure TfrmMensagem.btOkClick(Sender: TObject);
begin
  ResultMsgModal  := mrAbort;
  Close;
end;

procedure TfrmMensagem.btSimClick(Sender: TObject);
begin
  ResultMsgModal  := mrYes;
  Close;
end;

procedure TfrmMensagem.btTecladoClick(Sender: TObject);
begin
  if kbTeclado = nil then begin
    frmMensagem.ClientWidth   := 850;
    frmMensagem.ClientHeight  := 500;
    kbTeclado                 := TTouchKeyboard.Create(nil);
    kbTeclado.RepeatRate      := 0;
    kbTeclado.RepeatDelay     := 0;
    kbTeclado.Align           := alBottom;
    kbTeclado.Height          := 500 - 276;
    kbTeclado.Parent          := Self;
    if iMsgTypeNo in [MSG_INPUT_INT, MSG_INPUT_CURR] then
      kbTeclado.Layout        := 'NumPad';
  end
  else begin
    frmMensagem.ClientWidth   := 550;
    frmMensagem.ClientHeight  := 276;
    FreeAndNil(kbTeclado);
  end;
end;

procedure TfrmMensagem.FormActivate(Sender: TObject);
begin
  Self.FormStyle := fsNormal;
end;

procedure TfrmMensagem.FormDeactivate(Sender: TObject);
begin
  Self.FormStyle := fsStayOnTop;
end;

procedure TfrmMensagem.FormDestroy(Sender: TObject);
begin
  FreeAndNil(kbTeclado);
end;

procedure TfrmMensagem.lbDetalhesClick(Sender: TObject);
begin
  pnMsgExtendida.Visible := not pnMsgExtendida.Visible;
  if pnMsgExtendida.Visible then begin
    frmMensagem.ClientHeight  := 400;
    lbDetalhes.Caption        := '&Ocultar Detalhes';
    btDetalhes.Glyph          := nil;
    ilDetalhes.GetBitmap(0, btDetalhes.Glyph);
  end
  else begin
    frmMensagem.ClientHeight  := 276;
    lbDetalhes.Caption        := '&Mostrar Detalhes';
    btDetalhes.Glyph          := nil;
    ilDetalhes.GetBitmap(1, btDetalhes.Glyph);
  end;
end;

function TfrmMensagem.RemoveControlChars(const InputStr: String): String;
  var
    I       : Integer;
    lStrVal : String;
begin
  lStrVal := Trim(InputStr);

  for I := 1 to Length(lStrVal) - 1 do
    if (Ord(lStrVal[I]) in [32..126]) then
      if ((lStrVal[I] = Chr(32)) and (lStrVal[I+1] = Chr(32))) then
        Delete(lStrVal,I,1);

  if (Length(lStrVal) > 0) then
    lStrVal[1] := UpCase(lStrVal[1]);

  Result := lStrVal;
end;

end.

