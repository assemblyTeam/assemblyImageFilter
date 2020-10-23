.data
	OpenCVDLL		BYTE "OpenCVDLL.dll", 0

	smFunction		BYTE "smImage", 0
	cameraFunction	BYTE "openCamera", 0

.data?
	curDLL		HANDLE ?
	curFunc		DD ?