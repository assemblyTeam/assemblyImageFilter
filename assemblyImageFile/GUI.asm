.386
.Model Flat, StdCall
Option Casemap :None

;==================== INCLUDE =======================
INCLUDE		header.inc
INCLUDE		structure.inc
INCLUDE		images.inc
INCLUDE		dll.inc

;==================== 找个词呗哥哥们 =======================
	printf				PROTO C :ptr sbyte, :VARARG

	WinMain				PROTO :DWORD, :DWORD, :DWORD, :DWORD
	WndProc				PROTO :DWORD, :DWORD, :DWORD, :DWORD
	LoadImageFromFile	PROTO :PTR BYTE, :DWORD
	ChangeBtnStatus		PROTO :DWORD, :DWORD, :location, :DWORD, :DWORD

;==================== DATA =======================
;外部可引用的变量
PUBLIC StartupInfo
PUBLIC UnicodeFileName
PUBLIC token

.data

	interfaceID		DWORD 0	; 当前所处的界面，0是初始界面，1是打开图片，2是摄像机
	openStatus		DWORD 0	; 控制按钮状态
	cameraStatus	DWORD 0
	exitStatus		DWORD 0

	szClassName		BYTE "MASMPlus_Class",0
	WindowName		BYTE "IMAGE", 0

	;初始化gdi+对象
	gdiplusToken	DD ?
	gdiplusSInput	GdiplusStartupInput <1, NULL, FALSE, FALSE>

.data?
	hInstance           DD ?
	hBitmap             DD ?
	pNumbOfBytesRead    DD ?
	StartupInfo         GdiplusStartupInput <?>
	UnicodeFileName     DD 32 DUP(?)
	BmpImage            DD ?
	token               DD ?

	background			DD ?
	emptyBtn			DD ?
	openBtn				DD ?
	openHoverBtn		DD ?
	openClickBtn		DD ?
	cameraBtn			DD ?
	cameraHoverBtn		DD ?
	cameraClickBtn		DD ?
	exitBtn				DD ?
	exitHoverBtn		DD ?
	exitClickBtn		DD ?

	curLocation			location <?>

;=================== CODE =========================
.code
START:
	INVOKE	GetModuleHandle, NULL
	mov		hInstance, eax
	INVOKE	GdiplusStartup, ADDR gdiplusToken, ADDR gdiplusSInput, NULL
	INVOKE	WinMain, hInstance, NULL, NULL, SW_SHOWDEFAULT
	INVOKE	GdiplusShutdown, gdiplusToken
	INVOKE	ExitProcess, 0

WinMain PROC hInst:DWORD, hPrevInst:DWORD, CmdLine:DWORD, CmdShow:DWORD
	LOCAL wc   :WNDCLASSEX
	LOCAL msg  :MSG
	LOCAL hWnd :HWND
	
	mov wc.cbSize, SIZEOF WNDCLASSEX
	mov wc.style, CS_HREDRAW or CS_VREDRAW or CS_BYTEALIGNWINDOW
	mov wc.lpfnWndProc, OFFSET WndProc
	mov wc.cbClsExtra, NULL
	mov wc.cbWndExtra, NULL
	push hInst
	pop wc.hInstance
	mov wc.hbrBackground, COLOR_BTNFACE+1
	mov wc.lpszMenuName, NULL
	mov wc.lpszClassName, OFFSET szClassName
	INVOKE LoadIcon, hInst, 100
	mov wc.hIcon, eax
	INVOKE LoadCursor, NULL, IDC_ARROW
	mov wc.hCursor, eax
	mov wc.hIconSm, 0

	INVOKE RegisterClassEx, ADDR wc
	INVOKE CreateWindowEx, NULL, ADDR szClassName, ADDR WindowName, 
		WS_OVERLAPPEDWINDOW, 460, 20, 1024, 768, NULL, NULL, hInst, NULL
	mov hWnd, eax
	INVOKE ShowWindow, hWnd, SW_SHOWNORMAL
	INVOKE UpdateWindow, hWnd
	
StartLoop:
	INVOKE GetMessage, ADDR msg, NULL, 0, 0
	cmp eax, 0
	je ExitLoop
	INVOKE TranslateMessage, ADDR msg
	INVOKE DispatchMessage, ADDR msg
	jmp StartLoop
ExitLoop:
	INVOKE KillTimer, hWnd, 1
	
	mov eax, msg.wParam
	ret
WinMain ENDP

WndProc PROC hWnd:DWORD, uMsg:DWORD, wParam :DWORD, lParam :DWORD
	LOCAL ps:PAINTSTRUCT
  local stRect: RECT
	LOCAL hdc:HDC
	LOCAL hMemDC:HDC
	LOCAL bm:BITMAP
	LOCAL graphics:HANDLE
	local pbitmap:HBITMAP
	local nhb:DWORD

	.IF uMsg == WM_CREATE

		; 打开计时器
		INVOKE	SetTimer, hWnd, 1, 10, NULL
		
		; 加载DLL
		INVOKE	LoadLibrary, OFFSET OpenCVDLL
		mov		curDLL, eax

		; 加在文件中的图像
		INVOKE	LoadImageFromFile, OFFSET bkImage, ADDR background
		INVOKE	LoadImageFromFile, OFFSET btnImage, ADDR emptyBtn
		INVOKE	LoadImageFromFile, OFFSET openImage, ADDR openBtn
		INVOKE	LoadImageFromFile, OFFSET openHoverImage, ADDR openHoverBtn
		;INVOKE	LoadImageFromFile, OFFSET openClickImage, ADDR openClickBtn
		INVOKE	LoadImageFromFile, OFFSET cameraImage, ADDR cameraBtn
		INVOKE	LoadImageFromFile, OFFSET cameraHoverImage, ADDR cameraHoverBtn
		;INVOKE	LoadImageFromFile, OFFSET cameraClickImage, ADDR cameraClickBtn
		INVOKE	LoadImageFromFile, OFFSET exitImage, ADDR exitBtn
		INVOKE	LoadImageFromFile, OFFSET exitHoverImage, ADDR exitHoverBtn
		;INVOKE	LoadImageFromFile, OFFSET exitClickImage, ADDR exitClickBtn

	.ELSEIF uMsg == WM_PAINT

		INVOKE  BeginPaint, hWnd, ADDR ps
		mov     hdc, eax

		invoke  GetClientRect, hWnd, addr stRect 
		INVOKE  CreateCompatibleDC, hdc
		mov     hMemDC, eax
		invoke  CreateCompatibleBitmap, hdc, 1024, 768		; 创建临时位图pbitmap
		mov		pbitmap, eax
		INVOKE  SelectObject, hMemDC, pbitmap
		INVOKE  GdipCreateFromHDC, hMemDC, ADDR graphics	; 创建绘图对象graphics

		.IF interfaceID == 0

			; 绘制初始界面
			INVOKE	GdipDrawImagePointRectI, graphics, background, 0, 0, 0, 0, 1024, 768, 2
			
			.IF openStatus == 0
				INVOKE	GdipDrawImagePointRectI, graphics, openBtn, openLocation.x, openLocation.y, 0, 0, openLocation.w, openLocation.h, 2
			.ELSEIF openStatus == 1
				INVOKE	GdipDrawImagePointRectI, graphics, openHoverBtn, openLocation.x, openLocation.y, 0, 0, openLocation.w, openLocation.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, emptyBtn, openLocation.x, openLocation.y, 0, 0, openLocation.w, openLocation.h, 2
			.ENDIF

			.IF cameraStatus == 0
				INVOKE	GdipDrawImagePointRectI, graphics, cameraBtn, cameraLocation.x, cameraLocation.y, 0, 0, cameraLocation.w, cameraLocation.h, 2
			.ELSEIF cameraStatus == 1
				INVOKE	GdipDrawImagePointRectI, graphics, cameraHoverBtn, cameraLocation.x, cameraLocation.y, 0, 0, cameraLocation.w, cameraLocation.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, emptyBtn, cameraLocation.x, cameraLocation.y, 0, 0, cameraLocation.w, cameraLocation.h, 2
			.ENDIF

			.IF exitStatus == 0
				INVOKE	GdipDrawImagePointRectI, graphics, exitBtn, exitLocation.x, exitLocation.y, 0, 0, exitLocation.w, exitLocation.h, 2
			.ELSEIF exitStatus == 1
				INVOKE	GdipDrawImagePointRectI, graphics, exitHoverBtn, exitLocation.x, exitLocation.y, 0, 0, exitLocation.w, exitLocation.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, emptyBtn, exitLocation.x, exitLocation.y, 0, 0, exitLocation.w, exitLocation.h, 2
			.ENDIF

		.ENDIF

		INVOKE  BitBlt, hdc, 0, 0, 1024, 768, hMemDC, 0, 0, SRCCOPY		; 绘图
			
		; 释放内存
		INVOKE	GdipDeleteGraphics, graphics
		INVOKE	DeleteObject, pbitmap
		INVOKE  DeleteDC, hMemDC
		INVOKE  EndPaint, hWnd, ADDR ps

	.ELSEIF uMsg == WM_MOUSEMOVE

		.IF interfaceID == 0

			; 获取当前鼠标坐标
			mov eax, lParam
			and eax, 0000FFFFh	; x坐标
			mov ebx, lParam
			shr ebx, 16			; y坐标
			
			; 改变按钮状态
			INVOKE	ChangeBtnStatus, eax, ebx, openLocation, offset openStatus, 1
			INVOKE	ChangeBtnStatus, eax, ebx, cameraLocation, offset cameraStatus, 1
			INVOKE	ChangeBtnStatus, eax, ebx, exitLocation, offset exitStatus, 1
			
		.ENDIF

	.ELSEIF uMsg == WM_LBUTTONDOWN
		
		.IF interfaceID == 0

			; 获取当前鼠标坐标
			mov eax, lParam
			and eax, 0000FFFFh	; x坐标
			mov ebx, lParam
			shr ebx, 16			; y坐标
			
			; 改变按钮状态
			INVOKE	ChangeBtnStatus, eax, ebx, openLocation, offset openStatus, 2
			INVOKE	ChangeBtnStatus, eax, ebx, cameraLocation, offset cameraStatus, 2
			INVOKE	ChangeBtnStatus, eax, ebx, exitLocation, offset exitStatus, 2
			
			; 鼠标位于Camera
			mov eax, cameraStatus;
			.IF eax == 2					
				INVOKE	GetProcAddress, curDLL, OFFSET cameraFunction
				mov		curFunc, eax	; 加载摄像头函数
				call	curFunc			; 调用摄像头函数
			.ENDIF

		.ENDIF
	; 根据定时器定时更新界面
	.ELSEIF uMsg == WM_TIMER
		; 获得当前窗口的rectangle
		invoke GetClientRect, hWnd, addr stRect
		; 指定重绘区域
		invoke InvalidateRect, hWnd, addr stRect, 0
		; 发送绘制信息
		invoke SendMessage, hWnd, WM_PAINT, NULL, NULL

	.ELSEIF uMsg == WM_DESTROY

		INVOKE  PostQuitMessage, NULL
		
	.ELSE
	
		INVOKE  DefWindowProc, hWnd, uMsg, wParam, lParam		
		ret

	.ENDIF
	
	xor  eax, eax
	ret
WndProc	ENDP

;-----------------------------------------------------
ChangeBtnStatus	PROC USES eax ebx ecx edx esi 
				x:DWORD, y:DWORD, btn_location:location, btn_status_addr:DWORD, new_status:DWORD
; 改变按钮状态
;-----------------------------------------------------
	mov esi, btn_status_addr
	mov DWORD PTR [esi], 0
	mov eax, x
	mov ebx, y
	.IF eax > btn_location.x
		mov ecx, btn_location.x
		add ecx, btn_location.w
		.IF eax < ecx
			.IF ebx > btn_location.y
				mov ecx, btn_location.y
				add ecx, btn_location.h
				.IF ebx < ecx
					mov esi, btn_status_addr
					mov edx, new_status
					mov [esi], edx
				.ENDIF
			.ENDIF
		.ENDIF
	.ENDIF
	ret
ChangeBtnStatus	ENDP

END START