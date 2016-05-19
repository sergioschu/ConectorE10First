unit uSeleciona;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Data.DB,
  Datasnap.DBClient, Vcl.Grids, Vcl.DBGrids, Vcl.Buttons, uFWPersistence, System.TypInfo,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TfrmSeleciona = class(TForm)
    pnPrincipal: TPanel;
    GroupBox1: TGroupBox;
    csSeleciona: TClientDataSet;
    dgSeleciona: TDBGrid;
    dsSeleciona: TDataSource;
    edPesquisa: TEdit;
    btSelecionar: TBitBtn;
    btBuscar: TBitBtn;
    procedure csSelecionaFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure btBuscarClick(Sender: TObject);
    procedure btSelecionarClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure dgSelecionaDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FTabelaPai : TFWPersistence;
    Retorno    : TEdit;
    procedure SelecionaDados(CriaCampos : Boolean);
    procedure Filter;
    procedure Seleciona;
  end;

var
  frmSeleciona: TfrmSeleciona;

implementation
uses
  uFWConnection,
  uDomains,
  uFuncoes;
{$R *.dfm}

{ TfrmSeleciona }

procedure TfrmSeleciona.btBuscarClick(Sender: TObject);
begin
  filter;
end;

procedure TfrmSeleciona.btSelecionarClick(Sender: TObject);
begin
  Seleciona;
end;

procedure TfrmSeleciona.csSelecionaFilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
Var
  I : Integer;
begin
  Accept := False;
  for I := 0 to DataSet.Fields.Count - 1 do begin
    if Pos(AnsiLowerCase(edPesquisa.Text),AnsiLowerCase(DataSet.Fields[I].AsVariant)) > 0 then begin
      Accept := True;
      Break;
    end;
  end;
end;

procedure TfrmSeleciona.dgSelecionaDblClick(Sender: TObject);
begin
  Seleciona;
  Close;
end;

procedure TfrmSeleciona.Filter;
begin
  csSeleciona.Filtered := False;
  csSeleciona.Filtered := Length(edPesquisa.Text) > 0;
end;

procedure TfrmSeleciona.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  frmSeleciona   := nil;
  Action         := Cafree;
end;

procedure TfrmSeleciona.FormCreate(Sender: TObject);
begin
  AjustaForm(Self);
end;

procedure TfrmSeleciona.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

  case Key of
    VK_ESCAPE : Close;
    VK_RETURN : begin
      if not csSeleciona.IsEmpty then begin
        Seleciona;
        Close;
      end;
    end;
    VK_UP : begin
      if not csSeleciona.IsEmpty then begin
        if csSeleciona.RecNo > 1 then
          csSeleciona.Prior;
      end;
    end;
    VK_DOWN : begin
      if not csSeleciona.IsEmpty then begin
        if csSeleciona.RecNo < csSeleciona.RecordCount then
          csSeleciona.Next;
      end;
    end;
  end;

end;

procedure TfrmSeleciona.FormShow(Sender: TObject);
begin
  SelecionaDados(True);
  edPesquisa.Text   := Retorno.Text;
  Filter;
  if csSeleciona.RecordCount = 1 then begin
    btSelecionarClick(nil);
    PostMessage(Self.Handle, WM_CLOSE, 0, 0);
  end;

  AutoSizeDBGrid(dgSeleciona);

end;

procedure TfrmSeleciona.Seleciona;
begin
  Retorno.Text    := csSeleciona.Fields[0].AsString;
end;

procedure TfrmSeleciona.SelecionaDados(CriaCampos: Boolean);
var
  List        : TPropList;
  Count,
  I           : Integer;
  QRConsulta  : TFDQuery;
  FDC         : TFWConnection;
begin

  FDC           := TFWConnection.Create;
  QRConsulta    := TFDQuery.Create(nil);
  try

    Count := GetPropList(FTabelaPai.ClassInfo, tkProperties, @List, False);
    QRConsulta.SQL.Add('SELECT ');

    for I := 0 to Pred(Count) do begin
      if (TFieldTypeDomain(GetObjectProp(FTabelaPai, List[I]^.Name)).isPK) or (TFieldTypeDomain(GetObjectProp(FTabelaPai, List[I]^.Name)).isSearchField) then
        QRConsulta.SQL.Add(Copy(FTabelaPai.ClassName, 2, Length(FTabelaPai.ClassName)) + '.' + List[I]^.Name + ', ');
    end;
    QRConsulta.SQL.Text := Copy(QRConsulta.SQL.Text, 1, Length(QRConsulta.SQL.Text) - 4);
    QRConsulta.SQL.Add(' FROM '+Copy(FTabelaPai.ClassName, 2, Length(FTabelaPai.ClassName)));

    for I := 0 to Pred(Count) do begin
      if List[I]^.Name = 'STATUS' then
        QRConsulta.SQL.Add('WHERE STATUS = TRUE');
    end;

    QRConsulta.Connection := FDC.FDConnection;
    QRConsulta.Prepare;
    QRConsulta.Open();
    QRConsulta.Offline;

    Count := GetPropList(FTabelaPai.ClassInfo, tkProperties, @List, False);

    for I := 0 to Pred(Count) do begin
      if (TFieldTypeDomain(GetObjectProp(FTabelaPai, List[I]^.Name)).isPK) or (TFieldTypeDomain(GetObjectProp(FTabelaPai, List[I]^.Name)).isSearchField) then begin
        QRConsulta.FieldByName(List[I]^.Name).DisplayLabel := TFieldTypeDomain(GetObjectProp(FTabelaPai, List[I]^.Name)).displayLabel;
        QRConsulta.FieldByName(List[I]^.Name).DisplayWidth := TFieldTypeDomain(GetObjectProp(FTabelaPai, List[I]^.Name)).displayWidth;
      end;
    end;

    if CriaCampos then begin
      for I := 0 to QRConsulta.FieldCount - 1 do
        csSeleciona.FieldDefs.Add(QRConsulta.Fields[I].FieldName,QRConsulta.Fields[I].DataType,QRConsulta.Fields[I].Size);
      csSeleciona.CreateDataSet;
      csSeleciona.Open;
      for I := 0 to QRConsulta.FieldCount - 1 do begin
        csSeleciona.FindField(QRConsulta.Fields[I].FieldName).DisplayLabel                 := QRConsulta.Fields[I].DisplayLabel;
        csSeleciona.FindField(QRConsulta.Fields[I].FieldName).DisplayWidth                 := QRConsulta.Fields[I].DisplayWidth;
        csSeleciona.FieldByName(QRConsulta.Fields[I].FieldName).Origin                       := QRConsulta.Fields[I].Origin;
        if csSeleciona.FieldByName(QRConsulta.Fields[I].FieldName).DataType in [ftFloat, ftCurrency] then begin
          TFloatField(csSeleciona.FieldByName(QRConsulta.Fields[I].FieldName)).DisplayFormat := TFloatField(QRConsulta.Fields[I]).DisplayFormat;
          TFloatField(csSeleciona.FieldByName(QRConsulta.Fields[I].FieldName)).EditFormat    := TFloatField(QRConsulta.Fields[I]).EditFormat;
        end;
      end;
    end;

    csSeleciona.EmptyDataSet;
    csSeleciona.DisableControls;
    QRConsulta.DisableControls;
    try
      while not QRConsulta.Eof do begin
        csSeleciona.Append;
        for I := 0 to QRConsulta.FieldCount - 1 do begin
          if csSeleciona.FindField(QRConsulta.Fields[I].FieldName) <> nil then
            csSeleciona.FieldByName(QRConsulta.Fields[I].FieldName).Value := QRConsulta.Fields[I].Value;
        end;
        csSeleciona.Post;
        QRConsulta.Next;
      end;
    finally
      csSeleciona.EnableControls;
    end;

  finally
    FreeAndNil(QRConsulta);
    FreeAndNil(FDC);
  end;
end;

end.
