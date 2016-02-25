unit uCadastroUsuario;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.DBGrids,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, FireDAC.Comp.Client, Data.DB,
  Datasnap.DBClient, Vcl.ImgList;

type
  TFrmCadastroUsuario = class(TForm)
    pnVisualizacao: TPanel;
    gdPesquisa: TDBGrid;
    pnEdicao: TPanel;
    dsPesquisa: TDataSource;
    csPesquisa: TClientDataSet;
    csPesquisaCODIGO: TIntegerField;
    csPesquisaNOME: TStringField;
    pnBotoesVisualizacao: TPanel;
    pnBotoesEdicao: TPanel;
    Panel1: TPanel;
    pnAjusteBotoes1: TPanel;
    pnPequisa: TPanel;
    edPesquisa: TEdit;
    csPesquisaEMAIL: TStringField;
    edNome: TEdit;
    edSenha: TEdit;
    edEmail: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label1: TLabel;
    Label4: TLabel;
    edConfirmarSenha: TEdit;
    btGravar: TSpeedButton;
    btCancelar: TSpeedButton;
    pnAjusteBotoes2: TPanel;
    btFechar: TSpeedButton;
    btExcluir: TSpeedButton;
    btAlterar: TSpeedButton;
    btNovo: TSpeedButton;
    csPesquisaSENHA: TStringField;
    btPesquisar: TSpeedButton;
    Panel2: TPanel;
    Panel3: TPanel;
    csPesquisaPERMITIRCADUSUARIO: TBooleanField;
    GridPanel1: TGridPanel;
    pnUsuarioEsquerda: TPanel;
    pnUsuarioDireita: TPanel;
    gdMenus: TDBGrid;
    csMenus: TClientDataSet;
    dsMenus: TDataSource;
    csMenusPERMITIR: TBooleanField;
    csMenusMENU: TStringField;
    csMenusCAPTION: TStringField;
    procedure sbFecharClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btBuscarClick(Sender: TObject);
    procedure csPesquisaFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure btNovoClick(Sender: TObject);
    procedure btAlterarClick(Sender: TObject);
    procedure btFecharClick(Sender: TObject);
    procedure btPesquisarClick(Sender: TObject);
    procedure btCancelarClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure btGravarClick(Sender: TObject);
    procedure btExcluirClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure gdMenusDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure gdMenusCellClick(Column: TColumn);
  private
    { Private declarations }
  public
    procedure CarregaDados;
    procedure CarregaMenus;
    procedure InvertePaineis;
    procedure Cancelar;
    procedure Filtrar;
    procedure AtualizarEdits(Limpar : Boolean);
    { Public declarations }
  end;

var
  FrmCadastroUsuario: TFrmCadastroUsuario;

implementation

uses
  uFWConnection,
  uMensagem,
  uBeanUsuario,
  uConstantes,
  uFuncoes,
  uBeanUsuario_Permissao;

{$R *.dfm}

procedure TFrmCadastroUsuario.AtualizarEdits(Limpar: Boolean);
begin
  if Limpar then begin
    edNome.Clear;
    edEmail.Clear;
    btGravar.Tag  := 0;
  end else begin
    edNome.Text                 := csPesquisaNOME.Value;
    edEmail.Text                := csPesquisaEMAIL.Value;
    edSenha.Text                := Criptografa(csPesquisaSENHA.Value, 'D');
    edConfirmarSenha.Text       := Criptografa(csPesquisaSENHA.Value, 'D');
    btGravar.Tag                := csPesquisaCODIGO.Value;
  end;
end;

procedure TFrmCadastroUsuario.btAlterarClick(Sender: TObject);
begin
  if not csPesquisa.IsEmpty then begin
    AtualizarEdits(False);
    CarregaMenus;
    InvertePaineis;
  end;
end;

procedure TFrmCadastroUsuario.btBuscarClick(Sender: TObject);
begin
  csPesquisa.Filtered := False;
  csPesquisa.Filtered := Length(edPesquisa.Text) > 0;
end;

procedure TFrmCadastroUsuario.btCancelarClick(Sender: TObject);
begin
  Cancelar;
end;

procedure TFrmCadastroUsuario.btExcluirClick(Sender: TObject);
Var
  FWC : TFWConnection;
  USU : TUSUARIO;
begin
  if not csPesquisa.IsEmpty then begin

    DisplayMsg(MSG_CONF, 'Excluir o Usuário Selecionado?');

    if ResultMsgModal = mrYes then begin

      try

        FWC := TFWConnection.Create;
        USU := TUSUARIO.Create(FWC);
        try

          USU.ID.Value := csPesquisaCODIGO.Value;
          USU.Delete;

          FWC.Commit;

          csPesquisa.Delete;

        except
          on E : Exception do begin
            FWC.Rollback;
            DisplayMsg(MSG_ERR, 'Erro ao Excluir Usuário, Verifique!', '', E.Message);
          end;
        end;
      finally
        FreeAndNil(USU);
        FreeAndNil(FWC);
      end;
    end;
  end;
end;

procedure TFrmCadastroUsuario.btFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmCadastroUsuario.btGravarClick(Sender: TObject);
Var
  FWC : TFWConnection;
  USU : TUSUARIO;
  UP  : TUSUARIO_PERMISSAO;
  I   : Integer;
begin

  try
    FWC := TFWConnection.Create;
    USU := TUSUARIO.Create(FWC);
    UP  := TUSUARIO_PERMISSAO.Create(FWC);
    try

      if Length(Trim(edNome.Text)) = 0 then begin
        DisplayMsg(MSG_WAR, 'Nome não informado, Verifique!');
        if edNome.CanFocus then
          edNome.SetFocus;
        Exit;
      end;

      if Length(Trim(edEmail.Text)) = 0 then begin
        DisplayMsg(MSG_WAR, 'Usuário/Email não informado, Verifique!');
        if edEmail.CanFocus then
          edEmail.SetFocus;
        Exit;
      end;

      if edSenha.Text <> edConfirmarSenha.Text then begin
        DisplayMsg(MSG_WAR, 'Senha de Confirmação não confere, Verifique!');
        if edConfirmarSenha.CanFocus then
          edConfirmarSenha.SetFocus;
        Exit;
      end;

      USU.NOME.Value                    := edNome.Text;
      USU.EMAIL.Value                   := edEmail.Text;

      if (Sender as TSpeedButton).Tag > 0 then begin
        USU.ID.Value                    := (Sender as TSpeedButton).Tag;
        USU.SENHA.Value                 := Criptografa(edSenha.Text, 'E');
        USU.Update;
      end else begin
        USU.SENHA.Value                 := Criptografa(edSenha.Text, 'E');
        USU.Insert;
      end;

      csMenus.DisableControls;
      try
        UP.SelectList('ID_USUARIO = ' + USU.ID.asSQL);
        if UP.Count > 0 then begin
          for I := 0 to Pred(UP.Count) do begin
            UP.ID.Value                 := TUSUARIO_PERMISSAO(UP.Itens[I]).ID.Value;
            UP.Delete;
          end;
        end;

        csMenus.First;
        while not csMenus.Eof do begin
          if csMenusPERMITIR.Value then begin
            UP.ID_USUARIO.Value         := USU.ID.Value;
            UP.MENU.Value               := csMenusMENU.Value;
            UP.Insert;
          end;

          csMenus.Next;
        end;
      finally
        csMenus.EnableControls;
      end;
      FWC.Commit;

      InvertePaineis;

      CarregaDados;
    except
      On E : Exception do begin
        FWC.Rollback;
        DisplayMsg(MSG_WAR, 'Erro ao Gravar Usuário!', '', E.Message);
      end;
    end;
  finally
    FreeAndNil(USU);
    FreeAndNil(UP);
    FreeAndNil(FWC);
  end;
end;

procedure TFrmCadastroUsuario.btNovoClick(Sender: TObject);
begin
  AtualizarEdits(True);
  CarregaMenus;
  InvertePaineis;
end;

procedure TFrmCadastroUsuario.btPesquisarClick(Sender: TObject);
begin
  Filtrar;
end;

procedure TFrmCadastroUsuario.Cancelar;
begin
  InvertePaineis;
end;

procedure TFrmCadastroUsuario.CarregaDados;
Var
  FWC : TFWConnection;
  USU : TUSUARIO;
  I   : Integer;
begin

  try
    FWC := TFWConnection.Create;
    USU := TUSUARIO.Create(FWC);
    try

      csPesquisa.EmptyDataSet;

      USU.SelectList();
      if USU.Count > 0 then begin
        for I := 0 to USU.Count -1 do begin
          csPesquisa.Append;
          csPesquisaCODIGO.Value              := TUSUARIO(USU.Itens[I]).ID.Value;
          csPesquisaNOME.Value                := TUSUARIO(USU.Itens[I]).NOME.Value;
          csPesquisaEMAIL.Value               := TUSUARIO(USU.Itens[I]).EMAIL.Value;
          csPesquisaSENHA.Value               := TUSUARIO(USU.Itens[I]).SENHA.Value;
          csPesquisa.Post;
        end;
      end;

    except
      on E : Exception do begin
        DisplayMsg(MSG_ERR, 'Erro ao Carregar os dados da Tela.', '', E.Message);
      end;
    end;

  finally
    FreeAndNil(USU);
    FreeAndNil(FWC);
  end;
end;

procedure TFrmCadastroUsuario.CarregaMenus;
var
  I     : Integer;
  CON   : TFWConnection;
  PU    : TUSUARIO_PERMISSAO;
begin
  csMenus.EmptyDataSet;
  csMenus.DisableControls;
  try
    for I := 0 to High(MENUS) do begin
      csMenus.Append;
      csMenusPERMITIR.Value        := False;
      csMenusMENU.Value            := MENUS[I].NOME;
      csMenusCAPTION.Value         := MENUS[I].CAPTION;
      csMenusPERMITIR.Value        := False;
      csMenus.Post;
    end;

    if btGravar.Tag > 0 then begin
      CON                            := TFWConnection.Create;
      PU                             := TUSUARIO_PERMISSAO.Create(CON);
      try
        PU.SelectList('ID_USUARIO = ' + IntToStr(btGravar.Tag));
        for I := 0 to Pred(PU.Count) do begin
          if csMenus.Locate(csMenusMENU.FieldName, TUSUARIO_PERMISSAO(PU.Itens[I]).MENU.Value, []) then begin
            csMenus.Edit;
            csMenusPERMITIR.Value    := True;
            csMenus.Post;
          end;
        end;
      finally
        FreeAndNil(PU);
        FreeAndNil(CON);
      end;
    end;
  finally
    csMenus.EnableControls;
  end;
end;

procedure TFrmCadastroUsuario.csPesquisaFilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
Var
  I : Integer;
begin
  Accept := False;
  for I := 0 to DataSet.Fields.Count - 1 do begin
    if not DataSet.Fields[I].IsNull then begin
      if Pos(AnsiLowerCase(edPesquisa.Text),AnsiLowerCase(DataSet.Fields[I].AsVariant)) > 0 then begin
        Accept := True;
        Break;
      end;
    end;
  end;
end;

procedure TFrmCadastroUsuario.Filtrar;
begin
  csPesquisa.Filtered := False;
  csPesquisa.Filtered := Length(edPesquisa.Text) > 0;
end;

procedure TFrmCadastroUsuario.FormCreate(Sender: TObject);
begin
  AjustaForm(Self);
end;

procedure TFrmCadastroUsuario.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

  case Key of
    VK_ESCAPE : begin
      if pnVisualizacao.Visible then
        Close
      else
        Cancelar;
    end;
    VK_RETURN : begin
      if edPesquisa.Focused then begin
        Filtrar;
      end else begin
        if edPesquisa.CanFocus then begin
          edPesquisa.SetFocus;
          edPesquisa.SelectAll;
        end;
      end;
    end;
    VK_UP : begin
      if not csPesquisa.IsEmpty then begin
        if csPesquisa.RecNo > 1 then
          csPesquisa.Prior;
      end;
    end;
    VK_DOWN : begin
      if not csPesquisa.IsEmpty then begin
        if csPesquisa.RecNo < csPesquisa.RecordCount then
          csPesquisa.Next;
      end;
    end else begin
      if not edPesquisa.Focused then begin
        if edPesquisa.CanFocus then begin
          edPesquisa.SetFocus;
        end;
      end;
    end;
  end;
end;

procedure TFrmCadastroUsuario.FormResize(Sender: TObject);
begin
  pnAjusteBotoes1.Width := ((pnBotoesVisualizacao.ClientWidth div 2) - (btExcluir.Left - btNovo.Left));
  pnAjusteBotoes2.Width := ((pnBotoesVisualizacao.ClientWidth div 2) - btGravar.Width) - 3;
end;

procedure TFrmCadastroUsuario.FormShow(Sender: TObject);
begin
  csPesquisa.CreateDataSet;
  CarregaDados;
  AutoSizeDBGrid(gdPesquisa);

  csMenus.CreateDataSet;
  csMenus.Open;

  if edPesquisa.CanFocus then
    edPesquisa.SetFocus;
end;

procedure TFrmCadastroUsuario.gdMenusCellClick(Column: TColumn);
begin
  csMenus.Edit;
  csMenusPERMITIR.Value     := not csMenusPERMITIR.Value;
  csMenus.Post;
end;

procedure TFrmCadastroUsuario.gdMenusDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
Const
  CtrlState : array[Boolean] of Integer = (DFCS_BUTTONCHECK, DFCS_BUTTONCHECK or DFCS_CHECKED);
var
  CheckBoxRectangle : TRect;
begin
  if ((gdSelected in State) or (gdFocused in State)) then begin
    gdMenus.Canvas.Font.Color  := clWhite;
    gdMenus.Canvas.Brush.Color := clBlue;
    gdMenus.Canvas.Font.Style  := [];
  end;

  gdMenus.DefaultDrawDataCell(Rect, gdMenus.Columns[DataCol].Field, State);

  if Column.Field.FieldName = csMenusPERMITIR.FieldName then begin
    gdMenus.Canvas.FillRect(Rect);
    CheckBoxRectangle.Left   := Rect.Left + 2;
    CheckBoxRectangle.Right  := Rect.Right - 2;
    CheckBoxRectangle.Top    := Rect.Top + 2;
    CheckBoxRectangle.Bottom := Rect.Bottom - 2;
    DrawFrameControl(gdMenus.Canvas.Handle, CheckBoxRectangle, DFC_BUTTON, CtrlState[Column.Field.AsBoolean]);
  end;
end;

procedure TFrmCadastroUsuario.InvertePaineis;
begin
  pnVisualizacao.Visible        := not pnVisualizacao.Visible;
  pnBotoesVisualizacao.Visible  := pnVisualizacao.Visible;
  pnEdicao.Visible              := not pnEdicao.Visible;
  pnBotoesEdicao.Visible        := pnEdicao.Visible;
  if pnEdicao.Visible then begin
    if edNome.CanFocus then
      edNome.SetFocus;
  end;
end;

procedure TFrmCadastroUsuario.sbFecharClick(Sender: TObject);
begin
  Close;
end;

end.
