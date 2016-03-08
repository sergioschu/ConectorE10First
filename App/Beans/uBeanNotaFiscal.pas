unit uBeanNotaFiscal;

interface
uses uFWPersistence, uDomains;

type
  TNOTAFISCAL = Class(TFWPersistence)
  private
    FSERIE: TFieldInteger;
    FCNPJCPF: TFieldString;
    FDOCUMENTO: TFieldInteger;
    FCFOP: TFieldInteger;
    FDATAEMISSAO: TFieldDateTime;
    FID: TFieldInteger;
    FESPECIE: TFieldString;
    FVALORTOTAL: TFieldCurrency;
    FSTATUS: TFieldBoolean;
    procedure SetCFOP(const Value: TFieldInteger);
    procedure SetCNPJCPF(const Value: TFieldString);
    procedure SetDATAEMISSAO(const Value: TFieldDateTime);
    procedure SetDOCUMENTO(const Value: TFieldInteger);
    procedure SetSERIE(const Value: TFieldInteger);
    procedure SetID(const Value: TFieldInteger);
    procedure SetESPECIE(const Value: TFieldString);
    procedure SetVALORTOTAL(const Value: TFieldCurrency);
    procedure SetSTATUS(const Value: TFieldBoolean);
  protected
    procedure InitInstance; override;
  published
    proPerty ID          : TFieldInteger read FID write SetID;
    property DOCUMENTO   : TFieldInteger read FDOCUMENTO write SetDOCUMENTO;
    property SERIE       : TFieldInteger read FSERIE write SetSERIE;
    property CNPJCPF     : TFieldString read FCNPJCPF write SetCNPJCPF;
    property DATAEMISSAO : TFieldDateTime read FDATAEMISSAO write SetDATAEMISSAO;
    property CFOP        : TFieldInteger read FCFOP write SetCFOP;
    property VALORTOTAL  : TFieldCurrency read FVALORTOTAL write SetVALORTOTAL;
    property ESPECIE     : TFieldString read FESPECIE write SetESPECIE;
    property STATUS      : TFieldBoolean read FSTATUS write SetSTATUS;
  End;

implementation

{ TNOTAFISCAL }

procedure TNOTAFISCAL.InitInstance;
begin
  inherited;
  ID.isPK                  := True;

  DOCUMENTO.isNotNull      := True;
  SERIE.isNotNull          := True;
  CNPJCPF.isNotNull        := True;
  CFOP.isNotNull           := True;
  DATAEMISSAO.isNotNull    := True;
  VALORTOTAL.isNotNull     := True;
  ESPECIE.isNotNull        := True;


  CNPJCPF.Size             := 19;
  ESPECIE.Size             := 2;


end;

procedure TNOTAFISCAL.SetCFOP(const Value: TFieldInteger);
begin
  FCFOP := Value;
end;

procedure TNOTAFISCAL.SetCNPJCPF(const Value: TFieldString);
begin
  FCNPJCPF := Value;
end;

procedure TNOTAFISCAL.SetDATAEMISSAO(const Value: TFieldDateTime);
begin
  FDATAEMISSAO := Value;
end;

procedure TNOTAFISCAL.SetDOCUMENTO(const Value: TFieldInteger);
begin
  FDOCUMENTO := Value;
end;

procedure TNOTAFISCAL.SetESPECIE(const Value: TFieldString);
begin
  FESPECIE := Value;
end;

procedure TNOTAFISCAL.SetID(const Value: TFieldInteger);
begin
  FID := Value;
end;

procedure TNOTAFISCAL.SetSERIE(const Value: TFieldInteger);
begin
  FSERIE := Value;
end;

procedure TNOTAFISCAL.SetSTATUS(const Value: TFieldBoolean);
begin
  FSTATUS := Value;
end;

procedure TNOTAFISCAL.SetVALORTOTAL(const Value: TFieldCurrency);
begin
  FVALORTOTAL := Value;
end;

end.
