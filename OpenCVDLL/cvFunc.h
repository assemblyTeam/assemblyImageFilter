#ifndef _DLL_DEMO_H_
#define _DLL_DEMO_H_
	
#ifdef DLLDEMO_EXPORTS
#define DLL_DEMO _declspec(dllexport)
#else
#define DLL_DEMO _declspec(dllimport)
#endif

#include <math.h>
#include <stdio.h>
#include <windows.h>
#include <opencv2\opencv.hpp>
#include <opencv2\imgproc\types_c.h>
#include <opencv2\highgui\highgui_c.h>

using namespace cv;
using namespace std;

// 将函数接口暴露出来
extern "C" __declspec(dllexport) void mopiImage(char*, char*);
extern "C" __declspec(dllexport) void yuhuaImage(char*, char*);
extern "C" __declspec(dllexport) void menghuanImage(char*, char*);
extern "C" __declspec(dllexport) void geteImage(char*, char*);
extern "C" __declspec(dllexport) void danyaImage(char*, char*);
extern "C" __declspec(dllexport) void heduImage(char*, char*);
extern "C" __declspec(dllexport) void huiduImage(char*, char*);
extern "C" __declspec(dllexport) void huaijiuImage(char*, char*);
extern "C" __declspec(dllexport) void maoboliImage(char*, char*);
extern "C" __declspec(dllexport) void fudiaoImage(char*, char*);
extern "C" __declspec(dllexport) void sumiaoImage(char*, char*);
extern "C" __declspec(dllexport) void releaseCamera();
extern "C" __declspec(dllexport) void openCamera(int);
extern "C" __declspec(dllexport) void captureFrame(char*, int);
extern "C" __declspec(dllexport) void saveImage(char*, char*);
extern "C" __declspec(dllexport) void compressImg(char*, char*);
#endif