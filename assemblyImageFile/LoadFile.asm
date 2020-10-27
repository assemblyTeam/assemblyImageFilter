.386
.Model Flat, StdCall
Option Casemap :None

INCLUDE		header.inc

.data
;声明为外部变量
EXTERN		StartupInfo: GdiplusStartupInput
EXTERN		UnicodeFileName: DWORD
EXTERN		token: DWORD

;外部可调用的函数
PUBLIC		LoadImageFromFile

.code
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

;-----------------------------------------------------
LoadImageFromFile	PROC FileName:PTR BYTE, Bitmap:DWORD
; 从文件中读取图片转换成Bitmap并存入Bitmap
;-----------------------------------------------------
	mov     eax, OFFSET StartupInfo
	mov     GdiplusStartupInput.GdiplusVersion[eax], 1

	INVOKE  GdiplusStartup, ADDR token, ADDR StartupInfo, 0
	INVOKE  UnicodeStr, FileName, ADDR UnicodeFileName
								
	INVOKE  GdipCreateBitmapFromFile, ADDR UnicodeFileName, Bitmap

	;INVOKE  GdipCreateBitmapFromFile, ADDR UnicodeFileName, ADDR BmpImage
	;INVOKE  GdipCreateHBITMAPFromBitmap, BmpImage, Bitmap, 0
	ret
LoadImageFromFile	ENDP

END