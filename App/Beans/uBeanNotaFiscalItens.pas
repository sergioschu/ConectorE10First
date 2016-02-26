unit uBeanNotaFiscalItens;

interface
uses uFWPersistence, uDomains;
type
  TNOTAFISCALITENS = Class(TFWPersistence)
  private
    FID_PRODUTO: TFieldInteger;
    FSEQUENCIA: TFieldInteger;
    FVALORUNITARIO: TFieldFloat;
    FID: TFieldInteger;
    FVALORTOTAL: TFieldCurrency;
    FQUANTIDADE: TFieldCurrency;
    FQUANTIDADEREC: TFieldCurrency;
    FQUANTIDADEAVA: TFieldCurrency;
    procedure SetID(const Value: TFieldInteger);
    procedure SetID_PRODUTO(const Value: TFieldInteger);
    procedure SetQUANTIDADE(const Value: TFieldCurrency);
    procedure SetSEQUENCIA(const Value: TFieldInteger);
    procedure SetVALORTOTAL(const Value: TFieldCurrency);
    procedure SetVALORUNITARIO(const Value: TFieldFloat);
    procedure SetQUANTIDADEAVA(const Value: TFieldCurrency);
    procedure SetQUANTIDADEREC(const Value: TFieldCurrency);
  protected
    procedure InitInstance; override;
  published
    property ID            : TFieldInteger read FID write SetID;
    property SEQUENCIA     : TFieldInteger read FSEQUENCIA write SetSEQUENCIA;
    property ID_PRODUTO    : TFieldInteger read FID_PRODUTO write SetID_PRODUTO;
    property QUANTIDADE    : TFieldCurrency read FQUANTIDADE write SetQUANTIDADE;
    property QUANTIDADEREC : TFieldCurrency read FQUANTIDADEREC write SetQUANTIDADEREC;
    property QUANTIDADEAVA : TFieldCurrency read FQUANTIDADEAVA write SetQUANTIDADEAVA;
    property VALORUNITARIO : TFieldFloat read FVALORUNITARIO write SetVALORUNITARIO;
    property VALORTOTAL    : TFieldCurrency read FVALORTOTAL write SetVALORTOTAL;
  End;
implementation

{ TNOTAFISCALITENS }

procedure TNOTAFISCALITENS.InitInstance;
begin
  inherited;
  ID.isPK                    := True;

  SEQUENCIA.isNotNull        := True;
  ID_PRODUTO.isNotNull       := True;
  QUANTIDADE.isNotNull       := True;
  QUANTIDADEREC.isNotNull    := True;
  QUANTIDADEAVA.isNotNull    := True;
  VALORUNITARIO.isNotNull    := True;
  VALORTOTAL.isNotNull       := True;
end;

procedure TNOTAFISCALITENS.SetID(const Value: TFieldInteger);
begin
  FID := Value;
end;

procedure TNOTAFISCALITENS.SetID_PRODUTO(const Value: TFieldInteger);
begin
  FID_PRODUTO := Value;
end;

procedure TNOTAFISCALITENS.SetQUANTIDADE(const Value: TFieldCurrency);
begin
  FQUANTIDADE := Value;
end;

procedure TNOTAFISCALITENS.SetQUANTIDADEAVA(const Value: TFieldCurrency);
begin
  FQUANTIDADEAVA := Value;
end;

procedure TNOTAFISCALITENS.SetQUANTIDADEREC(const Value: TFieldCurrency);
begin
  FQUANTIDADEREC := Value;
end;

procedure TNOTAFISCALITENS.SetSEQUENCIA(const Value: TFieldInteger);
begin
  FSEQUENCIA := Value;
end;

procedure TNOTAFISCALITENS.SetVALORTOTAL(const Value: TFieldCurrency);
begin
  FVALORTOTAL := Value;
end;

procedure TNOTAFISCALITENS.SetVALORUNITARIO(const Value: TFieldFloat);
begin
  FVALORUNITARIO := Value;
end;

end.
