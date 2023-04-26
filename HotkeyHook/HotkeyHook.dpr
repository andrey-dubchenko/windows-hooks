library HotkeyHook;

uses
 Windows,
 Messages,
 SysUtils;

//==============================================================================
type
 THookRec = record
  AppWindow1:HWND;
  AppWindow2:HWND;
  SysHook:HHOOK;
 end;
 PHookRec = ^THookRec;
var
 HookRec            :PHookRec = nil;
//==============================================================================

{$R *.res}
//==============================================================================
// Check target bit status
//==============================================================================
function IsBitSet(Value:cardinal; BitNum:byte):boolean;
begin
 result := ((Value shr BitNum) and 1) = 1;
end;
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
  HC_ACTION:
   begin
    if (wParam = VK_F11) and (IsBitSet(lParam, 31)) then
     SetForegroundWindow(HookRec^.AppWindow1);
    if (wParam = VK_F12) and (IsBitSet(lParam, 31)) then
     SetForegroundWindow(HookRec^.AppWindow2);
   end;
 end;
 result := 0;
end;
//==============================================================================
// Install Hook
//==============================================================================
function SetHook(Handle1, Handle2:HWND):boolean; stdcall;
begin
 if (Handle1 > 0) and (Handle2 > 0) then
  begin
   HookRec^.AppWindow1 := Handle1;
   HookRec^.AppWindow2 := Handle2;
   HookRec^.SysHook := SetWindowsHookEx(WH_KEYBOARD, @SysMsgProc, HInstance, 0);
  end;
 result := (HookRec^.SysHook <> 0);
end;
//==============================================================================
// Uninstall Hook
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
    hMapObject := CreateFileMapping(INVALID_HANDLE_VALUE, nil, PAGE_READWRITE, 0, SizeOf(THookRec), 'hotkeyHook');
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

