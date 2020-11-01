.386
.Model Flat, StdCall
Option Casemap :None

;==================== INCLUDE =======================
INCLUDE		header.inc
INCLUDE		structure.inc
INCLUDE		images.inc
INCLUDE		dll.inc

;==================== FUNCTION =======================
	rand					PROTO C
	printf					PROTO C :ptr sbyte, :VARARG

	RandStr					PROTO
	DeleteTmpImage			PROTO
	cameraThread			PROTO

	WinMain					PROTO :DWORD, :DWORD, :DWORD, :DWORD
	WndProc					PROTO :DWORD, :DWORD, :DWORD, :DWORD
	LoadImageFromFile		PROTO :PTR BYTE, :DWORD
	ChangeBtnStatus			PROTO :DWORD, :DWORD, :location, :DWORD, :DWORD
	GetFileNameFromDialog	PROTO :DWORD, :DWORD, :DWORD, :DWORD
	SaveImg		PROTO

;==================== DATA =======================
;外部可引用的变量
PUBLIC	StartupInfo
PUBLIC	UnicodeFileName
PUBLIC	token
PUBLIC	ofn

.data

	interfaceID				DWORD 0	; 当前所处的界面，0是初始界面，1是打开图片，2是摄像机
	; 控制按钮状态
	openStatus				DWORD 0	
	cameraStatus			DWORD 0
	exitStatus					DWORD 0
	backStatus				DWORD 0
	saveStatus				DWORD 0

	yuantu1Status			DWORD 0
	yuantu2Status			DWORD 0
	sumiao1Status			DWORD 0
	sumiao2Status			DWORD 0
	fudiao1Status			DWORD 0
	fudiao2Status			DWORD 0
	maoboli1Status		DWORD 0
	maoboli2Status		DWORD 0
	huaijiu1Status			DWORD 0
	huaijiu2Status			DWORD 0
	huidu1Status			DWORD 0
	huidu2Status			DWORD 0
	hedu1Status				DWORD 0
	hedu2Status				DWORD 0
	danya1Status			DWORD 0
	danya2Status			DWORD 0
	gete1Status				DWORD 0
	gete2Status				DWORD 0
	menghuan1Status	DWORD 0
	menghuan2Status	DWORD 0
	yuhua1Status			DWORD 0
	yuhua2Status			DWORD 0
	mopi1Status				DWORD 0
	mopi2Status				DWORD 0

	szClassName		BYTE "MASMPlus_Class",0
	WindowName		BYTE "IMAGE", 0

	tmpFileName		BYTE 256 DUP(0) 	; 临时文件
	isFiltered		DWORD 0				; 是否添加过滤镜
	cameraFilterType		DWORD 0

	;初始化gdi+对象
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

	background0				DD ?
	background1				DD ?
	background2				DD ?
	szImage						DD ?
	tmpImage					DD ?
	frame							DD ?

	openBtn						DD ?
	openHoverBtn				DD ?
	cameraBtn					DD ?
	cameraHoverBtn			DD ?
	exitBtn							DD ?
	exitHoverBtn				DD ?
	backBtn						DD ?
	backHoverBtn				DD ?
	saveBtn						DD ?
	saveHoverBtn				DD ?

	yuantu1Btn					DD ?
	yuantu1HoverBtn			DD ?
	yuantu2Btn					DD ?
	yuantu2HoverBtn			DD ?
	sumiao1Btn					DD ?
	sumiao1HoverBtn			DD ?
	sumiao2Btn					DD ?
	sumiao2HoverBtn			DD ?
	fudiao1Btn					DD ?
	fudiao1HoverBtn			DD ?
	fudiao2Btn					DD ?
	fudiao2HoverBtn			DD ?
	maoboli1Btn				DD ?
	maoboli1HoverBtn		DD ?
	maoboli2Btn				DD ?
	maoboli2HoverBtn		DD ?
	huaijiu1Btn					DD ?
	huaijiu1HoverBtn			DD ?
	huaijiu2Btn					DD ?
	huaijiu2HoverBtn			DD ?
	huidu1Btn					DD ?
	huidu1HoverBtn			DD ?
	huidu2Btn					DD ?
	huidu2HoverBtn			DD ?
	hedu1Btn						DD ?
	hedu1HoverBtn			DD ?
	hedu2Btn						DD ?
	hedu2HoverBtn			DD ?
	danya1Btn					DD ?
	danya1HoverBtn			DD ?
	danya2Btn					DD ?
	danya2HoverBtn			DD ?
	gete1Btn						DD ?
	gete1HoverBtn				DD ?
	gete2Btn						DD ?
	gete2HoverBtn				DD ?
	menghuan1Btn				DD ?
	menghuan1HoverBtn	DD ?
	menghuan2Btn				DD ?
	menghuan2HoverBtn	DD ?
	yuhua1Btn					DD ?
	yuhua1HoverBtn			DD ?
	yuhua2Btn					DD ?
	yuhua2HoverBtn			DD ?
	mopi1Btn						DD ?
	mopi1HoverBtn			DD ?
	mopi2Btn						DD ?
	mopi2HoverBtn			DD ?

	curLocation			location <?>

	ofn					OPENFILENAME <0>
	save_ofn			OPENFILENAME <0>
	szFileName			BYTE 256 DUP(0)
	testMsg				BYTE '这是测试信息', 0
	testTitle			BYTE '这是测试', 0
	szFilterString		DB '图片文件', 0, '*.png;*.jpg', 0, 0	; 文件过滤
	szInitialDir		DB './', 0 ; 初始目录
	szTitle				DB '请选择择图片', 0 ; 对话框标题
	szMessageTitle		DB '你选择择的文件是', 0
	saveFileName		BYTE 256 DUP(0)
	currentWorkDir		BYTE 256 DUP(0)
	szWidth				DD ?
	szHeight			DD ?

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

		; 打开计时器
		INVOKE	SetTimer, hWnd, 1, 10, NULL
		
		INVOKE	LoadLibrary, OFFSET OpenCVDLL
		mov		OpenCV, eax				; 加载DLL
		INVOKE	GetProcAddress, OpenCV, OFFSET cameraFunction
		mov		cameraFunc, eax			; 加载摄像头函数
		INVOKE	GetProcAddress, OpenCV, OFFSET frameFunction
		mov		frameFunc, eax				; 加载捕捉帧函数
		INVOKE	GetProcAddress, OpenCV, OFFSET releaseFunction
		mov		releaseFunc, eax
		INVOKE	GetProcAddress, OpenCV, OFFSET sumiaoFunction
		mov		sumiaoFunc, eax			; 加载素描滤镜函数
		INVOKE	GetProcAddress, OpenCV, OFFSET fudiaoFunction
		mov		fudiaoFunc, eax			; 加载浮雕滤镜函数
		INVOKE	GetProcAddress, OpenCV, OFFSET maoboliFunction
		mov		maoboliFunc, eax			; 加载毛玻璃滤镜函数
		INVOKE	GetProcAddress, OpenCV, OFFSET huaijiuFunction
		mov		huaijiuFunc, eax			; 加载怀旧滤镜函数
		INVOKE	GetProcAddress, OpenCV, OFFSET huiduFunction
		mov		huiduFunc, eax				; 加载灰度滤镜函数
		INVOKE	GetProcAddress, OpenCV, OFFSET heduFunction
		mov		heduFunc, eax				; 加载褐度滤镜函数
		INVOKE	GetProcAddress, OpenCV, OFFSET danyaFunction
		mov		danyaFunc, eax				; 加载淡雅滤镜函数
		INVOKE	GetProcAddress, OpenCV, OFFSET geteFunction
		mov		geteFunc, eax				; 加载哥特滤镜函数
		INVOKE	GetProcAddress, OpenCV, OFFSET menghuanFunction
		mov		menghuanFunc, eax		; 加载梦幻滤镜函数
		INVOKE	GetProcAddress, OpenCV, OFFSET yuhuaFunction
		mov		yuhuaFunc, eax				; 加载羽化滤镜函数
		INVOKE	GetProcAddress, OpenCV, OFFSET mopiFunction
		mov		mopiFunc, eax				; 加载磨皮滤镜函数
		INVOKE	GetProcAddress, OpenCV, OFFSET saveImageFunction
		mov		saveImageFunc, eax

		; 加载文件中的图像
		INVOKE	LoadImageFromFile, OFFSET bkImage, ADDR background0
		INVOKE	LoadImageFromFile, OFFSET bgImgImage, ADDR background1
		INVOKE	LoadImageFromFile, OFFSET bgCameraImage, ADDR background2

		INVOKE	LoadImageFromFile, OFFSET openImage, ADDR openBtn
		INVOKE	LoadImageFromFile, OFFSET openHoverImage, ADDR openHoverBtn
		INVOKE	LoadImageFromFile, OFFSET cameraImage, ADDR cameraBtn
		INVOKE	LoadImageFromFile, OFFSET cameraHoverImage, ADDR cameraHoverBtn
		INVOKE	LoadImageFromFile, OFFSET exitImage, ADDR exitBtn
		INVOKE	LoadImageFromFile, OFFSET exitHoverImage, ADDR exitHoverBtn
		INVOKE	LoadImageFromFile, OFFSET backImage, ADDR backBtn
		INVOKE	LoadImageFromFile, OFFSET backHoverImage, ADDR backHoverBtn
		INVOKE	LoadImageFromFile, OFFSET saveImage, ADDR saveBtn
		INVOKE	LoadImageFromFile, OFFSET saveHoverImage, ADDR saveHoverBtn

		INVOKE   LoadImageFromFile, OFFSET yuantu1Image, ADDR yuantu1Btn
		INVOKE   LoadImageFromFile, OFFSET yuantu1HoverImage, ADDR yuantu1HoverBtn
		INVOKE   LoadImageFromFile, OFFSET yuantu2Image, ADDR yuantu2Btn
		INVOKE   LoadImageFromFile, OFFSET yuantu2HoverImage, ADDR yuantu2HoverBtn
		INVOKE   LoadImageFromFile, OFFSET sumiao1Image, ADDR sumiao1Btn
		INVOKE   LoadImageFromFile, OFFSET sumiao1HoverImage, ADDR sumiao1HoverBtn
		INVOKE   LoadImageFromFile, OFFSET sumiao2Image, ADDR sumiao2Btn
		INVOKE   LoadImageFromFile, OFFSET sumiao2HoverImage, ADDR sumiao2HoverBtn
		INVOKE   LoadImageFromFile, OFFSET fudiao1Image, ADDR fudiao1Btn
		INVOKE   LoadImageFromFile, OFFSET fudiao1HoverImage, ADDR fudiao1HoverBtn
		INVOKE   LoadImageFromFile, OFFSET fudiao2Image, ADDR fudiao2Btn
		INVOKE   LoadImageFromFile, OFFSET fudiao2HoverImage, ADDR fudiao2HoverBtn
		INVOKE   LoadImageFromFile, OFFSET maoboli1Image, ADDR maoboli1Btn
		INVOKE   LoadImageFromFile, OFFSET maoboli1HoverImage, ADDR maoboli1HoverBtn
		INVOKE   LoadImageFromFile, OFFSET maoboli2Image, ADDR maoboli2Btn
		INVOKE   LoadImageFromFile, OFFSET maoboli2HoverImage, ADDR maoboli2HoverBtn
		INVOKE   LoadImageFromFile, OFFSET huaijiu1Image, ADDR huaijiu1Btn
		INVOKE   LoadImageFromFile, OFFSET huaijiu1HoverImage, ADDR huaijiu1HoverBtn
		INVOKE   LoadImageFromFile, OFFSET huaijiu2Image, ADDR huaijiu2Btn
		INVOKE   LoadImageFromFile, OFFSET huaijiu2HoverImage, ADDR huaijiu2HoverBtn
		INVOKE   LoadImageFromFile, OFFSET huidu1Image, ADDR huidu1Btn
		INVOKE   LoadImageFromFile, OFFSET huidu1HoverImage, ADDR huidu1HoverBtn
		INVOKE   LoadImageFromFile, OFFSET huidu2Image, ADDR huidu2Btn
		INVOKE   LoadImageFromFile, OFFSET huidu2HoverImage, ADDR huidu2HoverBtn
		INVOKE   LoadImageFromFile, OFFSET hedu1Image, ADDR hedu1Btn
		INVOKE   LoadImageFromFile, OFFSET hedu1HoverImage, ADDR hedu1HoverBtn
		INVOKE   LoadImageFromFile, OFFSET hedu2Image, ADDR hedu2Btn
		INVOKE   LoadImageFromFile, OFFSET hedu2HoverImage, ADDR hedu2HoverBtn
		INVOKE   LoadImageFromFile, OFFSET danya1Image, ADDR danya1Btn
		INVOKE   LoadImageFromFile, OFFSET danya1HoverImage, ADDR danya1HoverBtn
		INVOKE   LoadImageFromFile, OFFSET danya2Image, ADDR danya2Btn
		INVOKE   LoadImageFromFile, OFFSET danya2HoverImage, ADDR danya2HoverBtn
		INVOKE   LoadImageFromFile, OFFSET gete1Image, ADDR gete1Btn
		INVOKE   LoadImageFromFile, OFFSET gete1HoverImage, ADDR gete1HoverBtn
		INVOKE   LoadImageFromFile, OFFSET gete2Image, ADDR gete2Btn
		INVOKE   LoadImageFromFile, OFFSET gete2HoverImage, ADDR gete2HoverBtn
		INVOKE   LoadImageFromFile, OFFSET menghuan1Image, ADDR menghuan1Btn
		INVOKE   LoadImageFromFile, OFFSET menghuan1HoverImage, ADDR menghuan1HoverBtn
		INVOKE   LoadImageFromFile, OFFSET menghuan2Image, ADDR menghuan2Btn
		INVOKE   LoadImageFromFile, OFFSET menghuan2HoverImage, ADDR menghuan2HoverBtn
		INVOKE   LoadImageFromFile, OFFSET yuhua1Image, ADDR yuhua1Btn
		INVOKE   LoadImageFromFile, OFFSET yuhua1HoverImage, ADDR yuhua1HoverBtn
		INVOKE   LoadImageFromFile, OFFSET yuhua2Image, ADDR yuhua2Btn
		INVOKE   LoadImageFromFile, OFFSET yuhua2HoverImage, ADDR yuhua2HoverBtn
		INVOKE   LoadImageFromFile, OFFSET mopi1Image, ADDR mopi1Btn
		INVOKE   LoadImageFromFile, OFFSET mopi1HoverImage, ADDR mopi1HoverBtn
		INVOKE   LoadImageFromFile, OFFSET mopi2Image, ADDR mopi2Btn
		INVOKE   LoadImageFromFile, OFFSET mopi2HoverImage, ADDR mopi2HoverBtn

		; 创建摄像头对象
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
		
			; 绘制背景图
			INVOKE	GdipDrawImagePointRectI, graphics, background0, 0, 0, 0, 0, 1024, 768, 2
			
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

			; 绘制背景图
			INVOKE	GdipDrawImagePointRectI, graphics, background1, 0, 0, 0, 0, 1024, 768, 2
		
			; 检测当前是否加过滤镜
			.IF isFiltered == 0
				INVOKE	LoadImageFromFile, OFFSET szFileName, ADDR szImage
				INVOKE	GdipDrawImagePointRectI, graphics, szImage, 0, 0, 0, 0, 1024, 768, 2
			.ELSE
				INVOKE	LoadImageFromFile, OFFSET tmpFileName, ADDR tmpImage
				INVOKE	GdipDrawImagePointRectI, graphics, tmpImage, 0, 0, 0, 0, 1024, 768, 2
			.ENDIF

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

			.IF yuantu1Status == 0
				INVOKE	GdipDrawImagePointRectI, graphics, yuantu1Btn, yuantu1Location.x, yuantu1Location.y, 0, 0, yuantu1Location.w, yuantu1Location.h, 2
			.ELSEIF yuantu1Status == 1
				INVOKE	GdipDrawImagePointRectI, graphics, yuantu1HoverBtn, yuantu1Location.x, yuantu1Location.y, 0, 0, yuantu1Location.w, yuantu1Location.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, yuantu1Btn, yuantu1Location.x, yuantu1Location.y, 0, 0, yuantu1Location.w, yuantu1Location.h, 2
			.ENDIF
			.IF sumiao1Status == 0
				INVOKE	GdipDrawImagePointRectI, graphics, sumiao1Btn, sumiao1Location.x, sumiao1Location.y, 0, 0, sumiao1Location.w, sumiao1Location.h, 2
			.ELSEIF sumiao1Status == 1
				INVOKE	GdipDrawImagePointRectI, graphics, sumiao1HoverBtn, sumiao1Location.x, sumiao1Location.y, 0, 0, sumiao1Location.w, sumiao1Location.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, sumiao1Btn, sumiao1Location.x, sumiao1Location.y, 0, 0, sumiao1Location.w, sumiao1Location.h, 2
			.ENDIF
			.IF fudiao1Status == 0
				INVOKE	GdipDrawImagePointRectI, graphics, fudiao1Btn, fudiao1Location.x, fudiao1Location.y, 0, 0, fudiao1Location.w, fudiao1Location.h, 2
			.ELSEIF fudiao1Status == 1
				INVOKE	GdipDrawImagePointRectI, graphics, fudiao1HoverBtn, fudiao1Location.x, fudiao1Location.y, 0, 0, fudiao1Location.w, fudiao1Location.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, fudiao1Btn, fudiao1Location.x, fudiao1Location.y, 0, 0, fudiao1Location.w, fudiao1Location.h, 2
			.ENDIF
			.IF maoboli1Status == 0
				INVOKE	GdipDrawImagePointRectI, graphics, maoboli1Btn, maoboli1Location.x, maoboli1Location.y, 0, 0, maoboli1Location.w, maoboli1Location.h, 2
			.ELSEIF maoboli1Status == 1
				INVOKE	GdipDrawImagePointRectI, graphics, maoboli1HoverBtn, maoboli1Location.x, maoboli1Location.y, 0, 0, maoboli1Location.w, maoboli1Location.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, maoboli1Btn, maoboli1Location.x, maoboli1Location.y, 0, 0, maoboli1Location.w, maoboli1Location.h, 2
			.ENDIF
			.IF huaijiu1Status == 0
				INVOKE	GdipDrawImagePointRectI, graphics, huaijiu1Btn, huaijiu1Location.x, huaijiu1Location.y, 0, 0, huaijiu1Location.w, huaijiu1Location.h, 2
			.ELSEIF huaijiu1Status == 1
				INVOKE	GdipDrawImagePointRectI, graphics, huaijiu1HoverBtn, huaijiu1Location.x, huaijiu1Location.y, 0, 0, huaijiu1Location.w, huaijiu1Location.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, huaijiu1Btn, huaijiu1Location.x, huaijiu1Location.y, 0, 0, huaijiu1Location.w, huaijiu1Location.h, 2
			.ENDIF
			.IF huidu1Status == 0
				INVOKE	GdipDrawImagePointRectI, graphics, huidu1Btn, huidu1Location.x, huidu1Location.y, 0, 0, huidu1Location.w, huidu1Location.h, 2
			.ELSEIF huidu1Status == 1
				INVOKE	GdipDrawImagePointRectI, graphics, huidu1HoverBtn, huidu1Location.x, huidu1Location.y, 0, 0, huidu1Location.w, huidu1Location.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, huidu1Btn, huidu1Location.x, huidu1Location.y, 0, 0, huidu1Location.w, huidu1Location.h, 2
			.ENDIF
			.IF hedu1Status == 0
				INVOKE	GdipDrawImagePointRectI, graphics, hedu1Btn, hedu1Location.x, hedu1Location.y, 0, 0, hedu1Location.w, hedu1Location.h, 2
			.ELSEIF hedu1Status == 1
				INVOKE	GdipDrawImagePointRectI, graphics, hedu1HoverBtn, hedu1Location.x, hedu1Location.y, 0, 0, hedu1Location.w, hedu1Location.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, hedu1Btn, hedu1Location.x, hedu1Location.y, 0, 0, hedu1Location.w, hedu1Location.h, 2
			.ENDIF
			.IF danya1Status == 0
				INVOKE	GdipDrawImagePointRectI, graphics, danya1Btn, danya1Location.x, danya1Location.y, 0, 0, danya1Location.w, danya1Location.h, 2
			.ELSEIF danya1Status == 1
				INVOKE	GdipDrawImagePointRectI, graphics, danya1HoverBtn, danya1Location.x, danya1Location.y, 0, 0, danya1Location.w, danya1Location.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, danya1Btn, danya1Location.x, danya1Location.y, 0, 0, danya1Location.w, danya1Location.h, 2
			.ENDIF
			.IF gete1Status == 0
				INVOKE	GdipDrawImagePointRectI, graphics, gete1Btn, gete1Location.x, gete1Location.y, 0, 0, gete1Location.w, gete1Location.h, 2
			.ELSEIF gete1Status == 1
				INVOKE	GdipDrawImagePointRectI, graphics, gete1HoverBtn, gete1Location.x, gete1Location.y, 0, 0, gete1Location.w, gete1Location.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, gete1Btn, gete1Location.x, gete1Location.y, 0, 0, gete1Location.w, gete1Location.h, 2
			.ENDIF
			.IF menghuan1Status == 0
				INVOKE	GdipDrawImagePointRectI, graphics, menghuan1Btn, menghuan1Location.x, menghuan1Location.y, 0, 0, menghuan1Location.w, menghuan1Location.h, 2
			.ELSEIF menghuan1Status == 1
				INVOKE	GdipDrawImagePointRectI, graphics, menghuan1HoverBtn, menghuan1Location.x, menghuan1Location.y, 0, 0, menghuan1Location.w, menghuan1Location.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, menghuan1Btn, menghuan1Location.x, menghuan1Location.y, 0, 0, menghuan1Location.w, menghuan1Location.h, 2
			.ENDIF
			.IF yuhua1Status == 0
				INVOKE	GdipDrawImagePointRectI, graphics, yuhua1Btn, yuhua1Location.x, yuhua1Location.y, 0, 0, yuhua1Location.w, yuhua1Location.h, 2
			.ELSEIF yuhua1Status == 1
				INVOKE	GdipDrawImagePointRectI, graphics, yuhua1HoverBtn, yuhua1Location.x, yuhua1Location.y, 0, 0, yuhua1Location.w, yuhua1Location.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, yuhua1Btn, yuhua1Location.x, yuhua1Location.y, 0, 0, yuhua1Location.w, yuhua1Location.h, 2
			.ENDIF
			.IF mopi1Status == 0
				INVOKE	GdipDrawImagePointRectI, graphics, mopi1Btn, mopi1Location.x, mopi1Location.y, 0, 0, mopi1Location.w, mopi1Location.h, 2
			.ELSEIF mopi1Status == 1
				INVOKE	GdipDrawImagePointRectI, graphics, mopi1HoverBtn, mopi1Location.x, mopi1Location.y, 0, 0, mopi1Location.w, mopi1Location.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, mopi1Btn, mopi1Location.x, mopi1Location.y, 0, 0, mopi1Location.w, mopi1Location.h, 2
			.ENDIF

		.ELSEIF interfaceID == 2

			; 绘制背景图
			INVOKE	GdipDrawImagePointRectI, graphics, background2, 0, 0, 0, 0, 1024, 768, 2

			; 绘制按钮
			.IF backStatus == 0
				INVOKE	GdipDrawImagePointRectI, graphics, backBtn, backLocation.x, backLocation.y, 0, 0, backLocation.w, backLocation.h, 2
			.ELSEIF backStatus == 1
				INVOKE	GdipDrawImagePointRectI, graphics, backHoverBtn, backLocation.x, backLocation.y, 0, 0, backLocation.w, backLocation.h, 2
			.ENDIF
			.IF saveStatus == 0
				INVOKE	GdipDrawImagePointRectI, graphics, saveBtn, saveLocation.x, saveLocation.y, 0, 0, saveLocation.w, saveLocation.h, 2
			.ELSEIF saveStatus == 1
				INVOKE	GdipDrawImagePointRectI, graphics, saveHoverBtn, saveLocation.x, saveLocation.y, 0, 0, saveLocation.w, saveLocation.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, saveBtn, saveLocation.x, saveLocation.y, 0, 0, saveLocation.w, saveLocation.h, 2
			.ENDIF

			.IF yuantu2Status == 0
				INVOKE	GdipDrawImagePointRectI, graphics, yuantu2Btn, yuantu2Location.x, yuantu2Location.y, 0, 0, yuantu2Location.w, yuantu2Location.h, 2
			.ELSEIF yuantu2Status == 1
				INVOKE	GdipDrawImagePointRectI, graphics, yuantu2HoverBtn, yuantu2Location.x, yuantu2Location.y, 0, 0, yuantu2Location.w, yuantu2Location.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, yuantu2Btn, yuantu2Location.x, yuantu2Location.y, 0, 0, yuantu2Location.w, yuantu2Location.h, 2
			.ENDIF
			.IF sumiao2Status == 0
				INVOKE	GdipDrawImagePointRectI, graphics, sumiao2Btn, sumiao2Location.x, sumiao2Location.y, 0, 0, sumiao2Location.w, sumiao2Location.h, 2
			.ELSEIF sumiao2Status == 1
				INVOKE	GdipDrawImagePointRectI, graphics, sumiao2HoverBtn, sumiao2Location.x, sumiao2Location.y, 0, 0, sumiao2Location.w, sumiao2Location.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, sumiao2Btn, sumiao2Location.x, sumiao2Location.y, 0, 0, sumiao2Location.w, sumiao2Location.h, 2
			.ENDIF
			.IF fudiao2Status == 0
				INVOKE	GdipDrawImagePointRectI, graphics, fudiao2Btn, fudiao2Location.x, fudiao2Location.y, 0, 0, fudiao2Location.w, fudiao2Location.h, 2
			.ELSEIF fudiao2Status == 1
				INVOKE	GdipDrawImagePointRectI, graphics, fudiao2HoverBtn, fudiao2Location.x, fudiao2Location.y, 0, 0, fudiao2Location.w, fudiao2Location.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, fudiao2Btn, fudiao2Location.x, fudiao2Location.y, 0, 0, fudiao2Location.w, fudiao2Location.h, 2
			.ENDIF
			.IF maoboli2Status == 0
				INVOKE	GdipDrawImagePointRectI, graphics, maoboli2Btn, maoboli2Location.x, maoboli2Location.y, 0, 0, maoboli2Location.w, maoboli2Location.h, 2
			.ELSEIF maoboli2Status == 1
				INVOKE	GdipDrawImagePointRectI, graphics, maoboli2HoverBtn, maoboli2Location.x, maoboli2Location.y, 0, 0, maoboli2Location.w, maoboli2Location.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, maoboli2Btn, maoboli2Location.x, maoboli2Location.y, 0, 0, maoboli2Location.w, maoboli2Location.h, 2
			.ENDIF
			.IF huaijiu2Status == 0
				INVOKE	GdipDrawImagePointRectI, graphics, huaijiu2Btn, huaijiu2Location.x, huaijiu2Location.y, 0, 0, huaijiu2Location.w, huaijiu2Location.h, 2
			.ELSEIF huaijiu2Status == 1
				INVOKE	GdipDrawImagePointRectI, graphics, huaijiu2HoverBtn, huaijiu2Location.x, huaijiu2Location.y, 0, 0, huaijiu2Location.w, huaijiu2Location.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, huaijiu2Btn, huaijiu2Location.x, huaijiu2Location.y, 0, 0, huaijiu2Location.w, huaijiu2Location.h, 2
			.ENDIF
			.IF huidu2Status == 0
				INVOKE	GdipDrawImagePointRectI, graphics, huidu2Btn, huidu2Location.x, huidu2Location.y, 0, 0, huidu2Location.w, huidu2Location.h, 2
			.ELSEIF huidu2Status == 1
				INVOKE	GdipDrawImagePointRectI, graphics, huidu2HoverBtn, huidu2Location.x, huidu2Location.y, 0, 0, huidu2Location.w, huidu2Location.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, huidu2Btn, huidu2Location.x, huidu2Location.y, 0, 0, huidu2Location.w, huidu2Location.h, 2
			.ENDIF
			.IF hedu2Status == 0
				INVOKE	GdipDrawImagePointRectI, graphics, hedu2Btn, hedu2Location.x, hedu2Location.y, 0, 0, hedu2Location.w, hedu2Location.h, 2
			.ELSEIF hedu2Status == 1
				INVOKE	GdipDrawImagePointRectI, graphics, hedu2HoverBtn, hedu2Location.x, hedu2Location.y, 0, 0, hedu2Location.w, hedu2Location.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, hedu2Btn, hedu2Location.x, hedu2Location.y, 0, 0, hedu2Location.w, hedu2Location.h, 2
			.ENDIF
			.IF danya2Status == 0
				INVOKE	GdipDrawImagePointRectI, graphics, danya2Btn, danya2Location.x, danya2Location.y, 0, 0, danya2Location.w, danya2Location.h, 2
			.ELSEIF danya2Status == 1
				INVOKE	GdipDrawImagePointRectI, graphics, danya2HoverBtn, danya2Location.x, danya2Location.y, 0, 0, danya2Location.w, danya2Location.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, danya2Btn, danya2Location.x, danya2Location.y, 0, 0, danya2Location.w, danya2Location.h, 2
			.ENDIF
			.IF gete2Status == 0
				INVOKE	GdipDrawImagePointRectI, graphics, gete2Btn, gete2Location.x, gete2Location.y, 0, 0, gete2Location.w, gete2Location.h, 2
			.ELSEIF gete2Status == 1
				INVOKE	GdipDrawImagePointRectI, graphics, gete2HoverBtn, gete2Location.x, gete2Location.y, 0, 0, gete2Location.w, gete2Location.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, gete2Btn, gete2Location.x, gete2Location.y, 0, 0, gete2Location.w, gete2Location.h, 2
			.ENDIF
			.IF menghuan2Status == 0
				INVOKE	GdipDrawImagePointRectI, graphics, menghuan2Btn, menghuan2Location.x, menghuan2Location.y, 0, 0, menghuan2Location.w, menghuan2Location.h, 2
			.ELSEIF menghuan2Status == 1
				INVOKE	GdipDrawImagePointRectI, graphics, menghuan2HoverBtn, menghuan2Location.x, menghuan2Location.y, 0, 0, menghuan2Location.w, menghuan2Location.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, menghuan2Btn, menghuan2Location.x, menghuan2Location.y, 0, 0, menghuan2Location.w, menghuan2Location.h, 2
			.ENDIF
			.IF yuhua2Status == 0
				INVOKE	GdipDrawImagePointRectI, graphics, yuhua2Btn, yuhua2Location.x, yuhua2Location.y, 0, 0, yuhua2Location.w, yuhua2Location.h, 2
			.ELSEIF yuhua2Status == 1
				INVOKE	GdipDrawImagePointRectI, graphics, yuhua2HoverBtn, yuhua2Location.x, yuhua2Location.y, 0, 0, yuhua2Location.w, yuhua2Location.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, yuhua2Btn, yuhua2Location.x, yuhua2Location.y, 0, 0, yuhua2Location.w, yuhua2Location.h, 2
			.ENDIF
			.IF mopi2Status == 0
				INVOKE	GdipDrawImagePointRectI, graphics, mopi2Btn, mopi2Location.x, mopi2Location.y, 0, 0, mopi2Location.w, mopi2Location.h, 2
			.ELSEIF mopi2Status == 1
				INVOKE	GdipDrawImagePointRectI, graphics, mopi2HoverBtn, mopi2Location.x, mopi2Location.y, 0, 0, mopi2Location.w, mopi2Location.h, 2
			.ELSE
				INVOKE	GdipDrawImagePointRectI, graphics, mopi2Btn, mopi2Location.x, mopi2Location.y, 0, 0, mopi2Location.w, mopi2Location.h, 2
			.ENDIF

		.ENDIF

		INVOKE  BitBlt, hdc, 0, 0, 1024, 768, hMemDC, 0, 0, SRCCOPY		; 绘图
			
		; 释放内存
		INVOKE	GdipDeleteGraphics, graphics
		INVOKE	GdipDisposeImage, tmpImage
		INVOKE	DeleteObject, pbitmap
		INVOKE	DeleteDC, hMemDC
		INVOKE	EndPaint, hWnd, ADDR ps

	.ELSEIF uMsg == WM_MOUSEMOVE

		; 获取当前鼠标坐标
		mov eax, lParam
		and eax, 0000FFFFh	; x坐标
		mov ebx, lParam
		shr ebx, 16			; y坐标
		
		; 改变按钮状态
		.IF interfaceID == 0

			INVOKE	ChangeBtnStatus, eax, ebx, openLocation, OFFSET openStatus, 1
			INVOKE	ChangeBtnStatus, eax, ebx, cameraLocation, OFFSET cameraStatus, 1
			INVOKE	ChangeBtnStatus, eax, ebx, exitLocation, OFFSET exitStatus, 1
			
		.ELSEIF interfaceID == 1
			
			INVOKE	ChangeBtnStatus, eax, ebx, backLocation, OFFSET backStatus, 1
			INVOKE	ChangeBtnStatus, eax, ebx, saveLocation, OFFSET saveStatus, 1

			INVOKE	ChangeBtnStatus, eax, ebx, yuantu1Location, OFFSET yuantu1Status, 1
			INVOKE	ChangeBtnStatus, eax, ebx, sumiao1Location, OFFSET sumiao1Status, 1
			INVOKE	ChangeBtnStatus, eax, ebx, fudiao1Location, OFFSET fudiao1Status, 1
			INVOKE	ChangeBtnStatus, eax, ebx, maoboli1Location, OFFSET maoboli1Status, 1
			INVOKE	ChangeBtnStatus, eax, ebx, huaijiu1Location, OFFSET huaijiu1Status, 1
			INVOKE	ChangeBtnStatus, eax, ebx, huidu1Location, OFFSET huidu1Status, 1
			INVOKE	ChangeBtnStatus, eax, ebx, hedu1Location, OFFSET hedu1Status, 1
			INVOKE	ChangeBtnStatus, eax, ebx, danya1Location, OFFSET danya1Status, 1
			INVOKE	ChangeBtnStatus, eax, ebx, gete1Location, OFFSET gete1Status, 1
			INVOKE	ChangeBtnStatus, eax, ebx, menghuan1Location, OFFSET menghuan1Status, 1
			INVOKE	ChangeBtnStatus, eax, ebx, yuhua1Location, OFFSET yuhua1Status, 1
			INVOKE	ChangeBtnStatus, eax, ebx, mopi1Location, OFFSET mopi1Status, 1

		.ELSEIF interfaceID == 2

			INVOKE	ChangeBtnStatus, eax, ebx, backLocation, OFFSET backStatus, 1
			INVOKE	ChangeBtnStatus, eax, ebx, saveLocation, OFFSET saveStatus, 1

			INVOKE	ChangeBtnStatus, eax, ebx, yuantu2Location, OFFSET yuantu2Status, 1
			INVOKE	ChangeBtnStatus, eax, ebx, sumiao2Location, OFFSET sumiao2Status, 1
			INVOKE	ChangeBtnStatus, eax, ebx, fudiao2Location, OFFSET fudiao2Status, 1
			INVOKE	ChangeBtnStatus, eax, ebx, maoboli2Location, OFFSET maoboli2Status, 1
			INVOKE	ChangeBtnStatus, eax, ebx, huaijiu2Location, OFFSET huaijiu2Status, 1
			INVOKE	ChangeBtnStatus, eax, ebx, huidu2Location, OFFSET huidu2Status, 1
			INVOKE	ChangeBtnStatus, eax, ebx, hedu2Location, OFFSET hedu2Status, 1
			INVOKE	ChangeBtnStatus, eax, ebx, danya2Location, OFFSET danya2Status, 1
			INVOKE	ChangeBtnStatus, eax, ebx, gete2Location, OFFSET gete2Status, 1
			INVOKE	ChangeBtnStatus, eax, ebx, menghuan2Location, OFFSET menghuan2Status, 1
			INVOKE	ChangeBtnStatus, eax, ebx, yuhua2Location, OFFSET yuhua2Status, 1
			INVOKE	ChangeBtnStatus, eax, ebx, mopi2Location, OFFSET mopi2Status, 1

		.ENDIF

	.ELSEIF uMsg == WM_LBUTTONDOWN
		
		; 获取当前鼠标坐标
		mov eax, lParam
		and eax, 0000FFFFh	; x坐标
		mov ebx, lParam
		shr ebx, 16			; y坐标

		.IF interfaceID == 0
			
			; 改变按钮状态
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
					; 切换界面状态
					mov	edx, 1
					mov	interfaceID, edx
					; 更改按键初始值
					mov edx, 0
					mov backStatus, edx
				.ENDIF

			.ENDIF

			; 鼠标位于Camera
			mov eax, cameraStatus
			.IF eax == 2					

				; 切换界面状态
				mov edx, 2
				mov interfaceID, edx

			.ENDIF

			; 鼠标位于Exit
			mov eax, exitStatus
			.IF eax == 2
				INVOKE	ExitProcess, 0
			.ENDIF

		.ELSEIF interfaceID == 1
			
			; 改变按钮状态
			INVOKE	ChangeBtnStatus, eax, ebx, backLocation, OFFSET backStatus, 2
			INVOKE	ChangeBtnStatus, eax, ebx, saveLocation, OFFSET saveStatus, 2

			INVOKE	ChangeBtnStatus, eax, ebx, yuantu1Location, OFFSET yuantu1Status, 2
			INVOKE	ChangeBtnStatus, eax, ebx, sumiao1Location, OFFSET sumiao1Status, 2
			INVOKE	ChangeBtnStatus, eax, ebx, fudiao1Location, OFFSET fudiao1Status, 2
			INVOKE	ChangeBtnStatus, eax, ebx, maoboli1Location, OFFSET maoboli1Status, 2
			INVOKE	ChangeBtnStatus, eax, ebx, huaijiu1Location, OFFSET huaijiu1Status, 2
			INVOKE	ChangeBtnStatus, eax, ebx, huidu1Location, OFFSET huidu1Status, 2
			INVOKE	ChangeBtnStatus, eax, ebx, hedu1Location, OFFSET hedu1Status, 2
			INVOKE	ChangeBtnStatus, eax, ebx, danya1Location, OFFSET danya1Status, 2
			INVOKE	ChangeBtnStatus, eax, ebx, gete1Location, OFFSET gete1Status, 2
			INVOKE	ChangeBtnStatus, eax, ebx, menghuan1Location, OFFSET menghuan1Status, 2
			INVOKE	ChangeBtnStatus, eax, ebx, yuhua1Location, OFFSET yuhua1Status, 2
			INVOKE	ChangeBtnStatus, eax, ebx, mopi1Location, OFFSET mopi1Status, 2

			; 鼠标位于back
			mov eax, backStatus
			.IF eax == 2
				
				; 清空缓存
				INVOKE	DeleteTmpImage
				; 切换界面状态
				mov edx, 0
				mov interfaceID, edx
				; 切换图片状态
				mov eax, 0
				mov isFiltered, eax

			.ENDIF

			; 鼠标位于save
			mov eax, saveStatus
			.IF eax == 2
				; todo
				INVOKE SaveImg
			.ENDIF

			; 鼠标位于yuantu
			mov eax, yuantu1Status
			.IF eax == 2
				
				; 切换状态
				mov eax, 0
				mov isFiltered, eax

			.ENDIF

			; 鼠标位于sumiao
			mov eax, sumiao1Status
			.IF eax == 2

				; 清空缓存
				INVOKE	DeleteTmpImage
				INVOKE	RandStr
				
				; 调用素描滤镜函数
				mov ebx, OFFSET tmpFileName
				mov edx, OFFSET szFileName
				push ebx
				push edx
				call sumiaoFunc
				pop eax
				pop eax
				; 切换状态
				mov eax, 1
				mov isFiltered, eax

			.ENDIF

			; 鼠标位于fudiao
			mov eax, fudiao1Status
			.IF eax == 2

				; 清空缓存
				INVOKE	DeleteTmpImage
				INVOKE	RandStr
				
				; 调用浮雕滤镜函数
				mov ebx, OFFSET tmpFileName
				mov edx, OFFSET szFileName
				push ebx
				push edx
				call fudiaoFunc
				pop eax
				pop eax
				; 切换状态
				mov eax, 1
				mov isFiltered, eax

			.ENDIF

			; 鼠标位于maoboli
			mov eax, maoboli1Status
			.IF eax == 2

				; 清空缓存
				INVOKE	DeleteTmpImage
				INVOKE	RandStr
				
				; 调用毛玻璃滤镜函数
				mov ebx, OFFSET tmpFileName
				mov edx, OFFSET szFileName
				push ebx
				push edx
				call maoboliFunc
				pop eax
				pop eax
				; 切换状态
				mov eax, 1
				mov isFiltered, eax

			.ENDIF

			; 鼠标位于huaijiu
			mov eax, huaijiu1Status
			.IF eax == 2

				; 清空缓存
				INVOKE	DeleteTmpImage
				INVOKE	RandStr
				
				; 调用怀旧滤镜函数
				mov ebx, OFFSET tmpFileName
				mov edx, OFFSET szFileName
				push ebx
				push edx
				call huaijiuFunc
				pop eax
				pop eax
				; 切换状态
				mov eax, 1
				mov isFiltered, eax

			.ENDIF

			; 鼠标位于huidu
			mov eax, huidu1Status
			.IF eax == 2

				; 清空缓存
				INVOKE	DeleteTmpImage
				INVOKE	RandStr
				
				; 调用灰度滤镜函数
				mov ebx, OFFSET tmpFileName
				mov edx, OFFSET szFileName
				push ebx
				push edx
				call huiduFunc
				pop eax
				pop eax
				; 切换状态
				mov eax, 1
				mov isFiltered, eax

			.ENDIF

			; 鼠标位于hedu
			mov eax, hedu1Status
			.IF eax == 2

				; 清空缓存
				INVOKE	DeleteTmpImage
				INVOKE	RandStr
				
				; 调用褐度滤镜函数
				mov ebx, OFFSET tmpFileName
				mov edx, OFFSET szFileName
				push ebx
				push edx
				call heduFunc
				pop eax
				pop eax
				; 切换状态
				mov eax, 1
				mov isFiltered, eax

			.ENDIF

			; 鼠标位于danya
			mov eax, danya1Status
			.IF eax == 2

				; 清空缓存
				INVOKE	DeleteTmpImage
				INVOKE	RandStr
				
				; 调用淡雅滤镜函数
				mov ebx, OFFSET tmpFileName
				mov edx, OFFSET szFileName
				push ebx
				push edx
				call danyaFunc
				pop eax
				pop eax
				; 切换状态
				mov eax, 1
				mov isFiltered, eax

			.ENDIF

			; 鼠标位于gete
			mov eax, gete1Status
			.IF eax == 2

				; 清空缓存
				INVOKE	DeleteTmpImage
				INVOKE	RandStr
				
				; 调用哥特滤镜函数
				mov ebx, OFFSET tmpFileName
				mov edx, OFFSET szFileName
				push ebx
				push edx
				call geteFunc
				pop eax
				pop eax
				; 切换状态
				mov eax, 1
				mov isFiltered, eax

			.ENDIF

			; 鼠标位于menghuan
			mov eax, menghuan1Status
			.IF eax == 2

				; 清空缓存
				INVOKE	DeleteTmpImage
				INVOKE	RandStr
				
				; 调用梦幻滤镜函数
				mov ebx, OFFSET tmpFileName
				mov edx, OFFSET szFileName
				push ebx
				push edx
				call menghuanFunc
				pop eax
				pop eax
				; 切换状态
				mov eax, 1
				mov isFiltered, eax

			.ENDIF

			; 鼠标位于yuhua
			mov eax, yuhua1Status
			.IF eax == 2

				; 清空缓存
				INVOKE	DeleteTmpImage
				INVOKE	RandStr
				
				; 调用羽化滤镜函数
				mov ebx, OFFSET tmpFileName
				mov edx, OFFSET szFileName
				push ebx
				push edx
				call yuhuaFunc
				pop eax
				pop eax
				; 切换状态
				mov eax, 1
				mov isFiltered, eax

			.ENDIF

			; 鼠标位于mopi
			mov eax, mopi1Status
			.IF eax == 2

				; 清空缓存
				INVOKE	DeleteTmpImage
				INVOKE	RandStr
				
				; 调用磨皮滤镜函数
				mov ebx, OFFSET tmpFileName
				mov edx, OFFSET szFileName
				push ebx
				push edx
				call mopiFunc
				pop eax
				pop eax
				; 切换状态
				mov eax, 1
				mov isFiltered, eax

			.ENDIF

		.ELSEIF interfaceID == 2

			; 改变按钮状态
			INVOKE	ChangeBtnStatus, eax, ebx, backLocation, OFFSET backStatus, 2
			INVOKE	ChangeBtnStatus, eax, ebx, saveLocation, OFFSET saveStatus, 2

			INVOKE	ChangeBtnStatus, eax, ebx, yuantu2Location, OFFSET yuantu2Status, 2
			INVOKE	ChangeBtnStatus, eax, ebx, sumiao2Location, OFFSET sumiao2Status, 2
			INVOKE	ChangeBtnStatus, eax, ebx, fudiao2Location, OFFSET fudiao2Status, 2
			INVOKE	ChangeBtnStatus, eax, ebx, maoboli2Location, OFFSET maoboli2Status, 2
			INVOKE	ChangeBtnStatus, eax, ebx, huaijiu2Location, OFFSET huaijiu2Status, 2
			INVOKE	ChangeBtnStatus, eax, ebx, huidu2Location, OFFSET huidu2Status, 2
			INVOKE	ChangeBtnStatus, eax, ebx, hedu2Location, OFFSET hedu2Status, 2
			INVOKE	ChangeBtnStatus, eax, ebx, danya2Location, OFFSET danya2Status, 2
			INVOKE	ChangeBtnStatus, eax, ebx, gete2Location, OFFSET gete2Status, 2
			INVOKE	ChangeBtnStatus, eax, ebx, menghuan2Location, OFFSET menghuan2Status, 2
			INVOKE	ChangeBtnStatus, eax, ebx, yuhua2Location, OFFSET yuhua2Status, 2
			INVOKE	ChangeBtnStatus, eax, ebx, mopi2Location, OFFSET mopi2Status, 2
			
			; 鼠标位于back
			mov eax, backStatus
			.IF eax == 2
				; 切换界面状态
				mov edx, 0
				mov interfaceID, edx
				; 杀死摄像头线程
				INVOKE  TerminateThread, hThread, OFFSET cameraThreadID
				call	releaseFunc
				;INVOKE  GetExitCodeThread, hThread, ADDR cameraThreadID
				;INVOKE  SuspendThread, hThread
			.ENDIF

			; 鼠标位于save
			mov eax, saveStatus
			.IF eax == 2
				; todo
				INVOKE SaveImg
			.ENDIF

			; 鼠标位于yuantu
			mov eax, yuantu2Status
			.IF eax == 2
				
				INVOKE  TerminateThread, hThread, OFFSET cameraThreadID
				call	releaseFunc
				mov ebx, 0
				mov cameraFilterType, ebx
				INVOKE  CreateThread, NULL, 0, OFFSET cameraThread, NULL, 0, OFFSET cameraThreadID
				mov		hThread, eax	; 获取进程句柄

			.ENDIF

			; 鼠标位于sumiao
			mov eax, sumiao2Status
			.IF eax == 2
				
				INVOKE  TerminateThread, hThread, OFFSET cameraThreadID
				call	releaseFunc
				mov ebx, 1
				mov cameraFilterType, ebx
				INVOKE  CreateThread, NULL, 0, OFFSET cameraThread, NULL, 0, OFFSET cameraThreadID
				mov		hThread, eax	; 获取进程句柄

			.ENDIF

			; 鼠标位于fudiao
			mov eax, fudiao2Status
			.IF eax == 2
				
				INVOKE  TerminateThread, hThread, OFFSET cameraThreadID
				call	releaseFunc
				mov ebx, 2
				mov cameraFilterType, ebx
				INVOKE  CreateThread, NULL, 0, OFFSET cameraThread, NULL, 0, OFFSET cameraThreadID
				mov		hThread, eax	; 获取进程句柄

			.ENDIF

			; 鼠标位于maoboli
			mov eax, maoboli2Status
			.IF eax == 2
				
				INVOKE  TerminateThread, hThread, OFFSET cameraThreadID
				call	releaseFunc
				mov ebx, 3
				mov cameraFilterType, ebx
				INVOKE  CreateThread, NULL, 0, OFFSET cameraThread, NULL, 0, OFFSET cameraThreadID
				mov		hThread, eax	; 获取进程句柄

			.ENDIF

			; 鼠标位于huaijiu
			mov eax, huaijiu2Status
			.IF eax == 2
				
				INVOKE  TerminateThread, hThread, OFFSET cameraThreadID
				call	releaseFunc
				mov ebx, 4
				mov cameraFilterType, ebx
				INVOKE  CreateThread, NULL, 0, OFFSET cameraThread, NULL, 0, OFFSET cameraThreadID
				mov		hThread, eax	; 获取进程句柄

			.ENDIF

			; 鼠标位于huidu
			mov eax, huidu2Status
			.IF eax == 2
				
				INVOKE  TerminateThread, hThread, OFFSET cameraThreadID
				call	releaseFunc
				mov ebx, 5
				mov cameraFilterType, ebx
				INVOKE  CreateThread, NULL, 0, OFFSET cameraThread, NULL, 0, OFFSET cameraThreadID
				mov		hThread, eax	; 获取进程句柄

			.ENDIF

			; 鼠标位于hedu
			mov eax, hedu2Status
			.IF eax == 2
				
				INVOKE  TerminateThread, hThread, OFFSET cameraThreadID
				call	releaseFunc
				mov ebx, 6
				mov cameraFilterType, ebx
				INVOKE  CreateThread, NULL, 0, OFFSET cameraThread, NULL, 0, OFFSET cameraThreadID
				mov		hThread, eax	; 获取进程句柄

			.ENDIF

			; 鼠标位于danya
			mov eax, danya2Status
			.IF eax == 2
				
				INVOKE  TerminateThread, hThread, OFFSET cameraThreadID
				call	releaseFunc
				mov ebx, 7
				mov cameraFilterType, ebx
				INVOKE  CreateThread, NULL, 0, OFFSET cameraThread, NULL, 0, OFFSET cameraThreadID
				mov		hThread, eax	; 获取进程句柄

			.ENDIF

			; 鼠标位于gete
			mov eax, gete2Status
			.IF eax == 2
				
				INVOKE  TerminateThread, hThread, OFFSET cameraThreadID
				call	releaseFunc
				mov ebx, 8
				mov cameraFilterType, ebx
				INVOKE  CreateThread, NULL, 0, OFFSET cameraThread, NULL, 0, OFFSET cameraThreadID
				mov		hThread, eax	; 获取进程句柄

			.ENDIF

			; 鼠标位于menghuan
			mov eax, menghuan2Status
			.IF eax == 2
				
				INVOKE  TerminateThread, hThread, OFFSET cameraThreadID
				call	releaseFunc
				mov ebx, 9
				mov cameraFilterType, ebx
				INVOKE  CreateThread, NULL, 0, OFFSET cameraThread, NULL, 0, OFFSET cameraThreadID
				mov		hThread, eax	; 获取进程句柄

			.ENDIF

			; 鼠标位于yuhua
			mov eax, yuhua2Status
			.IF eax == 2
			
				INVOKE  TerminateThread, hThread, OFFSET cameraThreadID
				call	releaseFunc
				mov ebx, 10
				mov cameraFilterType, ebx
				INVOKE  CreateThread, NULL, 0, OFFSET cameraThread, NULL, 0, OFFSET cameraThreadID
				mov		hThread, eax	; 获取进程句柄

			.ENDIF

			; 鼠标位于mopi
			mov eax, mopi2Status
			.IF eax == 2
				
				INVOKE  TerminateThread, hThread, OFFSET cameraThreadID
				call	releaseFunc
				mov ebx, 11
				mov cameraFilterType, ebx
				INVOKE  CreateThread, NULL, 0, OFFSET cameraThread, NULL, 0, OFFSET cameraThreadID
				mov		hThread, eax	; 获取进程句柄

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

cameraThread	PROC
	mov ebx, cameraFilterType
	push ebx
	call cameraFunc
	pop eax
	mov eax, 233
	ret
cameraThread ENDP

;-----------------------------------------------------
ChangeBtnStatus	PROC USES eax ebx ecx edx esi x:DWORD, y:DWORD, btn_location:location, btn_status_addr:DWORD, new_status:DWORD
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

;-----------------------------------------------------
SaveImg	PROC	USES esi edi ecx
; 保存图片到指定路径
;-----------------------------------------------------
	INVOKE	RtlZeroMemory, addr save_ofn, sizeof save_ofn
	mov save_ofn.lStructSize, sizeof save_ofn		;结构的大小
	mov save_ofn.lpstrFilter, OFFSET szFilterString	;文件过滤器
	mov save_ofn.lpstrInitialDir, OFFSET szInitialDir ; 初始目录
	mov save_ofn.lpstrFile, OFFSET saveFileName	;文件名的存放位置
	mov save_ofn.nMaxFile, 256	;文件名的最大长度
	mov	save_ofn.Flags, OFN_PATHMUSTEXIST
	INVOKE	GetSaveFileName, addr save_ofn
	.IF eax != 0			;若选择了文件
		; 获得了当前可执行文件的目录 含\*.exe
		; INVOKE GetModuleFileName, hInstance, addr currentWorkDir, 256
		; INVOKE MessageBoxA, NULL, addr currentWorkDir, addr szTitle, NULL
		; 拼接字符串 tmp_Image为临时文件的绝对路径
		mov esi, OFFSET szFileName
		mov edi, OFFSET tmp_Image
		mov eax, [esi]
		L1:
			mov ebx, [esi]
			mov [edi], ebx
			add esi, 1
			add edi, 1
			mov eax, [esi]
			cmp eax, 0
			jne L1
		sub edi, 1
		mov eax, [edi]

		L2:
			mov eax, 0
			mov [edi], eax
			sub edi, 1
			mov eax, [edi]
			cmp eax, '\'
			jne L2
		add edi, 1

		mov esi, OFFSET tmpFileName
		mov eax, [esi]
		L3:
			mov ebx, [esi]
			mov [edi], ebx
			add esi, 1
			add edi, 1
			mov eax, [esi]
			cmp eax, 0
			jne L3
		; INVOKE MessageBoxA, NULL, addr tmp_Image, addr szTitle, NULL

		mov esi, OFFSET saveFileName
		push esi
		mov esi, OFFSET tmp_Image
		push esi
		CALL	saveImageFunc
		pop esi
		pop esi
		INVOKE DeleteFile, addr tmp_Image
	.ENDIF
	ret
SaveImg ENDP

;-----------------------------------------------------
DeleteTmpImage	PROC	USES esi edi ecx
; 删除滤镜过程中出现的临时图
;-----------------------------------------------------
	mov esi, OFFSET szFileName
	mov edi, OFFSET tmp_Image
	mov eax, [esi]
	L1:
		mov ebx, [esi]
		mov [edi], ebx
		add esi, 1
		add edi, 1
		mov eax, [esi]
		cmp eax, 0
		jne L1
	sub edi, 1
	mov eax, [edi]

	L2:
		mov eax, 0
		mov [edi], eax
		sub edi, 1
		mov eax, [edi]
		cmp eax, '\'
		jne L2
	add edi, 1

	mov esi, OFFSET tmpFileName
	mov eax, [esi]
	L3:
		mov ebx, [esi]
		mov [edi], ebx
		add esi, 1
		add edi, 1
		mov eax, [esi]
		cmp eax, 0
		jne L3
	
	;INVOKE MessageBoxA, NULL, addr tmpFileName, addr szTitle, NULL
	;INVOKE MessageBoxA, NULL, addr tmp_Image, addr szTitle, NULL
	INVOKE DeleteFile, addr tmp_Image
	ret
DeleteTmpImage ENDP

;-----------------------------------------------------
RandStr	PROC
; 将tmpFileName置为随机字符串
;-----------------------------------------------------
	mov		esi, OFFSET tmpFileName
	xor		ebx, ebx
	mov		ecx, 10
L1:
	push	ecx
	;mov		ah, 00h
	;int		1ah
	;mov		ax, dx
	INVOKE	rand
	xor		dx, dx
	mov		cx, 10
	div		cx
	add		dl, '0'
	
	mov		BYTE PTR [esi + ebx], dl
	add		ebx, 1
	pop		ecx
	Loop	L1

	mov     edi, OFFSET pngType
	xor     edx, edx
L2:
	mov		cl, BYTE PTR [edi + edx]
	mov		[esi + ebx], cl
	add		edx, 1
	add		ebx, 1
	test    cl, cl
	jnz		L2

	ret
RandStr	ENDP

END START