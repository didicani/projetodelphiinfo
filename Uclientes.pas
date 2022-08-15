unit Uclientes;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, Vcl.ExtCtrls, cxTextEdit,
  cxDBEdit, Vcl.StdCtrls, Data.DB, Datasnap.DBClient, Data.DBXJSON, System.JSON,
  DBXJSONReflect, idHTTP, Vcl.ComCtrls, IdSSLOpenSSL, Vcl.Grids, Vcl.DBGrids, Vcl.DBCtrls, Vcl.Mask,
  IniFiles,IdComponent, IdTCPConnection,IdTCPClient,IdBaseComponent,IdMessage,IdExplicitTLSClientServerBase,
  IdMessageClient,  IdSMTPBase,   IdSMTP,   IdIOHandler,    IdIOHandlerSocket,   IdIOHandlerStack,
  IdSSL,   IdAttachmentFile,    IdText, XMLIntf, XMLDoc,IWSystem ;



type
  TEnderecoCompleto = record
    CEP,
    logradouro,
    complemento,
    bairro,
    localidade,
    uf,
    unidade,
    IBGE : string
  end;

type
  TFrmClientes = class(TForm)
    CdsClientes: TClientDataSet;
    CdsClientesnom_cliente: TStringField;
    CdsClientesidentidade_cliente: TStringField;
    CdsClientescpf_cliente: TStringField;
    CdsClientestel_cliente: TStringField;
    CdsClientesemail_cliente: TStringField;
    CdsClientescep_cliente: TStringField;
    CdsClientesdes_logradouro_cliente: TStringField;
    CdsClientesnumero_cliente: TStringField;
    CdsClientescomplemento_cliente: TStringField;
    CdsClientesbairro_cliente: TStringField;
    CdsClientescidade_cliente: TStringField;
    CdsClientesestado_cliente: TStringField;
    CdsClientespais_cliente: TStringField;
    lb_nom_cliente: TLabel;
    cxDBTextEd_nom_cliente: TcxDBTextEdit;
    lb_identidade_cliente: TLabel;
    cxDBTextEd_identidade_cliente: TcxDBTextEdit;
    Label4: TLabel;
    Label5: TLabel;
    cxDBTextEd_telefone_cliente: TcxDBTextEdit;
    Label6: TLabel;
    cxDBTextEd_email_cliente: TcxDBTextEdit;
    cxDBTextEd_cpf_cliente: TcxDBTextEdit;
    Bevel1: TBevel;
    LbCep_cliente: TLabel;
    cxDBTextEd_cep_cliente: TcxDBTextEdit;
    lb_logradouro_cliente: TLabel;
    cxDBTextEd_logradouro_cliente: TcxDBTextEdit;
    lbnumeroCliente: TLabel;
    cxDBTextEdNum_endereco_cliente: TcxDBTextEdit;
    lbcomplemento_cliente: TLabel;
    cxDBTextEd_complemento_endereco_cliente: TcxDBTextEdit;
    lbBairro: TLabel;
    cxDBTextEd_bairro_cliente: TcxDBTextEdit;
    lbCidadeCliente: TLabel;
    cxDBTextEd_cidade_cliente: TcxDBTextEdit;
    lbEstadoCliente: TLabel;
    cxDBTextEd_estado_cliente: TcxDBTextEdit;
    lbPaisCliente: TLabel;
    cxDBTextEd_Pais_cliente: TcxDBTextEdit;
    DBNavigator1: TDBNavigator;
    DsClientes: TDataSource;
    function getDados(params: TEnderecoCompleto): TJSONObject;
    function removerAcentuacao(str: string): string;
    procedure CarregaDados(JSON: TJSONObject);
    procedure CarregaDadosEndereco(jsonArray: TJSONArray);
    procedure LimparCampos;
    procedure cxDBTextEd_cep_clienteExit(Sender: TObject);
    procedure mensagemAviso(mensagem: string);
    function EnviarEmail(const AAssunto, ADestino, AAnexo: String): Boolean;
    procedure CdsClientesAfterPost(DataSet: TDataSet);
    function ValidaCPF(CPF: string): boolean;
    function FormataCPF(CPF: string): string;
    procedure cxDBTextEd_cpf_clienteExit(Sender: TObject);
    function CamposValidados: Boolean;
    procedure CdsClientesBeforePost(DataSet: TDataSet);
  private
    { Private declarations }

     var
      dadosEnderecoCompleto : TEnderecoCompleto;
  public
    { Public declarations }
  end;

var
  FrmClientes: TFrmClientes;

implementation

{$R *.dfm}



procedure TFrmClientes.CarregaDados(JSON: TJSONObject);
begin
  try


    CdsClientescidade_cliente.AsString  := UpperCase(JSON.Get('localidade').JsonValue.Value);
    CdsClientesbairro_cliente.AsString      := JSON.Get('bairro').JsonValue.Value;
    CdsClientesestado_cliente.AsString          := JSON.Get('uf').JsonValue.Value;
    CdsClientescomplemento_cliente.AsString := JSON.Get('complemento').JsonValue.Value;
    CdsClientesestado_cliente.AsString     := JSON.Get('uf').JsonValue.Value;
    CdsClientesdes_logradouro_cliente.AsString     := JSON.Get('logradouro').JsonValue.Value;

  except
    on e: Exception do
    begin
      Application.MessageBox(PChar('Ocorreu um erro ao consultar o CEP'), 'Erro', MB_OK + MB_ICONERROR);
    end;
  end;
end;

function TFrmClientes.getDados(params: TEnderecoCompleto): TJSONObject;
var
  HTTP: TIdHTTP;
  IDSSLHandler: TIdSSLIOHandlerSocketOpenSSL;
  Response: TStringStream;
  JsonArray: TJSONArray;
begin
  try
    HTTP := TIdHTTP.Create;
    IDSSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create;
    HTTP.IOHandler := IDSSLHandler;
    Response := TStringStream.Create('');
    IDSSLHandler.SSLOptions.Method := sslvSSLv23;
    IDSSLHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];



    HTTP.Get('https://viacep.com.br/ws/' + params.CEP + '/json', Response);
    if (HTTP.ResponseCode = 200) and not (UTF8ToString(Response.DataString) = '{'#$A'  "erro": true'#$A'}') then
    begin
      Result := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(UTF8ToString(Response.DataString)), 0) as TJSONObject;
    end
    else
      raise Exception.Create('CEP inexistente!');


   
  finally
    FreeAndNil(HTTP);
    FreeAndNil(IDSSLHandler);
    Response.Destroy;
  end;
end;

procedure TFrmClientes.LimparCampos;
var
  I : integer;
begin
  for I := 0 to Self.ControlCount - 1 do
    if Self.Controls[I] is TcxDBTextEdit then
      TEdit(Self.Controls[I]).Clear;


  CdsClientescidade_cliente.AsString  := '';
  CdsClientesbairro_cliente.AsString      := '';
  CdsClientesestado_cliente.AsString          := '';
  CdsClientescomplemento_cliente.AsString := '';
  CdsClientesestado_cliente.AsString   := '';

  with CdsClientes do
  begin
    DisableControls;
    try
      while not Eof do
        Delete;
    finally
      EnableControls;
    end;
  end;
end;

procedure TFrmClientes.CarregaDadosEndereco(jsonArray: TJSONArray);
var
  i : Integer;
  resultados, jsonObjeto : TJSONObject;
begin

  try
    for i := 0 to jsonArray.Size - 1 do
    begin


      CdsClientescidade_cliente.AsString  := UpperCase(TJSONObject(jsonArray.Get(0)).Get('localidade').JsonValue.Value);
      CdsClientesbairro_cliente.AsString      := TJSONObject(jsonArray.Get(i)).Get('bairro').JsonValue.Value;
      CdsClientesestado_cliente.AsString          := TJSONObject(jsonArray.Get(i)).Get('uf').JsonValue.Value;
      CdsClientescomplemento_cliente.AsString := TJSONObject(jsonArray.Get(i)).Get('complemento').JsonValue.Value;
      CdsClientesestado_cliente.AsString     := TJSONObject(jsonArray.Get(i)).Get('uf').JsonValue.Value;
      CdsClientesdes_logradouro_cliente.AsString     :=TJSONObject(jsonArray.Get(i)).Get('logradouro').JsonValue.Value;
    end;
  finally
  //  cds_dados.First;
    CdsClientes.EnableControls;
  end;

end;



procedure TFrmClientes.CdsClientesAfterPost(DataSet: TDataSet);
var XMLDocument: TXMLDocument;
  NodeTabela, NodeRegistro, NodeEndereco: IXMLNode;
begin
  XMLDocument := TXMLDocument.Create(Self);
  try
    XMLDocument.Active := True;
    NodeTabela := XMLDocument.AddChild('Clientes');

    NodeRegistro := NodeTabela.AddChild('Cadastro');
    NodeRegistro.ChildValues['Nome'] := cxDBTextEd_nom_cliente.Text;
    NodeRegistro.ChildValues['Identidade'] := cxDBTextEd_identidade_cliente.Text;
    NodeRegistro.ChildValues['CPF'] := cxDBTextEd_cpf_cliente.Text;
    NodeRegistro.ChildValues['Telefone'] := cxDBTextEd_telefone_cliente.Text;
    NodeRegistro.ChildValues['Email'] := cxDBTextEd_email_cliente.Text;
    NodeEndereco := NodeRegistro.AddChild('Endereco');
    NodeEndereco.ChildValues['Cep'] := cxDBTextEd_cep_cliente.Text;
    NodeEndereco.ChildValues['Logradouro'] := cxDBTextEd_logradouro_cliente.Text;
    NodeEndereco.ChildValues['Numero'] :=cxDBTextEdNum_endereco_cliente.Text;
    NodeEndereco.ChildValues['Complemento'] := cxDBTextEd_complemento_endereco_cliente.Text;
    NodeEndereco.ChildValues['Bairro'] := cxDBTextEd_bairro_cliente.Text;
    NodeEndereco.ChildValues['Cidade'] := cxDBTextEd_cidade_cliente.Text;
    NodeEndereco.ChildValues['Estado'] := cxDBTextEd_estado_cliente.Text;
    NodeEndereco.ChildValues['Pais'] := cxDBTextEd_Pais_cliente.Text;

    XMLDocument.SaveToFile(gsAppPath +'\Cliente.xml');

    if EnviarEmail('Envio de Cadastro de Cliente', cxDBTextEd_email_cliente.Text, gsAppPath +'\Cliente.xml')
    then ShowMessage('Enviado com sucesso!')
    else ShowMessage('Não foi possível enviar o e-mail!');
  finally
    XMLDocument.Free;
  end;

end;


procedure TFrmClientes.CdsClientesBeforePost(DataSet: TDataSet);
begin
   if not (CamposValidados) then
      Abort
end;

function TFrmClientes.CamposValidados: Boolean;
var
  i :Integer;
  Campos :TStrings;
  Bcampos : Boolean;
begin
   try

      Bcampos := false;
      Campos := TStringList.Create;
      Campos.Insert(0, 'Preencha os campos obrigatórios:');
      Campos.Insert(1, EmptyStr) ;
      for i:=0 to CdsClientes.Fields.Count-1 do
      begin
         if (CdsClientes.Fields[i].Tag=1) then
            if (CdsClientes.Fields[i].AsString=EmptyStr) then
            begin
               Campos.Add('- ' + CdsClientes.Fields[i].DisplayName);
               Bcampos := true;
            end;


      end;

      if Bcampos = True then
      begin
       ShowMessage(Campos.Text);
       result := false;
      end
      else result := true;
  finally
     Campos.Free;
  end;
end;

procedure TFrmClientes.cxDBTextEd_cep_clienteExit(Sender: TObject);
var
  jsonObject: TJSONObject;
begin
  if Length(cxDBTextEd_cep_cliente.Text) <> 8 then
  begin
    mensagemAviso('CEP inválido');
    cxDBTextEd_cep_cliente.SetFocus;
    exit;
  end;

  dadosEnderecoCompleto.CEP := cxDBTextEd_cep_cliente.text;

  jsonObject := getDados(dadosEnderecoCompleto);

  if jsonObject <> nil then
    CarregaDados(jsonObject)
  else
  begin
    mensagemAviso('CEP inválido ou não encontrado');
    cxDBTextEd_cep_cliente.SetFocus;
    Exit;
  end;
end;

procedure TFrmClientes.cxDBTextEd_cpf_clienteExit(Sender: TObject);
begin
  if ValidaCPF(cxDBTextEd_cpf_cliente.Text)  then
  begin
      cxDBTextEd_cpf_cliente.Text := FormataCPF(cxDBTextEd_cpf_cliente.Text) ;
  end
  else
  begin
    ShowMessage('Erro: CPF inválido !!!');
    cxDBTextEd_cpf_cliente.SetFocus();
  end;
end;


function TFrmClientes.ValidaCPF(CPF: string): boolean;
var  dig10, dig11: string;
    s, i, r, peso: integer;
begin
// length - retorna o tamanho da string (CPF é um número formado por 11 dígitos)
  if ((CPF = '00000000000') or (CPF = '11111111111') or
      (CPF = '22222222222') or (CPF = '33333333333') or
      (CPF = '44444444444') or (CPF = '55555555555') or
      (CPF = '66666666666') or (CPF = '77777777777') or
      (CPF = '88888888888') or (CPF = '99999999999') or
      (length(CPF) <> 11))
     then begin
              ValidaCPF := false;
              exit;
            end;

// try - protege o código para eventuais erros de conversão de tipo na função StrToInt
  try
{ *-- Cálculo do 1o. Digito Verificador --* }
    s := 0;
    peso := 10;
    for i := 1 to 9 do
    begin
// StrToInt converte o i-ésimo caractere do CPF em um número
      s := s + (StrToInt(CPF[i]) * peso);
      peso := peso - 1;
    end;
    r := 11 - (s mod 11);
    if ((r = 10) or (r = 11))
       then dig10 := '0'
    else str(r:1, dig10); // converte um número no respectivo caractere numérico

{ *-- Cálculo do 2o. Digito Verificador --* }
    s := 0;
    peso := 11;
    for i := 1 to 10 do
    begin
      s := s + (StrToInt(CPF[i]) * peso);
      peso := peso - 1;
    end;
    r := 11 - (s mod 11);
    if ((r = 10) or (r = 11))
       then dig11 := '0'
    else str(r:1, dig11);

{ Verifica se os digitos calculados conferem com os digitos informados. }
    if ((dig10 = CPF[10]) and (dig11 = CPF[11]))
       then ValidaCPF := true
    else ValidaCPF := false;
  except
    ValidaCPF := false
  end;
end;

function TFrmClientes.FormataCPF(CPF: string): string;
begin
  FormataCPF := copy(CPF, 1, 3) + '.' + copy(CPF, 4, 3) + '.' +
    copy(CPF, 7, 3) + '-' + copy(CPF, 10, 2);
end;

function TFrmClientes.removerAcentuacao(str: string): string;
var
  x: Integer;
const
  ComAcento = 'àâêôûãõáéíóúçüÀÂÊÔÛÃÕÁÉÍÓÚÇÜ';
  SemAcento = 'aaeouaoaeioucuAAEOUAOAEIOUCU';
begin
  for x := 1 to Length(Str) do

    if Pos(Str[x], ComAcento) <> 0 then
      Str[x] := SemAcento[Pos(Str[x], ComAcento)];

  Result := Str;
end;


procedure TFrmClientes.mensagemAviso(mensagem: string);
begin
  Application.MessageBox(PChar(mensagem), '', MB_OK + MB_ICONERROR);
end;



function TFrmClientes.EnviarEmail(const AAssunto, ADestino, AAnexo: String): Boolean;
var
  IniFile              : TIniFile;
  sFrom                : String;
  sBccList             : String;
  sHost                : String;
  iPort                : Integer;
  sUserName            : String;
  sPassword            : String;

  idMsg                : TIdMessage;
  IdText               : TIdText;
  idSMTP               : TIdSMTP;
  IdSSLIOHandlerSocket : TIdSSLIOHandlerSocketOpenSSL;
begin
  try
    try

      IniFile                          := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini');
      sFrom                            := IniFile.ReadString('Email' , 'From'     , sFrom);
      sBccList                         := IniFile.ReadString('Email' , 'BccList'  , sBccList);
      sHost                            := IniFile.ReadString('Email' , 'Host'     , sHost);
      iPort                            := IniFile.ReadInteger('Email', 'Port'     , iPort);
      sUserName                        := IniFile.ReadString('Email' , 'UserName' , sUserName);
      sPassword                        := IniFile.ReadString('Email' , 'Password' , sPassword);

      //Configura os parâmetros necessários para SSL
      IdSSLIOHandlerSocket                   := TIdSSLIOHandlerSocketOpenSSL.Create(Self);
      IdSSLIOHandlerSocket.SSLOptions.Method := sslvSSLv23;
      IdSSLIOHandlerSocket.SSLOptions.Mode  := sslmClient;



      //Variável referente a mensagem
      idMsg                            := TIdMessage.Create(Self);
      idMsg.CharSet                    := 'utf-8';
      idMsg.Encoding                   := meMIME;
      idMsg.From.Name                  := sFrom ;
      idMsg.From.Address               := sFrom;
      idMsg.Priority                   := mpNormal;
      idMsg.Subject                    := AAssunto;


      IdText := TIdText.Create(idMsg.MessageParts);
      IdText.Body.Add('<td class="esd-stripe" align="center">                                                                                                ');
      IdText.Body.Add('    <table class="es-content-body" style="background-color: transparent;" width="600" cellspacing="0" cellpadding="0" align="center"> ');
      IdText.Body.Add('        <tbody>                                                                                                                       ');
      IdText.Body.Add('            <tr>                                                                                                                      ');
      IdText.Body.Add('                <td class="esd-structure es-p20t es-p30r es-p30l" align="left">                                                       ');
      IdText.Body.Add('                    <table cellpadding="0" cellspacing="0" width="100%">                                                              ');
      IdText.Body.Add('                        <tbody>                                                                                                       ');
      IdText.Body.Add('                            <tr>                                                                                                      ');
      IdText.Body.Add('                                <td width="540" class="esd-container-frame" align="center" valign="top">                              ');
      IdText.Body.Add('                                    <table cellpadding="0" cellspacing="0" width="100%">                                              ');
      IdText.Body.Add('                                        <tbody>                                                                                       ');
      IdText.Body.Add('                                            <tr>                                                                                      ');
      IdText.Body.Add('                                                <td align="left" class="esd-block-text">                                              ');
      IdText.Body.Add('                                                    <p><strong>-- Dados Pessoais</strong></p>                                         ');
      IdText.Body.Add('                                                </td>                                                                                 ');
      IdText.Body.Add('                                            </tr>                                                                                     ');
      IdText.Body.Add('                                        </tbody>                                                                                      ');
      IdText.Body.Add('                                    </table>                                                                                          ');
      IdText.Body.Add('                                </td>                                                                                                 ');
      IdText.Body.Add('                            </tr>                                                                                                     ');
      IdText.Body.Add('                        </tbody>                                                                                                      ');
      IdText.Body.Add('                    </table>                                                                                                          ');
      IdText.Body.Add('                </td>                                                                                                                 ');
      IdText.Body.Add('            </tr>                                                                                                                     ');
      IdText.Body.Add('            <tr>                                                                                                                      ');
      IdText.Body.Add('                <td class="esd-structure es-p20t es-p30r es-p30l" align="left">                                                       ');
      IdText.Body.Add('                    <!--[if mso]><table width="540" cellpadding="0" cellspacing="0"><tr><td width="174" valign="top"><![endif]-->     ');
      IdText.Body.Add('                    <table cellpadding="0" cellspacing="0" class="es-left" align="left">                                              ');
      IdText.Body.Add('                        <tbody>                                                                                                       ');
      IdText.Body.Add('                            <tr>                                                                                                      ');
      IdText.Body.Add('                                <td width="174" class="es-m-p0r es-m-p20b esd-container-frame" valign="top" align="center">           ');
      IdText.Body.Add('                                    <table cellpadding="0" cellspacing="0" width="100%">                                              ');
      IdText.Body.Add('                                        <tbody>                                                                                       ');
      IdText.Body.Add('                                            <tr>                                                                                      ');
      IdText.Body.Add('                                                <td align="left" class="esd-block-text">                                              ');
      IdText.Body.Add('                                                    <p style="text-align: right;">Nome:.</p>                                          ');
      IdText.Body.Add('                                                </td>                                                                                 ');
      IdText.Body.Add('                                            </tr>                                                                                     ');
      IdText.Body.Add('                                        </tbody>                                                                                      ');
      IdText.Body.Add('                                    </table>                                                                                          ');
      IdText.Body.Add('                                </td>                                                                                                 ');
      IdText.Body.Add('                            </tr>                                                                                                     ');
      IdText.Body.Add('                        </tbody>                                                                                                      ');
      IdText.Body.Add('                    </table>                                                                                                          ');
      IdText.Body.Add('                    <!--[if mso]></td><td width="20"></td><td width="346" valign="top"><![endif]-->                                   ');
      IdText.Body.Add('                    <table cellpadding="0" cellspacing="0" align="right">                                                             ');
      IdText.Body.Add('                        <tbody>                                                                                                       ');
      IdText.Body.Add('                            <tr>                                                                                                      ');
      IdText.Body.Add('                                <td width="346" align="left" class="esd-container-frame">                                             ');
      IdText.Body.Add('                                    <table cellpadding="0" cellspacing="0" width="100%">                                              ');
      IdText.Body.Add('                                        <tbody>                                                                                       ');
      IdText.Body.Add('                                            <tr>                                                                                      ');
      IdText.Body.Add('                                                <td align="left" class="esd-block-text">                                              ');
      IdText.Body.Add('                                                    <p>'+cxDBTextEd_nom_cliente.Text+'</p>                                                                     ');
      IdText.Body.Add('                                                </td>                                                                                 ');
      IdText.Body.Add('                                            </tr>                                                                                     ');
      IdText.Body.Add('                                        </tbody>                                                                                      ');
      IdText.Body.Add('                                    </table>                                                                                          ');
      IdText.Body.Add('                                </td>                                                                                                 ');
      IdText.Body.Add('                            </tr>                                                                                                     ');
      IdText.Body.Add('                        </tbody>                                                                                                      ');
      IdText.Body.Add('                    </table>                                                                                                          ');
      IdText.Body.Add('                    <!--[if mso]></td></tr></table><![endif]-->                                                                       ');
      IdText.Body.Add('                </td>                                                                                                                 ');
      IdText.Body.Add('            </tr>                                                                                                                     ');
      IdText.Body.Add('            <tr>                                                                                                                      ');
      IdText.Body.Add('                <td class="esd-structure es-p20t es-p30r es-p30l" align="left">                                                       ');
      IdText.Body.Add('                    <!--[if mso]><table width="540" cellpadding="0" cellspacing="0"><tr><td width="174" valign="top"><![endif]-->     ');
      IdText.Body.Add('                    <table cellpadding="0" cellspacing="0" class="es-left" align="left">                                              ');
      IdText.Body.Add('                        <tbody>                                                                                                       ');
      IdText.Body.Add('                            <tr>                                                                                                      ');
      IdText.Body.Add('                                <td width="174" class="es-m-p0r es-m-p20b esd-container-frame" valign="top" align="center">           ');
      IdText.Body.Add('                                    <table cellpadding="0" cellspacing="0" width="100%">                                              ');
      IdText.Body.Add('                                        <tbody>                                                                                       ');
      IdText.Body.Add('                                            <tr>                                                                                      ');
      IdText.Body.Add('                                                <td align="left" class="esd-block-text">                                              ');
      IdText.Body.Add('                                                    <p style="text-align: right;">Identidade :.</p>                                   ');
      IdText.Body.Add('                                                </td>                                                                                 ');
      IdText.Body.Add('                                            </tr>                                                                                     ');
      IdText.Body.Add('                                        </tbody>                                                                                      ');
      IdText.Body.Add('                                    </table>                                                                                          ');
      IdText.Body.Add('                                </td>                                                                                                 ');
      IdText.Body.Add('                            </tr>                                                                                                     ');
      IdText.Body.Add('                        </tbody>                                                                                                      ');
      IdText.Body.Add('                    </table>                                                                                                          ');
      IdText.Body.Add('                    <!--[if mso]></td><td width="20"></td><td width="346" valign="top"><![endif]-->                                   ');
      IdText.Body.Add('                    <table cellpadding="0" cellspacing="0" align="right">                                                             ');
      IdText.Body.Add('                        <tbody>                                                                                                       ');
      IdText.Body.Add('                            <tr>                                                                                                      ');
      IdText.Body.Add('                                <td width="346" align="left" class="esd-container-frame">                                             ');
      IdText.Body.Add('                                    <table cellpadding="0" cellspacing="0" width="100%">                                              ');
      IdText.Body.Add('                                        <tbody>                                                                                       ');
      IdText.Body.Add('                                            <tr>                                                                                      ');
      IdText.Body.Add('                                                <td align="left" class="esd-block-text">                                              ');
      IdText.Body.Add('                                                    <p>'+cxDBTextEd_identidade_cliente.Text+'</p>                                                              ');
      IdText.Body.Add('                                                </td>                                                                                 ');
      IdText.Body.Add('                                            </tr>                                                                                     ');
      IdText.Body.Add('                                        </tbody>                                                                                      ');
      IdText.Body.Add('                                    </table>                                                                                          ');
      IdText.Body.Add('                                </td>                                                                                                 ');
      IdText.Body.Add('                            </tr>                                                                                                     ');
      IdText.Body.Add('                        </tbody>                                                                                                      ');
      IdText.Body.Add('                    </table>                                                                                                          ');
      IdText.Body.Add('                    <!--[if mso]></td></tr></table><![endif]-->                                                                       ');
      IdText.Body.Add('                </td>                                                                                                                 ');
      IdText.Body.Add('            </tr>                                                                                                                     ');
      IdText.Body.Add('            <tr>                                                                                                                      ');
      IdText.Body.Add('                <td class="esd-structure es-p20t es-p30r es-p30l" align="left">                                                       ');
      IdText.Body.Add('                    <!--[if mso]><table width="540" cellpadding="0" cellspacing="0"><tr><td width="174" valign="top"><![endif]-->     ');
      IdText.Body.Add('                    <table cellpadding="0" cellspacing="0" class="es-left" align="left">                                              ');
      IdText.Body.Add('                        <tbody>                                                                                                       ');
      IdText.Body.Add('                            <tr>                                                                                                      ');
      IdText.Body.Add('                                <td width="174" class="es-m-p0r es-m-p20b esd-container-frame" valign="top" align="center">           ');
      IdText.Body.Add('                                    <table cellpadding="0" cellspacing="0" width="100%">                                              ');
      IdText.Body.Add('                                        <tbody>                                                                                       ');
      IdText.Body.Add('                                            <tr>                                                                                      ');
      IdText.Body.Add('                                                <td align="right" class="esd-block-text">                                             ');
      IdText.Body.Add('                                                    <p>CPF:.</p>                                                                      ');
      IdText.Body.Add('                                                </td>                                                                                 ');
      IdText.Body.Add('                                            </tr>                                                                                     ');
      IdText.Body.Add('                                        </tbody>                                                                                      ');
      IdText.Body.Add('                                    </table>                                                                                          ');
      IdText.Body.Add('                                </td>                                                                                                 ');
      IdText.Body.Add('                            </tr>                                                                                                     ');
      IdText.Body.Add('                        </tbody>                                                                                                      ');
      IdText.Body.Add('                    </table>                                                                                                          ');
      IdText.Body.Add('                    <!--[if mso]></td><td width="20"></td><td width="346" valign="top"><![endif]-->                                   ');
      IdText.Body.Add('                    <table cellpadding="0" cellspacing="0" align="right">                                                             ');
      IdText.Body.Add('                        <tbody>                                                                                                       ');
      IdText.Body.Add('                            <tr>                                                                                                      ');
      IdText.Body.Add('                                <td width="346" align="left" class="esd-container-frame">                                             ');
      IdText.Body.Add('                                    <table cellpadding="0" cellspacing="0" width="100%">                                              ');
      IdText.Body.Add('                                        <tbody>                                                                                       ');
      IdText.Body.Add('                                            <tr>                                                                                      ');
      IdText.Body.Add('                                                <td align="left" class="esd-block-text">                                              ');
      IdText.Body.Add('                                                    <p>'+cxDBTextEd_cpf_cliente.Text+'</p>                                                                      ');
      IdText.Body.Add('                                                </td>                                                                                 ');
      IdText.Body.Add('                                            </tr>                                                                                     ');
      IdText.Body.Add('                                        </tbody>                                                                                      ');
      IdText.Body.Add('                                    </table>                                                                                          ');
      IdText.Body.Add('                                </td>                                                                                                 ');
      IdText.Body.Add('                            </tr>                                                                                                     ');
      IdText.Body.Add('                        </tbody>                                                                                                      ');
      IdText.Body.Add('                    </table>                                                                                                          ');
      IdText.Body.Add('                    <!--[if mso]></td></tr></table><![endif]-->                                                                       ');
      IdText.Body.Add('                </td>                                                                                                                 ');
      IdText.Body.Add('            </tr>                                                                                                                     ');
      IdText.Body.Add('            <tr>                                                                                                                      ');
      IdText.Body.Add('                <td class="esd-structure es-p20t es-p30r es-p30l" align="left">                                                       ');
      IdText.Body.Add('                    <!--[if mso]><table width="540" cellpadding="0" cellspacing="0"><tr><td width="174" valign="top"><![endif]-->     ');
      IdText.Body.Add('                    <table cellpadding="0" cellspacing="0" class="es-left" align="left">                                              ');
      IdText.Body.Add('                        <tbody>                                                                                                       ');
      IdText.Body.Add('                            <tr>                                                                                                      ');
      IdText.Body.Add('                                <td width="174" class="es-m-p0r es-m-p20b esd-container-frame" valign="top" align="center">           ');
      IdText.Body.Add('                                    <table cellpadding="0" cellspacing="0" width="100%">                                              ');
      IdText.Body.Add('                                        <tbody>                                                                                       ');
      IdText.Body.Add('                                            <tr>                                                                                      ');
      IdText.Body.Add('                                                <td align="left" class="esd-block-text">                                              ');
      IdText.Body.Add('                                                    <p style="text-align: right;">Telefone:.</p>                                      ');
      IdText.Body.Add('                                                </td>                                                                                 ');
      IdText.Body.Add('                                            </tr>                                                                                     ');
      IdText.Body.Add('                                        </tbody>                                                                                      ');
      IdText.Body.Add('                                    </table>                                                                                          ');
      IdText.Body.Add('                                </td>                                                                                                 ');
      IdText.Body.Add('                            </tr>                                                                                                     ');
      IdText.Body.Add('                        </tbody>                                                                                                      ');
      IdText.Body.Add('                    </table>                                                                                                          ');
      IdText.Body.Add('                    <!--[if mso]></td><td width="20"></td><td width="346" valign="top"><![endif]-->                                   ');
      IdText.Body.Add('                    <table cellpadding="0" cellspacing="0" align="right">                                                             ');
      IdText.Body.Add('                        <tbody>                                                                                                       ');
      IdText.Body.Add('                            <tr>                                                                                                      ');
      IdText.Body.Add('                                <td width="346" align="left" class="esd-container-frame">                                             ');
      IdText.Body.Add('                                    <table cellpadding="0" cellspacing="0" width="100%">                                              ');
      IdText.Body.Add('                                        <tbody>                                                                                       ');
      IdText.Body.Add('                                            <tr>                                                                                      ');
      IdText.Body.Add('                                                <td align="left" class="esd-block-text">                                              ');
      IdText.Body.Add('                                                    <p>'+cxDBTextEd_telefone_cliente.Text+'</p>                                                                     ');
      IdText.Body.Add('                                                </td>                                                                                 ');
      IdText.Body.Add('                                            </tr>                                                                                     ');
      IdText.Body.Add('                                        </tbody>                                                                                      ');
      IdText.Body.Add('                                    </table>                                                                                          ');
      IdText.Body.Add('                                </td>                                                                                                 ');
      IdText.Body.Add('                            </tr>                                                                                                     ');
      IdText.Body.Add('                        </tbody>                                                                                                      ');
      IdText.Body.Add('                    </table>                                                                                                          ');
      IdText.Body.Add('                    <!--[if mso]></td></tr></table><![endif]-->                                                                       ');
      IdText.Body.Add('                </td>                                                                                                                 ');
      IdText.Body.Add('            </tr>                                                                                                                     ');
      IdText.Body.Add('            <tr>                                                                                                                      ');
      IdText.Body.Add('                <td class="esd-structure es-p20t es-p30r es-p30l" align="left">                                                       ');
      IdText.Body.Add('                    <!--[if mso]><table width="540" cellpadding="0" cellspacing="0"><tr><td width="174" valign="top"><![endif]-->     ');
      IdText.Body.Add('                    <table cellpadding="0" cellspacing="0" class="es-left" align="left">                                              ');
      IdText.Body.Add('                        <tbody>                                                                                                       ');
      IdText.Body.Add('                            <tr>                                                                                                      ');
      IdText.Body.Add('                                <td width="174" class="es-m-p0r es-m-p20b esd-container-frame" valign="top" align="center">           ');
      IdText.Body.Add('                                    <table cellpadding="0" cellspacing="0" width="100%">                                              ');
      IdText.Body.Add('                                        <tbody>                                                                                       ');
      IdText.Body.Add('                                            <tr>                                                                                      ');
      IdText.Body.Add('                                                <td align="right" class="esd-block-text">                                             ');
      IdText.Body.Add('                                                    <p>Email:.</p>                                                                    ');
      IdText.Body.Add('                                                </td>                                                                                 ');
      IdText.Body.Add('                                            </tr>                                                                                     ');
      IdText.Body.Add('                                        </tbody>                                                                                      ');
      IdText.Body.Add('                                    </table>                                                                                          ');
      IdText.Body.Add('                                </td>                                                                                                 ');
      IdText.Body.Add('                            </tr>                                                                                                     ');
      IdText.Body.Add('                        </tbody>                                                                                                      ');
      IdText.Body.Add('                    </table>                                                                                                          ');
      IdText.Body.Add('                    <!--[if mso]></td><td width="20"></td><td width="346" valign="top"><![endif]-->                                   ');
      IdText.Body.Add('                    <table cellpadding="0" cellspacing="0" align="right">                                                             ');
      IdText.Body.Add('                        <tbody>                                                                                                       ');
      IdText.Body.Add('                            <tr>                                                                                                      ');
      IdText.Body.Add('                                <td width="346" align="left" class="esd-container-frame">                                             ');
      IdText.Body.Add('                                    <table cellpadding="0" cellspacing="0" width="100%">                                              ');
      IdText.Body.Add('                                        <tbody>                                                                                       ');
      IdText.Body.Add('                                            <tr>                                                                                      ');
      IdText.Body.Add('                                                <td align="left" class="esd-block-text">                                              ');
      IdText.Body.Add('                                                    <p>'+cxDBTextEd_email_cliente.Text+'</p>                                                                    ');
      IdText.Body.Add('                                                </td>                                                                                 ');
      IdText.Body.Add('                                            </tr>                                                                                     ');
      IdText.Body.Add('                                        </tbody>                                                                                      ');
      IdText.Body.Add('                                    </table>                                                                                          ');
      IdText.Body.Add('                                </td>                                                                                                 ');
      IdText.Body.Add('                            </tr>                                                                                                     ');
      IdText.Body.Add('                        </tbody>                                                                                                      ');
      IdText.Body.Add('                    </table>                                                                                                          ');
      IdText.Body.Add('                    <!--[if mso]></td></tr></table><![endif]-->                                                                       ');
      IdText.Body.Add('                </td>                                                                                                                 ');
      IdText.Body.Add('            </tr>                                                                                                                     ');
      IdText.Body.Add('            <tr>                                                                                                                      ');
      IdText.Body.Add('                <td class="esd-structure es-p20t es-p30r es-p30l" align="left">                                                       ');
      IdText.Body.Add('                    <table cellpadding="0" cellspacing="0" width="100%">                                                              ');
      IdText.Body.Add('                        <tbody>                                                                                                       ');
      IdText.Body.Add('                            <tr>                                                                                                      ');
      IdText.Body.Add('                                <td width="540" class="esd-container-frame" align="center" valign="top">                              ');
      IdText.Body.Add('                                    <table cellpadding="0" cellspacing="0" width="100%">                                              ');
      IdText.Body.Add('                                        <tbody>                                                                                       ');
      IdText.Body.Add('                                            <tr>                                                                                      ');
      IdText.Body.Add('                                                <td align="left" class="esd-block-text">                                              ');
      IdText.Body.Add('                                                    <p><strong>-- Dadoas do Endereço</strong></p>                                     ');
      IdText.Body.Add('                                                </td>                                                                                 ');
      IdText.Body.Add('                                            </tr>                                                                                     ');
      IdText.Body.Add('                                        </tbody>                                                                                      ');
      IdText.Body.Add('                                    </table>                                                                                          ');
      IdText.Body.Add('                                </td>                                                                                                 ');
      IdText.Body.Add('                            </tr>                                                                                                     ');
      IdText.Body.Add('                        </tbody>                                                                                                      ');
      IdText.Body.Add('                    </table>                                                                                                          ');
      IdText.Body.Add('                </td>                                                                                                                 ');
      IdText.Body.Add('            </tr>                                                                                                                     ');
      IdText.Body.Add('            <tr>                                                                                                                      ');
      IdText.Body.Add('                <td class="esd-structure es-p20t es-p30r es-p30l" align="left">                                                       ');
      IdText.Body.Add('                    <!--[if mso]><table width="540" cellpadding="0" cellspacing="0"><tr><td width="174" valign="top"><![endif]-->     ');
      IdText.Body.Add('                    <table cellpadding="0" cellspacing="0" class="es-left" align="left">                                              ');
      IdText.Body.Add('                        <tbody>                                                                                                       ');
      IdText.Body.Add('                            <tr>                                                                                                      ');
      IdText.Body.Add('                                <td width="174" class="es-m-p0r es-m-p20b esd-container-frame" valign="top" align="center">           ');
      IdText.Body.Add('                                    <table cellpadding="0" cellspacing="0" width="100%">                                              ');
      IdText.Body.Add('                                        <tbody>                                                                                       ');
      IdText.Body.Add('                                            <tr>                                                                                      ');
      IdText.Body.Add('                                                <td align="right" class="esd-block-text">                                             ');
      IdText.Body.Add('                                                    <p>CEP:.</p>                                                                      ');
      IdText.Body.Add('                                                </td>                                                                                 ');
      IdText.Body.Add('                                            </tr>                                                                                     ');
      IdText.Body.Add('                                        </tbody>                                                                                      ');
      IdText.Body.Add('                                    </table>                                                                                          ');
      IdText.Body.Add('                                </td>                                                                                                 ');
      IdText.Body.Add('                            </tr>                                                                                                     ');
      IdText.Body.Add('                        </tbody>                                                                                                      ');
      IdText.Body.Add('                    </table>                                                                                                          ');
      IdText.Body.Add('                    <!--[if mso]></td><td width="20"></td><td width="346" valign="top"><![endif]-->                                   ');
      IdText.Body.Add('                    <table cellpadding="0" cellspacing="0" align="right">                                                             ');
      IdText.Body.Add('                        <tbody>                                                                                                       ');
      IdText.Body.Add('                            <tr>                                                                                                      ');
      IdText.Body.Add('                                <td width="346" align="left" class="esd-container-frame">                                             ');
      IdText.Body.Add('                                    <table cellpadding="0" cellspacing="0" width="100%">                                              ');
      IdText.Body.Add('                                        <tbody>                                                                                       ');
      IdText.Body.Add('                                            <tr>                                                                                      ');
      IdText.Body.Add('                                                <td align="left" class="esd-block-text">                                              ');
      IdText.Body.Add('                                                    <p>'+cxDBTextEd_cep_cliente.Text+'</p>                                                                      ');
      IdText.Body.Add('                                                </td>                                                                                 ');
      IdText.Body.Add('                                            </tr>                                                                                     ');
      IdText.Body.Add('                                        </tbody>                                                                                      ');
      IdText.Body.Add('                                    </table>                                                                                          ');
      IdText.Body.Add('                                </td>                                                                                                 ');
      IdText.Body.Add('                            </tr>                                                                                                     ');
      IdText.Body.Add('                        </tbody>                                                                                                      ');
      IdText.Body.Add('                    </table>                                                                                                          ');
      IdText.Body.Add('                    <!--[if mso]></td></tr></table><![endif]-->                                                                       ');
      IdText.Body.Add('                </td>                                                                                                                 ');
      IdText.Body.Add('            </tr>                                                                                                                     ');
      IdText.Body.Add('            <tr>                                                                                                                      ');
      IdText.Body.Add('                <td class="esd-structure es-p20t es-p30r es-p30l" align="left">                                                       ');
      IdText.Body.Add('                    <!--[if mso]><table width="540" cellpadding="0" cellspacing="0"><tr><td width="174" valign="top"><![endif]-->     ');
      IdText.Body.Add('                    <table cellpadding="0" cellspacing="0" class="es-left" align="left">                                              ');
      IdText.Body.Add('                        <tbody>                                                                                                       ');
      IdText.Body.Add('                            <tr>                                                                                                      ');
      IdText.Body.Add('                                <td width="174" class="es-m-p0r es-m-p20b esd-container-frame" valign="top" align="center">           ');
      IdText.Body.Add('                                    <table cellpadding="0" cellspacing="0" width="100%">                                              ');
      IdText.Body.Add('                                        <tbody>                                                                                       ');
      IdText.Body.Add('                                            <tr>                                                                                      ');
      IdText.Body.Add('                                                <td align="right" class="esd-block-text">                                             ');
      IdText.Body.Add('                                                    <p>Logradouro:.</p>                                                               ');
      IdText.Body.Add('                                                </td>                                                                                 ');
      IdText.Body.Add('                                            </tr>                                                                                     ');
      IdText.Body.Add('                                        </tbody>                                                                                      ');
      IdText.Body.Add('                                    </table>                                                                                          ');
      IdText.Body.Add('                                </td>                                                                                                 ');
      IdText.Body.Add('                            </tr>                                                                                                     ');
      IdText.Body.Add('                        </tbody>                                                                                                      ');
      IdText.Body.Add('                    </table>                                                                                                          ');
      IdText.Body.Add('                    <!--[if mso]></td><td width="20"></td><td width="346" valign="top"><![endif]-->                                   ');
      IdText.Body.Add('                    <table cellpadding="0" cellspacing="0" align="right">                                                             ');
      IdText.Body.Add('                        <tbody>                                                                                                       ');
      IdText.Body.Add('                            <tr>                                                                                                      ');
      IdText.Body.Add('                                <td width="346" align="left" class="esd-container-frame">                                             ');
      IdText.Body.Add('                                    <table cellpadding="0" cellspacing="0" width="100%">                                              ');
      IdText.Body.Add('                                        <tbody>                                                                                       ');
      IdText.Body.Add('                                            <tr>                                                                                      ');
      IdText.Body.Add('                                                <td align="left" class="esd-block-text">                                              ');
      IdText.Body.Add('                                                    <p>'+cxDBTextEd_logradouro_cliente.Text+'</p>                                                                      ');
      IdText.Body.Add('                                                </td>                                                                                 ');
      IdText.Body.Add('                                            </tr>                                                                                     ');
      IdText.Body.Add('                                        </tbody>                                                                                      ');
      IdText.Body.Add('                                    </table>                                                                                          ');
      IdText.Body.Add('                                </td>                                                                                                 ');
      IdText.Body.Add('                            </tr>                                                                                                     ');
      IdText.Body.Add('                        </tbody>                                                                                                      ');
      IdText.Body.Add('                    </table>                                                                                                          ');
      IdText.Body.Add('                    <!--[if mso]></td></tr></table><![endif]-->                                                                       ');
      IdText.Body.Add('                </td>                                                                                                                 ');
      IdText.Body.Add('            </tr>                                                                                                                     ');
      IdText.Body.Add('            <tr>                                                                                                                      ');
      IdText.Body.Add('                <td class="esd-structure es-p20t es-p30r es-p30l" align="left">                                                       ');
      IdText.Body.Add('                    <!--[if mso]><table width="540" cellpadding="0" cellspacing="0"><tr><td width="174" valign="top"><![endif]-->     ');
      IdText.Body.Add('                    <table cellpadding="0" cellspacing="0" class="es-left" align="left">                                              ');
      IdText.Body.Add('                        <tbody>                                                                                                       ');
      IdText.Body.Add('                            <tr>                                                                                                      ');
      IdText.Body.Add('                                <td width="174" class="es-m-p0r es-m-p20b esd-container-frame" valign="top" align="center">           ');
      IdText.Body.Add('                                    <table cellpadding="0" cellspacing="0" width="100%">                                              ');
      IdText.Body.Add('                                        <tbody>                                                                                       ');
      IdText.Body.Add('                                            <tr>                                                                                      ');
      IdText.Body.Add('                                                <td align="right" class="esd-block-text">                                             ');
      IdText.Body.Add('                                                    <p>Número:.</p>                                                                   ');
      IdText.Body.Add('                                                </td>                                                                                 ');
      IdText.Body.Add('                                            </tr>                                                                                     ');
      IdText.Body.Add('                                        </tbody>                                                                                      ');
      IdText.Body.Add('                                    </table>                                                                                          ');
      IdText.Body.Add('                                </td>                                                                                                 ');
      IdText.Body.Add('                            </tr>                                                                                                     ');
      IdText.Body.Add('                        </tbody>                                                                                                      ');
      IdText.Body.Add('                    </table>                                                                                                          ');
      IdText.Body.Add('                    <!--[if mso]></td><td width="20"></td><td width="346" valign="top"><![endif]-->                                   ');
      IdText.Body.Add('                    <table cellpadding="0" cellspacing="0" align="right">                                                             ');
      IdText.Body.Add('                        <tbody>                                                                                                       ');
      IdText.Body.Add('                            <tr>                                                                                                      ');
      IdText.Body.Add('                                <td width="346" align="left" class="esd-container-frame">                                             ');
      IdText.Body.Add('                                    <table cellpadding="0" cellspacing="0" width="100%">                                              ');
      IdText.Body.Add('                                        <tbody>                                                                                       ');
      IdText.Body.Add('                                            <tr>                                                                                      ');
      IdText.Body.Add('                                                <td align="left" class="esd-block-text">                                              ');
      IdText.Body.Add('                                                    <p>'+cxDBTextEdNum_endereco_cliente.Text+'</p>                                                                      ');
      IdText.Body.Add('                                                </td>                                                                                 ');
      IdText.Body.Add('                                            </tr>                                                                                     ');
      IdText.Body.Add('                                        </tbody>                                                                                      ');
      IdText.Body.Add('                                    </table>                                                                                          ');
      IdText.Body.Add('                                </td>                                                                                                 ');
      IdText.Body.Add('                            </tr>                                                                                                     ');
      IdText.Body.Add('                        </tbody>                                                                                                      ');
      IdText.Body.Add('                    </table>                                                                                                          ');
      IdText.Body.Add('                    <!--[if mso]></td></tr></table><![endif]-->                                                                       ');
      IdText.Body.Add('                </td>                                                                                                                 ');
      IdText.Body.Add('            </tr>                                                                                                                     ');
      IdText.Body.Add('            <tr>                                                                                                                      ');
      IdText.Body.Add('                <td class="esd-structure es-p20t es-p30r es-p30l" align="left">                                                       ');
      IdText.Body.Add('                    <!--[if mso]><table width="540" cellpadding="0" cellspacing="0"><tr><td width="174" valign="top"><![endif]-->     ');
      IdText.Body.Add('                    <table cellpadding="0" cellspacing="0" class="es-left" align="left">                                              ');
      IdText.Body.Add('                        <tbody>                                                                                                       ');
      IdText.Body.Add('                            <tr>                                                                                                      ');
      IdText.Body.Add('                                <td width="174" class="es-m-p0r es-m-p20b esd-container-frame" valign="top" align="center">           ');
      IdText.Body.Add('                                    <table cellpadding="0" cellspacing="0" width="100%">                                              ');
      IdText.Body.Add('                                        <tbody>                                                                                       ');
      IdText.Body.Add('                                            <tr>                                                                                      ');
      IdText.Body.Add('                                                <td align="right" class="esd-block-text">                                             ');
      IdText.Body.Add('                                                    <p>Complemento:.</p>                                                              ');
      IdText.Body.Add('                                                </td>                                                                                 ');
      IdText.Body.Add('                                            </tr>                                                                                     ');
      IdText.Body.Add('                                        </tbody>                                                                                      ');
      IdText.Body.Add('                                    </table>                                                                                          ');
      IdText.Body.Add('                                </td>                                                                                                 ');
      IdText.Body.Add('                            </tr>                                                                                                     ');
      IdText.Body.Add('                        </tbody>                                                                                                      ');
      IdText.Body.Add('                    </table>                                                                                                          ');
      IdText.Body.Add('                    <!--[if mso]></td><td width="20"></td><td width="346" valign="top"><![endif]-->                                   ');
      IdText.Body.Add('                    <table cellpadding="0" cellspacing="0" align="right">                                                             ');
      IdText.Body.Add('                        <tbody>                                                                                                       ');
      IdText.Body.Add('                            <tr>                                                                                                      ');
      IdText.Body.Add('                                <td width="346" align="left" class="esd-container-frame">                                             ');
      IdText.Body.Add('                                    <table cellpadding="0" cellspacing="0" width="100%">                                              ');
      IdText.Body.Add('                                        <tbody>                                                                                       ');
      IdText.Body.Add('                                            <tr>                                                                                      ');
      IdText.Body.Add('                                                <td align="left" class="esd-block-text">                                              ');
      IdText.Body.Add('                                                    <p>'+cxDBTextEd_complemento_endereco_cliente.Text+'</p>                                                              ');
      IdText.Body.Add('                                                </td>                                                                                 ');
      IdText.Body.Add('                                            </tr>                                                                                     ');
      IdText.Body.Add('                                        </tbody>                                                                                      ');
      IdText.Body.Add('                                    </table>                                                                                          ');
      IdText.Body.Add('                                </td>                                                                                                 ');
      IdText.Body.Add('                            </tr>                                                                                                     ');
      IdText.Body.Add('                        </tbody>                                                                                                      ');
      IdText.Body.Add('                    </table>                                                                                                          ');
      IdText.Body.Add('                    <!--[if mso]></td></tr></table><![endif]-->                                                                       ');
      IdText.Body.Add('                </td>                                                                                                                 ');
      IdText.Body.Add('            </tr>                                                                                                                     ');
      IdText.Body.Add('            <tr>                                                                                                                      ');
      IdText.Body.Add('                <td class="esd-structure es-p20t es-p30r es-p30l" align="left">                                                       ');
      IdText.Body.Add('                    <!--[if mso]><table width="540" cellpadding="0" cellspacing="0"><tr><td width="174" valign="top"><![endif]-->     ');
      IdText.Body.Add('                    <table cellpadding="0" cellspacing="0" class="es-left" align="left">                                              ');
      IdText.Body.Add('                        <tbody>                                                                                                       ');
      IdText.Body.Add('                            <tr>                                                                                                      ');
      IdText.Body.Add('                                <td width="174" class="es-m-p0r es-m-p20b esd-container-frame" valign="top" align="center">           ');
      IdText.Body.Add('                                    <table cellpadding="0" cellspacing="0" width="100%">                                              ');
      IdText.Body.Add('                                        <tbody>                                                                                       ');
      IdText.Body.Add('                                            <tr>                                                                                      ');
      IdText.Body.Add('                                                <td align="right" class="esd-block-text">                                             ');
      IdText.Body.Add('                                                    <p>Bairro:.</p>                                                                   ');
      IdText.Body.Add('                                                </td>                                                                                 ');
      IdText.Body.Add('                                            </tr>                                                                                     ');
      IdText.Body.Add('                                        </tbody>                                                                                      ');
      IdText.Body.Add('                                    </table>                                                                                          ');
      IdText.Body.Add('                                </td>                                                                                                 ');
      IdText.Body.Add('                            </tr>                                                                                                     ');
      IdText.Body.Add('                        </tbody>                                                                                                      ');
      IdText.Body.Add('                    </table>                                                                                                          ');
      IdText.Body.Add('                    <!--[if mso]></td><td width="20"></td><td width="346" valign="top"><![endif]-->                                   ');
      IdText.Body.Add('                    <table cellpadding="0" cellspacing="0" align="right">                                                             ');
      IdText.Body.Add('                        <tbody>                                                                                                       ');
      IdText.Body.Add('                            <tr>                                                                                                      ');
      IdText.Body.Add('                                <td width="346" align="left" class="esd-container-frame">                                             ');
      IdText.Body.Add('                                    <table cellpadding="0" cellspacing="0" width="100%">                                              ');
      IdText.Body.Add('                                        <tbody>                                                                                       ');
      IdText.Body.Add('                                            <tr>                                                                                      ');
      IdText.Body.Add('                                                <td align="left" class="esd-block-text">                                              ');
      IdText.Body.Add('                                                    <p>'+cxDBTextEd_bairro_cliente.Text+'</p>                                                                   ');
      IdText.Body.Add('                                                </td>                                                                                 ');
      IdText.Body.Add('                                            </tr>                                                                                     ');
      IdText.Body.Add('                                        </tbody>                                                                                      ');
      IdText.Body.Add('                                    </table>                                                                                          ');
      IdText.Body.Add('                                </td>                                                                                                 ');
      IdText.Body.Add('                            </tr>                                                                                                     ');
      IdText.Body.Add('                        </tbody>                                                                                                      ');
      IdText.Body.Add('                    </table>                                                                                                          ');
      IdText.Body.Add('                    <!--[if mso]></td></tr></table><![endif]-->                                                                       ');
      IdText.Body.Add('                </td>                                                                                                                 ');
      IdText.Body.Add('            </tr>                                                                                                                     ');
      IdText.Body.Add('            <tr>                                                                                                                      ');
      IdText.Body.Add('                <td class="esd-structure es-p20t es-p30r es-p30l" align="left">                                                       ');
      IdText.Body.Add('                    <!--[if mso]><table width="540" cellpadding="0" cellspacing="0"><tr><td width="174" valign="top"><![endif]-->     ');
      IdText.Body.Add('                    <table cellpadding="0" cellspacing="0" class="es-left" align="left">                                              ');
      IdText.Body.Add('                        <tbody>                                                                                                       ');
      IdText.Body.Add('                            <tr>                                                                                                      ');
      IdText.Body.Add('                                <td width="174" class="es-m-p0r es-m-p20b esd-container-frame" valign="top" align="center">           ');
      IdText.Body.Add('                                    <table cellpadding="0" cellspacing="0" width="100%">                                              ');
      IdText.Body.Add('                                        <tbody>                                                                                       ');
      IdText.Body.Add('                                            <tr>                                                                                      ');
      IdText.Body.Add('                                                <td align="right" class="esd-block-text">                                             ');
      IdText.Body.Add('                                                    <p>Cidade:.</p>                                                                   ');
      IdText.Body.Add('                                                </td>                                                                                 ');
      IdText.Body.Add('                                            </tr>                                                                                     ');
      IdText.Body.Add('                                        </tbody>                                                                                      ');
      IdText.Body.Add('                                    </table>                                                                                          ');
      IdText.Body.Add('                                </td>                                                                                                 ');
      IdText.Body.Add('                            </tr>                                                                                                     ');
      IdText.Body.Add('                        </tbody>                                                                                                      ');
      IdText.Body.Add('                    </table>                                                                                                          ');
      IdText.Body.Add('                    <!--[if mso]></td><td width="20"></td><td width="346" valign="top"><![endif]-->                                   ');
      IdText.Body.Add('                    <table cellpadding="0" cellspacing="0" align="right">                                                             ');
      IdText.Body.Add('                        <tbody>                                                                                                       ');
      IdText.Body.Add('                            <tr>                                                                                                      ');
      IdText.Body.Add('                                <td width="346" align="left" class="esd-container-frame">                                             ');
      IdText.Body.Add('                                    <table cellpadding="0" cellspacing="0" width="100%">                                              ');
      IdText.Body.Add('                                        <tbody>                                                                                       ');
      IdText.Body.Add('                                            <tr>                                                                                      ');
      IdText.Body.Add('                                                <td align="left" class="esd-block-text">                                              ');
      IdText.Body.Add('                                                    <p>'+cxDBTextEd_cidade_cliente.Text+'</p>                                                                   ');
      IdText.Body.Add('                                                </td>                                                                                 ');
      IdText.Body.Add('                                            </tr>                                                                                     ');
      IdText.Body.Add('                                        </tbody>                                                                                      ');
      IdText.Body.Add('                                    </table>                                                                                          ');
      IdText.Body.Add('                                </td>                                                                                                 ');
      IdText.Body.Add('                            </tr>                                                                                                     ');
      IdText.Body.Add('                        </tbody>                                                                                                      ');
      IdText.Body.Add('                    </table>                                                                                                          ');
      IdText.Body.Add('                    <!--[if mso]></td></tr></table><![endif]-->                                                                       ');
      IdText.Body.Add('                </td>                                                                                                                 ');
      IdText.Body.Add('            </tr>                                                                                                                     ');
      IdText.Body.Add('            <tr>                                                                                                                      ');
      IdText.Body.Add('                <td class="esd-structure es-p20t es-p30r es-p30l" align="left">                                                       ');
      IdText.Body.Add('                    <!--[if mso]><table width="540" cellpadding="0" cellspacing="0"><tr><td width="174" valign="top"><![endif]-->     ');
      IdText.Body.Add('                    <table cellpadding="0" cellspacing="0" class="es-left" align="left">                                              ');
      IdText.Body.Add('                        <tbody>                                                                                                       ');
      IdText.Body.Add('                            <tr>                                                                                                      ');
      IdText.Body.Add('                                <td width="174" class="es-m-p0r es-m-p20b esd-container-frame" valign="top" align="center">           ');
      IdText.Body.Add('                                    <table cellpadding="0" cellspacing="0" width="100%">                                              ');
      IdText.Body.Add('                                        <tbody>                                                                                       ');
      IdText.Body.Add('                                            <tr>                                                                                      ');
      IdText.Body.Add('                                                <td align="right" class="esd-block-text">                                             ');
      IdText.Body.Add('                                                    <p>Estado:.</p>                                                                   ');
      IdText.Body.Add('                                                </td>                                                                                 ');
      IdText.Body.Add('                                            </tr>                                                                                     ');
      IdText.Body.Add('                                        </tbody>                                                                                      ');
      IdText.Body.Add('                                    </table>                                                                                          ');
      IdText.Body.Add('                                </td>                                                                                                 ');
      IdText.Body.Add('                            </tr>                                                                                                     ');
      IdText.Body.Add('                        </tbody>                                                                                                      ');
      IdText.Body.Add('                    </table>                                                                                                          ');
      IdText.Body.Add('                    <!--[if mso]></td><td width="20"></td><td width="346" valign="top"><![endif]-->                                   ');
      IdText.Body.Add('                    <table cellpadding="0" cellspacing="0" align="right">                                                             ');
      IdText.Body.Add('                        <tbody>                                                                                                       ');
      IdText.Body.Add('                            <tr>                                                                                                      ');
      IdText.Body.Add('                                <td width="346" align="left" class="esd-container-frame">                                             ');
      IdText.Body.Add('                                    <table cellpadding="0" cellspacing="0" width="100%">                                              ');
      IdText.Body.Add('                                        <tbody>                                                                                       ');
      IdText.Body.Add('                                            <tr>                                                                                      ');
      IdText.Body.Add('                                                <td align="left" class="esd-block-text">                                              ');
      IdText.Body.Add('                                                    <p>'+cxDBTextEd_estado_cliente.Text+'</p>                                                                       ');
      IdText.Body.Add('                                                </td>                                                                                 ');
      IdText.Body.Add('                                            </tr>                                                                                     ');
      IdText.Body.Add('                                        </tbody>                                                                                      ');
      IdText.Body.Add('                                    </table>                                                                                          ');
      IdText.Body.Add('                                </td>                                                                                                 ');
      IdText.Body.Add('                            </tr>                                                                                                     ');
      IdText.Body.Add('                        </tbody>                                                                                                      ');
      IdText.Body.Add('                    </table>                                                                                                          ');
      IdText.Body.Add('                    <!--[if mso]></td></tr></table><![endif]-->                                                                       ');
      IdText.Body.Add('                </td>                                                                                                                 ');
      IdText.Body.Add('            </tr>                                                                                                                     ');
      IdText.Body.Add('            <tr>                                                                                                                      ');
      IdText.Body.Add('                <td class="esd-structure es-p20t es-p30r es-p30l" align="left">                                                       ');
      IdText.Body.Add('                    <!--[if mso]><table width="540" cellpadding="0" cellspacing="0"><tr><td width="174" valign="top"><![endif]-->     ');
      IdText.Body.Add('                    <table cellpadding="0" cellspacing="0" class="es-left" align="left">                                              ');
      IdText.Body.Add('                        <tbody>                                                                                                       ');
      IdText.Body.Add('                            <tr>                                                                                                      ');
      IdText.Body.Add('                                <td width="174" class="es-m-p0r es-m-p20b esd-container-frame" valign="top" align="center">           ');
      IdText.Body.Add('                                    <table cellpadding="0" cellspacing="0" width="100%">                                              ');
      IdText.Body.Add('                                        <tbody>                                                                                       ');
      IdText.Body.Add('                                            <tr>                                                                                      ');
      IdText.Body.Add('                                                <td align="right" class="esd-block-text">                                             ');
      IdText.Body.Add('                                                    <p>País:.</p>                                                                     ');
      IdText.Body.Add('                                                </td>                                                                                 ');
      IdText.Body.Add('                                            </tr>                                                                                     ');
      IdText.Body.Add('                                        </tbody>                                                                                      ');
      IdText.Body.Add('                                    </table>                                                                                          ');
      IdText.Body.Add('                                </td>                                                                                                 ');
      IdText.Body.Add('                            </tr>                                                                                                     ');
      IdText.Body.Add('                        </tbody>                                                                                                      ');
      IdText.Body.Add('                    </table>                                                                                                          ');
      IdText.Body.Add('                    <!--[if mso]></td><td width="20"></td><td width="346" valign="top"><![endif]-->                                   ');
      IdText.Body.Add('                    <table cellpadding="0" cellspacing="0" align="right">                                                             ');
      IdText.Body.Add('                        <tbody>                                                                                                       ');
      IdText.Body.Add('                            <tr>                                                                                                      ');
      IdText.Body.Add('                                <td width="346" align="left" class="esd-container-frame">                                             ');
      IdText.Body.Add('                                    <table cellpadding="0" cellspacing="0" width="100%">                                              ');
      IdText.Body.Add('                                        <tbody>                                                                                       ');
      IdText.Body.Add('                                            <tr>                                                                                      ');
      IdText.Body.Add('                                                <td align="left" class="esd-block-text">                                              ');
      IdText.Body.Add('                                                    <p>'+cxDBTextEd_Pais_cliente.Text+'</p>                                                                     ');
      IdText.Body.Add('                                                </td>                                                                                 ');
      IdText.Body.Add('                                            </tr>                                                                                     ');
      IdText.Body.Add('                                        </tbody>                                                                                      ');
      IdText.Body.Add('                                    </table>                                                                                          ');
      IdText.Body.Add('                                </td>                                                                                                 ');
      IdText.Body.Add('                            </tr>                                                                                                     ');
      IdText.Body.Add('                        </tbody>                                                                                                      ');
      IdText.Body.Add('                    </table>                                                                                                          ');
      IdText.Body.Add('                    <!--[if mso]></td></tr></table><![endif]-->                                                                       ');
      IdText.Body.Add('                </td>                                                                                                                 ');
      IdText.Body.Add('            </tr>                                                                                                                     ');
      IdText.Body.Add('        </tbody>                                                                                                                      ');
      IdText.Body.Add('    </table>                                                                                                                          ');
      IdText.Body.Add('</td>                                                                                                                                 ');
            IdText.ContentType := 'text/html; charset=iso-8859-1';

      //Add Destinatário(s)
      idMsg.Recipients.Add;
      idMsg.Recipients.EMailAddresses := ADestino;
      idMsg.BccList.EMailAddresses    := sBccList;



      //Prepara o Servidor
      IdSMTP                           := TIdSMTP.Create(Self);
      IdSMTP.IOHandler                 := IdSSLIOHandlerSocket;
      IdSMTP.UseTLS                    := utUseImplicitTLS;
      IdSMTP.AuthType                  := satDefault;
      IdSMTP.Host                      := sHost;
      IdSMTP.AuthType                  := satDefault;
      IdSMTP.Port                      := iPort;
      IdSMTP.Username                  := sUserName;
      IdSMTP.Password                  := sPassword;

      //Conecta e Autentica
      IdSMTP.Connect;
      IdSMTP.Authenticate;

      if AAnexo <> EmptyStr then
        if FileExists(AAnexo) then
          TIdAttachmentFile.Create(idMsg.MessageParts, AAnexo);

      //Se a conexão foi bem sucedida, envia a mensagem
      if IdSMTP.Connected then
      begin
        try
          IdSMTP.Send(idMsg);
        except on E:Exception do
          begin
            ShowMessage('Erro ao tentar enviar: ' + E.Message);
          end;
        end;
      end;

      //Depois de tudo pronto, desconecta do servidor SMTP
      if IdSMTP.Connected then
        IdSMTP.Disconnect;

      Result := True;
    finally
      IniFile.Free;

      UnLoadOpenSSLLibrary;

      FreeAndNil(idMsg);
      FreeAndNil(IdSSLIOHandlerSocket);
      FreeAndNil(idSMTP);
    end;
  except on e:Exception do
    begin
      Result := False;
    end;
  end;
end;

end.
