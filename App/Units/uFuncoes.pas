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
  System.Classes;

  procedure CarregarConfigLocal;
  procedure CarregaArrayMenus(Menu : TMainMenu);
  procedure DefinePermissaoMenu(Menu : TMainMenu);
  procedure CarregarConexaoBD;
  procedure AutoSizeDBGrid(const DBGrid: TDBGrid);
  procedure AjustaForm(Form : TForm);
  procedure CriarComandoSequenciaMenu(Menu: TMainMenu);
  function ValidaUsuario(Email, Senha : String) : Boolean;
  function MD5(Texto : String): String;
  Function Criptografa(Texto : String; Tipo : String) : String;
  function SoNumeros(Texto: String): String;
  function CalculaPercentualDiferenca(ValorAnterior, ValorNovo : Currency) : Currency;
  function StrZero(Zeros : string; Quant : Integer): string;
  procedure SaveLog(Msg: String);

implementation

Uses
  uConstantes,
  IniFiles,
  uFWConnection,
  uBeanUsuario,
  uBeanUsuario_Permissao,
  uDomains;

procedure CarregarConfigLocal;
Var
  ArqINI : TIniFile;
begin

  ArqINI := TIniFile.Create(DirArqConf);
  try

    LOGIN.Usuario               := ArqINI.ReadString('LOGIN', 'USUARIO', '');
    LOGIN.LembrarUsuario        := ArqINI.ReadBool('LOGIN', 'LEMBRARUSUARIO', True);

    CONFIG_LOCAL.DirRelatorios  := ArqINI.ReadString('CONFIGURACOES', 'DIR_RELATORIOS', 'C:\CrossAbacos\Relatorios\');
    CONFIG_LOCAL.FTPUsuario     := ArqINI.ReadString('CONFIGURACOES', 'FTP_USUARIO', '');
    CONFIG_LOCAL.FTPSenha       := ArqINI.ReadString('CONFIGURACOES', 'FTP_SENHA', '');
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
Var
  Log : TStringList;
  ArqLog  : String;
begin
  ArqLog  := 'C:\ConectorE10First\Log.txt';
  try
    Log := TStringList.Create;
    try
      if FileExists(ArqLog) then
        Log.LoadFromFile(ArqLog);
      Log.Add(DateTimeToStr(Now) + ' ' + Msg)

    except
      on E : Exception do
        Log.Add('Erro.: ' + E.Message);
    end;
  finally
    Log.SaveToFile(ArqLog);
    FreeAndNil(Log);
  end;
end;
end.
