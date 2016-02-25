unit uBeanUsuario_Permissao;

interface
uses uFWPersistence, uDomains;
type
  TUSUARIO_PERMISSAO = class(TFWPersistence)
  private
    FID: TFieldInteger;
    FMENU: TFieldString;
    FID_USUARIO: TFieldInteger;
    procedure SetID(const Value: TFieldInteger);
    procedure SetID_USUARIO(const Value: TFieldInteger);
    procedure SetMENU(const Value: TFieldString);
  protected
    procedure InitInstance; override;
  published
      property ID          : TFieldInteger read FID write SetID;
      property ID_USUARIO  : TFieldInteger read FID_USUARIO write SetID_USUARIO;
      property MENU        : TFieldString read FMENU write SetMENU;
  end;
implementation

{ TUSUARIO_PERMISSAO }

procedure TUSUARIO_PERMISSAO.InitInstance;
begin
  inherited;

  ID.isPK                     := True;

  ID_USUARIO.isNotNull        := True;
  MENU.isNotNull              := True;

  MENU.Size                   := 100;
end;

procedure TUSUARIO_PERMISSAO.SetID(const Value: TFieldInteger);
begin
  FID := Value;
end;

procedure TUSUARIO_PERMISSAO.SetID_USUARIO(const Value: TFieldInteger);
begin
  FID_USUARIO := Value;
end;

procedure TUSUARIO_PERMISSAO.SetMENU(const Value: TFieldString);
begin
  FMENU := Value;
end;

end.
