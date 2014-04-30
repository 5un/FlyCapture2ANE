#include "FC2Manager.h"
#include <stdlib.h>

FC2Manager::FC2Manager(){}

FREContext FC2Manager::freContext = NULL;
FlyCapture2::Image* FC2Manager::m_processedImage;

int FC2Manager::getNumCameras(){
	FlyCapture2::BusManager busManager;
	FlyCapture2::Error error;

	unsigned int numCameras = 0;
    error = busManager.GetNumOfCameras(&numCameras);
    if (error != FlyCapture2::PGRERROR_OK)
    {
        return -1;
	}

	return numCameras;
}

void OnImageGrabbed(FlyCapture2::Image* pImage, const void* pCallbackData)
{
	FC2Manager::onImageGrabbed(pImage, pCallbackData);
    return;
}

void FC2Manager::onImageGrabbed(FlyCapture2::Image* pImage, const void* pCallbackData){
	
	FREDispatchStatusEventAsync(freContext, (const uint8_t*) "frame", (const uint8_t*) "frame");

	FlyCapture2::Error error;
    // Convert the raw image
	FlyCapture2::Image newImage;
	error = pImage->Convert(FlyCapture2::PIXEL_FORMAT_RGBU, &newImage);
    if (error != FlyCapture2::PGRERROR_OK)
    {
		//PrintError( error );
        return;
    }  
	m_processedImage = &newImage;

}

void FC2Manager::startCamera(int index){

	FlyCapture2::Error error;
	FlyCapture2::BusManager busManager;

	FREDispatchStatusEventAsync(freContext, (const uint8_t*) "trace",(const uint8_t*) "hello from startCamera");

	unsigned int numCameras = 0;
    error = busManager.GetNumOfCameras(&numCameras);
    if (error != FlyCapture2::PGRERROR_OK)
    {
        return;
	}
	if(index > (numCameras-1)) return;

	FlyCapture2::PGRGuid guid;
    error = busManager.GetCameraFromIndex(index, &guid);
    if (error != FlyCapture2::PGRERROR_OK)
    {
		PrintError( error );
		return;
		//return -1;
    }

	 error = mainCamera.Connect(&guid);
    if (error != FlyCapture2::PGRERROR_OK)
    {
        PrintError( error );
        return;
		//return -1;
    }

	 // Get the camera information
    FlyCapture2::CameraInfo camInfo;
    error = mainCamera.GetCameraInfo(&camInfo);
    if (error != FlyCapture2::PGRERROR_OK)
    {
        PrintError( error );
        return;
		//return -1;
    }
	FREDispatchStatusEventAsync(freContext, (const uint8_t*) "trace",(const uint8_t*) "getCameraInfo");

    error = mainCamera.StartCapture(OnImageGrabbed);
    if (error != FlyCapture2::PGRERROR_OK)
    {
        PrintError( error );
        return;
    }

	m_processedImage = new FlyCapture2::Image;
}

void FC2Manager::stopCamera(){
	FlyCapture2::Error error;
	
	error = mainCamera.StopCapture();
    if (error != FlyCapture2::PGRERROR_OK)
    {
        PrintError( error );
        return;
    }      

	// Disconnect the camera
    error = mainCamera.Disconnect();
    if (error != FlyCapture2::PGRERROR_OK)
    {
        PrintError( error );
        return;
		//return -1;
    }
}

void FC2Manager::getRGBFrame(FREObject argv[]){  
	
	FlyCapture2::Error error;
	
	unsigned int rows,cols,stride;
    FlyCapture2::PixelFormat format;
    m_processedImage->GetDimensions( &rows, &cols, &stride, &format );  
	PrintImageInfo(rows, cols, stride);

	FRETrace((const uint8_t*)"[FlyCapture2] Copy");

	const unsigned int numRGBBytes = rows * cols * 4;
	FREObject objectByteArray = argv[0];
	FREByteArray byteArray;			
	FREObject length;
	FRENewObjectFromUint32(numRGBBytes, &length);
	FRESetObjectProperty(objectByteArray, (const uint8_t*) "length", length, NULL);
	FREAcquireByteArray(objectByteArray, &byteArray);
	memcpy(byteArray.bytes, m_processedImage->GetData(), numRGBBytes);
	FREReleaseByteArray(objectByteArray);
}

void FC2Manager::grabImage(FREObject argv[]){
	unsigned int index; 
	FREGetObjectAsUint32(argv[0], &index);

	FlyCapture2::Error error;
	FlyCapture2::Camera cam;
	FlyCapture2::BusManager busManager;

	FREDispatchStatusEventAsync(freContext, (const uint8_t*) "trace",(const uint8_t*) "hello from startCamera");

	unsigned int numCameras = 0;
    error = busManager.GetNumOfCameras(&numCameras);
    if (error != FlyCapture2::PGRERROR_OK)
    {
        return;
	}
	if(index > (numCameras-1)) return;

	FlyCapture2::PGRGuid guid;
    error = busManager.GetCameraFromIndex(index, &guid);
    if (error != FlyCapture2::PGRERROR_OK)
    {
		PrintError( error );
		return;
		//return -1;
    }

	 error = cam.Connect(&guid);
    if (error != FlyCapture2::PGRERROR_OK)
    {
        PrintError( error );
        return;
		//return -1;
    }

	 // Get the camera information
    FlyCapture2::CameraInfo camInfo;
    error = cam.GetCameraInfo(&camInfo);
    if (error != FlyCapture2::PGRERROR_OK)
    {
        PrintError( error );
        return;
		//return -1;
    }
	FREDispatchStatusEventAsync(freContext, (const uint8_t*) "trace",(const uint8_t*) "getCameraInfo");

	/////////////////////////////////////////////
	// Experimental
	//////////////////////////////////////////
	// Start capturing images
    error = cam.StartCapture();
    if (error != FlyCapture2::PGRERROR_OK)
    {
        PrintError( error );
        return;
    }

    FlyCapture2::Image rawImage;                 
	// Retrieve an image
    error = cam.RetrieveBuffer( &rawImage );
    if (error != FlyCapture2::PGRERROR_OK)
    {
        PrintError( error );
        return;
    }

    // Create a converted image
    FlyCapture2::Image convertedImage;
		
        // Convert the raw image
		error = rawImage.Convert(FlyCapture2::PIXEL_FORMAT_RGBU, &convertedImage);
        if (error != FlyCapture2::PGRERROR_OK)
        {
            PrintError( error );
            return;
        }  

		unsigned int rows,cols,stride;
        FlyCapture2::PixelFormat format;
        convertedImage.GetDimensions( &rows, &cols, &stride, &format );  
		PrintImageInfo(rows, cols, stride);

		//TODO make memcpy
		const unsigned int numRGBBytes = rows * cols * 4;
		FREObject objectByteArray = argv[1];
		FREByteArray byteArray;			
		FREObject length;
		FRENewObjectFromUint32(numRGBBytes, &length);
		FRESetObjectProperty(objectByteArray, (const uint8_t*) "length", length, NULL);
		FREAcquireByteArray(objectByteArray, &byteArray);
		
		//uint8_t* pData = (uint8_t*) calloc (numRGBBytes,sizeof(uint8_t));
		//memcpy(byteArray.bytes, pData, numRGBBytes);

		unsigned int dataSize = convertedImage.GetDataSize();
		char log[128];
		sprintf_s(log,"datasize %d\n",dataSize);
		FRETrace((const uint8_t*) log);
		memcpy(byteArray.bytes, convertedImage.GetData(), numRGBBytes);
		FREReleaseByteArray(objectByteArray);
		
		FRETrace((const uint8_t*)"Completed Grab Image");


    // Stop capturing images
    error = cam.StopCapture();
    if (error != FlyCapture2::PGRERROR_OK)
    {
        PrintError( error );
        return;
    }      
	/////////////////////////////////////////////
	// Experimental
	//////////////////////////////////////////


	// Disconnect the camera
	
    error = cam.Disconnect();
    if (error != FlyCapture2::PGRERROR_OK)
    {
        PrintError( error );
        return;
		//return -1;
    }
	FREDispatchStatusEventAsync(freContext, (const uint8_t*) "trace",(const uint8_t*) "cam Disconnected");
	
}



void FC2Manager::FRETrace(const uint8_t* message){
	FREDispatchStatusEventAsync(freContext, (const uint8_t*) "trace", message);
}

void FC2Manager::getCameraInfo(int index){
	

}

void FC2Manager::setFreContext(FREContext pFreContext)
{
	freContext = pFreContext;
}

// Utils

void FC2Manager::PrintError( FlyCapture2::Error error )
{
	FREDispatchStatusEventAsync(freContext, (const uint8_t*) "trace",(const uint8_t*) error.GetDescription());
}

void FC2Manager::PrintCameraInfo( FlyCapture2::CameraInfo* pCamInfo )
{
	/*
	char cameraInfoStr[128];

    _snprintf(
		cameraInfoStr, 128,
        "\n*** CAMERA INFORMATION ***\n"
        "Serial number - %u\n"
        "Camera model - %s\n"
        "Camera vendor - %s\n"
        "Sensor - %s\n"
        "Resolution - %s\n"
        "Firmware version - %s\n"
        "Firmware build time - %s\n\n",
        pCamInfo->serialNumber,
        pCamInfo->modelName,
        pCamInfo->vendorName,
        pCamInfo->sensorInfo,
        pCamInfo->sensorResolution,
        pCamInfo->firmwareVersion,
        pCamInfo->firmwareBuildTime );
		*/
	//FREDispatchStatusEventAsync(freContext, (const uint8_t*) "trace",(const uint8_t*) cameraInfoStr);

	FREDispatchStatusEventAsync(freContext, (const uint8_t*) "trace",(const uint8_t*) "getCamInfo");
}

void FC2Manager::PrintImageInfo(int width, int height, int stride){
	char version[128];

	sprintf_s( 
		version, 
		"Image Info: width=%d height=%d stride=%d\n", 
		width,height,stride );

	FRETrace((const uint8_t*) version);
}