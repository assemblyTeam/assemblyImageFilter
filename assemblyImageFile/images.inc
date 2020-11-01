;==================== IMAGES =======================
.data
	;背景图
	bkImage							BYTE "images/bg.png", 0
	bgImgImage					BYTE "images/bg_img.png", 0
	bgCameraImage				BYTE "images/bg_camera.png", 0

	;按钮
	;一般按钮
	openImage						BYTE "images/start.png", 0
	openHoverImage				BYTE "images/start_hover.png", 0
	cameraImage					BYTE "images/camera.png", 0
	cameraHoverImage			BYTE "images/camera_hover.png", 0
	exitImage							BYTE "images/exit.png", 0
	exitHoverImage				BYTE "images/exit_hover.png", 0
	backImage						BYTE "images/exit.png", 0
	backHoverImage				BYTE "images/exit_hover.png", 0
	saveImage						BYTE "images/start.png", 0
	saveHoverImage				BYTE "images/start_hover.png", 0

	;滤镜按钮
	;原图0
	yuantu1Image					BYTE "images/yuantu1.png", 0
	yuantu1HoverImage			BYTE "images/yuantu1_hover.png", 0
	yuantu2Image					BYTE "images/yuantu2.png", 0
	yuantu2HoverImage			BYTE "images/yuantu2_hover.png", 0

	;素描1
	sumiao1Image					BYTE "images/sumiao1.png", 0	
	sumiao1HoverImage		BYTE "images/sumiao1_hover.png", 0
	sumiao2Image					BYTE "images/sumiao2.png", 0
	sumiao2HoverImage		BYTE "images/sumiao2_hover.png", 0

	;浮雕2
	fudiao1Image					BYTE "images/fudiao1.png", 0
	fudiao1HoverImage			BYTE "images/fudiao1_hover.png", 0
	fudiao2Image					BYTE "images/fudiao2.png", 0
	fudiao2HoverImage			BYTE "images/fudiao2_hover.png", 0

	;毛玻璃3
	maoboli1Image				BYTE "images/maoboli1.png", 0
	maoboli1HoverImage		BYTE "images/maoboli1_hover.png", 0
	maoboli2Image				BYTE "images/maoboli2.png", 0
	maoboli2HoverImage		BYTE "images/maoboli2_hover.png", 0

	;怀旧4
	huaijiu1Image					BYTE "images/huaijiu1.png", 0	
	huaijiu1HoverImage			BYTE "images/huaijiu1_hover.png", 0	
	huaijiu2Image					BYTE "images/huaijiu2.png", 0	
	huaijiu2HoverImage			BYTE "images/huaijiu2_hover.png", 0

	;灰度5
	huidu1Image					BYTE "images/huidu1.png", 0
	huidu1HoverImage			BYTE "images/huidu1_hover.png", 0
	huidu2Image					BYTE "images/huidu2.png", 0
	huidu2HoverImage			BYTE "images/huidu2_hover.png", 0

	;褐度6
	hedu1Image						BYTE "images/fugu1.png", 0
	hedu1HoverImage			BYTE "images/fugu1_hover.png", 0
	hedu2Image						BYTE "images/fugu2.png", 0	
	hedu2HoverImage			BYTE "images/fugu2_hover.png", 0

	;淡雅7
	danya1Image					BYTE "images/danya1.png", 0
	danya1HoverImage			BYTE "images/danya1_hover.png", 0
	danya2Image					BYTE "images/danya2.png", 0
	danya2HoverImage			BYTE "images/danya2_hover.png", 0

	;哥特8
	gete1Image						BYTE "images/gete1.png", 0	
	gete1HoverImage			BYTE "images/gete1_hover.png", 0
	gete2Image						BYTE "images/gete2.png", 0	
	gete2HoverImage			BYTE "images/gete2_hover.png", 0

	;梦幻9
	menghuan1Image			BYTE "images/menghuan1.png", 0
	menghuan1HoverImage	BYTE "images/menghuan1_hover.png", 0
	menghuan2Image			BYTE "images/menghuan2.png", 0
	menghuan2HoverImage	BYTE "images/menghuan2_hover.png", 0

	;羽化10
	yuhua1Image					BYTE "images/yuhua1.png", 0
	yuhua1HoverImage			BYTE "images/yuhua1_hover.png", 0
	yuhua2Image					BYTE "images/yuhua2.png", 0
	yuhua2HoverImage			BYTE "images/yuhua2_hover.png", 0

	;磨皮11
	mopi1Image						BYTE "images/mopi1.png", 0
	mopi1HoverImage			BYTE "images/mopi1_hover.png", 0
	mopi2Image						BYTE "images/mopi2.png", 0
	mopi2HoverImage			BYTE "images/mopi2_hover.png", 0

	tmp_Image						BYTE 256 DUP(0)
	frameImage						BYTE "images/Video.png", 0

	pngType							BYTE ".png", 0

	;位置
	bkLocation						location <0, 0, 1024, 768>

	openLocation					location <100, 632, 156, 56>
	cameraLocation				location <400, 632, 156, 56>
	exitLocation						location <700, 632, 156, 56>
	backLocation					location <0, 22, 156, 56>
	saveLocation					location <250, 22, 156, 56>

	yuantu1Location				location <857, 22, 110, 40>				;0
	sumiao1Location				location <857, 84, 110, 40>				;1
	fudiao1Location				location <857, 146, 110, 40>			;2
	maoboli1Location			location <857, 208, 110, 40>			;3
	huaijiu1Location				location <857, 270, 110, 40>			;4
	huidu1Location				location <857, 332, 110, 40>			;5
	hedu1Location					location <857, 394, 110, 40>			;6
	danya1Location				location <857, 456, 110, 40>			;7
	gete1Location					location <857, 518, 110, 40>			;8
	menghuan1Location		location <857, 580, 110, 40>			;9
	yuhua1Location				location <857, 642, 110, 40>			;10
	mopi1Location					location <857, 704, 110, 40>			;11

	yuantu2Location				location <90, 80, 153, 154>				;0
	sumiao2Location				location <90, 307, 153, 154>			;1
	fudiao2Location				location <90, 534, 153, 154>			;2
	maoboli2Location			location <320, 80, 153, 154>			;3
	huaijiu2Location				location <320, 307, 153, 154>			;4
	huidu2Location				location <320, 534, 153, 154>			;5
	hedu2Location					location <550, 80, 153, 154>			;6
	danya2Location				location <550, 307, 153, 154>			;7
	gete2Location					location <550, 534, 153, 154>			;8
	menghuan2Location		location <780, 80, 153, 154>			;9
	yuhua2Location				location <780, 307, 153, 154>			;10
	mopi2Location					location <780, 534, 153, 154>			;11