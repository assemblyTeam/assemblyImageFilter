;==================== IMAGES =======================
.data
	; ��ʼ��·����
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
	sumiaoImage	BYTE "images/start.png", 0								;1
	sumiaoHoverImage	BYTE "images/start_hover.png", 0
	fudiaoImage	    BYTE "images/start.png", 0								;2
	fudiaoHoverImage	BYTE "images/start_hover.png", 0
	maoboliImage	BYTE "images/start.png", 0								;3
	maoboliHoverImage	BYTE "images/start_hover.png", 0
	huaijiuImage	BYTE "images/start.png", 0								;4
	huaijiuHoverImage	BYTE "images/start_hover.png", 0
	huiduImage	BYTE "images/start.png", 0									;5
	huiduHoverImage	BYTE "images/start_hover.png", 0
	heduImage	BYTE "images/start.png", 0									;6
	heduHoverImage	BYTE "images/start_hover.png", 0
	danyaImage	BYTE "images/start.png", 0									;7
	danyaHoverImage	BYTE "images/start_hover.png", 0
	geteImage	BYTE "images/start.png", 0									;8
	geteHoverImage	BYTE "images/start_hover.png", 0
	menghuanImage	BYTE "images/start.png", 0							;9
	menghuanHoverImage	BYTE "images/start_hover.png", 0
	yuhuaImage	BYTE "images/start.png", 0									;10
	yuhuaHoverImage	BYTE "images/start_hover.png", 0
	mopiImage	BYTE "images/start.png", 0									;11
	mopiHoverImage	BYTE "images/start_hover.png", 0
	yuantuImage	BYTE "images/start.png", 0
	yuantuHoverImage	BYTE "images/start_hover.png", 0

	wgyImage			BYTE "images/WGY.png", 0
	smwgyImage			BYTE "images/smWGY.png", 0
	tmp_Image			BYTE 256 DUP(0)
	compressFileName	BYTE "compressed.png", 0
	frameImage			BYTE "images/Video.png", 0

	pngType				BYTE ".png", 0

	; ��ť����
	bkLocation			location <0, 0, 1024, 768>
	openLocation		location <100, 100, 80, 23>
	cameraLocation		location <300, 100, 80, 23>
	backLocation		location <0, 0, 80, 23>
	exitLocation		location <500, 100, 80, 23>
	sumiaoLocation		location <800, 50, 80, 23>			;1
	fudiaoLocation			location <800, 100, 80, 23>			;2
	maoboliLocation		location <800, 150, 80, 23>			;3
	huaijiuLocation			location <800, 200, 80, 23>			;4
	huiduLocation			location <800, 250, 80, 23>			;5
	heduLocation			location <800, 300, 80, 23>			;6
	danyaLocation			location <800, 350, 80, 23>			;7
	geteLocation			location <800, 400, 80, 23>			;8
	menghuanLocation	location <800, 450, 80, 23>			;9
	yuhuaLocation			location <800, 500, 80, 23>			;10
	mopiLocation			location <800, 550, 80, 23>			;11
	saveLocation		location <100, 0, 80, 23>
	yuantuLocation		location <200, 0, 80, 23>