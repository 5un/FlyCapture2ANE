package com.asunnotthesun.adobeair.extensions
{
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	[Event(name="info", type="com.as3nui.nativeExtensions.air.kinect.events.DeviceInfoEvent")]
	
	public class FlyCapture2Extension extends EventDispatcher
	{
		
		private static var isInstantiated:Boolean = false;
		private static var context:ExtensionContext;
		
		private var imageByteArray:ByteArray;
		private var imageData:BitmapData;
		
		private var frameCount:uint = 0;
		
		public function FlyCapture2Extension()
		{
			if (isInstantiated)
				return;
			
			try
			{
				context = ExtensionContext.createExtensionContext("com.asunnotthesun.adobeair.extensions.FlyCapture2Extension",""); 
				context.addEventListener(StatusEvent.STATUS, contextStatusHandler, false, 0, true);
				
				imageByteArray = new ByteArray();
				imageData = new BitmapData(1928, 1448, false, 0x000000);
				
				context.call("init");

				isInstantiated = true;
			}
			catch (e:Error)
			{
			}
		}
		
		public function getVersion(): String
		{
			var versionStr:String = context.call("getVersion") as String;
			return versionStr;
		}
		
		public function getNumCameras(): int
		{
			var ret:int = context.call("getNumCameras") as int;
			return ret;
		}
		
		public function startCamera(index:int):void
		{
			context.call("startCamera", index);	
		}
		
		public function stopCamera():void
		{
			context.call("stopCamera");	
		}
		
		
		// Context Status Handler
		
		public function grabImage(index:int):BitmapData
		{
			
			context.call("grabImage", index, imageByteArray);
			imageByteArray.position = 0;
			imageByteArray.endian = Endian.LITTLE_ENDIAN;

			trace('total bytes : ' + imageByteArray.length);
			
			if(imageData!=null && imageByteArray!=null){
				imageData.setPixels(imageData.rect, imageByteArray);
				return imageData;	
			}
			
			return null;
		}
		
		public function getRGBFrame():BitmapData
		{
			
			context.call("getRGBFrame", imageByteArray);
			imageByteArray.position = 0;
			imageByteArray.endian = Endian.BIG_ENDIAN;
						
			if(imageData!=null && imageByteArray!=null){
				imageData.setPixels(imageData.rect, imageByteArray);
				return imageData;	
			}
			
			return null;
		}
		
		protected function contextStatusHandler(event:StatusEvent):void
		{
			trace("statusHander " + event.code);
			if(event.code == "trace"){
				trace("[FlyCapture2] " + event.level);
			}else if(event.code =="frame"){
				trace("FrameGrabber Callback " + frameCount);
				frameCount++;
				dispatchEvent(new Event("frame",true,false));
			}
			
		}
		
	}
}