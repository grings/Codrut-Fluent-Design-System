program FluentUXTest;

uses
  Vcl.Forms,
  CFX.ThemeManager,
  CFXTest in 'CFXTest.pas' {Form1},
  CFX.Template in '..\Source\CFX.Template.pas';

{$R *.res}
begin
  Application.Initialize;

  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
