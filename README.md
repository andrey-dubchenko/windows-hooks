# windows-hooks

FocusHook

Recieves HWND of last activated windows

Usage
 SetHook(hWnd: HWND) => install hook that sends WM_USER + 1 message to target HWND. wParam of this message contains HWND of activated window

HotkeyHook

Hook to set system wide hotkeys. This project was created to switch active window between two applications (uses F11 & F12 keys)

Usage 
 SetHook(Handle1, Handle2: HWND); => install hook that switches beetween two applications(F11 & F12)

 