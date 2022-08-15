object FrmClientes: TFrmClientes
  Left = 0
  Top = 0
  Caption = 'Cadastro de Clientes'
  ClientHeight = 529
  ClientWidth = 771
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object lb_nom_cliente: TLabel
    Left = 32
    Top = 40
    Width = 63
    Height = 13
    Caption = 'Nome Cliente'
    FocusControl = cxDBTextEd_nom_cliente
  end
  object lb_identidade_cliente: TLabel
    Left = 32
    Top = 96
    Width = 52
    Height = 13
    Caption = 'Identidade'
    FocusControl = cxDBTextEd_identidade_cliente
  end
  object Label4: TLabel
    Left = 32
    Top = 128
    Width = 19
    Height = 13
    Caption = 'CPF'
  end
  object Label5: TLabel
    Left = 32
    Top = 160
    Width = 42
    Height = 13
    Caption = 'Telefone'
    FocusControl = cxDBTextEd_telefone_cliente
  end
  object Label6: TLabel
    Left = 32
    Top = 192
    Width = 24
    Height = 13
    Caption = 'Email'
    FocusControl = cxDBTextEd_email_cliente
  end
  object Bevel1: TBevel
    Left = 21
    Top = 211
    Width = 697
    Height = 281
  end
  object LbCep_cliente: TLabel
    Left = 69
    Top = 251
    Width = 26
    Height = 13
    Caption = 'Cep :'
    FocusControl = cxDBTextEd_cep_cliente
  end
  object lb_logradouro_cliente: TLabel
    Left = 69
    Top = 277
    Width = 62
    Height = 13
    Caption = 'Logradouro :'
    FocusControl = cxDBTextEd_logradouro_cliente
  end
  object lbnumeroCliente: TLabel
    Left = 69
    Top = 309
    Width = 44
    Height = 13
    Caption = 'Numero :'
    FocusControl = cxDBTextEdNum_endereco_cliente
  end
  object lbcomplemento_cliente: TLabel
    Left = 69
    Top = 336
    Width = 120
    Height = 13
    Caption = 'Complemento Endere'#231'o :'
    FocusControl = cxDBTextEd_complemento_endereco_cliente
  end
  object lbBairro: TLabel
    Left = 69
    Top = 363
    Width = 35
    Height = 13
    Caption = 'Bairro :'
    FocusControl = cxDBTextEd_bairro_cliente
  end
  object lbCidadeCliente: TLabel
    Left = 69
    Top = 390
    Width = 40
    Height = 13
    Caption = 'Cidade :'
    FocusControl = cxDBTextEd_cidade_cliente
  end
  object lbEstadoCliente: TLabel
    Left = 69
    Top = 417
    Width = 40
    Height = 13
    Caption = 'Estado :'
    FocusControl = cxDBTextEd_estado_cliente
  end
  object lbPaisCliente: TLabel
    Left = 69
    Top = 444
    Width = 26
    Height = 13
    Caption = 'Pais :'
    FocusControl = cxDBTextEd_Pais_cliente
  end
  object cxDBTextEd_nom_cliente: TcxDBTextEdit
    Left = 32
    Top = 59
    DataBinding.DataField = 'nom_cliente'
    DataBinding.DataSource = DsClientes
    TabOrder = 0
    Width = 505
  end
  object cxDBTextEd_identidade_cliente: TcxDBTextEdit
    Left = 91
    Top = 93
    DataBinding.DataField = 'identidade_cliente'
    DataBinding.DataSource = DsClientes
    TabOrder = 1
    Width = 121
  end
  object cxDBTextEd_telefone_cliente: TcxDBTextEdit
    Left = 87
    Top = 157
    DataBinding.DataField = 'tel_cliente'
    DataBinding.DataSource = DsClientes
    TabOrder = 3
    Width = 121
  end
  object cxDBTextEd_email_cliente: TcxDBTextEdit
    Left = 87
    Top = 184
    DataBinding.DataField = 'email_cliente'
    DataBinding.DataSource = DsClientes
    TabOrder = 4
    Width = 442
  end
  object cxDBTextEd_cpf_cliente: TcxDBTextEdit
    Left = 87
    Top = 130
    DataBinding.DataField = 'cpf_cliente'
    DataBinding.DataSource = DsClientes
    TabOrder = 2
    OnExit = cxDBTextEd_cpf_clienteExit
    Width = 121
  end
  object cxDBTextEd_cep_cliente: TcxDBTextEdit
    Left = 211
    Top = 248
    DataBinding.DataField = 'cep_cliente'
    DataBinding.DataSource = DsClientes
    TabOrder = 5
    OnExit = cxDBTextEd_cep_clienteExit
    Width = 121
  end
  object cxDBTextEd_logradouro_cliente: TcxDBTextEdit
    Left = 211
    Top = 274
    DataBinding.DataField = 'des_logradouro_cliente'
    DataBinding.DataSource = DsClientes
    TabOrder = 6
    Width = 390
  end
  object cxDBTextEdNum_endereco_cliente: TcxDBTextEdit
    Left = 211
    Top = 301
    DataBinding.DataField = 'numero_cliente'
    DataBinding.DataSource = DsClientes
    TabOrder = 7
    Width = 121
  end
  object cxDBTextEd_complemento_endereco_cliente: TcxDBTextEdit
    Left = 211
    Top = 328
    DataBinding.DataField = 'complemento_cliente'
    DataBinding.DataSource = DsClientes
    TabOrder = 8
    Width = 310
  end
  object cxDBTextEd_bairro_cliente: TcxDBTextEdit
    Left = 211
    Top = 355
    DataBinding.DataField = 'bairro_cliente'
    DataBinding.DataSource = DsClientes
    TabOrder = 9
    Width = 310
  end
  object cxDBTextEd_cidade_cliente: TcxDBTextEdit
    Left = 211
    Top = 382
    DataBinding.DataField = 'cidade_cliente'
    DataBinding.DataSource = DsClientes
    TabOrder = 10
    Width = 310
  end
  object cxDBTextEd_estado_cliente: TcxDBTextEdit
    Left = 211
    Top = 409
    DataBinding.DataField = 'estado_cliente'
    DataBinding.DataSource = DsClientes
    TabOrder = 11
    Width = 121
  end
  object cxDBTextEd_Pais_cliente: TcxDBTextEdit
    Left = 211
    Top = 436
    DataBinding.DataField = 'pais_cliente'
    DataBinding.DataSource = DsClientes
    TabOrder = 12
    Width = 121
  end
  object DBNavigator1: TDBNavigator
    Left = 32
    Top = 9
    Width = 240
    Height = 25
    DataSource = DsClientes
    TabOrder = 13
  end
  object CdsClientes: TClientDataSet
    PersistDataPacket.Data = {
      E30100009619E0BD01000000180000000D000000000003000000E3010B6E6F6D
      5F636C69656E7465010049000000010005574944544802000200780012696465
      6E7469646164655F636C69656E74650100490000000100055749445448020002
      000F000B6370665F636C69656E74650100490000000100055749445448020002
      0014000B74656C5F636C69656E74650100490000000100055749445448020002
      0014000D656D61696C5F636C69656E7465010049000000010005574944544802
      00020064000B6365705F636C69656E7465010049000000010005574944544802
      0002000A00166465735F6C6F677261646F75726F5F636C69656E746501004900
      000001000557494454480200020078000E6E756D65726F5F636C69656E746501
      00490000000100055749445448020002000A0013636F6D706C656D656E746F5F
      636C69656E74650100490000000100055749445448020002001E000E62616972
      726F5F636C69656E74650100490000000100055749445448020002001E000E63
      69646164655F636C69656E746501004900000001000557494454480200020028
      000E65737461646F5F636C69656E746501004900000001000557494454480200
      02001E000C706169735F636C69656E7465010049000000010005574944544802
      00020014000000}
    Active = True
    Aggregates = <>
    Params = <>
    BeforePost = CdsClientesBeforePost
    AfterPost = CdsClientesAfterPost
    Left = 440
    Top = 208
    object CdsClientesnom_cliente: TStringField
      Tag = 1
      DisplayLabel = 'Nome Cliente'
      FieldName = 'nom_cliente'
      Size = 120
    end
    object CdsClientesidentidade_cliente: TStringField
      Tag = 1
      DisplayLabel = 'Identidade'
      FieldName = 'identidade_cliente'
      Size = 15
    end
    object CdsClientescpf_cliente: TStringField
      Tag = 1
      DisplayLabel = 'CPF'
      DisplayWidth = 20
      FieldName = 'cpf_cliente'
    end
    object CdsClientestel_cliente: TStringField
      Tag = 1
      DisplayLabel = 'Telefone'
      FieldName = 'tel_cliente'
    end
    object CdsClientesemail_cliente: TStringField
      Tag = 1
      DisplayLabel = 'Email'
      FieldName = 'email_cliente'
      Size = 100
    end
    object CdsClientescep_cliente: TStringField
      Tag = 1
      DisplayLabel = 'Cep'
      FieldName = 'cep_cliente'
      Size = 10
    end
    object CdsClientesdes_logradouro_cliente: TStringField
      Tag = 1
      DisplayLabel = 'Logradouro'
      FieldName = 'des_logradouro_cliente'
      Size = 120
    end
    object CdsClientesnumero_cliente: TStringField
      Tag = 1
      DisplayLabel = 'Numero'
      FieldName = 'numero_cliente'
      Size = 10
    end
    object CdsClientescomplemento_cliente: TStringField
      DisplayLabel = 'Complemente Endere'#231'o'
      FieldName = 'complemento_cliente'
      Size = 30
    end
    object CdsClientesbairro_cliente: TStringField
      Tag = 1
      DisplayLabel = 'Bairro'
      FieldName = 'bairro_cliente'
      Size = 30
    end
    object CdsClientescidade_cliente: TStringField
      Tag = 1
      DisplayLabel = 'Cidade'
      FieldName = 'cidade_cliente'
      Size = 40
    end
    object CdsClientesestado_cliente: TStringField
      Tag = 1
      DisplayLabel = 'Estado'
      FieldName = 'estado_cliente'
      Size = 30
    end
    object CdsClientespais_cliente: TStringField
      Tag = 1
      DisplayLabel = 'Pais'
      FieldName = 'pais_cliente'
    end
  end
  object DsClientes: TDataSource
    DataSet = CdsClientes
    Left = 440
    Top = 264
  end
end
