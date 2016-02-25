unit uFWPersistence;

interface

uses
  TypInfo,
  SysUtils,
  Classes,
  uDomains,
  DB,
  uFWConnection,
  IniFiles,
  FireDAC.Comp.Client,
  FireDAC.DApt,
  FireDAC.UI,
  FireDAC.Stan.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Error,
  comObj;

type
  TFWPersistence = class(TInterfacedPersistent)

  private
    FItens: TList;
    FSQLDS: TFDQuery;
    FFWC: TFWConnection;
    FREF: Boolean;

    function GetItem(const Index: Integer): TFWPersistence;
    procedure AddItem(const Value: TFWPersistence);
    function GetCount: Integer;
    procedure SQLScript(SQL: String);
    function FindParam(Param: String): Boolean;
    function MontaWhere: String;
    procedure SetSQLDS(const Value: TFDQuery);
    procedure SetFWC(const Value: TFWConnection);

  protected
    procedure InitInstance; virtual;
    constructor CreateFields(aConexao: TFWConnection); overload;

  public
    constructor Create(aConexao: TFWConnection); overload;
    constructor Create; overload;

    destructor Destroy; override;

    property Itens[const Index: Integer]: TFWPersistence read GetItem; default;
    property Count: Integer read GetCount default 0;
    property SQLDS: TFDQuery read FSQLDS write SetSQLDS;
    property FWC: TFWConnection read FFWC write SetFWC;

    procedure SelectList(SQLWhere: String = ''; SQLOrder: String = '');
    procedure Insert;
    procedure Update;
    procedure Delete;

    procedure ClearFields;

    procedure Open;
    procedure Close;
    procedure StartTransaction;
    procedure Rollback;
    procedure Commit;

    procedure buscaIndicesExcel(Arquivo : String; Excel : OLEVariant); virtual;
  end;

implementation

uses
  uConstantes;

constructor TFWPersistence.CreateFields(aConexao: TFWConnection);
begin

  FSQLDS := TFDQuery.Create(nil);
  FWC := aConexao;
  FSQLDS.Transaction := FWC.FDTransaction;

  InitInstance;

end;

constructor TFWPersistence.Create;
begin
  Self.Create(nil);
end;

Constructor TFWPersistence.Create(aConexao: TFWConnection);
begin
  FItens := TList.Create();

  FREF := False;
  if (aConexao = nil) then
    FWC := TFWConnection.Create
  else
  begin
    FREF := True;
    FWC := aConexao;
  end;

  FSQLDS := TFDQuery.Create(nil);
  FSQLDS.Transaction := FWC.FDTransaction;

  InitInstance;

end;

destructor TFWPersistence.Destroy;
var
  I, J, Count: Integer;
  List: TPropList;
begin
  try
    Count := GetPropList(Self.ClassInfo, tkProperties, @List, False);

    for J := 0 to FItens.Count - 1 do
    begin
      for I := 0 to Count - 1 do
        TFieldTypeDomain(GetObjectProp(TFWPersistence(FItens.Items[J]), List[I]^.Name)).Free;
      FreeAndNil(TFWPersistence(FItens.Items[J]).FItens);
      FreeAndNil(TFWPersistence(FItens.Items[J]).FSQLDS);
      Dispose(FItens.Items[J]);
      FItens.Items[J] := nil;
    end;

    for I := 0 to Count - 1 do
      TFieldTypeDomain(GetObjectProp(Self, List[I]^.Name)).Free;

  finally
    FreeAndNil(FItens);
    FreeAndNil(FSQLDS);
    if not FREF then
      FreeAndNil(FFWC);
    inherited;
  end;
end;

procedure TFWPersistence.InitInstance;
var
  I, Count: Integer;
  List: TPropList;
begin
  try
    Count := GetPropList(Self.ClassInfo, tkProperties, @List, False);
    for I := 0 to Count - 1 do
    begin
      SetObjectProp(Self, List[I]^.Name, TFieldTypeDomain(GetObjectPropClass(Self, List[I]^.Name).Create).Create);
      TFieldTypeDomain(GetObjectProp(Self, List[I]^.Name)).isNull := True;
    end;
  except
  end;
end;

procedure TFWPersistence.AddItem(const Value: TFWPersistence);
begin
  FItens.Add(Value);
end;

function TFWPersistence.GetItem(const Index: Integer): TFWPersistence;
begin
  Result := FItens[Index];
end;

function TFWPersistence.MontaWhere: String;
var
  WHERE: TStringList;
  List: TPropList;
  I, Count: Integer;
begin
  WHERE := TStringList.Create;
  try
    Count := GetPropList(Self.ClassInfo, tkProperties, @List, False);

    WHERE.Clear;

    if Count > 0 then
      WHERE.Add('WHERE 1=1');

    for I := 0 to (Count - 1) do
      if TFieldTypeDomain(GetObjectProp(Self, List[I]^.Name)).isPK then
        WHERE.Add('AND ' + List[I]^.Name + ' = :' + List[I]^.Name);

    Result := WHERE.Text;
  finally
    FreeAndNil(WHERE);
  end;
end;

procedure TFWPersistence.Open;
begin
  //FWC.Open;
end;

procedure TFWPersistence.SetFWC(const Value: TFWConnection);
begin
  FFWC := Value;
end;

procedure TFWPersistence.SetSQLDS(const Value: TFDQuery);
begin
  FSQLDS := Value;
end;

procedure TFWPersistence.SQLScript(SQL: String);
var
  List: TPropList;
  I, J, Count: Integer;
  FieldType: TFieldTypeDomain;
  ValorCampoChave : Variant;
begin
  try
    SQLDS.SQL.Text := SQL;

    if not FWC.FDConnection.Connected then
      raise Exception.Create('Não Conectado!');

    SQLDS.Connection := FWC.FDConnection;
    Count := GetPropList(Self.ClassInfo, tkProperties, @List, False);
    for I := 0 to Pred(Count) do begin

      if (TFieldTypeDomain(GetObjectProp(Self, List[I]^.Name)) is TFieldInteger) then begin
        if SQLDS.FindParam(List[I]^.Name) <> nil then
          SQLDS.ParamByName(List[I]^.Name).DataType := ftInteger;
      end else if (TFieldTypeDomain(GetObjectProp(Self, List[I]^.Name)) is TFieldString) then begin
        if SQLDS.FindParam(List[I]^.Name) <> nil then
          SQLDS.ParamByName(List[I]^.Name).DataType := ftString;
      end else if (TFieldTypeDomain(GetObjectProp(Self, List[I]^.Name)) is TFieldDateTime) then begin
        if SQLDS.FindParam(List[I]^.Name) <> nil then
          SQLDS.ParamByName(List[I]^.Name).DataType := ftDateTime;
      end else if (TFieldTypeDomain(GetObjectProp(Self, List[I]^.Name)) is TFieldBoolean) then begin
        if SQLDS.FindParam(List[I]^.Name) <> nil then
          SQLDS.ParamByName(List[I]^.Name).DataType := ftBoolean;
      end else if (TFieldTypeDomain(GetObjectProp(Self, List[I]^.Name)) is TFieldCurrency) then begin
        if SQLDS.FindParam(List[I]^.Name) <> nil then
          SQLDS.ParamByName(List[I]^.Name).DataType := ftCurrency;
      end else if (TFieldTypeDomain(GetObjectProp(Self, List[I]^.Name)) is TFieldFloat) then begin
        if SQLDS.FindParam(List[I]^.Name) <> nil then
          SQLDS.ParamByName(List[I]^.Name).DataType := ftFloat;
      end else if (TFieldTypeDomain(GetObjectProp(Self, List[I]^.Name)) is TFieldBlob) then begin
        if SQLDS.FindParam(List[I]^.Name) <> nil then
          SQLDS.ParamByName(List[I]^.Name).DataType := ftBlob;
      end;
    end;

    SQLDS.Prepare;

    if SQLDS.ParamCount > 0 then
    begin
      Count := GetPropList(Self.ClassInfo, tkProperties, @List, False);

      for I := 0 to (Count - 1) do
      begin
        if not FindParam(List[I]^.Name) then
          continue;

        FieldType := TFieldTypeDomain(GetObjectProp(Self, List[I]^.Name));

        if FieldType.isNull and FieldType.isNotNull and not FieldType.isPK then
          raise EAbort.Create('Campo ' + List[I]^.Name + ' não pode ser nulo!' + #13 + #10 + SQL);

        if FieldType.isNull then begin
            SQLDS.ParamByName(List[I]^.Name).Clear;
        end else
          SQLDS.ParamByName(List[I]^.Name).Value := FieldType.asVariant;

      end;
    end;

    if Pos('UPDATE', SQLDS.SQL.Text) > 0 then begin
      SQLDS.Command.CommandKind := skUpdate;
      SQLDS.ExecSQL;
    end else begin
      if Pos('DELETE', SQLDS.SQL.Text) > 0 then begin
        SQLDS.Command.CommandKind := skDelete;
        SQLDS.ExecSQL;
      end else
        SQLDS.OpenOrExecute;
    end;

  except
    on E: Exception do
      raise EAbort.Create(E.message + #13 + #10 + SQLDS.SQL.Text);
    on E: EFDDBEngineException  do
      raise EAbort.Create(E.message + #13 + #10 + SQLDS.SQL.Text);
  end;
end;

procedure TFWPersistence.Insert;
var
  SQL, sFields: TStringList;
  List: TPropList;
  I, Count: Integer;
begin
  SQL := TStringList.Create;
  sFields := TStringList.Create;
  try

    Count := GetPropList(Self.ClassInfo, tkProperties, @List, False);

    sFields.Clear;
    SQL.Clear;

    for I := 0 to (Count - 1) do begin
      if not (TFieldTypeDomain(GetObjectProp(Self, List[I]^.Name)).isPK) then begin
        if (I = Count - 1) then
          sFields.Add(List[I]^.Name)
        else
          sFields.Add(List[I]^.Name + ', ');
      end;
    end;

    SQL.Add('INSERT INTO ' + Copy(Self.ClassName, 2, Length(Self.ClassName)) + '(');
    SQL.Add(sFields.Text);
    SQL.Add(') VALUES (');

    sFields.Clear;

    for I := 0 to (Count - 1) do begin
      if not (TFieldTypeDomain(GetObjectProp(Self, List[I]^.Name)).isPK) then begin
        if (I = Count - 1) then
          sFields.Add(':' + List[I]^.Name)
        else
          sFields.Add(':' + List[I]^.Name + ', ');
      end;
    end;

    SQL.Add(sFields.Text);
    SQL.Add(') RETURNING ');

    // Retorna as chaves primárias do referido item inserido
    for I := 0 to (Count - 1) do // retorna número da NF
      if (TFieldTypeDomain(GetObjectProp(Self, List[I]^.Name)).isPK) then
        SQL.Add(List[I]^.Name + ',');
    SQL.Text := Copy(SQL.Text, 1, Length(SQL.Text) - 3); // Remove vírgula

    // Executa a SQL
    SQLScript(SQL.Text);

    // Retorna as chaves primárias do referido item inserido
    for I := 0 to (Count - 1) do // retorna número da NF
      if (TFieldTypeDomain(GetObjectProp(Self, List[I]^.Name)).isPK) then
        TFieldTypeDomain(GetObjectProp(Self, List[I]^.Name)).asVariant := SQLDS.FieldByName(List[I]^.Name).asVariant;

  finally
    FreeAndNil(SQL);
    FreeAndNil(sFields);
  end;
end;

procedure TFWPersistence.Update;
var
  SQL, sFields: TStringList;
  List: TPropList;
  I, Count: Integer;
begin
  SQL := TStringList.Create;
  sFields := TStringList.Create;
  try
    Count := GetPropList(Self.ClassInfo, tkProperties, @List, False);

    sFields.Clear;
    SQL.Clear;

    for I := 0 to (Count - 1) do
      if not TFieldTypeDomain(GetObjectProp(Self, List[I]^.Name)).isNull then
        sFields.Add(List[I]^.Name + ' = :' + List[I]^.Name + ',');

    sFields.Text := Copy(sFields.Text, 1, Length(sFields.Text) - 3);
    // Remove vírgula

    SQL.Add('UPDATE ' + Copy(Self.ClassName, 2, Length(Self.ClassName)) + ' SET');
    SQL.Add(sFields.Text);
    SQL.Add(MontaWhere);

    SQLScript(SQL.Text);

  finally
    FreeAndNil(SQL);
    FreeAndNil(sFields);
  end;
end;

procedure TFWPersistence.Delete;
var
  SQL: TStringList;
begin
  SQL := TStringList.Create;
  try
    SQL.Clear;
    SQL.Add('DELETE');
    SQL.Add('FROM ' + Copy(Self.ClassName, 2, Length(Self.ClassName)));
    SQL.Add(MontaWhere);

    SQLScript(SQL.Text);
  finally
    FreeAndNil(SQL);
  end;
end;

procedure TFWPersistence.SelectList(SQLWhere: String = ''; SQLOrder: String = '');
var
  sFields, SQL: TStringList;
  I, J, Count: Integer;
  List: TPropList;
  objTmp: TFWPersistence;
  FieldType: TFieldTypeDomain;
begin
  sFields := TStringList.Create;
  SQL := TStringList.Create;
  try
    Count := GetPropList(Self.ClassInfo, tkProperties, @List, False);

    sFields.Clear;
    SQL.Clear;

    // Limpa a memória
    for J := 0 to FItens.Count - 1 do
    begin
      for I := 0 to Count - 1 do
        TFieldTypeDomain(GetObjectProp(TFWPersistence(FItens.Items[J]), List[I]^.Name)).Free;
      FreeAndNil(TFWPersistence(FItens.Items[J]).FItens);
      Dispose(FItens.Items[J]);
      FreeAndNil(TFWPersistence(FItens.Items[J]).FSQLDS);
    end;
    FItens.Clear;

    for I := 0 to (Count - 1) do
    begin
      if (I = Count - 1) then
        sFields.Add(List[I]^.Name)
      else
        sFields.Add(List[I]^.Name + ',');
    end;

    SQL.Add('SELECT');
    SQL.Add(sFields.Text);
    SQL.Add(' FROM ' + AnsiLowerCase(Copy(Self.ClassName, 2, Length(Self.ClassName))));
    SQL.Add('WHERE 1=1');

    if (SQLWhere <> '') then
      SQL.Add('AND ' + SQLWhere);

    if (SQLOrder <> '') then
    begin
      SQL.Add('ORDER BY');
      SQL.Add(SQLOrder);
    end;

    SQLScript(SQL.Text);
    SQLDS.DisableControls;
    while not SQLDS.Eof do begin
      objTmp := TFWPersistence((Self.ClassType).Create).CreateFields(FWC);
      for I := 0 to (Count - 1) do
      begin
        Try
        FieldType := TFieldTypeDomain(GetObjectProp(objTmp, List[I]^.Name));
        if not SQLDS.FieldByName(List[I]^.Name).isNull then
          FieldType.asVariant := SQLDS.FieldByName(List[I]^.Name).asVariant;
        Except
        End;
      end;
      AddItem(objTmp);
      SQLDS.Next;
    end;

  finally
    FreeAndNil(SQL);
    FreeAndNil(sFields);
  end;
end;

function TFWPersistence.GetCount: Integer;
begin
  Result := FItens.Count;
end;

procedure TFWPersistence.buscaIndicesExcel(Arquivo: String; Excel: OLEVariant);
var
  I,
  Column,
  TotalColumns,
  Count: Integer;
  List: TPropList;
begin
  try
    TotalColumns                     := Excel.ActiveCell.Column;
    Count := GetPropList(Self.ClassInfo, tkProperties, @List, False);
    for Column := 1 to TotalColumns do begin
      for I := 0 to Count - 1 do begin
        if AnsiUpperCase(TFieldTypeDomain(GetObjectProp(Self, List[I]^.Name)).excelTitulo) = AnsiUpperCase(Excel.Workbooks[ExtractFileName(Arquivo)].WorkSheets[1].Cells.Item[1, Column].Value) then begin
          TFieldTypeDomain(GetObjectProp(Self, List[I]^.Name)).excelIndice := Column;
          Break;
        end;
      end;
    end;
  except
  end;

end;

procedure TFWPersistence.ClearFields;
var
  I, Count: Integer;
  List: TPropList;
begin
  try
    Count := GetPropList(Self.ClassInfo, tkProperties, @List, False);
    for I := 0 to Count - 1 do
      TFieldTypeDomain(GetObjectProp(Self, List[I]^.Name)).isNull    := True;
  except
  end;
end;

procedure TFWPersistence.Close;
begin
  FWC.Close;
end;

procedure TFWPersistence.StartTransaction;
begin
  try
    //if not FSQLDS.Transaction.InTransaction then
    //  FSQLDS.IB_Transaction.StartTransaction;
  except
    On E: Exception do
      raise EAbort.Create(E.message);
  end;
end;

procedure TFWPersistence.Commit;
begin
  try
    FSQLDS.Transaction.Commit;
  except
    On E: Exception do
      raise EAbort.Create(E.message);
  end;
end;

procedure TFWPersistence.Rollback;
begin
  try
    FSQLDS.Transaction.Rollback;
  except
    On E: Exception do
      raise EAbort.Create(E.message);
  end;
end;

function TFWPersistence.FindParam(Param: String): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to SQLDS.ParamCount - 1 do
  begin
    if (SQLDS.Params[I].Name = Param) then
    begin
      Result := True;
      break;
    end;
  end;
end;

end.
