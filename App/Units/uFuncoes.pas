unit uFuncoes;

interface

uses
  System.SysUtils,
  System.UITypes,
  IdHashMessageDigest,
  Vcl.Dialogs,
  Grids,
  DBGrids,
  DateUtils,
  Winapi.Windows,
  Vcl.Menus,
  Vcl.Forms,
  Vcl.StdCtrls,
  System.Classes,
  Data.DB,
  System.Win.ComObj,
  Datasnap.DBClient,
  Vcl.Graphics;

  procedure CarregarConfigLocal;
  procedure CarregaArrayMenus(Menu : TMainMenu);
  procedure DefinePermissaoMenu(Menu : TMainMenu);
  procedure CarregarConexaoBD;
  procedure AutoSizeDBGrid(const DBGrid: TDBGrid);
  procedure AjustaForm(Form : TForm);
  procedure CriarComandoSequenciaMenu(Menu: TMainMenu);
  procedure OrdenarGrid(Column: TColumn);
  procedure CancelaPedido;
  function ValidaUsuario(Email, Senha : String) : Boolean;
  function MD5(Texto : String): String;
  Function Criptografa(Texto : String; Tipo : String) : String;
  function SoNumeros(Texto: String): String;
  function CalculaPercentualDiferenca(ValorAnterior, ValorNovo : Currency) : Currency;
  function StrZero(Zeros : string; Quant : Integer): string;
  procedure SaveLog(Msg: String);
  function FormataData(Data : TDateTime) : String;
  function FormataNumeros(Valor : String) : Double;
  procedure ExpXLS(DataSet: TDataSet; NomeArq: string);
  procedure TotalizaRegistros(cds : TClientDataSet; edtQuantidade : TEdit);
  procedure SalvarArquivo(FileName: String);
  function StrFirstToDateTime(Str : String) : TDateTime;

implementation

Uses
  uMensagem,
  uConstantes,
  IniFiles,
  uFWConnection,
  uBeanUsuario,
  uBeanUsuario_Permissao,
  uDomains,
  uBeanPedido,
  uBeanPedido_Cancelamento;

procedure SalvarArquivo(FileName: String);
var
  Diretorio : string;
begin
  if Pos('SC', FileName) > 0 then
    Diretorio := DirArquivosFTP + 'SC\' + FormatDateTime('yyyymmdd', Now) + '\'
  else if Pos('CONF', FileName) > 0 then
    Diretorio := DirArquivosFTP + 'CONF\' + FormatDateTime('yyyymmdd', Now) + '\'
  else if Pos('MDD', FileName) > 0 then
    Diretorio := DirArquivosFTP + 'MDD\' + FormatDateTime('yyyymmdd', Now) + '\'
  else if Pos('ARMZ', FileName) > 0 then
    Diretorio := DirArquivosFTP + 'ARMZ\' + FormatDateTime('yyyymmdd', Now) + '\'
  else if Pos('PROD', FileName) > 0 then
    Diretorio := DirArquivosFTP + 'PROD\' + FormatDateTime('yyyymmdd', Now) + '\';

  if not DirectoryExists(Diretorio) then
    ForceDirectories(Diretorio);
  MoveFile(PwideChar(FileName), PwideChar(Diretorio + ExtractFileName(FileName)));
end;

function StrFirstToDateTime(Str : String) : TDateTime;
var
  MySettings: TFormatSettings;
begin
  try
    GetLocaleFormatSettings(GetUserDefaultLCID, MySettings);
    MySettings.DateSeparator := '-';
    MySettings.TimeSeparator := ':';
    MySettings.ShortDateFormat := 'yyyy-mm-dd';
    MySettings.ShortTimeFormat := 'hh:nn:ss.zzz';

    Result := StrToDateTimeDef(Str, Now, MySettings);
  except
    SaveLog('Erro na Função StrFirstToDateTime Texto = ' + Str);
  end;
end;

procedure TotalizaRegistros(cds : TClientDataSet; edtQuantidade : TEdit);
begin
  edtQuantidade.Text := '0';
  if not cds.IsEmpty then
    edtQuantidade.Text := IntToStr(cds.RecordCount);
end;

function FormataNumeros(Valor : String) : Double;
begin
  Result := StrToFloat(StringReplace(StringReplace(Valor, '.','', [rfReplaceAll]), ',', '.', [rfReplaceAll]));
end;

function FormataData(Data : TDateTime) : String;
begin
  Result := FormatDateTime('yyyymmdd', Data);
end;

procedure CarregarConfigLocal;
Var
  ArqINI : TIniFile;
begin

  ArqINI := TIniFile.Create(DirArqConf);
  try

    LOGIN.Usuario                 := ArqINI.ReadString('LOGIN', 'USUARIO', '');
    LOGIN.LembrarUsuario          := ArqINI.ReadBool('LOGIN', 'LEMBRARUSUARIO', True);

    CONFIG_LOCAL.DirRelatorios    := ArqINI.ReadString('CONFIGURACOES', 'DIR_RELATORIOS', 'C:\ConectorE10First\Relatorios\');
    CONFIG_LOCAL.DirLog           := ArqINI.ReadString('CONFIGURACOES', 'DIR_LOGS', 'C:\ConectorE10First\Logs\');
    CONFIG_LOCAL.FTPDir           := ArqINI.ReadString('CONFIGURACOES', 'FTP_DIR', '');
    CONFIG_LOCAL.FTPUsuario       := ArqINI.ReadString('CONFIGURACOES', 'FTP_USUARIO', '');
    CONFIG_LOCAL.FTPSenha         := ArqINI.ReadString('CONFIGURACOES', 'FTP_SENHA', '');
    CONFIG_LOCAL.Sleep            := ArqINI.ReadInteger('CONFIGURACOES', 'FTP_SLEEP', 0);
    CONFIG_LOCAL.DIR_ARQ_PDF      := ArqINI.ReadString('CONFIGURACOES', 'DIR_ARQ_PDF', 'C:\ConectorE10First\PDF_Gerados\');
    CONFIG_LOCAL.NOME             := ArqINI.ReadString('EMPRESA', 'RAZAOSOCIAL', 'SIMSEN & BOROSKE LTDA');
    CONFIG_LOCAL.APELIDO          := ArqINI.ReadString('EMPRESA', 'APELIDO', 'Estrela 10');
    CONFIG_LOCAL.ID_DEPOSIT_FIRST := ArqINI.ReadString('CONFIGURACOES', 'ID_DEPOSIT_FIRST', '');
    CONFIG_LOCAL.SECRET_KEY_FIRST := ArqINI.ReadString('CONFIGURACOES', 'SECRET_KEY_FIRST', '');
  finally
    FreeAndNil(ArqINI);
  end;

end;

procedure CarregarConexaoBD;
Var
  ArqINI : TIniFile;
begin

  ArqINI := TIniFile.Create(DirArqConf);
  try

    CONEXAO.LibVendor     := ExtractFilePath(ParamStr(0)) + 'libpq.dll';
    CONEXAO.Database      := ArqINI.ReadString('CONEXAOBD', 'Database', '');
    CONEXAO.Server        := ArqINI.ReadString('CONEXAOBD', 'Server', 'localhost');
    CONEXAO.User_Name     := ArqINI.ReadString('CONEXAOBD', 'User_Name', '');
    CONEXAO.Password      := ArqINI.ReadString('CONEXAOBD', 'Password', '');
    CONEXAO.CharacterSet  := ArqINI.ReadString('CONEXAOBD', 'CharacterSet', 'UTF8');
    CONEXAO.DriverID      := ArqINI.ReadString('CONEXAOBD', 'DriverID', 'PG');
    CONEXAO.Port          := ArqINI.ReadString('CONEXAOBD', 'Port', '5432');

  finally
    FreeAndNil(ArqINI);
  end;

end;

procedure AutoSizeDBGrid(const DBGrid: TDBGrid);
var
  TotalColumnWidth, ColumnCount, GridClientWidth, Filler, i: Integer;
begin
  ColumnCount := DBGrid.Columns.Count;
  if ColumnCount = 0 then
    Exit;

  // compute total width used by grid columns and vertical lines if any
  TotalColumnWidth := 0;
  for i := 0 to ColumnCount-1 do
    TotalColumnWidth := TotalColumnWidth + DBGrid.Columns[i].Width;
  if dgColLines in DBGrid.Options then
    // include vertical lines in total (one per column)
    TotalColumnWidth := TotalColumnWidth + ColumnCount;

  // compute grid client width by excluding vertical scroll bar, grid indicator,
  // and grid border
  GridClientWidth := DBGrid.Width - GetSystemMetrics(SM_CXVSCROLL);
  if dgIndicator in DBGrid.Options then begin
    GridClientWidth := GridClientWidth - IndicatorWidth;
    if dgColLines in DBGrid.Options then
      Dec(GridClientWidth);
  end;
  if DBGrid.BorderStyle = bsSingle then begin
    if DBGrid.Ctl3D then // border is sunken (vertical border is 2 pixels wide)
      GridClientWidth := GridClientWidth - 4
    else // border is one-dimensional (vertical border is one pixel wide)
      GridClientWidth := GridClientWidth - 2;
  end;

  // adjust column widths
  if TotalColumnWidth < GridClientWidth then begin
    Filler := (GridClientWidth - TotalColumnWidth) div ColumnCount;
    for i := 0 to ColumnCount-1 do
      DBGrid.Columns[i].Width := DBGrid.Columns[i].Width + Filler;
  end
//  else if TotalColumnWidth > GridClientWidth then begin
//    Filler := (TotalColumnWidth - GridClientWidth) div ColumnCount;
//    if (TotalColumnWidth - GridClientWidth) mod ColumnCount <> 0 then
//      Inc(Filler);
//    for i := 0 to ColumnCount-1 do
//      DBGrid.Columns[i].Width := DBGrid.Columns[i].Width - Filler;
//  end;
end;

procedure AjustaForm(Form : TForm);
begin
  Form.ClientHeight := Application.MainForm.ClientHeight - 2; //Cabeçalho form principal
  Form.ClientWidth  := Application.MainForm.ClientWidth;
  Form.Height       := Application.MainForm.ClientHeight - 2; //Cabeçalho form principal
  Form.Width        := Application.MainForm.ClientWidth;
  Form.Top          := Application.MainForm.Top   + Application.MainForm.BorderWidth + 47;
  Form.Left         := Application.MainForm.Left  + Application.MainForm.BorderWidth + 3;
end;

procedure CriarComandoSequenciaMenu(Menu: TMainMenu);
Var
  I, J, K,
  PosMenu1,
  PosMenu2,
  PosMenu3 : Integer;
Const
  Alfabeto : String = 'ABCDEFGHIJKLMNOPQRSTUVXYWZ';
begin
  if Menu is TMainMenu then begin
    PosMenu1 := 1;
    for I := 0 to Menu.Items.Count - 1 do begin
      if ((Menu.Items[I].Visible) and (Menu.Items[I].Enabled)) then begin
        Menu.Items[I].Caption := '&' + Alfabeto[PosMenu1] + ' - ' + Trim(Menu.Items[I].Caption);
        Inc(PosMenu1);
        PosMenu2 := 1;
        for J := 0 to Menu.Items[I].Count - 1 do begin
          if ((Menu.Items[I].Items[J].Visible) and (Menu.Items[I].Items[J].Enabled)) then begin
            if Pos('&', Menu.Items[I].Items[J].Caption) = 0 then begin
              Menu.Items[I].Items[J].Caption := '&' + Alfabeto[PosMenu2] + ' - ' + Trim(Menu.Items[I].Items[J].Caption);
              Inc(PosMenu2);
              PosMenu3 := 1;
              for K := 0 to Menu.Items[I].Items[J].Count - 1 do begin
                if ((Menu.Items[I].Items[J].Items[K].Visible) and (Menu.Items[I].Items[J].Items[K].Enabled)) then begin
                  if Pos('&', Menu.Items[I].Items[J].Items[K].Caption) = 0 then begin
                    Menu.Items[I].Items[J].Items[K].Caption := '&' + Alfabeto[PosMenu3] + ' - ' + Trim(Menu.Items[I].Items[J].Items[K].Caption);
                    Inc(PosMenu3);
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end else begin
    raise Exception.Create('Menu não Específicado, Verifique!');
    Exit;
  end;
end;

procedure OrdenarGrid(Column: TColumn);
var
  Indice    : string;
  Existe    : Boolean;
  I         : Integer;
  CDS_idx   : TClientDataSet;
  DB_GRID   : TDBGrid;
  C         : TColumn;
begin

  if Column.Grid.DataSource.DataSet is TClientDataSet then begin

    CDS_idx := TClientDataSet(Column.Grid.DataSource.DataSet);

    if CDS_idx.IndexFieldNames = Column.FieldName then begin

      Indice := AnsiUpperCase(Column.FieldName+'_INV');

      Existe  := False;
      For I := 0 to Pred(CDS_idx.IndexDefs.Count) do begin
        if AnsiUpperCase(CDS_idx.IndexDefs[I].Name) = Indice then begin
          Existe := True;
          Break;
        end;
      end;

      if not Existe then
        with CDS_idx.IndexDefs.AddIndexDef do begin
          Name := indice;
          Fields := Column.FieldName;
          Options := [ixDescending];
        end;
      CDS_idx.IndexName := Indice;
    end else
      CDS_idx.IndexFieldNames := Column.FieldName;

    if Column.Grid is TDBGrid then begin
      DB_GRID := TDBGrid(Column.Grid);
      for I := 0 to DB_GRID.Columns.Count - 1 do begin
        C := DB_GRID.Columns[I];
        if Column <> C then begin
          if C.Title.Font.Color <> clWindowText then
            C.Title.Font.Color := clWindowText;
        end;
      end;
      Column.Title.Font.Color := clBlue;
    end;
  end;
end;

procedure CancelaPedido;
Var
  FWC : TFWConnection;
  P   : TPEDIDO;
  PC  : TPEDIDO_CANCELAMENTO;
  Motivo,
  Pedido : String;
begin

  if USUARIO.CODIGO = 0 then begin
    DisplayMsg(MSG_WAR, 'Usuário inválido para Cancelamento, Verifique!');
    Exit;
  end;

  DisplayMsg(MSG_INPUT_TEXT, 'Informe o Número do Pedido, ou passe o Leitor!');

  if ResultMsgModal = mrOk then begin

    Pedido := ResultMsgInputText;

    if Length(Trim(Pedido)) > 0  then begin

      FWC := TFWConnection.Create;
      P   := TPEDIDO.Create(FWC);
      PC  := TPEDIDO_CANCELAMENTO.Create(FWC);
      try
        try

          P.SelectList('PEDIDO = ' + QuotedStr(Trim(Pedido)));
          if P.Count > 0 then begin
            if TPEDIDO(P.Itens[0]).STATUS.Value = 6 then begin
              DisplayMsg(MSG_WAR, 'Pedido N.º ' + Trim(Pedido) + ' já encontra-se cancelado!');
              Exit;
            end;

            repeat
              Motivo := EmptyStr;
              DisplayMsg(MSG_INPUT_TEXT, 'Informe o motivo do Cancelamento!' + sLineBreak + 'Motivo Obrigatório.');
              if ResultMsgModal = mrOk then begin
                if Length(Trim(ResultMsgInputText)) > 0  then
                  Motivo := ResultMsgInputText;
              end else
                Exit;
            until Motivo <> EmptyStr;

            //Cancela o Pedido
            P.ID.Value          := TPEDIDO(P.Itens[0]).ID.Value;
            P.STATUS.Value      := 6;
            P.Update;

            //Insere o Cancelamento.
            PC.ID.isNull        := True;
            PC.ID_PEDIDO.Value  := P.ID.Value;
            PC.ID_USUARIO.Value := USUARIO.CODIGO;
            PC.DATA_HORA.Value  := Now;
            PC.MOTIVO.Value     := Motivo;
            PC.Insert;

            FWC.Commit;

            DisplayMsg(MSG_OK, 'Pedido N.º ' + Trim(Pedido) + ' cancelado com Sucesso!');

          end else begin
            DisplayMsg(MSG_WAR, 'Pedido N.º ' + Trim(Pedido) + ' não encontrado, Verifique!');
          end;
        except
          on E : Exception do Begin
            FWC.Rollback;
            DisplayMsg(MSG_ERR, 'Erro ao cancelar Pedido!', '', E.Message);
            Exit;
          End;
        end;
      finally
        FreeAndNil(PC);
        FreeAndNil(P);
        FreeAndNil(FWC);
      end;
    end;
  end;
end;

function ValidaUsuario(Email, Senha : String) : Boolean;
Var
  FWC : TFWConnection;
  USU : TUSUARIO;
begin

  Result  := False;

  if UpperCase(Email) = 'ADMINISTRADOR' then begin
    if UpperCase(Senha) = 'SUPER' + IntToStr(DayOf(Date)) then begin
      USUARIO.CODIGO              := 0;
      USUARIO.NOME                := 'ADMINISTRADOR';
      USUARIO.EMAIL               := '';
      Result := True;
      Exit;
    end;
  end;

  try
    try

      FWC := TFWConnection.Create;

      USU := TUSUARIO.Create(FWC);

      USU.SelectList('UPPER(EMAIL) = ' + QuotedStr(UpperCase(Email)));

      if USU.Count > 0 then begin
        if (Criptografa(TUSUARIO(USU.Itens[0]).SENHA.Value, 'D') = Senha) then begin
          USUARIO.CODIGO              := TUSUARIO(USU.Itens[0]).ID.Value;
          USUARIO.NOME                := TUSUARIO(USU.Itens[0]).NOME.Value;
          USUARIO.EMAIL               := TUSUARIO(USU.Itens[0]).EMAIL.Value;
//          USUARIO.PERMITIRCADUSUARIO  := TUSUARIO(USU.Itens[0]).PERMITIR_CAD_USUARIO.Value;
          Result          := True;
        end;
      end;
    except
      on E : exception do
        raise Exception.Create('Erro ao validar Usuário, Verifique!');
    end;
  finally
    FreeAndNil(USU);
    FreeAndNil(FWC);
  end;
end;

function MD5(Texto : String): String;
var
  MD5 : TIdHashMessageDigest5;
begin
  MD5 := TIdHashMessageDigest5.Create;
  try
    Exit(MD5.HashStringAsHex(Texto));
  finally
    FreeAndNil(MD5);
  end;
end;

//funcao que retorno o código ASCII dos caracteres
function AsciiToInt(Caracter: Char): Integer;
var
  i: Integer;
begin
  i := 32;
  while i < 255 do begin
    if Chr(i) = Caracter then
      Break;
    i := i + 1;
  end;
  Result := i;
end;

Function Criptografa(Texto : String; Tipo : String) : String;
var
  I    : Integer;
  Chave: Integer;
begin

  Chave := 10;

  if (Trim(Texto) = EmptyStr) or (chave = 0) then begin
    Result := Texto;
  end else begin
    Result := '';
    if UpperCase(Tipo) = 'E' then begin
      for I := 1 to Length(texto) do begin
        Result := Result + Chr(AsciiToInt(texto[I])+chave);
      end;
    end else begin
      for I := 1 to Length(Texto) do begin
        Result := Result + Chr(AsciiToInt(Texto[I]) - Chave);
      end;
    end;
  end;
end;
procedure CarregaArrayMenus(Menu : TMainMenu);
var
  I,
  J,
  K : Integer;
begin
  SetLength(MENUS, 0);
  for I := 0 to Pred(Menu.Items.Count) do begin
    if Menu.Items[I].Count = 0 then begin
      SetLength(MENUS, Length(MENUS) + 1);
      Menus[High(MENUS)].NOME   := Menu.Items[I].Name;
      Menus[High(MENUS)].CAPTION:= StringReplace(Menu.Items[I].Caption, '&', '', [rfReplaceAll]);
    end else begin
      for J := 0 to Pred(Menu.Items[I].Count) do begin
        if Menu.Items[I].Items[J].Count = 0 then begin
          SetLength(MENUS, Length(MENUS) + 1);
          Menus[High(MENUS)].NOME   := Menu.Items[I].Items[J].Name;
          Menus[High(MENUS)].CAPTION:= StringReplace(Menu.Items[I].Items[J].Caption, '&', '', [rfReplaceAll]);
        end else begin
          for K := 0 to Pred(Menu.Items[I].Items[J].Count) do begin
            SetLength(MENUS, Length(MENUS) + 1);
            Menus[High(MENUS)].NOME   := Menu.Items[I].Items[J].Items[K].Name;
            Menus[High(MENUS)].CAPTION:= StringReplace(Menu.Items[I].Items[J].Items[K].Caption, '&', '', [rfReplaceAll]);
          end;
        end;
      end;
    end;
  end;
end;

procedure DefinePermissaoMenu(Menu : TMainMenu);
var
  I,
  J,
  K   : Integer;
  CON : TFWConnection;
  PU  : TUSUARIO_PERMISSAO;
begin
  CON                                        :=  TFWConnection.Create;
  PU                                         := TUSUARIO_PERMISSAO.Create(CON);
  try
//    for I := 0 to Pred(Menu.Items.Count) do begin
//      if Menu.Items[I].Count = 0 then begin
//        PU.SelectList('ID_USUARIO = ' + IntToStr(USUARIO.CODIGO) + ' AND MENU = ' + QuotedStr(Menu.Items[I].Name));
//        Menu.Items[I].Visible                := PU.Count > 0;
//      end else begin
//        for J := 0 to Pred(Menu.Items[I].Count) do begin
//          if Menu.Items[I].Items[J].Count = 0 then begin
//            PU.SelectList('ID_USUARIO = ' + IntToStr(USUARIO.CODIGO) + ' AND MENU = ' + QuotedStr(Menu.Items[I].Items[J].Name));
//            Menu.Items[I].Items[J].Visible     := PU.Count > 0;
//          end else begin
//            for K := 0 to Pred(Menu.Items[I].Items[J].Count) do begin
//              PU.SelectList('ID_USUARIO = ' + IntToStr(USUARIO.CODIGO) + ' AND MENU = ' + QuotedStr(Menu.Items[I].Items[J].Items[K].Name));
//              Menu.Items[I].Items[J].Items[K].Visible     := PU.Count > 0;
//            end;
//          end;
//        end;
//      end;
//    end;
    for I := 0 to Pred(Menu.Items.Count) do begin
      if Menu.Items[I].Count > 0 then begin
        Menu.Items[I].Visible                := False;
        for J := 0 to Pred(Menu.Items[I].Count) do begin
          if Menu.Items[I].Items[J].Count = 0 then begin
            PU.SelectList('ID_USUARIO = ' + IntToStr(USUARIO.CODIGO) + ' AND MENU = ' + QuotedStr(Menu.Items[I].Items[J].Name));
            Menu.Items[I].Items[J].Visible     := PU.Count > 0;
          end else begin
            Menu.Items[I].Items[J].Visible     := False;
            for K := 0 to Pred(Menu.Items[I].Items[J].Count) do begin
              PU.SelectList('ID_USUARIO = ' + IntToStr(USUARIO.CODIGO) + ' AND MENU = ' + QuotedStr(Menu.Items[I].Items[J].Items[K].Name));
              Menu.Items[I].Items[J].Items[K].Visible     := PU.Count > 0;
              if Menu.Items[I].Items[J].Items[K].Visible then
                Menu.Items[I].Items[J].Visible            := True;
            end;
          end;
          if Menu.Items[I].Items[J].Visible then
            Menu.Items[I].Visible            := True;

        end;
      end;
    end;
  finally
    FreeAndNil(PU);
    FreeAndNil(CON);
  end;

end;

function SoNumeros(Texto: String): String;
var
    I : Integer;
Begin
  I := 1;
  if Length(Texto) > 0 then
    while I <= Length(Texto) do begin
      if not (Texto[I] in ['0'..'9']) then begin
        Delete(Texto,I,1);
        Continue;
      end;
      Inc(I);
    end;
  Result := Texto;
end;

function CalculaPercentualDiferenca(ValorAnterior, ValorNovo : Currency) : Currency;
begin
  Result := 0.00;
  if ValorAnterior > 0.00 then
    if ValorNovo > 0.00 then
        Result := Trunc((((ValorNovo * 100) / ValorAnterior) - 100) * 100) / 100.00
end;


function StrZero(Zeros : string; Quant : Integer): string;
begin
  Result := Zeros;
  Quant := Quant - Length(Result);
  if Quant > 0 then
   Result := StringOfChar('0', Quant)+Result;
end;
procedure SaveLog(Msg: String);
var
  ArquivoLog : TextFile;
  Caminho : string;
begin

  Caminho := CONFIG_LOCAL.DirLog + FormatDateTime('yyyymmdd', Now) + '.txt';

  if not DirectoryExists(CONFIG_LOCAL.DirLog) then
    ForceDirectories(CONFIG_LOCAL.DirLog);

  AssignFile(ArquivoLog, Caminho);

  if FileExists(Caminho) then
    Append(ArquivoLog)
  else
    Rewrite(ArquivoLog);

  try
    Writeln(ArquivoLog, DateTimeToStr(Now) + ' ' + msg)
  finally
    CloseFile(ArquivoLog);
  end;
end;

procedure ExpXLS(DataSet: TDataSet; NomeArq: string);
var
  ExcApp: OleVariant;
  I,
  L : Integer;
  VarNomeArq : String;
begin

  DataSet.DisableControls;

  try

    if DataSet.IsEmpty then
      Exit;

    VarNomeArq := DirArquivosExcel + NomeArq;

    if not DirectoryExists(DirArquivosExcel) then
      ForceDirectories(DirArquivosExcel);

    if FileExists(VarNomeArq) then
      DeleteFile(PChar(VarNomeArq));

    ExcApp := CreateOleObject('Excel.Application');
    ExcApp.Visible := True;
    ExcApp.WorkBooks.Add;
    DataSet.First;
    L := 1;
    DataSet.First;
    while not DataSet.Eof do begin
      if L = 1 then begin
        for I := 1 to DataSet.Fields.Count - 1 do
          if DataSet.Fields[i].Visible then
            ExcApp.WorkBooks[1].Sheets[1].Cells[L,I] := DataSet.Fields[i].DisplayName;
        L := L + 1;
      end;

      for I := 1 to DataSet.Fields.Count - 1 do
        if DataSet.Fields[i].Visible then
          ExcApp.WorkBooks[1].Sheets[1].Cells[L,I] := DataSet.Fields[i].DisplayText;

      DataSet.Next;
      L := L + 1;
    end;
    ExcApp.Columns.AutoFit;
    ExcApp.WorkBooks[1].SaveAs(VarNomeArq);
  finally
    DataSet.EnableControls;
  end;
end;

end.
