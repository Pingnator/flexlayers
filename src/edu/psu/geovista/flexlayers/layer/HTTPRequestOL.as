package edu.psu.geovista.flexlayers.layer
{
	import edu.psu.geovista.flexlayers.Layer;
	import edu.psu.geovista.flexlayers.Util;
	import mx.containers.Canvas;
	import edu.psu.geovista.flexlayers.Map;
	import edu.psu.geovista.flexlayers.CanvasOL;
	import flash.utils.Dictionary;
	
	public class HTTPRequestOL extends Layer
	{
		
		public var URL_HASH_FACTOR:Number = (Math.sqrt(5) - 1) / 2;
		
		public var url:String = null;
		
		public var params:Object = null;
		
		public function HTTPRequestOL(name:String, url:String, params:Object = null, options:Object = null):void {
	        super(name, options);
	        this.url = url;
	        this.canvas = canvas;
	        this.params = Util.extend( new Object(), params);
		}
		
		override public function destroy(setNewBaseLayer:Boolean = true):void {
			this.url = null;
			this.params = null;
			super.destroy(setNewBaseLayer);
		}
		
		override public function clone(obj:Object):Object {
			if (obj == null) {
	            obj = new HTTPRequestOL(this.name,
                                       this.url,
                                       this.params,
                                       this.options);
	        }

	        obj = new Layer(this.name, arguments).clone([obj]);
	        
	        return obj;
		}
		
		public function setUrl(newUrl:String):void {
			this.url = newUrl;
		}
		
		public function mergeNewParams(newParams:Array):void {
			this.params = Util.extend(this.params, newParams);
		}
		
		public function selectUrl(paramString:String, urls:Array):String {
			var product:int = 1;
	        for (var i:int = 0; i < paramString.length; i++) { 
	            product *= paramString.charCodeAt(i) * this.URL_HASH_FACTOR; 
	            product -= Math.floor(product); 
	        }
	        return urls[Math.floor(product * urls.length)];
		}
		
		public function getFullRequestString(newParams:Object = null, altUrl:String = null):String {
	        var url = altUrl || this.url;
	        
	        var allParams:Object = Util.extend(new Object(), this.params);
	        allParams = Util.extend(allParams, newParams);
	        var paramsString = Util.getParameterString(allParams);

	        if (url is Array) {
	            url = this.selectUrl(paramsString, url);
	        }   

	        var urlParams = 
	            Util.upperCaseObject(Util.getArgs(url));
	        for(var key:String in allParams) {
	            if(key.toUpperCase() in urlParams) {
	                delete allParams[key];
	            }
	        }
	        paramsString = Util.getParameterString(allParams);
	        
	        var requestString = url;        
	        
	        if (paramsString != "") {
	            var lastServerChar = url.charAt(url.length - 1);
	            if ((lastServerChar == "&") || (lastServerChar == "?")) {
	                requestString += paramsString;
	            } else {
	                if (url.indexOf('?') == -1) {
	                    requestString += '?' + paramsString;
	                } else {
	                    requestString += '&' + paramsString;
	                }
	            }
	        }
	        return requestString;	
		}
		
		private var CLASS_NAME:String = "FlexLayers.Layer.HTTPRequestOL";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}
	}
}