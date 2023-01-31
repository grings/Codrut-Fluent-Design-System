unit CFXTest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UCL.Form,

  // CFX LIBRARY
  CFX.Forms, CFX.Colors, CFX.ThemeManager, Vcl.StdCtrls, Vcl.TitleBarCtrls,
  Vcl.ExtCtrls, Vcl.Imaging.jpeg, CFX.Button, CFX.Checkbox, CFX.Panels,
  CFX.StandardIcons, CFX.Slider, CFX.Dialogs;

type
  TForm1 = class(FXForm)
    Label1: TLabel;
    Timer1: TTimer;
    FXButton1: FXButton;
    FXMinimisePanel1: FXMinimisePanel;
    FXButon2: FXButton;
    FXButton2: FXButton;
    FXSlider2: FXSlider;
    FXCheckBox1: FXCheckBox;
    TitleBarPanel1: TTitleBarPanel;
    FXStandardIcon1: FXStandardIcon;
    FXStandardIcon2: FXStandardIcon;
    procedure Button2Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure CButton1Click(Sender: TObject);
    procedure FXButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: FXForm;

implementation

{$R *.dfm}

procedure TForm1.Button2Click(Sender: TObject);
begin
  Self.SmokeEffect := NOT Self.SmokeEffect;

  if Application.ComponentState = [] then
    ShowMessage('');
end;

procedure TForm1.CButton1Click(Sender: TObject);
begin
  Self.SmokeEffect := true;
end;

procedure TForm1.FXButton1Click(Sender: TObject);
var
  A: FXDialog;
begin
  A := FXDialog.Create;

  A.Title := 'Hello World!';
  A.Text := 'This is a very important message, from our SPONSOR This is a very important message, from our SPONSOR This is a very important message, from our SPONSOR This is a very important message, from our SPONSOR This is a very important message, from our SPONSOR ';

  A.Buttons := [mbOk, mbCancel];

  A.Execute;

  A.Free;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Self.SmokeEffect := false;
end;

end.
