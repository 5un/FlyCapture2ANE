package  {
	import flash.display.Sprite;
	import flash.events.*;
	import com.asunnotthesun.adobeair.extensions.FlyCapture2Extension;
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;

	public class MyApp extends Sprite{

		var mFlyCap:FlyCapture2Extension;
		var bitmap:Bitmap;
		public function MyApp() {
			// constructor code
			trace(NativeApplication.nativeApplication.runtimeVersion);
			mFlyCap = new FlyCapture2Extension();
			
			//mFlyCap.getVersion();
			trace(mFlyCap.getVersion());
			
			btnGrab01.addEventListener(MouseEvent.MOUSE_UP, btnGrabClickHandler);
			
			bitmap = new Bitmap();
			bitmap.x = 0;
			bitmap.y = 0;
			bitmap.scaleX = 0.25;
			bitmap.scaleY = 0.25;
			addChild(bitmap);
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true);
			trace("finish constructor");
		}
		
		protected function addedToStageHandler(event:Event):void {
			trace("added to stage");
        	//trace(mFlyCap.getNumCameras());
    		var numCameras = mFlyCap.getNumCameras();
			
			if(numCameras > 0){
				trace("numCameras = " + numCameras);
				
				mFlyCap.addEventListener("frame",handleRGBImage);
				
				mFlyCap.startCamera(0);
				
				/*
				var bmpd:BitmapData = mFlyCap.grabImage(0);
				
				if(bmpd!=null){
					trace("bitmap is not null");

					var bmp:Bitmap = new Bitmap(bmpd);
					trace('bitmap data width = ' + bmpd.width + ' height = ' + bmpd.height);
					bmp.x = 0;
					bmp.y = 0;
					bmp.scaleX = 0.25;
					bmp.scaleY = 0.25;
					//bmp.scaleX = stage.width / 1928.0;
					//bmp.scaleY = stage.height / 1448.0;
					addChild(bmp);
				}*/
			}
			
		}
		
		protected function btnGrabClickHandler(event:MouseEvent):void{
			trace("click");
			
			//handleRGBImage();
			
			//mFlyCap.stopCamera();
			
			/*
			var bmpd:BitmapData = mFlyCap.grabImage(0);
			if(bmpd!=null){
				var bmp:Bitmap = new Bitmap(bmpd);
				addChild(bmp);
			}*/
		}

		protected function handleRGBImage(event:Event){
			var bmpd:BitmapData = mFlyCap.getRGBFrame();
			if(bmpd!=null){
				trace("bitmap is not null");
				bitmap.bitmapData = bmpd
			}
		}
		


	} // end of class
	
	
	
}
