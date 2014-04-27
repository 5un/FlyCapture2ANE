package  {
	import flash.display.Sprite;
	import com.asunnotthesun.adobeair.extensions.FlyCapture2Extension;
	import flash.desktop.NativeApplication;

	public class MyApp extends Sprite{

		var mFlyCap:FlyCapture2Extension;

		public function MyApp() {
			// constructor code
			trace(NativeApplication.nativeApplication.runtimeVersion);
			mFlyCap = new FlyCapture2Extension();
			
			//mFlyCap.getVersion();
			trace(mFlyCap.getVersion());
		}

	}
	
}
