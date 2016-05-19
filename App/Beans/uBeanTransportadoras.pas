unit uBeanTransportadoras;

interface
uses uFWPersistence, uDomains;

type TTRANSPORTADORA = Class(TFWPersistence)
  private
    FCNPJ: TFieldString;
    FID: TFieldInteger;
    FNOME: TFieldString;
    procedure SetCNPJ(const Value: TFieldString);
    procedure SetID(const Value: TFieldInteger);
    procedure SetNOME(const Value: TFieldString);
  protected
    procedure InitInstance; override;
  published
    property ID : TFieldInteger read FID write SetID;
    property CNPJ : TFieldString read FCNPJ write SetCNPJ;
    property NOME : TFieldString read FNOME write SetNOME;
End;
implementation

{ TTRANSPORTADORAS }

procedure TTRANSPORTADORA.InitInstance;
begin
  inherited;
  ID.isPK             := True;

  CNPJ.Size           := 19;
  NOME.Size           := 100;

  NOME.isSearchField  := True;
  CNPJ.isSearchField  := True;

  ID.displayLabel     := 'Código';
  NOME.displayLabel   := 'Nome';
  CNPJ.displayLabel   := 'CNPJ';
end;

procedure TTRANSPORTADORA.SetCNPJ(const Value: TFieldString);
begin
  FCNPJ := Value;
end;

procedure TTRANSPORTADORA.SetID(const Value: TFieldInteger);
begin
  FID := Value;
end;

procedure TTRANSPORTADORA.SetNOME(const Value: TFieldString);
begin
  FNOME := Value;
end;

end.
