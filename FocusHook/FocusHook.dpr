library FocusHook;

uses
 Windows,
 Messages,
 SysUtils;

//==============================================================================
const
 WM_KBATTACHED      = WM_USER + 1;
//==============================================================================
type
 THookRec = record
  AppWindow:HWND;
  SysHook:HHOOK;
 end;
 PHookRec = ^THookRec;
var
 HookRec            :PHookRec = nil;
//==============================================================================

{$R *.res}
//==============================================================================
// Hook Proc
//==============================================================================
function SysMsgProc(code:integer; wParam:dword; lParam:longint):longint; stdcall;
begin
 if code < 0 then
  begin
   result := CallNextHookEx(HookRec^.SysHook, Code, wParam, lParam);
   Exit;
  end;
 case code of
  HCBT_ACTIVATE:
   begin
    if (wParam > 0) and (wParam <> HookRec^.AppWindow) then
     PostMessage(HookRec^.AppWindow, WM_KBATTACHED, wParam, 0);
   end;
 end;
 result := 0;
end;
//==============================================================================
// Install Hook
//==============================================================================
function SetHook(Handle:HWND):boolean; stdcall;
begin
 if Handle > 0 then
  begin
   HookRec^.AppWindow := Handle;
   HookRec^.SysHook := SetWindowsHookEx(WH_CBT, @SysMsgProc, HInstance, 0);
  end;
 result := (HookRec^.SysHook <> 0);
end;
//==============================================================================
// Unistall Hook
//==============================================================================
function UnsetHook:boolean; stdcall;
begin
 UnhookWindowsHookEx(HookRec^.SysHook);
 HookRec^.SysHook := 0;
 result := true;
end;
//==============================================================================
// DLL Entry Point
//==============================================================================
{$J+}
procedure EntryPointProc(Reason:integer);
const
 hMapObject         :THandle = 0;
begin
 case reason of
  DLL_PROCESS_ATTACH:
   begin
    hMapObject := CreateFileMapping(INVALID_HANDLE_VALUE, nil, PAGE_READWRITE, 0, SizeOf(THookRec), 'focusHook');
    HookRec := MapViewOfFile(hMapObject, FILE_MAP_ALL_ACCESS, 0, 0, SizeOf(THookRec));
   end;
  DLL_PROCESS_DETACH:
   begin
    UnMapViewOfFile(HookRec);
    CloseHandle(hMapObject);
   end;
  DLL_THREAD_ATTACH,
   DLL_THREAD_DETACH:;
 end;
end;
//==============================================================================
exports SetHook, UnsetHook;
//==============================================================================
begin
 DllProc := @EntryPointProc;
 EntryPointProc(DLL_PROCESS_ATTACH);
end.
//==============================================================================

