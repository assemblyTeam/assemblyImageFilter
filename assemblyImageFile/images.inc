;==================== IMAGES =======================
.data
	; 初始化路径名
	bkImage				BYTE "images/bg.png", 0
	btnImage			BYTE "images/button_bg.png", 0
	openImage			BYTE "images/start.png", 0
	openHoverImage		BYTE "images/start_hover.png", 0
	cameraImage			BYTE "images/camera.png", 0
	cameraHoverImage	BYTE "images/camera_hover.png", 0
	backImage			BYTE "images/exit.png", 0
	backHoverImage		BYTE "images/exit_hover.png", 0
	exportImage			BYTE "images/start.png", 0
	exportHoverImage	BYTE "images/start_hover.png", 0
	exitImage			BYTE "images/exit.png", 0
	exitHoverImage		BYTE "images/exit_hover.png", 0

	wgyImage			BYTE "images/WGY.png", 0
	smwgyImage			BYTE "images/smWGY.png", 0

	frameImage			BYTE "images/Video.png", 0

	pngType				BYTE "PNG", 0

	; 按钮坐标
	bkLocation			location <0, 0, 1024, 768>
	openLocation		location <100, 100, 80, 23>
	cameraLocation		location <300, 100, 80, 23>
	backLocation		location <0, 0, 80, 23>
	exitLocation		location <500, 100, 80, 23>