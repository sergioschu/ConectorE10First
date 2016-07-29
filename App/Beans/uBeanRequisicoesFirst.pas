unit uBeanRequisicoesFirst;

interface
uses uFWPersistence, uDomains;

type
  TREQUISICOESFIRST = class(TFWPersistence)
  private
    FDATAHORA: TFieldDateTime;
    FTIPOREQUISICAO: TFieldString;
    FID: TFieldInteger;
    FDSC_STATUS: TFieldString;
    FCOD_STATUS: TFieldInteger;
    procedure SetCOD_STATUS(const Value: TFieldInteger);
    procedure SetDATAHORA(const Value: TFieldDateTime);
    procedure SetDSC_STATUS(const Value: TFieldString);
    procedure SetID(const Value: TFieldInteger);
    procedure SetTIPOREQUISICAO(const Value: TFieldString);
  protected
    procedure InitInstance; override;
  published
    property ID : TFieldInteger read FID write SetID;
    property DATAHORA : TFieldDateTime read FDATAHORA write SetDATAHORA;
    property COD_STATUS : TFieldInteger read FCOD_STATUS write SetCOD_STATUS;
    property DSC_STATUS : TFieldString read FDSC_STATUS write SetDSC_STATUS;
    property TIPOREQUISICAO : TFieldString read FTIPOREQUISICAO write SetTIPOREQUISICAO;
  end;

implementation

{ TREQUISICOESFIRST }

procedure TREQUISICOESFIRST.InitInstance;
begin
  inherited;
  ID.isPK   := True;

  DSC_STATUS.Size     := 255;
  TIPOREQUISICAO.Size := 100;
end;

procedure TREQUISICOESFIRST.SetCOD_STATUS(const Value: TFieldInteger);
begin
  FCOD_STATUS := Value;
end;

procedure TREQUISICOESFIRST.SetDATAHORA(const Value: TFieldDateTime);
begin
  FDATAHORA := Value;
end;

procedure TREQUISICOESFIRST.SetDSC_STATUS(const Value: TFieldString);
begin
  FDSC_STATUS := Value;
end;

procedure TREQUISICOESFIRST.SetID(const Value: TFieldInteger);
begin
  FID := Value;
end;

procedure TREQUISICOESFIRST.SetTIPOREQUISICAO(const Value: TFieldString);
begin
  FTIPOREQUISICAO := Value;
end;

end.
