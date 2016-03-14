unit uCadastroTransportadora;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Samples.Gauges, Vcl.ExtCtrls, System.Win.ComObj, System.TypInfo,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.Grids, Vcl.DBGrids, Data.DB, Datasnap.DBClient;

type
  TfrmCadastroTransportadora = class(TForm)
    pnVisualizacao: TPanel;
    dgTransportadoras: TDBGrid;
    pnPequisa: TPanel;
    btPesquisar: TSpeedButton;
    edPesquisa: TEdit;
    Panel2: TPanel;
    GridPanel1: TGridPanel;
    Panel1: TPanel;
    btAtualizar: TSpeedButton;
    pbAtualizaProduto: TGauge;
    Panel3: TPanel;
    btFechar: TSpeedButton;
    dsTransportadoras: TDataSource;
    csTransportadoras: TClientDataSet;
    OpenDialog1: TOpenDialog;
    csTransportadorasID: TIntegerField;
    csTransportadorasCNPJ: TStringField;
    csTransportadorasNOME: TStringField;
    procedure FormShow(Sender: TObject);
    procedure csTransportadorasFilterRecord(DataSet: TDataSet;
      var Accept: Boolean);
    procedure btPesquisarClick(Sender: TObject);
    procedure edPesquisaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btFecharClick(Sender: TObject);
    procedure btAtualizarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure CarregaDados;
    procedure Filtrar;
    procedure AtualizaTransportadoras;
  end;

var
  frmCadastroTransportadora: TfrmCadastroTransportadora;

implementation
uses
  uFuncoes,
  uMensagem,
  uDomains,
  uFWConnection,
  uBeanTransportadoras;
{$R *.dfm}

procedure TfrmCadastroTransportadora.AtualizaTransportadoras;
const
  xlCellTypeLastCell = $0000000B;
Var
  FWC     : TFWConnection;
  T       : TTRANSPORTADORA;
  List    : TPropList;
  Arquivo : String;
  Excel   : OleVariant;
  arrData,
  Valor   : Variant;
  vrow,
  vcol,
  Count,
  I,
  J       : Integer;
begin
  if OpenDialog1.Execute then begin
    if Pos(ExtractFileExt(OpenDialog1.FileName), '|.xls|.xlsx|') > 0 then begin
      Arquivo := OpenDialog1.FileName;

      if not FileExists(Arquivo) then begin
        DisplayMsg(MSG_WAR, 'Arquivo selecionado não existe! Verifique!');
        Exit;
      end;

      // Cria Excel- OLE Object
      Excel                      := CreateOleObject('Excel.Application');
      FWC                        := TFWConnection.Create;
      T                          := TTRANSPORTADORA.Create(FWC);
      pbAtualizaProduto.Progress := 0;

      DisplayMsg(MSG_WAIT, 'Buscando dados do arquivo Excel!');
      try
        FWC.StartTransaction;
        try
          // Esconde Excel
          Excel.Visible  := False;
          // Abre o Workbook
          Excel.Workbooks.Open(Arquivo);

          Excel.Cells.SpecialCells(xlCellTypeLastCell, EmptyParam).Activate;
          vrow                                 := Excel.ActiveCell.Row;
          vcol                                 := Excel.ActiveCell.Column;
          pbAtualizaProduto.MaxValue           := vrow;
          arrData                              := Excel.Range['A1', Excel.WorkSheets[1].Cells[vrow, vcol].Address].Value;

          T.CNPJ.excelTitulo          := 'CNPJ';
          T.NOME.excelTitulo          := 'Razão social';
          
          T.buscaIndicesExcel(Arquivo, Excel);

          Count                                           := GetPropList(T.ClassInfo, tkProperties, @List, False);
          for I := 0 to Pred(Count) do begin
            if (TFieldTypeDomain(GetObjectProp(T, List[I]^.Name)).excelTitulo <> '') and (TFieldTypeDomain(GetObjectProp(T, List[I]^.Name)).excelIndice <= 0) then begin
              DisplayMsg(MSG_WAR, 'Estrutura do Arquivo Inválida, Verifique!', '', 'Colunas: ' + sLineBreak + 'CNPJ, ' + sLineBreak +
                                                                                    'Razão social');
              Exit;
            end;
          end;

          for I := 2 to vrow do begin
            for J := 0 to Pred(Count) do begin
              if (TFieldTypeDomain(GetObjectProp(T, List[J]^.Name)).excelIndice > 0) then begin
                Valor                                   := Trim(arrData[I, TFieldTypeDomain(GetObjectProp(T, List[J]^.Name)).excelIndice]);
                if Valor <> '' then
                  TFieldTypeDomain(GetObjectProp(T, List[J]^.Name)).asVariant := Valor;
              end;
            end;

            T.SelectList('cnpj = ' + T.CNPJ.asSQL);
            if T.Count > 0 then begin
              T.ID.Value    := TTRANSPORTADORA(T.Itens[0]).ID.Value;
              T.Update;
            end else
              T.Insert;
            pbAtualizaProduto.Progress           := I;
            Application.ProcessMessages;
          end;

          FWC.Commit;

          DisplayMsg(MSG_OK, 'Transportadoras Atualizadas com Sucesso!');
          CarregaDados;
        except
          on E : Exception do begin
            FWC.Rollback;
            DisplayMsg(MSG_ERR, 'Erro ao atualizar Transportadoras!', '', E.Message);
            Exit;
          end;
        end;
      finally
        arrData := Unassigned;
        pbAtualizaProduto.Progress               := 0;
        if not VarIsEmpty(Excel) then begin
          Excel.Quit;
          Excel := Unassigned;
        end;
        FreeAndNil(T);
        FreeAndNil(FWC);
      end;
    end;
  end;
end;

procedure TfrmCadastroTransportadora.btAtualizarClick(Sender: TObject);
begin
  if btAtualizar.Tag = 0 then begin
    btAtualizar.Tag   := 1;
    try
      AtualizaTransportadoras;
    finally
      btAtualizar.Tag   := 0;
    end;                     
  end;
end;

procedure TfrmCadastroTransportadora.btFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCadastroTransportadora.btPesquisarClick(Sender: TObject);
begin
  Filtrar;
end;

procedure TfrmCadastroTransportadora.CarregaDados;
var
  FWC   : TFWConnection;
  T     : TTRANSPORTADORA;
  I     : Integer;
begin
  FWC    := TFWConnection.Create;
  T      := TTRANSPORTADORA.Create(FWC);
  DisplayMsg(MSG_WAIT, 'Buscando dados no Banco de Dados!');
  csTransportadoras.DisableControls;
  try
    try
      T.SelectList();
      for I := 0 to Pred(T.Count) do begin
        csTransportadoras.Append;
        csTransportadorasID.Value   := TTRANSPORTADORA(T.Itens[I]).ID.Value;
        csTransportadorasCNPJ.Value := TTRANSPORTADORA(T.Itens[I]).CNPJ.Value;
        csTransportadorasNOME.Value := TTRANSPORTADORA(T.Itens[I]).NOME.Value;
        csTransportadoras.Post;
      end;
      DisplayMsgFinaliza;
    except
      on E : Exception do begin
        DisplayMsg(MSG_WAR, 'Erro ao consultar dados!', '', E.Message);
        Exit;
      end;
    end;
  finally
    csTransportadoras.EnableControls;
    FreeAndNil(T);
    FreeAndNil(FWC);
  end;
end;

procedure TfrmCadastroTransportadora.csTransportadorasFilterRecord(
  DataSet: TDataSet; var Accept: Boolean);
var
  I : Integer;
begin
  for I := 0 to Pred(csTransportadoras.FieldCount) do begin
    Accept   := Pos(AnsiUpperCase(edPesquisa.Text), AnsiUpperCase(csTransportadoras.Fields[I].AsString)) > 0;
    if Accept then Exit;
  end;
end;

procedure TfrmCadastroTransportadora.edPesquisaKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_RETURN : Filtrar;
    VK_UP : begin
      if not ((csTransportadoras.IsEmpty) or (csTransportadoras.Bof)) then
        csTransportadoras.Prior;
    end;
    VK_DOWN : begin
      if not ((csTransportadoras.IsEmpty) or (csTransportadoras.Eof)) then
        csTransportadoras.Next;    
    end;
  end;
end;

procedure TfrmCadastroTransportadora.Filtrar;
begin
  csTransportadoras.Filtered   := False;
  csTransportadoras.Filtered   := edPesquisa.Text <> '';
end;

procedure TfrmCadastroTransportadora.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Close;

end;

procedure TfrmCadastroTransportadora.FormShow(Sender: TObject);
begin
  csTransportadoras.CreateDataSet;
  csTransportadoras.Open;

  AjustaForm(Self);
  AutoSizeDBGrid(dgTransportadoras);
  CarregaDados;
end;

end.
