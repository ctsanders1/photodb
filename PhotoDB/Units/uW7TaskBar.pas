unit uW7TaskBar;

interface

uses
  Windows, ComObj, ShlObj, ActiveX;

const
  CLSID_TaskbarList: TGUID = '{56fdf344-fd6d-11d0-958a-006097c9a090}';
  IID_ITaskbarList : TGUID = '{56FDF342-FD6D-11d0-958A-006097C9A090}';
  IID_ITaskbarList2: TGUID = '{602D4995-B13A-429b-A66E-1935E44F4317}';
  IID_ITaskbarList3: TGUID = '{ea1afb91-9e28-4b86-90e9-9e9f8a5eefaf}';

type
  TBPF = (TBPF_NOPROGRESS = 0,
          TBPF_INDETERMINATE = 1,
          TBPF_NORMAL = 2,
          TBPF_ERROR = 4,
          TBPF_PAUSED = 8);
  TBATF = (TBATF_USEMDITHUMBNAIL = 1,
           TBATF_USEMDILIVEPREVIEW = 2);

  ITaskbarList = interface(IUnknown)
    ['{56FDF342-FD6D-11d0-958A-006097C9A090}']
    function HrInit: HResult; stdcall;
    function AddTab(hWndOwner: HWND): HRESULT; stdcall;
    function DeleteTab(hWndOwner: HWND): HRESULT; stdcall;
    function ActivateTab(hWndOwner: HWND): HRESULT; stdcall;
    function SetActiveAlt(hWndOwner: HWND): HRESULT; stdcall;
  end; { ITaskbarList }

  ITaskbarList2 = interface(ITaskbarList)
    ['{602D4995-B13A-429b-A66E-1935E44F4317}']
    function MarkFullscreenWindow(wnd : HWND; fFullscreen : bool) : HResult; stdcall;
  end;

  ITaskbarList3 = interface (ITaskbarList2)
  ['{ea1afb91-9e28-4b86-90e9-9e9f8a5eefaf}']
    function SetProgressValue (hWnd: HWND; ullCompleted: int64; ullTotal: int64): HRESULT; stdcall;
    function SetProgressState (hWnd: HWND; tbpFlags: TBPF): HRESULT; stdcall;
    function RegisterTab (hwndTab: HWND; hwndMDI: HWND): HRESULT; stdcall;
    function UnregisterTab (hwndTab: HWND): HRESULT; stdcall;
    function SetTabOrder (hwndTab: HWND; hwndInsertBefore: HWND): HRESULT; stdcall;
    function SetTabActive (hwndTab: HWND; hwndMDI: HWND; tbatFlags: TBATF): HRESULT; stdcall;
    function ThumbBarAddButtons (hWnd: HWND; cButtons: integer; pButtons: pointer): HRESULT; stdcall;
    function ThumbBarUpdateButtons (hWnd: HWND; cButtons: cardinal; pButtons: pointer): HRESULT; stdcall;
    function ThumbBarSetImageList (hWnd: HWND; himl: pointer): HRESULT; stdcall;
    function SetOverlayIcon (hWnd: HWND; hIcon: HICON; pszDescription: PWideChar): HRESULT; stdcall;
    function SetThumbnailTooltip (hWnd: HWND; pszTip: PWideChar): HRESULT; stdcall;
    function SetThumbnailClip (hWnd: HWND; prcClip: PRect): HRESULT; stdcall;
  end;

function CreateTaskBarInstance : ITaskbarList3;

implementation

function CreateTaskBarInstance : ITaskbarList3;
begin
  if CoCreateInstance(CLSID_TaskbarList, nil, CLSCTX_INPROC_SERVER or CLSCTX_LOCAL_SERVER, IID_ITaskbarList3, Result) = S_OK then
    if Result.HrInit <> S_OK then
    begin
      Result._Release;
      Result := nil;
    end else
      Exit;

  Result := nil;
end;

end.
 