unit uWPDClasses;

interface

uses
  Generics.Collections,
  System.Classes,
  System.SysUtils,
  System.Math,
  System.SyncObjs,
  Winapi.Windows,
  Winapi.ActiveX,
  Vcl.Imaging.Jpeg,
  Vcl.Imaging.pngimage,
  Vcl.Graphics,
  uGraphicUtils,
  uConstants,
  uMemory,
  uPortableClasses,
  uWPDInterfaces,
  uBitmapUtils,
  uJpegUtils,
  GIFImage;

const
  MAX_RESOURCE_WAIT_TIME = 60000; //60 sec to wait maximum
  RESOURCE_RETRY_TIME = 100;

  E_RESOURCE_IN_USE = -2147024726;// (800700aa)': Automation Error. The requested resource is in use.
  E_NOT_FOUND = -2147023728;

type
  TWPDDeviceManager = class;
  TWPDDevice = class;

  TWPDItem = class(TInterfacedObject, IPDItem)
  private
    FDevice: TWPDDevice;
    FIDevice: IPDevice;
    FItemType: TPortableItemType;
    FName: string;
    FItemKey: string;
    FErrorCode: HRESULT;
    FFullSize, FFreeSize: Int64;
    FItemDate: TDateTime;
    FDeviceID: string;
    FDeviceName: string;
    FWidth: Integer;
    FHeight: Integer;
    FLoadOnlyName: Boolean;
    FVisible: Boolean;
    procedure ErrorCheck(Code: HRESULT);
    procedure TransferContent(ResourceID: TGUID; Stream: TStream; out ResourceFormat: TGUID;
      CallBack: TPDProgressCallBack);
    procedure ReadProperties;
  public
    constructor Create(ADevice: TWPDDevice; AItemKey: string; LoadOnlyName: Boolean = False);
    function GetErrorCode: HRESULT;
    function GetItemType: TPortableItemType;
    function GetName: string;
    function GetItemKey: string;
    function GetFullSize: Int64;
    function GetFreeSize: Int64;
    function GetItemDate: TDateTime;
    function GetDeviceID: string;
    function GetDeviceName: string;
    function GetWidth: Integer;
    function GetHeight: Integer;
    function GetIsVisible: Boolean;
    function GetInnerInterface: IUnknown;
    function ExtractPreview(var PreviewImage: TBitmap): Boolean;
    function SaveToStream(S: TStream): Boolean;
    function SaveToStreamEx(S: TStream; CallBack: TPDProgressCallBack): Boolean;
    function Clone: IPDItem;
  end;

  TWPDDevice = class(TInterfacedObject, IPDevice)
  private
    FContent: IPortableDeviceContent;
    FManager: TWPDDeviceManager;
    FIManager: IPManager;
    FDevice: IPortableDevice;
    FErrorCode: HRESULT;
    FDeviceID: string;
    FName: string;
    FPropertiesReaded: Boolean;
    FBatteryStatus: Byte;
    FDeviceType: TDeviceType;
    procedure ErrorCheck(Code: HRESULT);
    function GetContent: IPortableDeviceContent;
    procedure InitProps;
    procedure FillItemsCallBack(ParentKey: string; Packet: TList<IPDItem>; var Cancel: Boolean; Context: Pointer);
  public
    constructor Create(AManager: TWPDDeviceManager; Device: IPortableDevice);
    function GetErrorCode: HRESULT;
    function GetName: string;
    function GetDeviceID: string;
    function GetBatteryStatus: Byte;
    function GetDeviceType: TDeviceType;
    procedure FillItems(ItemKey: string; Items: TList<IPDItem>);
    procedure FillItemsWithCallBack(ItemKey: string; CallBack: TFillItemsCallBack; Context: Pointer);
    function GetItemByKey(ItemKey: string): IPDItem;
    function GetItemByPath(Path: string): IPDItem;
    function Delete(ItemKey: string): Boolean;
    property Manager: TWPDDeviceManager read FManager;
    property Content: IPortableDeviceContent read GetContent;
    property Device: IPortableDevice read FDevice;
    property DeviceID: string read GetDeviceID;
  end;

  TWPDDeviceManager = class(TInterfacedObject, IPManager)
  private
    FManager: IPortableDeviceManager;
    FErrorCode: HRESULT;
    procedure ErrorCheck(Code: HRESULT);
    procedure FillDeviceCallBack(Packet: TList<IPDevice>; var Cancel: Boolean; Context: Pointer);
    procedure FindDeviceByNameCallBack(Packet: TList<IPDevice>; var Cancel: Boolean; Context: Pointer);
    procedure FindDeviceByIDCallBack(Packet: TList<IPDevice>; var Cancel: Boolean; Context: Pointer);
  public
    constructor Create;
    function GetErrorCode: HRESULT;
    procedure FillDevices(Devices: TList<IPDevice>);
    procedure FillDevicesWithCallBack(CallBack: TFillDevicesCallBack; Context: Pointer);
    function GetDeviceByName(DeviceName: string): IPDevice;
    function GetDeviceByID(DeviceID: string): IPDevice;
    property Manager: IPortableDeviceManager read FManager;
  end;

  TEventTargetInfo = class
  public
    EventTypes: TPortableEventTypes;
    CallBack: TPortableEventCallBack;
  end;

  TEventDeviceInfo = class
  public
    DeviceID: string;
    Device: IPortableDevice;
    Cookie: string;
  end;

  TWPDDeviceEventCallback = class(TInterfacedObject, IPortableDeviceEventCallback)
  public
    function OnEvent(const pEventParameters: IPortableDeviceValues): HRESULT; stdcall;
  end;

  TWPDEventManager = class(TInterfacedObject, IPEventManager)
  private
    FSync: TCriticalSection;
    FEventTargets: TList<TEventTargetInfo>;
    FEventDevices: TList<TEventDeviceInfo>;
    FDeviceCallBack: IPortableDeviceEventCallback;
    procedure InvokeItem(EventType: TPortableEventType; DeviceID, ItemKey, ItemPath: string);
    procedure UnregisterDevice(DeviceID: string);
    procedure RegisterDevice(Device: TWPDDevice);
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterNotification(EventTypes: TPortableEventTypes; CallBack: TPortableEventCallBack);
    procedure UnregisterNotification(CallBack: TPortableEventCallBack);
  end;

  TFindDeviceContext = class(TObject)
  public
    Name: string;
    Device: IPDevice;
  end;

function WPDEventManager: TWPDEventManager;

implementation

var
  //only one request to WIA at moment - limitation of WIA, looks like WPD has the same limitation
  //http://msdn.microsoft.com/en-us/library/windows/desktop/ms630350%28v=vs.85%29.aspx
  FEventManager: TWPDEventManager = nil;
  FIEventManager: IPEventManager = nil;

function WPDEventManager: TWPDEventManager;
begin
  if FEventManager = nil then
  begin
    FEventManager := TWPDEventManager.Create;
    FIEventManager := FEventManager;
  end;

  Result := FEventManager;
end;

{ TWPDDeviceManager }

constructor TWPDDeviceManager.Create;
var
  HR: HRESULT;
begin
  FManager := nil;
  FErrorCode := S_OK;

  HR := CoCreateInstance(CLSID_PortableDeviceManager,
                         nil,
                         CLSCTX_INPROC_SERVER,
                         IID_PortableDeviceManager,
                         FManager);

  ErrorCheck(HR);
end;

procedure TWPDDeviceManager.ErrorCheck(Code: HRESULT);
begin
  if Failed(Code) then
    FErrorCode := Code;
end;

procedure TWPDDeviceManager.FillDeviceCallBack(Packet: TList<IPDevice>;
  var Cancel: Boolean; Context: Pointer);
begin
  TList<IPDevice>(Context).AddRange(Packet);
end;

procedure TWPDDeviceManager.FillDevices(Devices: TList<IPDevice>);
begin
  FillDevicesWithCallBack(FillDeviceCallBack, Devices);
end;

procedure TWPDDeviceManager.FillDevicesWithCallBack(CallBack: TFillDevicesCallBack; Context: Pointer);
var
  HR: HRESULT;
  PDISs: array of PWSTR;
  DeviceIDCount: Cardinal;
  I: Integer;
  FDevice: IPortableDevice;
  Key: _tagpropertykey;
  ClientInformation: IPortableDeviceValues;
  Device: TWPDDevice;
  DevList: TList<IPDevice>;
  Cancel: Boolean;
begin
  if FManager = nil then
    Exit;

  Cancel := False;
  DevList := TList<IPDevice>.Create;
  try
    repeat
      HR := FManager.GetDevices(nil, @DeviceIDCount);
    until E_RESOURCE_IN_USE <> HR;

    if SUCCEEDED(HR) then
    begin
      SetLength(PDISs, DeviceIDCount);

      repeat
        HR := FManager.GetDevices(PLPWSTR(PDISs), @DeviceIDCount);
      until E_RESOURCE_IN_USE <> HR;

      if SUCCEEDED(HR) then
      begin
        for I := 0 to Integer(DeviceIDCount) - 1 do
        begin
          HR := CoCreateInstance(CLSID_PortableDevice{FTM},
                  nil,
                  CLSCTX_INPROC_SERVER,
                  IID_PortableDevice{FTM},
                  FDevice);

          if SUCCEEDED(HR) then
          begin

            HR := CoCreateInstance(CLSID_PortableDeviceValues,
                                  nil,
                                  CLSCTX_INPROC_SERVER,
                                  IID_PortableDeviceValues,
                                  ClientInformation);

            if SUCCEEDED(HR) then
            begin
              Key.fmtid := WPD_CLIENT_INFO;
              Key.pid := 2;
              HR := ClientInformation.SetStringValue(Key, PChar('Photo Database'));

              if SUCCEEDED(HR) then
              begin

                Key.pid := 3;
                ErrorCheck(ClientInformation.SetUnsignedIntegerValue(Key, MajorVersion));

                Key.pid := 4;
                ErrorCheck(ClientInformation.SetUnsignedIntegerValue(key, MinorVersion));

                Key.pid := 5;
                ErrorCheck(ClientInformation.SetUnsignedIntegerValue(key, 0)); //build number
              end else
                ErrorCheck(HR);

              if Succeeded(HR) then
              begin
                repeat
                  HR := FDevice.Open(PWideChar(PDISs[I]), ClientInformation);
                until E_RESOURCE_IN_USE <> HR;

                //DEVICE IS READY FOR USING
                if Succeeded(HR) then
                begin
                  Device := TWPDDevice.Create(Self, FDevice);
                  if Device.GetDeviceType <> dtOther then
                  begin
                    DevList.Clear;
                    DevList.Add(Device);
                    CallBack(DevList, Cancel, Context);
                    if Cancel then
                      Break;
                  end else
                    F(Device);
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  finally
    F(DevList);
  end;
end;

procedure TWPDDeviceManager.FindDeviceByIDCallBack(Packet: TList<IPDevice>;
  var Cancel: Boolean; Context: Pointer);
var
  Device: IPDevice;
  C: TFindDeviceContext;
begin
  C := TFindDeviceContext(Context);

  for Device in Packet do
    if AnsiUpperCase(Device.DeviceID) = AnsiUpperCase(C.Name) then
    begin
      C.Device := Device;
      Cancel := True;
    end;
end;

procedure TWPDDeviceManager.FindDeviceByNameCallBack(Packet: TList<IPDevice>;
  var Cancel: Boolean; Context: Pointer);
var
  Device: IPDevice;
  C: TFindDeviceContext;
begin
  C := TFindDeviceContext(Context);

  for Device in Packet do
    if AnsiUpperCase(Device.Name) = AnsiUpperCase(C.Name) then
    begin
      C.Device := Device;
      Cancel := True;
    end;
end;

function TWPDDeviceManager.GetDeviceByID(DeviceID: string): IPDevice;
var
  Context: TFindDeviceContext;
begin
  Context := TFindDeviceContext.Create;
  try
    Context.Name := DeviceID;
    try
      FillDevicesWithCallBack(FindDeviceByIDCallBack, Context);
    finally
      Result := Context.Device;
    end;
  finally
    F(Context);
  end;
end;

function TWPDDeviceManager.GetDeviceByName(DeviceName: string): IPDevice;
var
  Context: TFindDeviceContext;
begin
  Context := TFindDeviceContext.Create;
  try
    Context.Name := DeviceName;
    try
      FillDevicesWithCallBack(FindDeviceByNameCallBack, Context);
    finally
      Result := Context.Device;
    end;
  finally
    F(Context);
  end;
end;

function TWPDDeviceManager.GetErrorCode: HRESULT;
begin
  Result := FErrorCode;
end;

{ TWPDDevice }

constructor TWPDDevice.Create(AManager: TWPDDeviceManager; Device: IPortableDevice);
var
  HR: HRESULT;
  cchFriendlyName: DWORD;
  pszFriendlyName: PWChar;
  pszDevID: PWChar;
begin
  FDevice := Device;
  FBatteryStatus := 255;
  FDeviceType := dtOther;
  FPropertiesReaded := False;
  FContent := nil;
  FName := DEFAULT_PORTABLE_DEVICE_NAME;

  if FDevice = nil then
    raise EInvalidOperation.Create('Device is null!');

  FDevice := Device;
  FManager := AManager;
  FIManager := AManager;

  repeat
    HR := FDevice.GetPnPDeviceID(pszDevID);
  until E_RESOURCE_IN_USE <> HR;

  FDeviceID := pszDevID;
  // First, pass NULL as the PWSTR return string parameter to get the total number
  // of characters to allocate for the string value.

  cchFriendlyName := 0;

  repeat
    HR := FManager.Manager.GetDeviceFriendlyName(PChar(FDeviceID), nil, @cchFriendlyName);
  until E_RESOURCE_IN_USE <> HR;

  // Second allocate the number of characters needed and retrieve the string value.
  if (SUCCEEDED(HR) and (cchFriendlyName > 0)) then
  begin
    GetMem(pszFriendlyName, cchFriendlyName * SizeOf(WChar));
    if (pszFriendlyName <> nil) then
    begin
      repeat
        HR := FManager.Manager.GetDeviceFriendlyName(PChar(FDeviceID), pszFriendlyName, @cchFriendlyName);
      until E_RESOURCE_IN_USE <> HR;

      if (Failed(HR)) then
        FName := DEFAULT_PORTABLE_DEVICE_NAME
      else
        FName := pszFriendlyName;

      FreeMem(pszFriendlyName);
    end else
      FName := DEFAULT_PORTABLE_DEVICE_NAME;
  end else
    ErrorCheck(HR);

  if FName = DEFAULT_PORTABLE_DEVICE_NAME then
  begin

    repeat
      HR := FManager.Manager.GetDeviceDescription(PChar(FDeviceID), nil, @cchFriendlyName);
    until E_RESOURCE_IN_USE <> HR;

    // Second allocate the number of characters needed and retrieve the string value.
    if (SUCCEEDED(HR) and (cchFriendlyName > 0)) then
    begin
      GetMem(pszFriendlyName, cchFriendlyName * SizeOf(WChar));
      if (pszFriendlyName <> nil) then
      begin
        repeat
          HR := FManager.Manager.GetDeviceDescription(PChar(FDeviceID), pszFriendlyName, @cchFriendlyName);
        until E_RESOURCE_IN_USE <> HR;

        if (Failed(HR)) then
          FName := DEFAULT_PORTABLE_DEVICE_NAME
        else
          FName := pszFriendlyName;

        FreeMem(pszFriendlyName);
      end else
        FName := DEFAULT_PORTABLE_DEVICE_NAME;
    end else
      ErrorCheck(HR);

  end;

  WPDEventManager.RegisterDevice(Self);
end;

function TWPDDevice.Delete(ItemKey: string): Boolean;
var
  pObjectIDs: IPortableDevicePropVariantCollection;
  ppResults: IPortableDevicePropVariantCollection;
  HR: HRESULT;
  pv: tag_inner_PROPVARIANT;
  ObjID: PChar;
  ppCapabilities: IPortableDeviceCapabilities;
  Mode: Integer;
  Command: _tagpropertykey;
  ppOptions: IPortableDeviceValues;
  key: _tagpropertykey;
  BoolValue: Integer;
begin
  Result := False;

  //To see if recursive deletion is supported, call IPortableDeviceCapabilities::GetCommandOptions.
  //If the retrieved IPortableDeviceValues interface contains a property value called
  //WPD_OPTION_OBJECT_MANAGEMENT_RECURSIVE_DELETE_SUPPORTED with a boolVal value of True, the device supports recursive deletion.
  Mode := PORTABLE_DEVICE_DELETE_NO_RECURSION;
  HR := FDevice.Capabilities(ppCapabilities);
  if Succeeded(HR) then
  begin
    Command.fmtid := WPD_CATEGORY_OBJECT_MANAGEMENT;
    Command.pid := WPD_COMMAND_OBJECT_MANAGEMENT_DELETE_OBJECTS;
    HR := ppCapabilities.GetCommandOptions(Command, ppOptions);
    if Succeeded(HR) then
    begin
      key.fmtid := WPD_CATEGORY_OBJECT_MANAGEMENT;
      key.pid := WPD_OPTION_OBJECT_MANAGEMENT_RECURSIVE_DELETE_SUPPORTED;
      HR := ppOptions.GetBoolValue(key, BoolValue);
      if Succeeded(HR) and (BoolValue = 1) then
        Mode := PORTABLE_DEVICE_DELETE_WITH_RECURSION;
    end;
  end;

  if Failed(HR) then
  begin
    ErrorCheck(HR);
    Exit;
  end;

  HR := CoCreateInstance(CLSID_PortableDevicePropVariantCollection,
                         nil,
                         CLSCTX_INPROC_SERVER,
                         IID_PortableDevicePropVariantCollection,
                         pObjectIDs);

  if Succeeded(HR) then
  begin
    HR := CoCreateInstance(CLSID_PortableDevicePropVariantCollection,
                           nil,
                           CLSCTX_INPROC_SERVER,
                           IID_PortableDevicePropVariantCollection,
                           ppResults);

    if Succeeded(HR) then
    begin
      ObjID := SysAllocString(PChar(ItemKey));
      try
        pv.VT := VT_LPWSTR;
        pv.__MIDL____MIDL_itf_PortableDeviceApi_0001_00000001.pwszVal := ObjID;

        HR := pObjectIDs.Add(pv);
        if Succeeded(HR) then
        begin
          HR := Content.Delete(Mode,
                               pObjectIDs,
                               ppResults);

          Result := Succeeded(HR);
        end;
      finally
        SysFreeString(ObjID);
      end;

    end;
  end;

  ErrorCheck(HR);
end;

procedure TWPDDevice.ErrorCheck(Code: HRESULT);
begin
  if Failed(Code) then
    FErrorCode := Code;
end;

procedure TWPDDevice.FillItems(ItemKey: string; Items: TList<IPDItem>);
begin
  FillItemsWithCallBack(ItemKey, FillItemsCallBack, Items);
end;

procedure TWPDDevice.FillItemsCallBack(ParentKey: string;
  Packet: TList<IPDItem>; var Cancel: Boolean; Context: Pointer);
begin
  TList<IPDItem>(Context).AddRange(Packet);
end;

procedure TWPDDevice.FillItemsWithCallBack(ItemKey: string;
  CallBack: TFillItemsCallBack; Context: Pointer);
const
  NUM_OBJECTS_TO_REQUEST = 10;
var
  HR: HRESULT;
  cFetched: DWORD;
  dwIndex: DWORD;
  Cancel: Boolean;
  EnumObjectIDs: IEnumPortableDeviceObjectIDs;
  ObjectIDArray:  array[0 .. NUM_OBJECTS_TO_REQUEST - 1] of PWSTR;
  ObjectKey: string;
  ItemList: TList<IPDItem>;
  Item: IPDItem;
  ParentPath: string;
begin
  Cancel := False;

  if ItemKey = '' then
    ItemKey := WPD_DEVICE_OBJECT_ID;

  ParentPath := PortableItemNameCache.GetPathByKey(FDeviceID, ItemKey);

  ItemList := TList<IPDItem>.Create;
  try

    repeat
      HR := Content.EnumObjects(0,                        // Flags are unused
                                PWideChar(ItemKey),       // Starting from the passed in object
                                nil,                      // Filter is unused
                                EnumObjectIDs);
    until E_RESOURCE_IN_USE <> HR;

    // Loop calling Next() while S_OK is being returned.
    while SUCCEEDED(HR) do
    begin
      repeat
        HR := EnumObjectIDs.Next(NUM_OBJECTS_TO_REQUEST,    // Number of objects to request on each NEXT call
                                 @ObjectIDArray,            // Array of PWSTR array which will be populated on each NEXT call
                                 cFetched);                 // Number of objects written to the PWSTR array
      until E_RESOURCE_IN_USE <> HR;

      if cFetched = 0 then
        Break;

      if (SUCCEEDED(HR)) then
      begin
        // Traverse the results of the Next() operation and recursively enumerate
        // Remember to free all returned object identifiers using CoTaskMemFree()

        for dwIndex := 0 to cFetched - 1 do
        begin
          ObjectKey := string(ObjectIDArray[dwIndex]);

          Item := TWPDItem.Create(Self, ObjectKey);
          ItemList.Add(Item);

          PortableItemNameCache.AddName(FDeviceID, Item.ItemKey, ItemKey, ParentPath + '\' + Item.Name);

          CallBack(ItemKey, ItemList, Cancel, Context);
          ItemList.Clear;
          if Cancel then
            Break;
        end;

        FreeList(ItemList, False);
      end;
    end;
  finally
    F(ItemList);
  end;
end;

function TWPDDevice.GetBatteryStatus: Byte;
begin
  InitProps;
  Result := FBatteryStatus;
end;

function TWPDDevice.GetDeviceID: string;
begin
  Result := FDeviceID;
end;

function TWPDDevice.GetDeviceType: TDeviceType;
begin
  InitProps;
  Result := FDeviceType;
end;

function TWPDDevice.GetErrorCode: HRESULT;
begin
  Result := FErrorCode;
end;

function TWPDDevice.GetItemByKey(ItemKey: string): IPDItem;
begin
  Result := TWPDItem.Create(Self, ItemKey);
end;

function TWPDDevice.GetItemByPath(Path: string): IPDItem;
var
  ItemKey, CurrentPath: string;
  HR: HRESULT;
  pFilter: IPortableDeviceValues;
  ppenum: IEnumPortableDeviceObjectIDs;
  Key: _tagpropertykey;
  cFetched: Cardinal;
  ObjectID: PWSTR;
  PathParts: TStringList;
  I: Integer;
  Item: IPDItem;
begin
  ItemKey := PortableItemNameCache.GetKeyByPath(FDeviceID, Path);
  if ItemKey = EMPTY_PATH then
  begin
    ItemKey := WPD_DEVICE_OBJECT_ID;

    PathParts := TStringList.Create;
    try
      PathParts.Delimiter := '\';
      PathParts.StrictDelimiter := True;
      PathParts.DelimitedText := Path;
      CurrentPath := '';

      HR := CoCreateInstance(CLSID_PortableDeviceValues, nil, CLSCTX_INPROC_SERVER, IID_PortableDeviceValues, pFilter);

      if Succeeded(HR) then
      begin
        for I := 0 to PathParts.Count - 1 do
        begin
          if PathParts[I] = '' then
            Continue;

          CurrentPath := CurrentPath + '\' + PathParts[I];
          Key.fmtid := PKEY_GenericObj;
          Key.pid := WPD_OBJECT_NAME;
          HR := pFilter.SetStringValue(Key, PChar(PathParts[I]));
          if Succeeded(HR) then
          begin

            repeat
            HR := FContent.EnumObjects(0,
                                       PChar(ItemKey),
                                       pFilter, //not all devices support this feature
                                       ppenum);
            until E_RESOURCE_IN_USE <> HR;

            while Succeeded(HR) do
            begin
              repeat
                HR := ppenum.Next(1,            // Number of objects to request on each NEXT call
                                  @ObjectID,    // Array of PWSTR array which will be populated on each NEXT call
                                  cFetched);    // Number of objects written to the PWSTR array
              until E_RESOURCE_IN_USE <> HR;

              if cFetched = 0 then
                Break;

              if Succeeded(HR) and (cFetched = 1) then
              begin
                Item := TWPDItem.Create(Self, string(ObjectID), True);
                //check item name because filter can be ignored by device
                if Item.GetName = PathParts[I] then
                begin
                  PortableItemNameCache.AddName(FDeviceID, string(ObjectID), ItemKey, CurrentPath);
                  ItemKey := string(ObjectID);
                  Break;
                end;
              end;
            end;
          end;
        end;
      end;
    finally
      F(PathParts);
    end;
  end;
  Result := GetItemByKey(ItemKey);
end;

function TWPDDevice.GetName: string;
begin
  Result := FName;
end;

procedure TWPDDevice.InitProps;
var
  HR: HRESULT;
  ppProperties: IPortableDeviceProperties;
  Key: _tagpropertykey;
  PropertiesToRead: IPortableDeviceKeyCollection;
  ppValues: IPortableDeviceValues;
  V: Cardinal;
begin
  if FPropertiesReaded then
    Exit;

  FPropertiesReaded := True;

  HR := CoCreateInstance(CLSID_PortableDeviceKeyCollection, nil, CLSCTX_INPROC_SERVER, IID_PortableDeviceKeyCollection, PropertiesToRead);
  if (SUCCEEDED(HR)) then
  begin
    repeat
      HR := Content.Properties(ppProperties);
    until E_RESOURCE_IN_USE <> HR;
  end else
    ErrorCheck(HR);

  ErrorCheck(HR);

  key.fmtid := PKEY_DeviceObj;
  key.pid := WPD_DEVICE_POWER_LEVEL;
  HR := PropertiesToRead.Add(key);
  ErrorCheck(HR);

  key.fmtid := PKEY_DeviceObj;
  key.pid := WPD_DEVICE_TYPE;
  HR := PropertiesToRead.Add(key);
  ErrorCheck(HR);

  // 3. Request the properties from the device.
  repeat
    HR :=  ppProperties.GetValues(PChar(WPD_DEVICE_OBJECT_ID),    // The object whose properties we are reading
                                  PropertiesToRead,               // The properties we want to read
                                  ppValues);                      // Result property values for the specified object
  until E_RESOURCE_IN_USE <> HR;

  if (SUCCEEDED(HR)) then
  begin
    key.fmtid := PKEY_DeviceObj;
    key.pid := WPD_DEVICE_POWER_LEVEL;
    HR := ppValues.GetUnsignedIntegerValue(key, V);
    if Succeeded(HR) then
      FBatteryStatus := Byte(V);

    key.fmtid := PKEY_DeviceObj;
    key.pid := WPD_DEVICE_TYPE;
    HR := ppValues.GetUnsignedIntegerValue(key, V);
    if Succeeded(HR) then
    begin
      case V of
        WPD_DEVICE_TYPE_CAMERA:
          FDeviceType := dtCamera;
        WPD_DEVICE_TYPE_MEDIA_PLAYER,
        WPD_DEVICE_TYPE_PHONE,
        WPD_DEVICE_TYPE_PERSONAL_INFORMATION_MANAGER,
        WPD_DEVICE_TYPE_AUDIO_RECORDER,
        WPD_DEVICE_TYPE_GENERIC:
          FDeviceType := dtPhone;
        WPD_DEVICE_TYPE_VIDEO:
          FDeviceType := dtVideo;
      end;
    end;

  end else
    ErrorCheck(HR);
end;

function TWPDDevice.GetContent: IPortableDeviceContent;
begin
  if FContent = nil then
    ErrorCheck(FDevice.Content(FContent));

  Result := FContent;
end;

{ TWPDItem }

function TWPDItem.Clone: IPDItem;
begin
  Result := Self;
end;

constructor TWPDItem.Create(ADevice: TWPDDevice; AItemKey: string; LoadOnlyName: Boolean = False);
begin
  FDevice := ADevice;
  FIDevice := ADevice; //to store reference to interface
  FItemKey := AItemKey;
  FErrorCode := S_OK;
  FItemType := piFile;
  FName := AItemKey;
  FFreeSize := 0;
  FFullSize := 0;
  FItemDate := MinDateTime;
  FDeviceID := ADevice.FDeviceID;
  FDeviceName := ADevice.FName;
  FWidth := 0;
  FHeight := 0;
  FVisible := True;
  FLoadOnlyName := LoadOnlyName;
  ReadProperties;
end;

procedure TWPDItem.ErrorCheck(Code: HRESULT);
begin
  if Failed(Code) then
    FErrorCode := Code;
end;

function TWPDItem.ExtractPreview(var PreviewImage: TBitmap): Boolean;
var
  MS: TMemoryStream;
  FormatGUID: TGUID;
  J: TJpegImage;
  PNG: TPngImage;
  W, H: Integer;
  CroppedImage: TBitmap;
  GIF: TGIFImage;
  Ext: string;
begin
  Result := False;
  MS := TMemoryStream.Create;
  try
    TransferContent(WPD_RESOURCE_THUMBNAIL, MS, FormatGUID, nil);
    if MS.Size = 0 then
    begin
      Ext := AnsiLowerCase(ExtractFileExt(FName));
      if (Ext = '.bmp') or (Ext = '.png') or (Ext = '.jpg') or (Ext = '.jpeg') or (Ext = '.gif') then
      begin
        TransferContent(WPD_RESOURCE_DEFAULT, MS, FormatGUID, nil);
        if (Ext = '.bmp') then
          FormatGUID := WPD_OBJECT_FORMAT_BMP;
        if (Ext = '.png') then
          FormatGUID := WPD_OBJECT_FORMAT_PNG;
        if (Ext = '.jpg') or (Ext = '.jpeg') then
          FormatGUID := WPD_OBJECT_FORMAT_JFIF;
        if (Ext = '.gif')  then
          FormatGUID := WPD_OBJECT_FORMAT_GIF;
      end else
        Exit;
    end;

    MS.Seek(0, soFromBeginning);
    if FormatGUID = WPD_OBJECT_FORMAT_BMP then
    begin
      PreviewImage.LoadFromStream(MS);
      Result := not PreviewImage.Empty;
    end else if FormatGUID = WPD_OBJECT_FORMAT_JFIF then
    begin
      J := TJpegImage.Create;
      try
        J.LoadFromStream(MS);
        Result := not J.Empty;
        if Result then
          AssignJpeg(PreviewImage, J);
      finally
        F(J);
      end;
    end else if FormatGUID = WPD_OBJECT_FORMAT_PNG then
    begin
      PNG := TPngImage.Create;
      try
        PNG.LoadFromStream(MS);
        Result := not PNG.Empty;
        if Result then
          AssignGraphic(PreviewImage, PNG);
      finally
        F(PNG);
      end;
    end else if FormatGUID = WPD_OBJECT_FORMAT_GIF then
    begin
      GIF := TGIFImage.Create;
      try
        GIF.LoadFromStream(MS);
        Result := not GIF.Empty;
        if Result then
          AssignBitmap(PreviewImage, GIF.Bitmap);
      finally
        F(GIF);
      end;
    end;
  finally
    F(MS);
  end;
  if Result and (FWidth > 0)  and (FHeight > 0) then
  begin

    W := FWidth;
    H := FHeight;
    ProportionalSize(PreviewImage.Width, PreviewImage.Height, W, H);
    if ((W <> PreviewImage.Width) or (H <> PreviewImage.Height)) and (W > 0) and (H > 0) then
    begin
      CroppedImage := TBitmap.Create;
      try
        CroppedImage.PixelFormat := pf24Bit;
        CroppedImage.SetSize(W, H);
        DrawImageExRect(CroppedImage, PreviewImage, PreviewImage.Width div 2 - W div 2, PreviewImage.Height div 2 - H div 2, W, H, 0, 0);
        F(PreviewImage);
        Exchange(PreviewImage, CroppedImage);
      finally
        F(CroppedImage);
      end;
    end;
  end;
end;

function TWPDItem.GetDeviceID: string;
begin
  Result := FDeviceID;
end;

function TWPDItem.GetDeviceName: string;
begin
  Result := FDeviceName;
end;

function TWPDItem.GetErrorCode: HRESULT;
begin
  Result := FErrorCode;
end;

function TWPDItem.GetFreeSize: Int64;
begin
  Result := FFreeSize;
end;

function TWPDItem.GetFullSize: Int64;
begin
  Result := FFullSize;
end;

function TWPDItem.GetHeight: Integer;
begin
  Result := FHeight;
end;

function TWPDItem.GetInnerInterface: IUnknown;
begin
  Result := nil;
end;

function TWPDItem.GetIsVisible: Boolean;
begin
  Result := FVisible;
end;

function TWPDItem.GetItemDate: TDateTime;
begin
  Result := FItemDate;
end;

function TWPDItem.GetItemKey: string;
begin
  Result := FItemKey;
end;

function TWPDItem.GetItemType: TPortableItemType;
begin
  Result := FItemType;
end;

function TWPDItem.GetName: string;
begin
  Result := FName;
end;

function TWPDItem.GetWidth: Integer;
begin
  Result := FWidth;
end;

procedure TWPDItem.ReadProperties;
var
  HR: HRESULT;
  ppProperties: IPortableDeviceProperties;
  PropertiesToRead: IPortableDeviceKeyCollection;
  Key: _tagpropertykey;
  ppValues: IPortableDeviceValues;
  pszObjectName: PChar;
  ObjectTypeGUID: TGUID;
  Size: Int64;
  V: tag_inner_PROPVARIANT;
  W, H: Integer;
  B: Integer;
begin
  HR := CoCreateInstance(CLSID_PortableDeviceKeyCollection, nil, CLSCTX_INPROC_SERVER, IID_PortableDeviceKeyCollection, PropertiesToRead);
  if (SUCCEEDED(HR)) then
  begin
    repeat
      HR := FDevice.Content.Properties(ppProperties);
    until E_RESOURCE_IN_USE <> HR;

    if Succeeded(HR) then
    begin

      Key.fmtid := PKEY_GenericObj;
      Key.pid := WPD_OBJECT_NAME;
      ErrorCheck(PropertiesToRead.Add(key));

      Key.fmtid := PKEY_GenericObj;
      Key.pid := WPD_OBJECT_ORIGINAL_FILE_NAME;
      ErrorCheck(PropertiesToRead.Add(key));

      Key.fmtid := PKEY_GenericObj;
      Key.pid := WPD_OBJECT_CONTENT_TYPE;
      ErrorCheck(PropertiesToRead.Add(key));

      Key.fmtid := PKEY_GenericObj;
      Key.pid := WPD_OBJECT_ISHIDDEN;
      ErrorCheck(PropertiesToRead.Add(key));

      repeat
        HR :=  ppProperties.GetValues(PChar(FItemKey),    // The object whose properties we are reading
                                      PropertiesToRead,   // The properties we want to read
                                      ppValues);          // Result property values for the specified object
      until E_RESOURCE_IN_USE <> HR;

      if Succeeded(HR) then
      begin

        Key.fmtid := PKEY_GenericObj;
        Key.pid := WPD_OBJECT_ORIGINAL_FILE_NAME;
        HR := ppValues.GetStringValue(key, pszObjectName);
        if (SUCCEEDED(HR)) then
          FName := pszObjectName
        else
        begin
          Key.fmtid := PKEY_GenericObj;
          Key.pid := WPD_OBJECT_NAME;
          HR := ppValues.GetStringValue(key, pszObjectName);
          if (SUCCEEDED(HR)) then
            FName := pszObjectName;
        end;

        Key.fmtid := PKEY_GenericObj;
        Key.pid := WPD_OBJECT_ISHIDDEN;
        HR := ppValues.GetBoolValue(key, B);
        if Succeeded(HR) and (B = 1) then
          FVisible := False;

        Key.pid := WPD_OBJECT_CONTENT_TYPE;
        HR := ppValues.GetGuidValue(key, ObjectTypeGUID);
        if (SUCCEEDED(HR)) then
        begin
          if ObjectTypeGUID = WPD_CONTENT_TYPE_FOLDER then
              FItemType := piDirectory;
          if ObjectTypeGUID = WPD_CONTENT_TYPE_IMAGE then
              FItemType := piImage;
          if ObjectTypeGUID = WPD_CONTENT_TYPE_VIDEO then
              FItemType := piVideo;
          if ObjectTypeGUID = WPD_CONTENT_TYPE_FUNCTIONAL_OBJECT then
              FItemType := piStorage;
        end;

        if FLoadOnlyName then
          Exit;

        PropertiesToRead.Clear;
        case FItemType of
          piImage,
          piVideo,
          piFile:
          begin
            Key.fmtid := PKEY_GenericObj;
            Key.pid := WPD_OBJECT_SIZE;
            ErrorCheck(PropertiesToRead.Add(key));

            Key.fmtid := PKEY_GenericObj;
            Key.pid := WPD_OBJECT_DATE_CREATED;
            ErrorCheck(PropertiesToRead.Add(key));

            key.fmtid := WPD_MEDIA_PROPERTIES_V1;
            Key.pid := WPD_MEDIA_WIDTH;
            PropertiesToRead.Add(key);

            key.fmtid := WPD_MEDIA_PROPERTIES_V1;
            Key.pid := WPD_MEDIA_HEIGHT;
            PropertiesToRead.Add(key);
            repeat
              HR :=  ppProperties.GetValues(PChar(FItemKey),    // The object whose properties we are reading
                                            PropertiesToRead,   // The properties we want to read
                                            ppValues);          // Result property values for the specified object
            until E_RESOURCE_IN_USE <> HR;

            if Succeeded(HR) then
            begin
              Key.fmtid := PKEY_GenericObj;
              Key.pid := WPD_OBJECT_SIZE;
              if ppValues.GetSignedLargeIntegerValue(key, Size) = S_OK then
                FFullSize := Size;

              Key.fmtid := PKEY_GenericObj;
              Key.pid := WPD_OBJECT_DATE_CREATED;
              if ppValues.GetValue(key, V) = S_OK then
                FItemDate := V.__MIDL____MIDL_itf_PortableDeviceApi_0001_00000001.date;

              key.fmtid := WPD_MEDIA_PROPERTIES_V1;
              Key.pid := WPD_MEDIA_WIDTH;
              if ppValues.GetSignedIntegerValue(key, W) = S_OK then
                FWidth := W;

              key.fmtid := WPD_MEDIA_PROPERTIES_V1;
              Key.pid := WPD_MEDIA_HEIGHT;
              if ppValues.GetSignedIntegerValue(key, H) = S_OK then
                FHeight := H;
            end;
          end;
          piStorage:
          begin
            Key.fmtid := WPD_STORAGE_OBJECT_PROPERTIES_V1;
            Key.pid := WPD_STORAGE_CAPACITY;
            ErrorCheck(PropertiesToRead.Add(key));

            Key.fmtid := WPD_STORAGE_OBJECT_PROPERTIES_V1;
            Key.pid := WPD_STORAGE_FREE_SPACE_IN_BYTES;
            ErrorCheck(PropertiesToRead.Add(key));

            repeat
              HR :=  ppProperties.GetValues(PChar(FItemKey),    // The object whose properties we are reading
                                            PropertiesToRead,   // The properties we want to read
                                            ppValues);          // Result property values for the specified object
            until E_RESOURCE_IN_USE <> HR;

            if Succeeded(HR) then
            begin
              Key.fmtid := WPD_STORAGE_OBJECT_PROPERTIES_V1;
              Key.pid := WPD_STORAGE_CAPACITY;
              if ppValues.GetSignedLargeIntegerValue(key, Size) = S_OK then
                FFullSize := Size
              else
                FVisible := False;

              Key.fmtid := WPD_STORAGE_OBJECT_PROPERTIES_V1;
              Key.pid := WPD_STORAGE_FREE_SPACE_IN_BYTES;
              if ppValues.GetSignedLargeIntegerValue(key, Size) = S_OK then
                FFreeSize := Size
              else
                FVisible := False;
            end;
          end;
        end;


      end else
        ErrorCheck(HR);

    end else
      ErrorCheck(HR);
  end else
    ErrorCheck(HR);

end;

function TWPDItem.SaveToStream(S: TStream): Boolean;
begin
  Result := SaveToStreamEx(S, nil);
end;

function TWPDItem.SaveToStreamEx(S: TStream; CallBack: TPDProgressCallBack): Boolean;
var
  FormatGUID: TGUID;
begin
  TransferContent(WPD_RESOURCE_DEFAULT, S, FormatGUID, CallBack);
  Result := FErrorCode = S_OK;
end;

//WPD_RESOURCE_THUMBNAIL or WPD_RESOURCE_DEFAULT
procedure TWPDItem.TransferContent(ResourceID: TGUID; Stream: TStream; out ResourceFormat: TGUID;
  CallBack: TPDProgressCallBack);
const
  DefaultBufferSize: Integer = 2 * 1024 * 1024;
var
  HR: HRESULT;
  pObjectDataStream: IStream;
  Buff: PByte;
  cbOptimalTransferSize: DWORD;
  Key: _tagpropertykey;
  ButesRead: Longint;
  ppResources: IPortableDeviceResources;
  ppResourceAttributes: IPortableDeviceValues;
  BufferSize, ReadBufferSize: Int64;
  ResFormat: TGUID;
  IsBreak: Boolean;
begin
  IsBreak := False;
  FErrorCode := S_OK;
  ResourceFormat := WPD_OBJECT_FORMAT_JFIF;
  BufferSize := DefaultBufferSize;

  repeat
    HR := FDevice.Content.Transfer(ppResources);
  until E_RESOURCE_IN_USE <> HR;

  if (SUCCEEDED(HR)) then
  begin
    repeat
      HR := ppResources.GetResourceAttributes(PChar(FItemKey),
                                              Key,
                                              ppResourceAttributes);
    until E_RESOURCE_IN_USE <> HR;

    if (SUCCEEDED(HR)) then
    begin
      key.fmtid := WPD_RESOURCE_ATTRIBUTES_V1;
      Key.pid := WPD_RESOURCE_ATTRIBUTE_OPTIMAL_READ_BUFFER_SIZE;
      if SUCCEEDED(ppResourceAttributes.GetSignedLargeIntegerValue(key, ReadBufferSize)) then
        BufferSize := ReadBufferSize;

      key.fmtid := WPD_RESOURCE_ATTRIBUTES_V1;
      Key.pid := WPD_RESOURCE_ATTRIBUTE_FORMAT;
      if SUCCEEDED(ppResourceAttributes.GetGuidValue(key, ResFormat)) and (ResFormat.D1 > 0) then
        ResourceFormat := ResFormat;
    end;

    BufferSize := Max(BufferSize, DefaultBufferSize);
    cbOptimalTransferSize := BufferSize;
    Key.fmtid := ResourceID;
    Key.pid := 0;

    repeat
      HR := ppResources.GetStream(PChar(FItemKey),         // Identifier of the object we want to transfer
                                  Key,                     // We are transferring the default resource (which is the entire object's data)
                                  STGM_READ,               // Opening a stream in READ mode, because we are reading data from the device.
                                  cbOptimalTransferSize,   // Driver supplied optimal transfer size
                                  pObjectDataStream);
    until E_RESOURCE_IN_USE <> HR;

    if (SUCCEEDED(HR)) then
    begin

      GetMem(Buff, BufferSize);
      try
        repeat

          HR := pObjectDataStream.Read(Buff, BufferSize, @ButesRead);

          if (SUCCEEDED(HR) and (ButesRead > 0)) then
          begin
            Stream.WriteBuffer(Buff[0], ButesRead);
            if Assigned(CallBack) then
              CallBack(Self, FFullSize, Stream.Size, IsBreak);
          end else if Failed(HR) and (HR <> E_RESOURCE_IN_USE) then
          begin
            IsBreak := False;
            Break;
          end;

          if IsBreak then
          begin
            FErrorCode := E_ABORT;
            Break;
          end;
        until (ButesRead = 0);

        repeat
          pObjectDataStream.Commit(0);
        until E_RESOURCE_IN_USE <> HR;
      finally
        FreeMem(Buff);
      end;

    end else
      ErrorCheck(HR);

  end else
    ErrorCheck(HR);

end;

{ TWPDEventManager }

constructor TWPDEventManager.Create;
begin
  FSync := TCriticalSection.Create;
  FEventTargets := TList<TEventTargetInfo>.Create;
  FEventDevices := TList<TEventDeviceInfo>.Create;
  FDeviceCallBack := TWPDDeviceEventCallback.Create;
end;

destructor TWPDEventManager.Destroy;
var
  HR: HRESULT;
  DevEventInfo: TEventDeviceInfo;
begin
  FreeList(FEventTargets);
  for DevEventInfo in FEventDevices do
  begin
    HR := DevEventInfo.Device.Unadvise(PChar(DevEventInfo.Cookie));
    if Failed(HR) then
      Break;
  end;
  FreeList(FEventDevices);
  F(FSync);
  inherited;
end;

procedure TWPDEventManager.InvokeItem(EventType: TPortableEventType; DeviceID, ItemKey, ItemPath: string);
var
  Info: TEventTargetInfo;
begin
  for Info in FEventTargets do
    if EventType in Info.EventTypes then
      Info.CallBack(EventType, DeviceID, ItemKey, ItemPath);
end;

procedure TWPDEventManager.RegisterNotification(EventTypes: TPortableEventTypes;
  CallBack: TPortableEventCallBack);
var
  Info: TEventTargetInfo;
begin
  Info := TEventTargetInfo.Create;
  Info.EventTypes := EventTypes;
  Info.CallBack := CallBack;
  FEventTargets.Add(Info);
end;

procedure TWPDEventManager.RegisterDevice(Device: TWPDDevice);
var
  HR: HRESULT;
  ppszCookie: PWideChar;
  EventDeviceInfo: TEventDeviceInfo;
  FDevice: IPortableDevice;
  ClientInformation: IPortableDeviceValues;
begin
  HR := CoInitializeEx(nil, COINIT_MULTITHREADED);
  //COINIT_MULTITHREADED is already initialized
  if HR = S_FALSE then
  begin
    FSync.Enter;
    try
      for EventDeviceInfo in FEventDevices do
        if AnsiLowerCase(EventDeviceInfo.DeviceID) = AnsiLowerCase(Device.DeviceID) then
          Exit;

      HR := CoCreateInstance(CLSID_PortableDeviceFTM,
              nil,
              CLSCTX_INPROC_SERVER,
              IID_PortableDeviceFTM,
              FDevice);

      if SUCCEEDED(HR) then
      begin

        HR := CoCreateInstance(CLSID_PortableDeviceValues,
                              nil,
                              CLSCTX_INPROC_SERVER,
                              IID_PortableDeviceValues,
                              ClientInformation);

        if SUCCEEDED(HR) then
        begin
          repeat
            HR := FDevice.Open(PWideChar(Device.DeviceID), ClientInformation);
          until E_RESOURCE_IN_USE <> HR;

          if Succeeded(HR) then
          begin
            repeat
              HR := FDevice.Advise(0, FDeviceCallBack, nil, ppszCookie);
            until E_RESOURCE_IN_USE <> HR;

            if Succeeded(HR) then
            begin
              EventDeviceInfo := TEventDeviceInfo.Create;
              EventDeviceInfo.Device := FDevice;
              EventDeviceInfo.DeviceID := Device.DeviceID;
              EventDeviceInfo.Cookie := string(ppszCookie);
              FEventDevices.Add(EventDeviceInfo);
              CoTaskMemFree(ppszCookie);
            end;
          end;
        end;
      end;

    finally
      FSync.Leave;
    end;
  end;
end;

procedure TWPDEventManager.UnregisterDevice(DeviceID: string);
var
  I: Integer;
  DevEventInfo: TEventDeviceInfo;
begin
  FSync.Enter;
  try
    for I := FEventDevices.Count - 1 downto 0 do
    begin
      DevEventInfo := FEventDevices[I];
      if AnsiLowerCase(DevEventInfo.DeviceID) = AnsiLowerCase(DeviceID) then
      begin
        DevEventInfo.DeviceID := '';
        DevEventInfo.Cookie := '';

        //todo: cleanup this in register event
        //FEventDevices.Remove(DevEventInfo);
        //DevEventInfo.Device.Unadvise(PChar(DevEventInfo.Cookie));
        //F(DevEventInfo);
      end;
    end;
  finally
    FSync.Leave;
  end;
end;

procedure TWPDEventManager.UnregisterNotification(CallBack: TPortableEventCallBack);
var
  I: Integer;
  Info: TEventTargetInfo;
begin
  for I := FEventTargets.Count - 1 downto 0 do
  begin
    Info := FEventTargets[I];
    if Addr(Info.CallBack) = Addr(CallBack) then
    begin
      FEventTargets.Remove(Info);
      Info.Free;
    end;
  end;
end;

{ TWPDDeviceEventCallback }

function TWPDDeviceEventCallback.OnEvent(
  const pEventParameters: IPortableDeviceValues): HRESULT;
var
  HR: HRESULT;
  Key: _tagpropertykey;
  DeviceID: PChar;
  EventGUID: TGUID;
  FilePath: string;
  PItemKey: PChar;
  Manager: IPManager;
  Device: IPDevice;
  Item: IPDItem;
begin
  Result := S_OK;

  if pEventParameters <> nil then
  begin
    Key.fmtid := WPD_EVENT_PROPERTIES_V1;
    Key.pid := WPD_EVENT_PARAMETER_PNP_DEVICE_ID;
    HR := pEventParameters.GetStringValue(Key, DeviceID);
    if Succeeded(HR) then
    begin
      Key.fmtid := WPD_EVENT_PROPERTIES_V1;
      Key.pid := WPD_EVENT_PARAMETER_EVENT_ID;
      HR := pEventParameters.GetGuidValue(Key, EventGUID);
      if Succeeded(HR) then
      begin

        if EventGUID = WPD_EVENT_OBJECT_REMOVED then
        begin
          Manager := TWPDDeviceManager.Create;
          Device := Manager.GetDeviceByID(DeviceID);
          if Device <> nil then
          begin
            Key.fmtid := PKEY_GenericObj;
            Key.pid := WPD_OBJECT_ID;
            HR := pEventParameters.GetStringValue(Key, PItemKey);
            if Succeeded(HR) then
            begin
              FilePath := Device.Name + PortableItemNameCache.GetPathByKey(DeviceID, string(PItemKey));
              TThread.Synchronize(nil,
                procedure
                begin
                  WPDEventManager.InvokeItem(peItemRemoved, DeviceID, string(PItemKey), FilePath);
                end
              );
            end;
          end;
        end;
        if EventGUID = WPD_EVENT_OBJECT_ADDED then
        begin
          Key.fmtid := PKEY_GenericObj;
          Key.pid := WPD_OBJECT_ID;
          HR := pEventParameters.GetStringValue(Key, PItemKey);
          if Succeeded(HR) then
          begin
            Manager := TWPDDeviceManager.Create;
            Device := Manager.GetDeviceByID(DeviceID);
            if Device <> nil then
            begin
              Item := Device.GetItemByKey(string(PItemKey));
              if Item <> nil then
              begin
                FilePath := Device.Name + PortableItemNameCache.GetPathByKey(DeviceID, string(PItemKey));
                TThread.Synchronize(nil,
                  procedure
                  begin
                    WPDEventManager.InvokeItem(peItemAdded, DeviceID, Item.ItemKey, FilePath);
                  end
                );
              end;
            end;
          end;
        end;
        if EventGUID = WPD_EVENT_DEVICE_REMOVED then
        begin
          WPDEventManager.UnregisterDevice(DeviceID);
          PortableItemNameCache.ClearDeviceCache(DeviceID);
          TThread.Synchronize(nil,
            procedure
            begin
              WPDEventManager.InvokeItem(peDeviceDisconnected, DeviceID, '', '');
            end
          );
        end;
      end;
    end;
end;
end;

initialization

finalization
  FIEventManager := nil;

end.
