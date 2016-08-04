unit uConsultaRequisicoes;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ImgList, Data.DB, Datasnap.DBClient,
  Vcl.Samples.Gauges, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.Grids,
  Vcl.DBGrids, FireDAC.Comp.Client, System.TypInfo, System.Win.ComObj,
  uFWConnection, Vcl.ComCtrls, Vcl.Mask, JvExMask, JvToolEdit;

type
  TFrmConsultaRequisicoes = class(TForm)
    pnVisualizacao: TPanel;
    gdRequisicoes: TDBGrid;
    pnPequisa: TPanel;
    btPesquisar: TSpeedButton;
    edPesquisa: TEdit;
    Panel2: TPanel;
    GridPanel1: TGridPanel;
    Panel1: TPanel;
    Panel3: TPanel;
    btFechar: TSpeedButton;
    dsRequisicoes: TDataSource;
    cds_Requisicoes: TClientDataSet;
    cds_RequisicoesID: TIntegerField;
    OpenDialog1: TOpenDialog;
    ImageList1: TImageList;
    pnConsulta: TPanel;
    btConsultar: TSpeedButton;
    rgStatus: TRadioGroup;
    edTotalRegistros: TEdit;
    gbTipoRequisicoes: TGroupBox;
    cbTipoRequisicoes: TComboBox;
    cds_RequisicoesDATA_HORA: TDateTimeField;
    cds_RequisicoesTIPOREQUISICAO: TStringField;
    cds_RequisicoesCOD_STATUS: TIntegerField;
    cds_RequisicoesDSC_STATUS: TStringField;
    gbPeriodo: TGroupBox;
    Label1: TLabel;
    edDataI: TJvDateEdit;
    edDataF: TJvDateEdit;
    cds_RequisicoesIDENTIFICADOR: TIntegerField;
    procedure btFecharClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cds_RequisicoesFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure btPesquisarClick(Sender: TObject);
    procedure cbFiltroStatusChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btConsultarClick(Sender: TObject);
  private
    procedure CarregarTela;
    procedure CarregarRequisicoes;

    procedure Filtrar;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmConsultaRequisicoes: TFrmConsultaRequisicoes;

implementation

uses
  uFuncoes,
  uDomains,
  uConstantes,
  uMensagem;

{$R *.dfm}

procedure TFrmConsultaRequisicoes.btConsultarClick(Sender: TObject);
begin
  if btConsultar.Tag = 0 then begin
    btConsultar.Tag    := 1;
    try
      CarregarRequisicoes;
    finally
      btConsultar.Tag  := 0;
    end;
  end;
end;

procedure TFrmConsultaRequisicoes.btFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmConsultaRequisicoes.btPesquisarClick(Sender: TObject);
begin
  if btPesquisar.Tag = 0 then begin
    btPesquisar.Tag    := 1;
    try
      Filtrar;
      TotalizaRegistros(cds_Requisicoes, edTotalRegistros);
    finally
      btPesquisar.Tag  := 0;
    end;
  end;
end;

procedure TFrmConsultaRequisicoes.CarregarRequisicoes;
Var
  FWC : TFWConnection;
  SQL : TFDQuery;
begin

  if edDataI.Date > edDataF.Date then begin
    DisplayMsg(MSG_WAR, 'Data Inicial não pode ser Maior que a Data Final, Verifique!');
    if edDataI.CanFocus then
      edDataI.SetFocus;
    Exit;
  end;

  FWC := TFWConnection.Create;
  SQL := TFDQuery.Create(nil);

  try
    try

      cds_Requisicoes.DisableControls;
      cds_Requisicoes.EmptyDataSet;

      SQL.Close;
      SQL.SQL.Clear;

      SQL.SQL.Add('SELECT');
      SQL.SQL.Add('	RQ.ID,');
      SQL.SQL.Add('	RQ.COD_STATUS,');
      SQL.SQL.Add('	RQ.DSC_STATUS,');
      SQL.SQL.Add('	RQ.TIPOREQUISICAO,');
      SQL.SQL.Add('	RQ.DATAHORA,');
      SQL.SQL.Add(' RQI.ID_DADOS');
      SQL.SQL.Add('FROM REQUISICOESFIRST RQ');
      SQL.SQL.Add('INNER JOIN REQ_ITENS RQI ON (RQI.ID_REQUISICOES = RQ.ID)');
      SQL.SQL.Add('WHERE 1 = 1');
      SQL.SQL.Add('AND CAST(RQ.DATAHORA AS DATE) BETWEEN :DATAI AND :DATAF');

      if cbTipoRequisicoes.ItemIndex > 0 then begin
        SQL.SQL.Add('AND UPPER(RQ.TIPOREQUISICAO) = UPPER(:TIPOREQUISICAO)');
        SQL.ParamByName('TIPOREQUISICAO').DataType := ftString;
        SQL.ParamByName('TIPOREQUISICAO').Value    := cbTipoRequisicoes.Items[cbTipoRequisicoes.ItemIndex];
      end;

      SQL.ParamByName('DATAI').DataType       := ftDate;
      SQL.ParamByName('DATAF').DataType       := ftDate;
      SQL.ParamByName('DATAI').Value          := edDataI.Date;
      SQL.ParamByName('DATAF').Value          := edDataF.Date;

      case rgStatus.ItemIndex of
        0 : SQL.SQL.Add('AND RQ.COD_STATUS = 200');
        1 : SQL.SQL.Add('AND RQ.COD_STATUS <> 200');
      end;

      SQL.SQL.Add('ORDER BY RQ.DATAHORA DESC');

      SQL.Connection                      := FWC.FDConnection;
      SQL.Prepare;
      SQL.Open;

      if not SQL.IsEmpty then begin
        SQL.First;
        while not SQL.Eof do begin
          cds_Requisicoes.Append;
          cds_RequisicoesID.Value               := SQL.Fields[0].Value;
          cds_RequisicoesCOD_STATUS.Value       := SQL.Fields[1].Value;
          cds_RequisicoesDSC_STATUS.Value       := SQL.Fields[2].Value;
          cds_RequisicoesTIPOREQUISICAO.Value   := SQL.Fields[3].Value;
          cds_RequisicoesDATA_HORA.AsString     := SQL.Fields[4].AsString;
          cds_RequisicoesIDENTIFICADOR.AsString := SQL.Fields[5].AsString;
          cds_Requisicoes.Post;

          SQL.Next;
        end;
        cds_Requisicoes.First;
      end;

      edTotalRegistros.Text := IntToStr(cds_Requisicoes.RecordCount);

    except
      on E : Exception do begin
        DisplayMsg(MSG_ERR, 'Erro ao Carregar os dados da Tela.', '', E.Message);
      end;
    end;

  finally
    FreeAndNil(SQL);
    FreeAndNil(FWC);
    cds_Requisicoes.EnableControls;
  end;
end;

procedure TFrmConsultaRequisicoes.CarregarTela;
Var
  I : TTIPOREQUISICAOFIRST;
begin

  edDataI.Date  := Date;
  edDataF.Date  := Date;

  rgStatus.ItemIndex  := 0;

  cbTipoRequisicoes.Items.Clear;
  cbTipoRequisicoes.Items.Add('Todos');

  for I := Low(TIPOREQUISICAOFIRST) to High(TIPOREQUISICAOFIRST) do
    cbTipoRequisicoes.Items.Add(TIPOREQUISICAOFIRST[I]);

  cbTipoRequisicoes.ItemIndex  := 0;

end;

procedure TFrmConsultaRequisicoes.cbFiltroStatusChange(Sender: TObject);
begin
  CarregarRequisicoes;
end;

procedure TFrmConsultaRequisicoes.cds_RequisicoesFilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
var
  I : Integer;
begin
  Accept := False;
  for I := 0 to Pred(cds_Requisicoes.FieldCount) do begin
    if not cds_Requisicoes.Fields[I].IsNull then
      Accept  := Pos(AnsiUpperCase(edPesquisa.Text), AnsiUpperCase(cds_Requisicoes.Fields[I].AsString)) > 0;
    if Accept then
      Break;
  end;
end;

procedure TFrmConsultaRequisicoes.Filtrar;
begin
  cds_Requisicoes.Filtered := False;
  cds_Requisicoes.Filtered := edPesquisa.Text <> '';
end;

procedure TFrmConsultaRequisicoes.FormCreate(Sender: TObject);
begin
  AjustaForm(Self);
end;

procedure TFrmConsultaRequisicoes.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE : Close;
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
  end;
end;

procedure TFrmConsultaRequisicoes.FormShow(Sender: TObject);
begin
  cds_Requisicoes.CreateDataSet;

  AutoSizeDBGrid(gdRequisicoes);

  CarregarTela;
end;

end.
