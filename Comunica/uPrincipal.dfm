object frmPrincipal: TfrmPrincipal
  Left = 0
  Top = 0
  Caption = 'Aplicativo de Verifica'#231#227'o dos testes'
  ClientHeight = 370
  ClientWidth = 559
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 304
    Width = 559
    Height = 66
    Align = alBottom
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object btIniciar: TBitBtn
      Left = 0
      Top = 0
      Width = 105
      Height = 66
      Align = alLeft
      Caption = 'Iniciar Leitura'
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
      Layout = blGlyphTop
      TabOrder = 0
      OnClick = btIniciarClick
    end
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 10000
    OnTimer = Timer1Timer
    Left = 416
    Top = 96
  end
  object ImageList1: TImageList
    Left = 256
    Top = 120
    Bitmap = {
      494C010102000800500010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000918FD600241FAE00241FAE00241FAE005B57C200D6D5F0000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FEFEFE00FBFB
      FB00F8F8F800F3F3F300F1F1F100F1F1F100F1F1F100F1F1F100F4F4F400F9F9
      F900FCFCFC00FEFEFE0000000000000000000000000000000000000000005B57
      C200241FAE00241FAE00918FD600C8C7EB00BAB9E6005B57C200241FAE00241F
      AE00E4E3F5000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FCFCFC00F9F9
      F900F4F4F400D6D4D30097857600AE9682009D887700ACA5A000F4F4F400F5F5
      F500FAFAFA00FDFDFD0000000000000000000000000000000000241FAE00241F
      AE00F1F1FA000000000000000000000000000000000000000000000000008481
      D200241FAE00ADABE10000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFE0000000000000000000000
      0000D9CEC600E9CCAF00F2D5B700F3DAC000F7E1CC00FCEBDB00BEA79500FEFE
      FD000000000000000000000000000000000000000000322DB300322DB3000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000D6D5F000241FAE00E4E3F500000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F0ECE800B99F8A00F8F6F400ECE7
      E300EBCCAA00EFCFAD00F2D6B800DEC8B300D0C3B800EAE5E000C2B1A300BDA7
      960000000000000000000000000000000000ADABE100241FAE00000000000000
      0000322DEE00241FED00241FED00241FED00241FED00241FED00241FED00ADAB
      F800000000008481D200241FAE00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000CBA37B00E4B68300D6B8
      9900EDCAA400F0D1B000D9C0A900FDFDFC00000000000000000000000000F8F7
      F5009F857100000000000000000000000000241FAE00918FD60000000000918F
      F600241FED00241FED00241FED00241FED00241FED00241FED00241FED00241F
      ED000000000000000000241FAE00D6D5F0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000B39A8400E4B17900EBC5
      9B00EDCCA700F1D6B800CFC2B800000000000000000000000000000000000000
      0000F6F3F100FDFDFC000000000000000000241FAE0000000000000000005B57
      F200241FED00241FED00241FED00241FED00241FED00241FED00241FED00241F
      ED0000000000000000005B57C2005B57C2000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000EFEBE800E8BB8900EBC6
      9D00EECDAA00F0D4B500F4DDC300C0A99400E7E0DB0000000000000000000000
      000000000000F7F5F3000000000000000000241FAE0000000000000000005B57
      F200241FED00241FED00241FED00241FED00241FED00241FED00241FED00241F
      ED000000000000000000BAB9E600241FAE000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000CFAE8C00EECB
      A400E9CDAF00C7AE9600C0AE9E00EEE9E60000000000FCFBFA00DCD2CA00BAA2
      8E00D4B69800E6E0DA000000000000000000241FAE0000000000000000005B57
      F200241FED00241FED00241FED00241FED00241FED00241FED00241FED00241F
      ED000000000000000000C8C7EB00241FAE000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000BFAD9E00E6DF
      DA00FEFEFD0000000000F8F6F400AB927F00DAC4AF00F1DAC100F2D5B500EECC
      A700EBC59B00B3977E000000000000000000241FAE0000000000000000005B57
      F200241FED00241FED00241FED00241FED00241FED00241FED00241FED00241F
      ED000000000000000000918FD600241FAE000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E6DFDA000000
      000000000000000000000000000000000000C7B6AA00E2CBB300EFD1B000EDCA
      A400EAC39700D3AA80000000000000000000241FAE00F1F1FA00000000005B57
      F200241FED00241FED00241FED00241FED00241FED00241FED00241FED00241F
      ED000000000000000000241FAE00918FD6000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000EDE8E400F7F5
      F30000000000000000000000000000000000FDFDFC00E2C9B100EFCFAD00ECC9
      A100E9BC8B00E6B57F00EFEAE700000000004D49BD00322DB30000000000E4E3
      FD00241FED00241FED00241FED00241FED00241FED00241FED00241FED00322D
      EE0000000000F1F1FA00241FAE00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000A88E
      7A00E1D9D2000000000000000000FAF8F700D2BAA500F1D4B600EFCEAB00E7C8
      A700C6B5A900D0A88000B69D87000000000000000000241FAE00C8C7EB000000
      0000E4E3FD005B57F2005B57F2005B57F2005B57F2005B57F200918FF6000000
      000000000000241FAE005B57C200000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C5B0A000E0CFBF00D0BBA900F2DEC900F3D9BE00F1D3B300EFD0B000D2C5
      BC000000000000000000D4C8BF000000000000000000BAB9E600241FAE00C8C7
      EB00000000000000000000000000000000000000000000000000000000000000
      0000322DB300241FAE0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000BFAC9E00E1CEBD00F5DFCA00F1D8BF00CDB49B00E5DDD7000000
      0000000000000000000000000000000000000000000000000000BAB9E600241F
      AE00322DB300F1F1FA00000000000000000000000000000000009F9DDB00241F
      AE00322DB3000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FBFAF900FDFCFC0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00004D49BD00241FAE00241FAE00241FAE00241FAE00241FAE00241FAE00ADAB
      E100000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FFFFF81F00000000C003E00700000000
      C003C7E300000000700F9FF100000000000F30090000000080E7200C00000000
      81F3600C00000000807B600C00000000C083600C00000000C403600C00000000
      DF03200C00000000CF01200900000000E601901900000000F00D8FF300000000
      F81FC3C700000000FE7FF00F0000000000000000000000000000000000000000
      000000000000}
  end
end
