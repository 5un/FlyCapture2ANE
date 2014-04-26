#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "FlyCapture2Extension.h"
#include "FlyCapture2.h"

extern "C"
{

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

	FRENamedFunction _Static_methods[] = {
		{ (const uint8_t*) "getVersion", 0, FlyCapture2_getVersion},
    };
    
	/*
	FRENamedFunction _Instance_methods[] = {
		{ (const uint8_t*) "start", 0, Kinect_start },    
	};
	*/
	void contextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctions, const FRENamedFunction** functions)
    {
        if ( 0 == strcmp( (const char*) ctxType, "shared" ) )
		{
			*numFunctions = sizeof( _Static_methods ) / sizeof( FRENamedFunction );
			*functions = _Static_methods;
		}
		else
        {
			/*
            *numFunctions = sizeof( _Instance_methods ) / sizeof( FRENamedFunction );
            *functions = _Instance_methods;
			*/
		}
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