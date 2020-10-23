#ifndef _DLL_DEMO_H_
#define _DLL_DEMO_H_
	
#ifdef DLLDEMO_EXPORTS
#define DLL_DEMO _declspec(dllexport)
#else
#define DLL_DEMO _declspec(dllimport)
#endif

#include <math.h>
#include <opencv2\opencv.hpp>
#include <opencv2\imgproc\types_c.h>

using namespace cv;
using namespace std;

// ±©Â¶º¯Êý½Ó¿Ú
extern "C" __declspec(dllexport) void smImage(char*, char*);
extern "C" __declspec(dllexport) void openCamera();
#endif