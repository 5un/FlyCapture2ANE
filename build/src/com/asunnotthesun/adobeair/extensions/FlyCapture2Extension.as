package com.asunnotthesun.adobeair.extensions
{
	
	import flash.external.ExtensionContext;
	
	public class FlyCapture2Extension 
	{
		
		private static var isInstantiated:Boolean = false;
		private static var context:ExtensionContext;
		
		public function FlyCapture2Extension()
		{
			trace("hello");
			if (isInstantiated)
				return;
			
			try
			{
				context = ExtensionContext.createExtensionContext("com.asunnotthesun.adobeair.extensions.FlyCapture2Extension",""); 
				isInstantiated = true;
			}
			catch (e:Error)
			{
			}
		}
		
		public function getVersion(): String
		{
			var test = context.call("getVersion");
			return test;
			
			//var arr:Array = context.call("getVersion") as Array;
			//return arr.toString();
		}
	}
}