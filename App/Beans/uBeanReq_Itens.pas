unit uBeanReq_Itens;

interface
uses uFWPersistence, uDomains;

type
  TREQ_ITENS = class(TFWPersistence)
  private
    FID_DADOS: TFieldInteger;
    FID_REQUISICOES: TFieldInteger;
    FID: TFieldInteger;
    procedure SetID(const Value: TFieldInteger);
    procedure SetID_DADOS(const Value: TFieldInteger);
    procedure SetID_REQUISICOES(const Value: TFieldInteger);
  protected
    procedure InitInstance; override;
  published
    property ID : TFieldInteger read FID write SetID;
    property ID_REQUISICOES : TFieldInteger read FID_REQUISICOES write SetID_REQUISICOES;
    property ID_DADOS : TFieldInteger read FID_DADOS write SetID_DADOS;
  end;
implementation

{ TREQ_ITENS }

procedure TREQ_ITENS.InitInstance;
begin
  inherited;
  ID.isPK := True;
end;

procedure TREQ_ITENS.SetID(const Value: TFieldInteger);
begin
  FID := Value;
end;

procedure TREQ_ITENS.SetID_DADOS(const Value: TFieldInteger);
begin
  FID_DADOS := Value;
end;

procedure TREQ_ITENS.SetID_REQUISICOES(const Value: TFieldInteger);
begin
  FID_REQUISICOES := Value;
end;

end.
