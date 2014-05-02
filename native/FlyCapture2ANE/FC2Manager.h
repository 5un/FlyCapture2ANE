#ifndef _FC2Manager_H
#define _FC2Manager_H

#include <FlyCapture2.h>
#include "FlashRuntimeExtensions.h"

class FC2Manager {

public:
	FC2Manager();
	
	int						getNumCameras();

	void					startCamera(int index);
	void					stopCamera();
	
	FREObject				getCameraInfo(int index);
	void					setCameraProperty();
	FREObject				getCameraProperty();

	void					setFreContext(FREContext pFreContext);
	void					getRGBFrame(FREObject argv[]);

	void					grabImage(FREObject argv[]);

	static void				onImageGrabbed(FlyCapture2::Image* pImage, const void* pCallbackData);

	static FREObject		FREObjectFromCameraInfo(FlyCapture2::CameraInfo* pCamInfo);

protected:
	static FREContext				freContext;
	FlyCapture2::Image				m_rawImage;
    static FlyCapture2::Image		m_processedImage;
	FlyCapture2::Camera				mainCamera;

private:
	void					PrintError( FlyCapture2::Error error );
	void					PrintCameraInfo( FlyCapture2::CameraInfo* pCamInfo );
	void					FRETrace(const uint8_t* message);
	void					PrintImageInfo(int width, int height, int stride);


	//void					OnImageGrabbed(FlyCapture2::Image* pImage, const void* pCallbackData);
};

#endif