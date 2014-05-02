#include "FlashRuntimeExtensions.h"

extern "C"
{
    
	FREObject FlyCapture2_init(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
	FREObject FlyCapture2_getVersion(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
	FREObject FlyCapture2_getNumCameras(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
	FREObject FlyCapture2_getCameraInfo(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
	FREObject FlyCapture2_startCamera(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
	FREObject FlyCapture2_stopCamera(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
	FREObject FlyCapture2_getRGBFrame(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);

	FREObject FlyCapture2_grabImage(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);

    //initializer / finalizer
    void contextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctions, const FRENamedFunction** functions);
    void contextFinalizer(FREContext ctx);
    
    __declspec(dllexport) void FlyCapture2Initializer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer);
	__declspec(dllexport) void FlyCapture2Finalizer(void* extData);
}