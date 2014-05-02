package  {
	import flash.display.Sprite;
	import flash.events.*;
	import com.asunnotthesun.adobeair.extensions.FlyCapture2Extension;
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import com.junkbyte.console.Cc;
	import com.junkbyte.console.Console;
	import com.junkbyte.console.ConsoleChannel;

	public class MyApp extends Sprite{

		var mFlyCap:FlyCapture2Extension;
		var bitmap:Bitmap;
		public function MyApp() {
			// constructor code
			trace(NativeApplication.nativeApplication.runtimeVersion);
			mFlyCap = new FlyCapture2Extension();
			setupLog();
			
			var flyCapVersion = mFlyCap.getVersion();
			Cc.info("flyCapVersion = " + flyCapVersion);
		
			//btnGrab01.addEventListener(MouseEvent.MOUSE_UP, btnGrabClickHandler);
			
			bitmap = new Bitmap();
			bitmap.x = 0;
			bitmap.y = 0;			
			//bitmap.scaleX = 0.25;
			//bitmap.scaleY = 0.25;
			addChild(bitmap);
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true);
		}
		
		protected function addedToStageHandler(event:Event):void {
			//trace(mFlyCap.getNumCameras());
    		var numCameras = mFlyCap.getNumCameras();
			Cc.info("numCameras = " + numCameras);
			
			if(numCameras > 0){
				mFlyCap.addEventListener("frame",handleRGBImage);
				mFlyCap.startCamera(0);
			}
			
		}

		protected function handleRGBImage(event:Event){
			var bmpd:BitmapData = mFlyCap.getRGBFrame();
			if(bmpd!=null){
				//makeItFit(bitmap, this);
				Cc.info("bitmap is not null");
				bitmap.bitmapData = bmpd
			}
		}
		
		protected function setupLog(){
			Cc.config.style.backgroundAlpha = 1;
			Cc.startOnStage(this, "`"); // "`" - change for password. This will start hidden
			Cc.visible = true; // Show console, because having password hides console.
			Cc.config.commandLineAllowed = true; // enable advanced (but security risk) features.
			Cc.config.tracing = true; // Also trace on flash's normal trace
			Cc.config.remotingPassword = ""; // Just so that remote don't ask for password
			Cc.remoting = true; // Start sending logs to remote (using LocalConnection)
			Cc.commandLine = true; // Show command line
			Cc.height = 220; // change height. You can set x y width height to position/size the main pane
		}
		
		function makeItFit(cont:Bitmap, hold:Sprite):void{
        	var holderRatio:Number = hold.width/hold.height;
        	var contentRatio:Number = cont.width/cont.height;
        	//compare both ratios to get the biggest side
        	if(holderRatio < contentRatio){
         	  cont.width = hold.width; //width bigger, lets make it fit
           		cont.scaleY = cont.scaleX; //adjust scale to avoid distortion
        	}else{
           		cont.height = hold.height;
           		cont.scaleX = cont.scaleY;
        	}
        		//now the size is ok, lets center the thing
        	cont.x = (hold.width - cont.width)/2;
        	cont.y = (hold.height - cont.height)/2;
		}
		
	} // end of class
	
	
	
}
