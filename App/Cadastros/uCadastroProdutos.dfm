object frmCadastroProdutos: TfrmCadastroProdutos
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'Cadastro de Produtos'
  ClientHeight = 541
  ClientWidth = 755
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = True
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnVisualizacao: TPanel
    Left = 0
    Top = 0
    Width = 755
    Height = 541
    Align = alClient
    TabOrder = 0
    object gdProdutos: TDBGrid
      AlignWithMargins = True
      Left = 4
      Top = 92
      Width = 747
      Height = 379
      Align = alClient
      DataSource = dsProdutos
      DrawingStyle = gdsGradient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      Options = [dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleHotTrack]
      ParentFont = False
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -20
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      Columns = <
        item
          Expanded = False
          FieldName = 'CODIGOPRODUTO'
          Title.Caption = 'SKU'
          Width = 100
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'DESCRICAO'
          Title.Caption = 'Descri'#231#227'o'
          Width = 400
          Visible = True
        end>
    end
    object pnPequisa: TPanel
      Left = 1
      Top = 49
      Width = 753
      Height = 40
      Align = alTop
      BevelOuter = bvNone
      Color = clWhite
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentBackground = False
      ParentFont = False
      TabOrder = 1
      object btPesquisar: TSpeedButton
        AlignWithMargins = True
        Left = 650
        Top = 3
        Width = 100
        Height = 34
        Align = alRight
        Glyph.Data = {
          F6060000424DF606000000000000360000002800000018000000180000000100
          180000000000C0060000C40E0000C40E00000000000000000000FFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFEFEFEF3F3F3E0E0E0CACACAA4A4A47F7F7F5E5E5E2626264D4C4CEE
          EEEEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFF3F3F3DBDBDBC6C6C6B5B5B59B9B9B8484847373736D6D6D4747
          472B29290404048C8C8CFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFBFBFBECECECDFDFDFD4D4D4CDCDCDCACACAD1D1D1DEDEDE
          ECECEC7E7E7E2B29290000008F8F907D7D7DFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFF8D8D8D2B29290000008F8F906D6D6DFBFBFBFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFF8E8E8E2B29290000008F8F906D6D6DFBFBFBFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8E8E8E2B29290000008F8F906D6D
          6DFBFBFBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8E8E8E2B2929000000
          8F8F906D6D6DFBFBFBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFA19E9E3A
          38380000008F8F90777777FDFDFDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFC3C1C1B9B3B14A4443979798777777FDFDFDFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFDFDFDB6B6B59A9A999999989898969999989B9B9B
          ABABABF6F6F6E9E9E9ADA4A3342D2CDFDCDBAFACACFDFDFDFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE6E6E68C8B8BB4B4B2CAC9C7CECECCCE
          CECCCCCCCBC9C9C8BBBBB88E8E8D9C9795362D2DD7D5D4B3B0B0FFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEAEAEA8B8B89BFBEBBC6C6
          C5C2C2C0C2C2C1C2C2C0C1C1C0C3C2C0C4C4C2C0C0BF8D8C8C979393E1E1E0FF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8D8D8C
          B6B6B4BDBDBABBBBB9BABAB7B8B7B5B7B7B4B7B7B4B9B9B6BBBBB9BCBCB9B8B8
          B58F8E8EF6F6F6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFC0C0C09E9E9DB5B5B2B0B0ADADACA9ACACA8ACACA8ACACA9ACACA9ACACA9
          AEADAAB0AFACB2B2AFACACA9A5A5A5FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFF9A9A9AA9A9A5A8A8A5A7A7A4A7A7A4A7A7A4A7A7A4A8
          A8A4A8A8A4A8A8A5A8A8A5A8A8A5A8A8A5A8A8A5929291FFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8F8F8EA2A29FA2A29FA2A39FA3A3
          A0A3A3A0A3A3A0A3A3A0A3A3A0A3A4A0A3A4A0A4A4A1A4A4A1A4A4A18B8B8AF9
          F9F9FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8B8B8A9E9E9B
          9E9E9B9E9E9B9E9E9B9E9F9B9E9F9C9E9F9C9F9F9C9F9F9C9F9F9C9FA09C9FA0
          9C9FA09D8C8C8AEBEBEBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFF8F8F8E9B9B999D9E9C9E9F9DA0A09EA1A19EA2A29FA2A2A0A2A3A0A2A3A0
          A1A2A0A1A29FA1A19FA0A09E878786F9F9F9FFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFF999A999FA09DABACABABACABACADABACADABACADABAC
          ADABACADABADADABADADABADADABADADABA6A6A48B8B8BFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC7C7C790918FB7B7B6B9B9B8B9B9
          B8B9B9B8B9BAB8B9BAB8B9BAB8B9BAB8B9BAB8B9BAB9B9BAB9999A98A8A8A8FF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8E8E8E
          A4A5A3CBCBCACBCBCACBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCCCBCBCCCBB2B2
          B0888988F7F7F7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFEDEDED858584A9AAA8DEDEDDE1E1E1E1E1E1E1E1E1E1E1E1E1E1E1
          E0E0E0B9B9B8858685D6D6D6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEDEDED898A89949494C2C3C2DFE0DFEC
          ECEBE4E4E4CACACA9D9D9D858685DADADAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC2C2
          C293949385868587888785868590908FB3B3B3FBFBFBFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
        ExplicitLeft = 685
      end
      object edPesquisa: TEdit
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 641
        Height = 34
        Align = alClient
        AutoSize = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
      end
    end
    object Panel2: TPanel
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 747
      Height = 42
      Align = alTop
      BevelOuter = bvNone
      Caption = 'Cadastro de Produtos'
      Color = clSkyBlue
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentBackground = False
      ParentFont = False
      TabOrder = 2
    end
    object GridPanel1: TGridPanel
      AlignWithMargins = True
      Left = 4
      Top = 477
      Width = 747
      Height = 60
      Align = alBottom
      ColumnCollection = <
        item
          Value = 50.000000000000000000
        end
        item
          Value = 50.000000000000000000
        end>
      ControlCollection = <
        item
          Column = 0
          Control = Panel1
          Row = 0
        end
        item
          Column = 1
          Control = Panel3
          Row = 0
        end>
      RowCollection = <
        item
          Value = 100.000000000000000000
        end>
      TabOrder = 3
      object Panel1: TPanel
        AlignWithMargins = True
        Left = 4
        Top = 4
        Width = 366
        Height = 52
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object btAtualizar: TSpeedButton
          AlignWithMargins = True
          Left = 263
          Top = 3
          Width = 100
          Height = 46
          Align = alRight
          Caption = '&Atualizar'
          Glyph.Data = {
            360C0000424D360C000000000000360000002800000020000000200000000100
            180000000000000C0000C40E0000C40E00000000000000000000FFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFEFEFEFCFCFCFBFBFBF9F9F9F8F8F8F5F5F5F3F3F3F2F2
            F2F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F3F3F3F4F4F4F7F7F7F9
            F9F9FAFAFAFCFCFCFEFEFEFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FEFEFEFAFAFAF7F7F7F3F3F3F0F0F0ECECECE9E9E9E6E6E6E3E3E3E1E1E1E0E0
            E0D4D3D3C3C2C0BAB8B6BCBAB8C8C7C6D7D7D7E0E0E0E0E0E0E2E2E2E5E5E5E8
            E8E8ECECECEFEFEFF3F3F3F6F6F6FAFAFAFDFDFDFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFEFEFEFCFCFCFBFBFBF9F9F9F6F6F6F4F4F4F4F4F4D6D4D3A39A
            93978576A38D7AAE9682AA927F9D8877958578ACA5A0DEDDDDF4F4F4F4F4F4F5
            F5F5F8F8F8FAFAFAFCFCFCFDFDFDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFEFEDDD6D1A78F7CCCB2
            99EAD0B6F2D9BFF5DDC4F5DFC9F3DFCCE7D4C3C5AF9DA89485E0DBD6FEFEFEFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFED9CEC6B99D85E9CCAFF2D4
            B5F2D5B7F3D7BBF3DAC0F5DDC5F7E1CCFAE7D4FCEBDBEFDFD1BEA795D3C7BDFE
            FEFDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE4DCD6
            D9CEC6FBFAF9FFFFFFFFFFFFFFFFFFFFFFFFDCD1CABA9E84EDCEAEF0CFADF0D2
            B2F2D5B8F2D8BDF5DCC4F2DDC9DECAB7CCB7A4CBB5A3DAC7B8EDDFD3CAB6A5C9
            BAAFFEFEFDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0ECE8
            9A7A61B99F8AD5C8BFF8F6F4FFFFFFECE7E3B2957DEBCCAAEFCCA8EFCFADF0D3
            B3F2D6B8F4DBC1DEC8B3B69F8CD0C3B8E8E1DCEAE5E0E0D8D1C2B1A3C8B6A7BD
            A796D2C4BBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFDFC
            B39A85DCB58BCBA47CB3967DC7B7ABB19884E2C2A2EECAA4EECDA9EFD0AFF1D3
            B4F3D8BDD5BFA9C3B1A4F7F5F3FFFFFFFFFFFFFFFFFFFFFFFFFEFEFEE8E1DCB5
            A08FA0846EE9E3DEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            D0C2B8CBA37BE7B47BE4B683CEA983D6B899EDCAA3EDCAA4EECDAAF0D1B0F2D6
            B8D9C0A9C3B2A5FDFDFCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8
            F7F5AC94839F8571FCFBFBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            F0ECE9B39171E6B57FE4B178E8BA87ECC69DECC79FEDCBA5EFCEABF1D2B2E6CD
            B3BCA797FAF9F8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFAF9F8A58C78DBD1CAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FDFDFCB39A84DFB383E4B179E8BD8DEBC59BECC8A1EDCCA7EFCFADF1D6B8C0A7
            90CFC2B8FFFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFF6F3F1BAA697FDFDFCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFD0C2B8CBA47BE6B57EE9C193EBC69CECC9A2EECCA8EFD0AEF1D4B6E4CC
            B3C1A994C4B2A5EEE9E6FEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFEDE8E4EDE8E5FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFEFEBE8B49172E8BB89EAC296EBC69DEDCAA4EECDAAEFD1AFF0D4B5F3D8
            BBF4DDC3E5D0BBC0A994B9A494E7E0DBFEFDFDFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFEFEF7F5F3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFDFCFCB39984E2BC92EBC498ECC79FEDCBA5EFCEABF1D3B2F3D8BAF2DA
            C0EAD4BEDCC6B1C6B19DAD9582B7A394F1EDEAFFFFFFFFFFFFFFFFFFFFFFFFFC
            FBFAF1EDEADBD1C8C5B3A6FAF9F7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFCFC1B7CFAE8CEDC89DEECBA4EECFACE9CDAFDAC0A6C7AE96BAA3
            8FC0AE9ED6CAC1EEE9E6FCFBFAFFFFFFFFFFFFFCFBFAF1EDEADCD2CAC5B3A6BA
            A28EC1A58CD4B698BC9D81E6E0DAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFEFEBE8B5977CDBBD9DC7A98DB79E87BBA594D2C5BBEBE5E1FAF8
            F7FEFEFEFFFFFFFDFCFCF2EFECDED4CDC6B5A9BCA693C3AA94D5BCA2E5CAADED
            CFAEEFCDA8EEC9A0DAB996C7B7A9FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFDFCFCBFAD9ECBBCB0E6DFDAF7F5F4FEFEFDFFFFFFFFFFFFFFFF
            FFF8F6F4BFADA0AB927FC5AF9DDAC4AFE9D3BDF1DAC1F3D9BDF2D5B5EFD0ADEE
            CCA7ECC8A1EBC59BE7C197B3977EFBFAFAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFF8F6F5FDFDFCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFEFEF0ECE9C3B2A5BDA491E3CEB9F4DEC6F3D9BDF1D5B7F0D2B1EFCFACED
            CBA6ECC8A0EAC499E9BD8CBC9875EAE4E0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFF8F6F4E6DFDAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFF2EEEBC7B6AABEA793E2CBB3F1D5B8EFD1B0EECEAAED
            CAA4ECC79EEAC397E7B781D3AA80CAB9ADFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFC5B5A8EDE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDAD0C8B99E89F1D7BBEFD0AFEECDA9ED
            C9A3EBC69DE9C092E5B37BE2B583B39780FCFBFBFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFEDE8E49B806AF7F5F3FFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFDFDFCC3B0A2E2C9B1F1D4B4EFCFADEECCA7EC
            C9A1ECC79EE9BC8BE4B279E6B57FBA9776EFEAE7FFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFEFEFEB5A090A48B77F3F0EDFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFEFDFDCDBFB4D4BDA7F3D7BAF0D2B2EFCFACEECBA6ED
            CAA3DEC0A0D3AE88E5B784E7B47BD0A87ED0C2B8FFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFF4F1EEA88E7AB69F8DE1D9D2FEFDFDFFFFFFFFFF
            FFFFFFFFFFFFFFFAF8F7C9B9ADD2BAA5F3D9BFF1D4B6F0D1B0EFCEABEECBA5E7
            C8A7B39A84C6B5A9B79A80D0A880E0B88CB69D87FDFDFCFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE2DAD3BCA694CFBEAFC3B1A2DDD3CBE9E3
            DEE8E1DCD4C8BEBBA694DDC7B2F4DCC3F2D7BAF1D3B5F0D0AFEFCDA9EECEACBA
            9D84E6DFDAFFFFFFF7F5F4D2C5BAB99D85A18167F0ECE9FFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDBD1C9C5B0A0EFE2D5E0CFBFD0BB
            A9D0BBA9E0CBB9F2DEC9F5DDC5F3D9BEF2D6B9F1D3B3F0D0AEEFD0B0C1A389D2
            C5BCFFFFFFFFFFFFFFFFFFFFFFFFF9F7F6D4C8BFE1D9D3FFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE0D7D0BAA391EADACBFBEB
            DCFAE7D5F7E2CDF5DEC7F4DBC2F3D8BDF2D6B8F2D5B6EACEB1BEA289D2C5BBFE
            FEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFEFEFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF2EFECBFAC9EC3AD
            9BE1CEBDF1DDCAF5DFCAF5DDC5F1D8BFE8CFB5CDB49BB79F8CE5DDD7FFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFEFEEFEA
            E7CFC0B6BEAA9ABAA390BAA28DBCA694C2AFA1E2DAD3FBFAFAFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFEFEFEFBFAF9FAF8F7FDFCFCFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
          OnClick = btAtualizarClick
          ExplicitLeft = 12
          ExplicitTop = 8
          ExplicitHeight = 44
        end
      end
      object Panel3: TPanel
        AlignWithMargins = True
        Left = 376
        Top = 4
        Width = 367
        Height = 52
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
        object btFechar: TSpeedButton
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 100
          Height = 46
          Align = alLeft
          Caption = '&Fechar'
          Glyph.Data = {
            F6060000424DF606000000000000360000002800000018000000180000000100
            180000000000C0060000C40E0000C40E00000000000000000000FFFFFFFFFFFF
            FCFCFCF9F9F9F6F6F6F2F2F2EDEDEDE9E9E9E6E6E6E6E6E6E7E7E7EAEAEAEEEE
            EEF3F3F3F7F7F7FAFAFAFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFDFDFDF9F9F9F2F2F2EAEAEAE1E1E1D9D9D9D0D0D0CBCBCBC9C9C9
            CCCCCCD2D2D2DADADAE3E3E3ECECECF4F4F4FBFBFBFEFEFEFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFDFDFDF9F9F9F1F1F1E9E9E9E0E0E0D7D7D7CF
            CFCFC9C9C9C7C7C7CACACAD0D0D0D9D9D9E1E1E1EAEAEAF3F3F3FAFAFAFEFEFE
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFEFEFCFCFCF8F8F8F4F4
            F4F0F0F0EBEBEBE6E6E6DBDBDBE0E0E0E3E3E3DDDDDD7373738C8C8C90909092
            92929595959696969898989999999999999A9A9A9A9A9ABFBFBFFFFFFFFFFFFF
            FEFEFEFEFEFEFDFDFDFCFCFCFAFAFAF8F8F8D7D7D7616984F4F4F4D2D2D22A31
            362125280B0C0C0C0C0C1111111515151919191D1D1D2222222626262A2A2A6C
            6C6CFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFEFEDDDDDD0E33A2
            687799D4D4D4414A505D6A734A545C23262A1111111414141919191D1D1D2121
            212525252828286B6B6BFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFDEDEDE0C39BD0648DE5E6B894B535965737C6370795E6B74464F5722272A
            1818191C1C1C2020202323232727276A6A6AFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFDEDEDE0C38BC014CF8225BDC2F3E596F7D856B788165
            737C5E6B7454606A2D33391B1B1B1E1E1E222222242424696969DEDEDE292970
            292984292A86292E8A29328F293692293A97293E9A0335D50049F61C5FF8366A
            DD45546D7180886D7B8365727B5B6771333A401919191D1D1D20202022222268
            6868DEDEDE0C0C940000B80001B90009C20011CA0019D20021DB0028E30034EB
            0044F41057F82F6DF94674DE46566D73818A6C7982616E77353B411818181B1B
            1B1E1E1E202020676767DEDEDE0C0C940000B80000B80007BF000FC80016D000
            1ED80026E0002EE8003DF0004CF81C60F83873F94876DD46566D717F8867757E
            383F451616161919191C1C1C1E1E1E676767DEDEDE0C0C940000B80000B80004
            BD000CC50013CD001BD50022DC0029E40034EB0042F30650F81F62F83571F93F
            70DD42526D6C7A833B43481414141717171A1A1A1B1B1B656565DEDEDE19199A
            4B4BCD4646CB4142CB3A41CF323FD42B3ED9243EDE1B3CE2143CE80C40EE0547
            F3044FF8175CF82667F92A48886672793E454A13131315151517171719191964
            6464DEDEDE1D1D9B6060D35D5DD25757D04F52D14750D53E4CD83448DC2B46E0
            2142E51840E90E41ED0443F10048F61940956B7A8678868F41474D1111111313
            13151515161616646464DEDEDE1E1E9C6E6ED76B6BD66363D45959D15055D446
            50D63C4BDA3247DC2843E01F40E4143BE70938EB1A39937988958B9AA27D8C94
            424A4F0F0F0F111111131313141414636363DEDEDE19199A5252CF5454CF4E4E
            CE4747CC4041CC383FCF313DD33040D72D42DC233EDE1636E11E349092A0AB9D
            AEB590A0A7829199444D520C0C0C0F0F0F101010111111626262EFEFEF80809C
            7E7E9C7E7E9C7E7E9C7E7E9C7E7E9C7E7F9D71728E212BA8303FD62136D81626
            819DAAB4BFCDD2A8B8BE95A5AC86959D464E540A0A0A0C0C0C0E0E0E0F0F0F61
            6161FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDEDEDE2429A4
            2A35CF252E876A737ECADADEC4D2D7B7C6CB9AABB28999A04850560808080A0A
            0A0B0B0B0C0C0C606060FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFDEDEDE1D1E9B2D3089ACACB4889598D1E0E4C9D8DCBECCD1ACBABF909FA6
            4A52570606060808080909090A0A0A5F5F5FFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFDEDEDE252563CCCCD3D7D7D78E999CD6E6EACDDCE1C1
            CFD4B3C1C6A5B2B851595D0404040505050707070707075E5E5EFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE6E6E6D0D0D5FFFFFFD7D7D7929F
            A2DCECF0D1E0E4C3D2D6B5C2C8A7B3B9535C610101010303030404040505055D
            5D5DFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFD7D7D797A3A6E0F1F4D2E2E6C4D2D7B6C3C9A7B4BA545C610101010101
            010202020202025D5D5DFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFD7D7D799A5A8E2F1F5D3E2E6C4D3D7B6C3C9A7B4BA
            545C610101010101010101010101015C5C5CFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE8E8E8565A5B6266675D626359
            5D5F55595B515556494C4D5C5C5C5C5C5C5C5C5C5C5C5C8A8A8A}
          OnClick = btFecharClick
          ExplicitLeft = 12
          ExplicitTop = 8
          ExplicitHeight = 104
        end
      end
    end
  end
  object dsProdutos: TDataSource
    DataSet = csProdutos
    Left = 312
    Top = 208
  end
  object csProdutos: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 416
    Top = 208
    object csProdutosID: TIntegerField
      FieldName = 'ID'
    end
    object csProdutosCODIGOPRODUTO: TStringField
      FieldName = 'CODIGOPRODUTO'
      Size = 25
    end
    object csProdutosDESCRICAO: TStringField
      FieldName = 'DESCRICAO'
      Size = 76
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 361
    Top = 265
  end
end
