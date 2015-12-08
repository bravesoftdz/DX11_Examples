program tutorial1;

{ DirectX 11 - Tutorial #1
      - The motivation of this tutorial is do demonstrate some very basic
        workflow of Direct3D 11, and how to start a very basic framework,
        since there are not much resources on the subject for FreePascal/Delphi
        and it can be rather hard to get started.

      - The rendering is done by an external class - TDXRenderer, which
        is also responsible for managing the DirectX resources.

  This examples demonstrates the following:
      - Create a window with Win32 API
      - Create Direct3D 11 device, device context and swapchain (unit: renderer.pas)
      - Create depth/stencil buffer
      - Create render target view from swapchain's backbuffer
      - Create viewport object and set to device context
      - Implement TDXRenderer.Clear() to clear backbuffer and depth buffer
          of the render target
      - Implement TDXRenderer.Present() method which presents the backbuffer
          to the screen (swapchain).

  TODO:
      - Nothing so far
}

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF}

uses
  Windows, Messages, SysUtils, Renderer;

const
  APP_NAME = 'Direct3D 11 - Tutorial #1';
  APP_SCREEN_WIDTH       = 800;
  APP_SCREEN_HEIGHT      = 600;

var
  app_hinstance,
  app_hwnd: HWND;

  screen_width,
  screen_height: Integer;

  renderer: TDXRenderer;

Function OnKeyDown(vkey: DWORD): LRESULT;
Begin
  If vkey = VK_ESCAPE then Begin
    //Post WM_QUIT message
    PostMessage(app_hwnd, WM_QUIT, 0, 0);
  End;

  Result := 0;
End;

Function WndProc(window_handle:HWND; umessage:UINT; w_param:WPARAM; l_param:LPARAM): LRESULT; stdcall;
Begin
  case umessage of
   //Check if window is destroyed
   WM_DESTROY: Begin
     PostQuitMessage(0);
     Exit(0);
   End;

   //Check if window is being closed
   WM_CLOSE: Begin
     PostQuitMessage(0);
     Exit(0);
   end;

   //Handle key down
   WM_KEYDOWN: Begin
     Result := OnKeyDown(w_param);
     Exit;
   End

   else Begin
     Result := DefWindowProc(window_handle, umessage, w_param, l_param);
     Exit;
   end;
  end;

  Result := E_FAIL;
End;

Function InitializeWindow: HRESULT;
var
   wnd_class: TWNDClassEx;
   pos_x, pos_y: Integer;
Begin
  //Get the instance of this application
  app_hinstance := GetModuleHandle(nil);

  //Setup the windows class with default settings.
  With wnd_class do Begin
   style         := CS_HREDRAW or CS_VREDRAW or CS_OWNDC;
   lpfnWndProc   := @WndProc;
   cbClsExtra    := 0;
   cbWndExtra    := 0;
   hInstance     := app_hinstance;
   hIcon         := LoadIcon(0, IDI_WINLOGO);
   hIconSm       := wnd_class.hIcon;
   hCursor       := LoadCursor(0, IDC_ARROW);
   hbrBackground := GetStockObject(BLACK_BRUSH);
   lpszMenuName  := nil;
   lpszClassName := APP_NAME;
   cbSize        := sizeof(WNDCLASSEX);
  end;

  //Register window class
  RegisterClassEx(wnd_class);

  //Decide window resolution
  screen_width  := APP_SCREEN_WIDTH;
  screen_height := APP_SCREEN_HEIGHT;

  //Place window on center of the screen
  pos_x := (GetSystemMetrics(SM_CXSCREEN) - screen_width) div 2;
  pos_y := (GetSystemMetrics(SM_CYSCREEN) - screen_height) div 2;

  //Create window
  app_hwnd := CreateWindowEx(
      WS_EX_APPWINDOW,
      APP_NAME,
      APP_NAME,
      WS_CLIPSIBLINGS or WS_CLIPCHILDREN or WS_POPUP or WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU,
      pos_x,
      pos_y,
      screen_width,
      screen_height,
      0,
      0,
      app_hinstance,
      nil
  );

  //Show and set focus
  ShowWindow(app_hwnd, SW_SHOW);
  SetForegroundWindow(app_hwnd);
  SetFocus(app_hwnd);

  Result := S_OK;
End;

Function UninitializeWindow: HRESULT;
Begin
  //Destroy window and unregister class
  DestroyWindow(app_hwnd);
  UnregisterClass(APP_NAME, app_hinstance);

  Result := S_OK;
End;

Procedure AppLoop;
var
   msg: TMSG;
Begin
  //Initialize message record
  {$HINTS off}
  FillChar(msg, SizeOf(msg), 0);
  {$HINTS on}

  While true do Begin
    //Handle message
    if PeekMessage(msg, 0, 0, 0, PM_REMOVE) then Begin
      TranslateMessage(msg);
      DispatchMessage(msg);
    end;

    //Terminate loop if we have received WM_QUIT
    if msg.message = WM_QUIT then
      Break;

    //Draw here
    renderer.Clear(D3DColor4f(0.0, 0.15, 0.5, 1));
    renderer.Render;
    renderer.Present;
  end;
End;

begin
  //Initialize window and acquire hWND
  InitializeWindow;

  //Create our renderer class, which will initialize Direct3D 11
  renderer := TDXRenderer.Create(app_hwnd, screen_width, screen_height);

  //Enter message handling loop
  AppLoop;

  //Destroy our renderer class (and thus uninitialize Direct3D 11)
  renderer.Free;

  //Destroy window
  UninitializeWindow;
end.

