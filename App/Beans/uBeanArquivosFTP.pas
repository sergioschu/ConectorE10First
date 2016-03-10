unit uBeanArquivosFTP;

interface
uses uFWPersistence, uDomains;

type TARQUIVOSFTP = Class(TFWPersistence)
  private
    FID: TFieldInteger;
    FDATAENVIO: TFieldDateTime;
    FMENSAGEM: TFieldString;
    FTIPO: TFieldInteger;
    procedure SetDATAENVIO(const Value: TFieldDateTime);
    procedure SetID(const Value: TFieldInteger);
    procedure SetMENSAGEM(const Value: TFieldString);
    procedure SetTIPO(const Value: TFieldInteger);
  protected
    procedure InitInstance; override;
  published
    property ID : TFieldInteger read FID write SetID;
    property TIPO : TFieldInteger read FTIPO write SetTIPO;
    property DATAENVIO : TFieldDateTime read FDATAENVIO write SetDATAENVIO;
    property MENSAGEM : TFieldString read FMENSAGEM write SetMENSAGEM;
End;
implementation

{ TARQUIVOSFTP }

procedure TARQUIVOSFTP.InitInstance;
begin
  inherited;
  ID.isPK    := True;

  MENSAGEM.Size    := 255;
end;

procedure TARQUIVOSFTP.SetDATAENVIO(const Value: TFieldDateTime);
begin
  FDATAENVIO := Value;
end;

procedure TARQUIVOSFTP.SetID(const Value: TFieldInteger);
begin
  FID := Value;
end;

procedure TARQUIVOSFTP.SetMENSAGEM(const Value: TFieldString);
begin
  FMENSAGEM := Value;
end;

procedure TARQUIVOSFTP.SetTIPO(const Value: TFieldInteger);
begin
  FTIPO := Value;
end;

end.
