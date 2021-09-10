unit bluetooth;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Bluetooth, System.Bluetooth.Components, FMX.ListBox,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Memo.Types, FMX.ScrollBox,
  FMX.Memo, FMX.Edit;

type
  TFBluetooth = class(TForm)
    Bluetooth1: TBluetooth;
    CDevicesList: TComboBox;
    CPairedDevicesList: TComboBox;
    BDiscoveryBluetoothDevices: TCornerButton;
    Timer1: TTimer;
    AniIndicator1: TAniIndicator;
    LStatus: TLabel;
    BConnect: TCornerButton;
    BClear: TCornerButton;
    BPair: TCornerButton;
    ESendingText: TEdit;
    Memo1: TMemo;
    BSend: TCornerButton;
    BGetData: TCornerButton;
    procedure Bluetooth1DiscoveryEnd(const Sender: TObject;
      const ADeviceList: TBluetoothDeviceList);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BDiscoveryBluetoothDevicesClick(Sender: TObject);
    procedure BConnectClick(Sender: TObject);
    procedure BClearClick(Sender: TObject);
    procedure BPairClick(Sender: TObject);
    procedure BSendClick(Sender: TObject);
    procedure BGetDataClick(Sender: TObject);
  private
    { Private declarations }
    FDiscoverDevices  : TBluetoothDeviceList;
    Fadapter          : TBluetoothAdapter;
    FBluetoothManager : TBluetoothManager;
    FPairedDevices    : TBluetoothDeviceList;
    ItemIndex         : Integer;
    FSocket           : TBluetoothSocket;
    procedure pairedDevices;
    procedure Connect;
    procedure SendData(Socket: TBluetoothSocket; Data: string);

    procedure Pair;

    function  GetServiceName(GUID: string): string;
    function GetData(socket:TBluetoothSocket):string;
  public
    { Public declarations }
  end;

var
  FBluetooth: TFBluetooth;

  const
  ServiceGUI = '{00001101-0000-1000-8000-00805F9B34FB}';

implementation

{$R *.fmx}

function TFBluetooth.GetData(socket:TBluetoothSocket):string;

var
  LBuffer: TBytes;
  Data : string;
begin

  Setlength(LBuffer, 50);
  LBuffer := socket.ReceiveData;
  Result := TEncoding.UTF8.GetString(LBuffer);

  end;

procedure TFBluetooth.SendData(Socket: TBluetoothSocket; Data: string);
begin
  socket.SendData(TEncoding.UTF8.GetBytes(Data));
end;


procedure TFBluetooth.Connect;
var
  LDevice: TBluetoothDevice;
begin
  LStatus.Text := 'BAÐLANIYOR.....';
  if (FSocket = nil) or (ItemIndex <> CPairedDevicesList.ItemIndex) then
  begin

    if CPairedDevicesList.ItemIndex > -1 then
    begin
      LDevice := FPairedDevices[CPairedDevicesList.ItemIndex] as TBluetoothDevice;
      FSocket := LDevice.CreateClientSocket(StringToGUID(ServiceGUI), False);

      if FSocket <> nil then
      begin
        ItemIndex := CPairedDevicesList.ItemIndex;
        FSocket.connect;
        LStatus.Text := 'Baðlandý';

      end
      else
        ShowMessage('Zaman Aþýmý');
    end
    else
      ShowMessage('Cihaz Seçilmedi');
  end;
end;

procedure TFBluetooth.Pair;
begin
begin
  if CDevicesList.ItemIndex > -1 then
    Fadapter.Pair(FDiscoverDevices[CDevicesList.ItemIndex])
  else
    ShowMessage('Cihaz seçiniz');
end;

end;


function TFBluetooth.GetServiceName(GUID: string): string;
var
  LServices: TBluetoothServiceList;
  LDevice: TBluetoothDevice;
  I: Integer;
begin
  LDevice := FPairedDevices[CPairedDevicesList.ItemIndex] as TBluetoothDevice;
  LServices := LDevice.GetServices;
  for I := 0 to LServices.Count - 1 do
  begin
    if StringToGUID(GUID) = LServices[I].UUID then
    begin
      Result := LServices[I].Name;

      break;
    end;
  end;
end;

procedure TFBluetooth.BClearClick(Sender: TObject);
begin
FreeAndNil(FSocket);
LStatus.Text := '';
end;

procedure TFBluetooth.BConnectClick(Sender: TObject);
begin
 Connect;
end;

procedure TFBluetooth.BDiscoveryBluetoothDevicesClick(Sender: TObject);
begin
  CDevicesList.Clear;
  Fadapter := FBluetoothManager.CurrentAdapter;
  FBluetoothManager.StartDiscovery(5000);
  FBluetoothManager.OnDiscoveryEnd := Bluetooth1DiscoveryEnd;
end;

procedure TFBluetooth.BGetDataClick(Sender: TObject);
begin
Memo1.Lines.Add(GetData(FSocket));
end;

procedure TFBluetooth.Bluetooth1DiscoveryEnd(const Sender: TObject;
  const ADeviceList: TBluetoothDeviceList);
var
  I: Integer;
begin
  FDiscoverDevices := ADeviceList;
  for I := 0 to ADeviceList.Count - 1 do
  begin
    CDevicesList.Items.Add(ADeviceList[I].DeviceName + '  -> ' +
    ADeviceList[I].Address);
    CDevicesList.ItemIndex := 0;


  end;
end;

procedure TFBluetooth.BPairClick(Sender: TObject);
begin
Pair;
end;

procedure TFBluetooth.BSendClick(Sender: TObject);
begin
SendData(FSocket, ESendingText.Text);
end;

procedure TFBluetooth.FormCreate(Sender: TObject);
begin
  try

    FBluetoothManager := TBluetoothManager.Current;
    Fadapter := FBluetoothManager.CurrentAdapter;

    PairedDevices;
    CPairedDevicesList.ItemIndex := 0;

  except
    on E: Exception do
    begin
      ShowMessage('Bluetooth cihazý bulunamadý: Baðlantý yok ya da kapalý!');
    end;
  end;
end;


procedure TFBluetooth.FormDestroy(Sender: TObject);
begin
 FreeAndNil(FSocket);
end;

procedure TFBluetooth.PairedDevices;
var
  I: Integer;
begin
  CPairedDevicesList.Clear;

  FPairedDevices := FBluetoothManager.GetPairedDevices;
  if FPairedDevices.Count > 0 then
    for I := 0 to FPairedDevices.Count - 1 do
      CPairedDevicesList.Items.Add(FPairedDevices[I].DeviceName)
  else
    CPairedDevicesList.Items.Add('Eþlenen cihaz yok');

end;

end.
