.data
	OpenCVDLL		BYTE "OpenCVDLL.dll", 0

	smFunction		BYTE "smImage", 0
	cameraFunction	BYTE "openCamera", 0
	frameFunction	BYTE "captureFrame", 0
	saveImageFunction	BYTE "saveImage", 0

.data?
	OpenCV			HANDLE ?
	smFunc			DD ?
	cameraFunc		DD ?
	frameFunc		DD ?
	saveImageFunc	DD ?