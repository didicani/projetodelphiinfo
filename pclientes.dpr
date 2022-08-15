program pclientes;

uses
  Vcl.Forms,
  Uclientes in 'Uclientes.pas' {FrmClientes},
  uEndereco in 'uEndereco.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmClientes, FrmClientes);
  Application.Run;
end.
