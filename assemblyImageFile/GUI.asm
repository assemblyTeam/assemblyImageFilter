.386
.Model Flat, StdCall
Option Casemap :None

;==================== INCLUDE =======================
INCLUDE		header.inc
INCLUDE		structure.inc
INCLUDE		images.inc
INCLUDE		dll.inc

;==================== FUNCTION =======================
	printf					PROTO C :ptr sbyte, :VARARG

	cameraThread			PROTO

	WinMain					PROTO :DWORD, :DWORD, :DWORD, :DWORD
	WndProc					PROTO :DWORD, :DWORD, :DWORD, :DWORD
	LoadImageFromFile		PROTO :PTR BYTE, :DWORD
	ChangeBtnStatus			PROTO :DWORD, :DWORD, :location, :DWORD, :DWORD
	GetFileNameFromDialog	PROTO :DWORD, :DWORD, :DWORD, :DWORD
	SaveImg		PROTO 

;==================== DATA =======================
;外部�?引用的变�?
PUBLIC	StartupInfo
PUBLIC	UnicodeFileName
PUBLIC	token
PUBLIC	ofn

.data

	interfaceID		DWORD 0	; 当前扢�处的界面�?0�?初�?�界�?�?1�?打开图片�?2�?摄像�?
	; 控制按钮状��?
	openStatus		DWORD 0	
	cameraStatus	DWORD 0
	backStatus		DWORD 0
	saveStatus		DWORD 0
	exitStatus		DWORD 0
	sumiaoStatus	DWORD 0

	szClassName		BYTE "MASMPlus_Class",0
	WindowName		BYTE "IMAGE", 0

	tmpFileName	BYTE "img_tmp.png", 0 	; 临时文件�?�?
	isFiltered	DWORD 0								; �?否添加过滤镜

	;初�?�化gdi+对象
	gdiplusToken	DD ?
	gdiplusSInput	GdiplusStartupInput <1, NULL, FALSE, FALSE>

.data?
	hInstance           DD ?
	hBitmap             DD ?
	hEvent				DD ?
	hThread				DD ?
	pNumbOfBytesRead    DD ?
	StartupInfo         GdiplusStartupInput <?>
	UnicodeFileName     DD 256 DUP(0)
	BmpImage            DD ?
	token               DD ?

	background			DD ?
	szImage				DD ?
	tmpImage				DD ?
	frame				DD ?
	emptyBtn			DD ?
	openBtn				DD ?
	openHoverBtn		DD ?
	openClickBtn		DD ?
	cameraBtn			DD ?
	cameraHoverBtn		DD ?
	cameraClickBtn		DD ?
	backBtn				DD ?
	backHoverBtn		DD ?
	saveBtn				DD ?
	saveHoverBtn	DD ?
	exitBtn				DD ?
	exitHoverBtn		DD ?
	exitClickBtn		DD ?
	sumiaoBtn	DD ?
	sumiaoHoverBtn	DD ?

	curLocation			location <?>

	ofn					OPENFILENAME <0>
	save_ofn		OPENFILENAME <0>
	szFileName			BYTE 256 DUP(0)
	testMsg				BYTE '这是测试信息', 0
	testTitle			BYTE '这是测试�?', 0
	szFilterString		DB '图片文件', 0, '*.png;*.jpg', 0, 0	; 文件过滤
	szInitialDir		DB './', 0 ; 初�?�目�?
	szTitle				DB '请��择图片', 0 ; 对话框标�?
	szMessageTitle		DB '你��择的文件是', 0
	saveFileName		BYTE 256 DUP(0)

	szWidth		DD ?
	szHeight	DD ?

	cameraThreadID		DD ?

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
		WS_OVERLAPPEDWINDOW, 300, 40, 1024, 768, NULL, NULL, hInst, NULL
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
	LOCAL stRect: RECT
	LOCAL hdc:HDC
	LOCAL hMemDC:HDC
	LOCAL bm:BITMAP
	LOCAL graphics:HANDLE
	LOCAL pbitmap:HBITMAP
	LOCAL nhb:DWORD

	.IF uMsg == WM_CREATE

		; 打开计时�?
		INVOKE	SetTimer, hWnd, 1, 10, NULL
		
		
		INVOKE	LoadLibrary, OFFSET OpenCVDLL
		mov		OpenCV, eax			; 加载DLL
		INVOKE	GetProcAddress, OpenCV, OFFSET cameraFunction
		mov		cameraFunc, eax		; 加载摄像头函�?
		INVOKE	GetProcAddress, OpenCV, OFFSET frameFunction
		mov		frameFunc, eax		; 加载捕捉帧函�?
		INVOKE	GetProcAddress, OpenCV, OFFSET releaseFunction
		mov		releaseFunc, eax
		INVOKE	GetProcAddress, OpenCV, OFFSET smFunction
		mov		smFunc, eax		; 加载素描滤镜函数
		INVOKE	GetProcAddress, OpenCV, OFFSET saveImageFunction
		mov		saveImageFunc, eax

		; 加载文件�?的图�?
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
		INVOKE	LoadImageFromFile, OFFSET backImage, ADDR backBtn
		INVOKE	LoadImageFromFile, OFFSET backHoverImage, ADDR backHoverBtn
		INVOKE	LoadImageFromFile, OFFSET openImage, ADDR saveBtn
		INVOKE	LoadImageFromFile, OFFSET openHoverImage, ADDR saveHoverBtn
		;INVOKE	LoadImageFromFile, OFFSET backClickImage, ADDR backClickBtn
		INVOKE   LoadImageFromFile, OFFSET sumiaoImage, ADDR sumiaoBtn
		INVOKE   LoadImageFromFile, OFFSET sumiaoHoverImage, ADDR sumiaoHoverBtn

		; 创建摄像头�?�象
		;INVOKE	CreateEvent, NULL, FALSE, FALSE, NULL
		;mov		hEvent, eax

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
		
			; 绘制初�?�界�?
			INVOKE	GdipDrawImagePointRectI, graphics, background, 0, 0, 0, 0, 1024, 768, 2
			
			.IF openStatus == 0
				INVOKE	GdipDrawImagePointRectI, graphics, openBtn, openLocation.x, openLocation.y, 0, 0, openLocation.w, openLocation.h, 2
			.ELSEIF openStatus == 1
				INVOKE	GdipDrawImagePointRectI, graphics, openHoverBtn, openLocation.x, openLocation.y, 0, 0, openLocation.w, openLocation.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, openBtn, openLocation.x, openLocation.y, 0, 0, openLocation.w, openLocation.h, 2
			.ENDIF

			.IF cameraStatus == 0
				INVOKE	GdipDrawImagePointRectI, graphics, cameraBtn, cameraLocation.x, cameraLocation.y, 0, 0, cameraLocation.w, cameraLocation.h, 2
			.ELSEIF cameraStatus == 1
				INVOKE	GdipDrawImagePointRectI, graphics, cameraHoverBtn, cameraLocation.x, cameraLocation.y, 0, 0, cameraLocation.w, cameraLocation.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, cameraBtn, cameraLocation.x, cameraLocation.y, 0, 0, cameraLocation.w, cameraLocation.h, 2
			.ENDIF

			.IF exitStatus == 0
				INVOKE	GdipDrawImagePointRectI, graphics, exitBtn, exitLocation.x, exitLocation.y, 0, 0, exitLocation.w, exitLocation.h, 2
			.ELSEIF exitStatus == 1
				INVOKE	GdipDrawImagePointRectI, graphics, exitHoverBtn, exitLocation.x, exitLocation.y, 0, 0, exitLocation.w, exitLocation.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, exitBtn, exitLocation.x, exitLocation.y, 0, 0, exitLocation.w, exitLocation.h, 2
			.ENDIF
		; 显示图片界面
		.ELSEIF interfaceID == 1
		
			; 棢�测当前是否加过滤�?
			.IF isFiltered == 0
				INVOKE	LoadImageFromFile, OFFSET szFileName, ADDR szImage
				INVOKE	GdipDrawImagePointRectI, graphics, szImage, 0, 0, 0, 0, 1024, 768, 2
			.ELSE
				INVOKE	LoadImageFromFile, OFFSET tmpFileName, ADDR tmpImage
				INVOKE	GdipDrawImagePointRectI, graphics, tmpImage, 0, 0, 0, 0, 1024, 768, 2
			.ENDIF

			;INVOKE	LoadImageFromFile, OFFSET szFileName, ADDR szImage
			;INVOKE	GdipGetImageWidth, szImage, OFFSET szWidth
			;INVOKE	GdipGetImageHeight, szImage, OFFSET szHeight
			;INVOKE	GdipDrawImagePointRectI, graphics, szImage, 0, 0, 0, 0, 1024, 768, 2

			; 绘制按钮
			.IF backStatus == 0
				INVOKE	GdipDrawImagePointRectI, graphics, backBtn, backLocation.x, backLocation.y, 0, 0, backLocation.w, backLocation.h, 2
			.ELSEIF backStatus == 1
				INVOKE	GdipDrawImagePointRectI, graphics, backHoverBtn, backLocation.x, backLocation.y, 0, 0, backLocation.w, backLocation.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, backBtn, backLocation.x, backLocation.y, 0, 0, backLocation.w, backLocation.h, 2
			.ENDIF
			.IF saveStatus == 0
				INVOKE	GdipDrawImagePointRectI, graphics, saveBtn, saveLocation.x, saveLocation.y, 0, 0, saveLocation.w, saveLocation.h, 2
			.ELSEIF saveStatus == 1
				INVOKE	GdipDrawImagePointRectI, graphics, saveHoverBtn, saveLocation.x, saveLocation.y, 0, 0, saveLocation.w, saveLocation.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, saveBtn, saveLocation.x, saveLocation.y, 0, 0, saveLocation.w, saveLocation.h, 2
			.ENDIF

			.IF sumiaoStatus == 0
				INVOKE	GdipDrawImagePointRectI, graphics, sumiaoBtn, sumiaoLocation.x, sumiaoLocation.y, 0, 0, sumiaoLocation.w, sumiaoLocation.h, 2
			.ELSEIF sumiaoStatus == 1
				INVOKE	GdipDrawImagePointRectI, graphics, sumiaoHoverBtn, sumiaoLocation.x, sumiaoLocation.y, 0, 0, sumiaoLocation.w, sumiaoLocation.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, sumiaoBtn, sumiaoLocation.x, sumiaoLocation.y, 0, 0, sumiaoLocation.w, sumiaoLocation.h, 2
			.ENDIF

		.ELSEIF interfaceID == 2
			
			; call frameFunc
			;INVOKE	LoadImageFromFile, OFFSET frameImage, ADDR frame
			;INVOKE	GdipDrawImagePointRectI, graphics, frame, 0, 0, 0, 0, 1024, 768, 2
			;INVOKE  ResumeThread, hThread
			;INVOKE	Sleep, 1000
			;INVOKE  SuspendThread, hThread

			; 绘制按钮
			.IF backStatus == 0
				INVOKE	GdipDrawImagePointRectI, graphics, backBtn, backLocation.x, backLocation.y, 0, 0, backLocation.w, backLocation.h, 2
			.ELSEIF backStatus == 1
				INVOKE	GdipDrawImagePointRectI, graphics, backHoverBtn, backLocation.x, backLocation.y, 0, 0, backLocation.w, backLocation.h, 2
			.ENDIF

		.ENDIF

		INVOKE  BitBlt, hdc, 0, 0, 1024, 768, hMemDC, 0, 0, SRCCOPY		; 绘图
			
		; 释放内存
		INVOKE	GdipDeleteGraphics, graphics
		INVOKE	DeleteObject, pbitmap
		INVOKE  DeleteDC, hMemDC
		INVOKE  EndPaint, hWnd, ADDR ps

	.ELSEIF uMsg == WM_MOUSEMOVE

		; 获取当前鼠标坐标
		mov eax, lParam
		and eax, 0000FFFFh	; x坐标
		mov ebx, lParam
		shr ebx, 16			; y坐标
		
		; 改变按钮状��?
		.IF interfaceID == 0

			INVOKE	ChangeBtnStatus, eax, ebx, openLocation, OFFSET openStatus, 1
			INVOKE	ChangeBtnStatus, eax, ebx, cameraLocation, OFFSET cameraStatus, 1
			INVOKE	ChangeBtnStatus, eax, ebx, exitLocation, OFFSET exitStatus, 1
			
		.ELSEIF interfaceID == 1
			
			INVOKE	ChangeBtnStatus, eax, ebx, backLocation, OFFSET backStatus, 1
			INVOKE	ChangeBtnStatus, eax, ebx, sumiaoLocation, OFFSET sumiaoStatus, 1
			INVOKE	ChangeBtnStatus, eax, ebx, saveLocation, OFFSET saveStatus, 1

		.ELSEIF interfaceID == 2

			INVOKE	ChangeBtnStatus, eax, ebx, backLocation, OFFSET backStatus, 1

		.ENDIF

	.ELSEIF uMsg == WM_LBUTTONDOWN
		
		; 获取当前鼠标坐标
		mov eax, lParam
		and eax, 0000FFFFh	; x坐标
		mov ebx, lParam
		shr ebx, 16			; y坐标

		.IF interfaceID == 0
			
			; 改变按钮状��?
			INVOKE	ChangeBtnStatus, eax, ebx, openLocation, offset openStatus, 2
			INVOKE	ChangeBtnStatus, eax, ebx, cameraLocation, offset cameraStatus, 2
			INVOKE	ChangeBtnStatus, eax, ebx, exitLocation, offset exitStatus, 2
			
			; 鼠标位于Open
			mov eax, openStatus
			.IF eax == 2

				; 打开文件选取窗口
				INVOKE	GetFileNameFromDialog, ADDR szFilterString, ADDR szInitialDir, ADDR szFileName, ADDR szTitle
				; 等于0说明没有打开文件
				.IF eax != 0
					; 切换界面状��?
					mov	edx, 1
					mov	interfaceID, edx
					; 更改按键初�?���?
					mov edx, 0
					mov backStatus, edx
				.ENDIF

			.ENDIF

			; 鼠标位于Camera
			mov eax, cameraStatus
			.IF eax == 2					

				; 切换界面状��?
				mov edx, 2
				mov interfaceID, edx
				; 创建打开摄像头的进程
				INVOKE  CreateThread, NULL, 0, OFFSET cameraThread, NULL, 0, OFFSET cameraThreadID
				;INVOKE  CreateThread, NULL, 0, OFFSET cameraFunc, NULL, 0, OFFSET cameraThreadID
				mov		hThread, eax	; 获取进程句柄
				;INVOKE  CloseHandle, eax

			.ENDIF

			; 鼠标位于Exit
			mov eax, exitStatus
			.IF eax == 2
				INVOKE	ExitProcess, 0
			.ENDIF

		.ELSEIF interfaceID == 1
			
			; 改变按钮状��?
			INVOKE	ChangeBtnStatus, eax, ebx, backLocation, OFFSET backStatus, 2
			INVOKE	ChangeBtnStatus, eax, ebx, sumiaoLocation, OFFSET sumiaoStatus, 2

			INVOKE	ChangeBtnStatus, eax, ebx, saveLocation, OFFSET saveStatus, 2
			; 鼠标位于back
			mov eax, backStatus
			.IF eax == 2
				
				; 切换界面状��?
				mov edx, 0
				mov interfaceID, edx

			.ENDIF
			mov eax, saveStatus
			.IF eax == 2
				; todo
				INVOKE SaveImg 
			.ENDIF

			; 鼠标位于sumiao
			mov eax, sumiaoStatus
			.IF eax == 2
				
				; 调用素描滤镜函数
				mov ebx, OFFSET tmpFileName
				mov edx, OFFSET szFileName
				push ebx
				push edx
				call smFunc
				pop eax
				pop eax
				; 切换状��?
				mov eax, 1
				mov isFiltered, eax

			.ENDIF

		.ELSEIF interfaceID == 2

			; 改变按钮状��?
			INVOKE	ChangeBtnStatus, eax, ebx, backLocation, OFFSET backStatus, 2
			
			; 鼠标位于back
			mov eax, backStatus
			.IF eax == 2
				; 切换界面状��?
				mov edx, 0
				mov interfaceID, edx
				; 杢�死摄像头线程
				INVOKE  TerminateThread, hThread, OFFSET cameraThreadID
				call	releaseFunc
				;INVOKE  GetExitCodeThread, hThread, ADDR cameraThreadID
				;INVOKE  SuspendThread, hThread
			.ENDIF

		.ENDIF

	; 根据定时器定时更新界�?
	.ELSEIF uMsg == WM_TIMER
		; 获得当前窗口的rectangle
		invoke GetClientRect, hWnd, addr stRect
		; 指定重绘区域
		invoke InvalidateRect, hWnd, addr stRect, 0
		; 发��绘制信�?
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

cameraThread	PROC
	push 0
	call cameraFunc
	pop eax
	mov eax, 233
	ret
cameraThread ENDP

;-----------------------------------------------------
ChangeBtnStatus	PROC USES eax ebx ecx edx esi x:DWORD, y:DWORD, btn_location:location, btn_status_addr:DWORD, new_status:DWORD
; 改变按钮状��?
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

;-----------------------------------------------------
SaveImg	PROC 
; 保存图片到指定路�?
;-----------------------------------------------------
	INVOKE	RtlZeroMemory, addr save_ofn, sizeof save_ofn
	mov save_ofn.lStructSize, sizeof save_ofn		;结构的大�?
	mov save_ofn.lpstrFilter, OFFSET szFilterString	;文件过滤�?
	mov save_ofn.lpstrInitialDir, OFFSET szInitialDir ; 初�?�目�?
	mov save_ofn.lpstrFile, OFFSET saveFileName	;文件名的存放位置
	mov save_ofn.nMaxFile, 256	;文件名的朢�大长�?
	mov	save_ofn.Flags, OFN_PATHMUSTEXIST
	INVOKE	GetSaveFileName, addr save_ofn
	.IF eax != 0			;若��择有文件，则显示出�?
		; todo opencv save img
		;INVOKE MessageBoxA, NULL, addr saveFileName, addr szTitle, NULL
		mov esi, OFFSET saveFileName
		push esi
		mov esi, OFFSET frameImage
		push esi
		CALL	saveImageFunc
		pop esi
		pop esi
	.ENDIF
	ret
SaveImg ENDP
END START