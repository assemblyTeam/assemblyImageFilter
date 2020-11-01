# assemblyImageFilter
汇编语言大作业

## 环境配置
clone代码，打开sln，.inc代码加入头文件，.asm代码加入源文件

按照课上的方式配置，完成后即可运行

## 终极目标
+ 上传单张图片，选择滤镜效果，输出
+ 摄像头实时采样，实时滤镜，点击输出图片（类似有滤镜的照相机）

## TODO
+ 每位同学往images传一张自拍，作美颜测试
+ 调研多asm编译，不然所有函数写在同一个asm文件中非常傻逼
+ 学习C++代码生成DLL供asm调用（宇哥已解决）
+ C++调用opencv库进行美颜滤镜
+ asm调用摄像头呈现实时影像


## 进度
### 10.20
陈荣钊搭建基础框架，完成图像绘制

### 10.21(issue分配)
伍冠宇按钮三态

孙梓健汇编多文件连接

### 10.23
陈荣钊实现C++封装OpenCV函数成DLL并使用汇编代码调用，成功调用了系统摄像头。

### 10.27
孙梓健完成汇编多文件连接

伍冠宇完成按钮三态，汇编语言打开文件选择器

陈荣钊整合代码，并将文件选择器选择出的图片文件展示至主界面

### 10.28
陈荣钊摄像头在主界面的布局（调试中）

### 10.29
陈荣钊实现汇编多线程调用摄像头，完成应用的返回和退出按钮

高俊峰实现一大堆滤镜

孙梓健实现素描滤镜的按钮逻辑、临时文件保存和效果预览

伍冠宇实现导出图片按钮逻辑

### 10.30
高俊峰实现磨皮(滤镜完成)

孙梓健实现所有滤镜按钮的逻辑

### 10.31
高俊峰实现摄像头滤镜函数

孙梓健实现摄像头按钮和逻辑，修改摄像头窗口创建逻辑

陈荣钊解决了图片文件调用时产生的占用冲突问题

### 11.1
伍冠宇实现压缩图片

目前bug：所有图片显示时比实际像素要大