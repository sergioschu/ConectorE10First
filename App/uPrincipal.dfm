object frmPrincipal: TfrmPrincipal
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  ClientHeight = 457
  ClientWidth = 910
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
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
    Width = 910
    Height = 457
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
      object Produtos1: TMenuItem
        Caption = 'Produtos'
        OnClick = Produtos1Click
      end
      object ransportadoras1: TMenuItem
        Caption = 'Transportadoras'
        OnClick = ransportadoras1Click
      end
    end
    object Lanamentos1: TMenuItem
      Caption = 'Lan'#231'amentos'
      object NotasFiscaisdeEntrada1: TMenuItem
        Caption = 'Notas Fiscais de Entrada'
        OnClick = NotasFiscaisdeEntrada1Click
      end
      object Pedidos1: TMenuItem
        Caption = 'Manuten'#231#227'o de Pedidos'
        OnClick = Pedidos1Click
      end
      object FaturamentodePedidos1: TMenuItem
        Caption = 'Faturamento de Pedidos'
        OnClick = FaturamentodePedidos1Click
      end
      object CancelamentodePedidos1: TMenuItem
        Caption = 'Cancelamento de Pedidos'
        OnClick = CancelamentodePedidos1Click
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
    object Relatrios1: TMenuItem
      Caption = 'Relat'#243'rios'
      object Divergncias1: TMenuItem
        Caption = 'Diverg'#234'ncias'
        OnClick = Divergncias1Click
      end
      object TempodeResposta1: TMenuItem
        Caption = 'Tempo de Resposta'
        OnClick = TempodeResposta1Click
      end
      object CdigodeRastreio1: TMenuItem
        Caption = 'C'#243'digo de Rastreio'
        OnClick = CdigodeRastreio1Click
      end
      object CancelamentodePedidos2: TMenuItem
        Caption = 'Cancelamento de Pedidos'
        OnClick = CancelamentodePedidos2Click
      end
    end
    object miSair: TMenuItem
      Caption = 'Sair'
      ShortCut = 27
      OnClick = miSairClick
    end
  end
end
