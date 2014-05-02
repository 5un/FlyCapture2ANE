#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "FlyCapture2Extension.h"
#include "FlyCapture2.h"

#include "FC2Manager.h"

extern "C"
{
	
	FC2Manager fc2Manager;

	FREObject FlyCapture2_init(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		fc2Manager.setFreContext(ctx);
		return NULL;
	}

	FREObject FlyCapture2_getVersion(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
    {
        FREObject retObj;

		FlyCapture2::FC2Version fc2Version;
		FlyCapture2::Utilities::GetLibraryVersion( &fc2Version );

		char version[128];

		sprintf_s( 
			version, 
			"FlyCapture2 library version: %d.%d.%d.%d\n", 
			fc2Version.major, fc2Version.minor, fc2Version.type, fc2Version.build );
		
		FRENewObjectFromUTF8(strlen((const char*)version)+1, (const uint8_t*) version, &retObj);

		return retObj;
    }

	FREObject FlyCapture2_getNumCameras(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
		FREObject retObj;
		
		int numCams = fc2Manager.getNumCameras();
		FRENewObjectFromInt32(numCams, &retObj);
		return retObj;
	}

	FREObject FlyCapture2_getCameraInfo(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
		FREObject retObj;
		
		unsigned int nr; FREGetObjectAsUint32(argv[0], &nr);
		retObj = fc2Manager.getCameraInfo(nr);
		return retObj;
	}

	FREObject FlyCapture2_startCamera(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
		FREObject retObj;
		
		unsigned int nr; FREGetObjectAsUint32(argv[0], &nr);
		fc2Manager.startCamera(nr);
		return NULL;
	}

	FREObject FlyCapture2_stopCamera(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
		fc2Manager.stopCamera();
		return NULL;
	}

	FREObject FlyCapture2_getRGBFrame(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
		fc2Manager.getRGBFrame(argv);
		return NULL;
	}

	FREObject FlyCapture2_grabImage(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
		fc2Manager.grabImage(argv);
		return NULL;
	}

	FRENamedFunction _Static_methods[] = {
		{ (const uint8_t*) "init", 0, FlyCapture2_init},
		{ (const uint8_t*) "getVersion", 0, FlyCapture2_getVersion},
		{ (const uint8_t*) "getNumCameras", 0, FlyCapture2_getNumCameras},
		{ (const uint8_t*) "getCameraInfo", 0, FlyCapture2_getCameraInfo},
		{ (const uint8_t*) "startCamera", 0, FlyCapture2_startCamera},
		{ (const uint8_t*) "stopCamera", 0, FlyCapture2_stopCamera},
		{ (const uint8_t*) "getRGBFrame", 0, FlyCapture2_getRGBFrame},
		{ (const uint8_t*) "grabImage", 0, FlyCapture2_grabImage}
    };
    
	/*
	FRENamedFunction _Instance_methods[] = {
		{ (const uint8_t*) "start", 0, Kinect_start },    
	};
	*/
	void contextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctions, const FRENamedFunction** functions)
    {
		/*
        if ( 0 == strcmp( (const char*) ctxType, "shared" ) )
		{
			*numFunctions = sizeof( _Static_methods ) / sizeof( FRENamedFunction );
			*functions = _Static_methods;
		}
		else
        {
            *numFunctions = sizeof( _Instance_methods ) / sizeof( FRENamedFunction );
            *functions = _Instance_methods;	
		}
		*/

		*numFunctions = sizeof( _Static_methods ) / sizeof( FRENamedFunction );
		*functions = _Static_methods;
	}
    
	void contextFinalizer(FREContext ctx)
    {
		return;
	}
    
	void FlyCapture2Initializer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer)
    {
		*ctxInitializer = &contextInitializer;
		*ctxFinalizer = &contextFinalizer;
	}
    
	void FlyCapture2Finalizer(void* extData)
    {
		return;
	}	
}