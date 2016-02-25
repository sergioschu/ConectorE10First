object frmPrincipal: TfrmPrincipal
  Left = 0
  Top = 0
  ClientHeight = 447
  ClientWidth = 900
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  WindowState = wsMaximized
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object IMFundo: TImage
    Left = 0
    Top = 0
    Width = 900
    Height = 447
    Align = alClient
    Stretch = True
    ExplicitLeft = -135
    ExplicitWidth = 1035
    ExplicitHeight = 467
  end
  object MainMenu1: TMainMenu
    Left = 320
    Top = 128
    object Cadastros1: TMenuItem
      Caption = 'Cadastros'
      object Usuario1: TMenuItem
        Caption = 'Usu'#225'rio'
        OnClick = Usuario1Click
      end
    end
    object Configuraes1: TMenuItem
      Caption = 'Configura'#231#245'es'
      object ConfigGerais1: TMenuItem
        Caption = 'Configura'#231#245'es do Sistema'
        OnClick = ConfigGerais1Click
      end
      object RedefinirSenha: TMenuItem
        Caption = 'Redefinir Senha'
        OnClick = RedefinirSenhaClick
      end
    end
    object miSair: TMenuItem
      Caption = 'Sair'
      ShortCut = 27
      OnClick = miSairClick
    end
  end
end
