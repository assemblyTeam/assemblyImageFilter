.386
.Model Flat, StdCall
Option Casemap :None

INCLUDE		header.inc

.data
;声明为外部变量
EXTERN		StartupInfo:		GdiplusStartupInput
EXTERN		UnicodeFileName:	DWORD
EXTERN		token:				DWORD
EXTERN		ofn:				OPENFILENAME

;外部可调用的函数
PUBLIC		LoadImageFromFile
PUBLIC		GetFileNameFromDialog

.code
;-----------------------------------------------------
UnicodeStr	PROC USES esi Source:DWORD, Dest:DWORD
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
	mov		WORD PTR [edx + eax * 2 + 1], 0
	test    ecx, ecx
	jnz     @b
	ret
UnicodeStr	ENDP

;-----------------------------------------------------
LoadImageFromFile	PROC FileName:PTR BYTE, Bitmap:DWORD
; 从文件中读取图片转换成Bitmap并存入Bitmap
;-----------------------------------------------------
	;mov     eax, OFFSET StartupInfo
	;mov     GdiplusStartupInput.GdiplusVersion[eax], 1
	;INVOKE  GdiplusStartup, ADDR token, ADDR StartupInfo, 0
	
	INVOKE  UnicodeStr, FileName, ADDR UnicodeFileName
	INVOKE  GdipCreateBitmapFromFile, ADDR UnicodeFileName, Bitmap

	;INVOKE  GdipCreateBitmapFromFile, ADDR UnicodeFileName, ADDR BmpImage
	;INVOKE  GdipCreateHBITMAPFromBitmap, BmpImage, Bitmap, 0
	ret
LoadImageFromFile	ENDP

;-----------------------------------------------------
GetFileNameFromDialog	PROC USES esi filter_string:DWORD, initial_dir:DWORD, filename:DWORD, dialog_title:DWORD
; 打开选择文件对话框 
; https://www.daimajiaoliu.com/daima/37f6f0d89900406/huibianzhongshiyongdakaiduihuakuang
; https://blog.csdn.net/weixin_33835103/article/details/91893316
;-----------------------------------------------------
	INVOKE	RtlZeroMemory, addr ofn, sizeof ofn
	mov ofn.lStructSize, sizeof ofn		;结构的大小
	mov esi, filter_string
	mov ofn.lpstrFilter, esi	;文件过滤器
	mov esi, initial_dir
	mov ofn.lpstrInitialDir, esi ; 初始目录
	mov esi, filename
	mov ofn.lpstrFile, esi	;文件名的存放位置
	mov ofn.nMaxFile, 256	;文件名的最大长度
	mov ofn.Flags, OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_LONGNAMES
	mov esi, dialog_title
	mov ofn.lpstrTitle, esi	;“打开”对话框的标题
	INVOKE GetOpenFileName, addr ofn	;显示打开对话框
	ret
GetFileNameFromDialog	ENDP

END