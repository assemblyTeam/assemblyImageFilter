.data
	OpenCVDLL		BYTE "OpenCVDLL.dll", 0

	smFunction		BYTE "smImage", 0
	cameraFunction	BYTE "openCamera", 0
	releaseFunction	BYTE "releaseCamera", 0
	frameFunction	BYTE "captureFrame", 0

.data?
	OpenCV			HANDLE ?
	cameraFunc		DD ?
	releaseFunc		DD ?
	frameFunc		DD ?