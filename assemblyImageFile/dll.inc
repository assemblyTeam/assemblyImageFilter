.data
	OpenCVDLL		BYTE "OpenCVDLL.dll", 0

	mopiFunction	BYTE "mopiImage", 0
	yuhuaFunction	BYTE "yuhuaImage", 0
	menghuanFunction	BYTE "menghuanImage", 0
	geteFunction	BYTE "geteImage", 0
	danyaFunction	BYTE "danyaImage", 0
	heduFunction	BYTE "heduImage", 0
	huiduFunction	BYTE "huiduImage", 0
	huaijiuFunction	BYTE "huaijiuImage", 0
	maoboliFunction	BYTE "maoboliImage", 0
	fudiaoFunction	BYTE "fudiaoImage", 0
	sumiaoFunction	BYTE "sumiaoImage", 0
	cameraFunction	BYTE "openCamera", 0
	releaseFunction	BYTE "releaseCamera", 0
	frameFunction	BYTE "captureFrame", 0
	saveImageFunction	BYTE "saveImage", 0

.data?
	OpenCV			HANDLE ?
	cameraFunc		DD ?
	releaseFunc		DD ?
	frameFunc		DD ?
	saveImageFunc	DD ?
	sumiaoFunc		DD ?
	fudiaoFunc		DD ?
	maoboliFunc		DD ?
	huaijiuFunc		DD ?
	huiduFunc		DD ?
	heduFunc		DD ?
	danyaFunc		DD ?
	geteFunc		DD ?
	menghuanFunc	DD ?
	yuhuaFunc		DD ?
	mopiFunc		DD ?
