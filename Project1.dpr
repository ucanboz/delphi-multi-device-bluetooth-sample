program Project1;

uses
  System.StartUpCopy,
  FMX.Forms,
  bluetooth in 'bluetooth.pas' {FBluetooth};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFBluetooth, FBluetooth);
  Application.Run;
end.
