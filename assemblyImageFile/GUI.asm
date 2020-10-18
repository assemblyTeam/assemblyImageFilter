.386
.Model Flat, StdCall
Option Casemap :None

;==================== INCLUDE =======================
INCLUDE		header.inc
INCLUDE		images.inc

;==================== 找个词呗哥哥们 =======================
	printf				PROTO C :ptr sbyte, :VARARG

	WinMain				PROTO :DWORD, :DWORD, :DWORD, :DWORD
	WndProc				PROTO :DWORD, :DWORD, :DWORD, :DWORD
	UnicodeStr			PROTO :DWORD, :DWORD
	LoadImageFromFile	PROTO :PTR BYTE

;==================== DATA =======================
.data

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

;=================== CODE =========================
.code
START:
	INVOKE GetModuleHandle, NULL
	mov hInstance, eax
	INVOKE GdiplusStartup, ADDR gdiplusToken, ADDR gdiplusSInput, NULL
	INVOKE WinMain, hInstance, NULL, NULL, SW_SHOWDEFAULT
	INVOKE GdiplusShutdown, gdiplusToken
	INVOKE ExitProcess, 0

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
		WS_OVERLAPPEDWINDOW, 460, 20, 360, 700, NULL, NULL, hInst, NULL
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
	LOCAL hdc:HDC
	LOCAL hMemDC:HDC
	LOCAL bm:BITMAP

	.IF uMsg == WM_CREATE

		INVOKE  LoadImageFromFile, OFFSET bkImage

	.ELSEIF uMsg == WM_PAINT

		INVOKE  BeginPaint, hWnd, ADDR ps
		mov     hdc, eax

		INVOKE  CreateCompatibleDC, eax

		mov     hMemDC, eax
		INVOKE  SelectObject, eax, hBitmap

		INVOKE  GetObject, hBitmap, SIZEOF(BITMAP), ADDR bm
		lea     edx, bm
	
		xor     eax, eax

		INVOKE  BitBlt, hdc, eax, eax,
				BITMAP.bmWidth[edx],
				BITMAP.bmHeight[edx],
				hMemDC, eax, eax, SRCCOPY
			
		INVOKE  DeleteDC, hMemDC
		INVOKE  EndPaint, hWnd, ADDR ps

	.ELSEIF uMsg == WM_DESTROY
	
		INVOKE  DeleteObject, hBitmap
		INVOKE  GdipDisposeImage, BmpImage
		INVOKE  PostQuitMessage, NULL
		
	.ELSE
	
		INVOKE  DefWindowProc, hWnd, uMsg, wParam, lParam		
		ret

	.ENDIF
	
	xor     eax,eax
	ret
WndProc	ENDP

;-----------------------------------------------------
LoadImageFromFile	PROC FileName:PTR BYTE
; 从文件中读取图片
; 转换成Bitmap并存入hBitmap
;-----------------------------------------------------
	mov     eax, OFFSET StartupInfo
	mov     GdiplusStartupInput.GdiplusVersion[eax], 1

	INVOKE  GdiplusStartup, ADDR token, ADDR StartupInfo, 0
	INVOKE  UnicodeStr, FileName, ADDR UnicodeFileName
								
	INVOKE  GdipCreateBitmapFromFile, ADDR UnicodeFileName, ADDR BmpImage
									
	INVOKE  GdipCreateHBITMAPFromBitmap, BmpImage, ADDR hBitmap, 0
	ret
LoadImageFromFile	ENDP

;-----------------------------------------------------
UnicodeStr	PROC USES esi ebx Source:DWORD, Dest:DWORD
; 用于将图片名称转换成Unicode字符串
;-----------------------------------------------------
	mov     ebx, 1
	mov     esi, Source
	mov     edx, Dest
	xor     eax, eax
	sub     eax, ebx
@@:
	add     eax, ebx
	movzx   ecx, BYTE PTR [esi + eax]
	mov     WORD PTR [edx + eax * 2], cx
	test    ecx, ecx
	jnz     @b
	ret
UnicodeStr	ENDP

END START