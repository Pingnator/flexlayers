package edu.psu.geovista.flexlayers
{
	public class FlexLayers
	{
		
		public static var ProxyHost:String;
		
		public static function loadURL(uri:String, params:Object, caller:Object, onComplete:Function = null, proxyIn:String = null):void {
			
			var proxy:String = null;
	        
	        if (proxyIn) {
	        	proxy = proxyIn;
	        } else if (FlexLayers.ProxyHost && uri.indexOf("http") == 0) {
	            proxy = FlexLayers.ProxyHost;
	        }
			
			var successorfailure:Function = onComplete;
			
			new RequestOL(uri,
                     {   method: 'get', 
                         parameters: params,
                         onComplete: successorfailure
                      }, proxy);
		}
		
		private var CLASS_NAME:String = "FlexLayers.FlexLayers";
		
		public function getClassName():String {
			return CLASS_NAME;
		}
	}
}