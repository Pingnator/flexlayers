package edu.psu.geovista.flexlayers
{
	import edu.psu.geovista.flexlayers.basetypes.Pixel;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import mx.events.ResizeEvent;
	
	public class Handler
	{
		
		public static var MOD_NONE:int = 0;
		public static var MOD_SHIFT:int = 1;
		public static var MOD_CTRL:int = 2;
		public static var MOD_ALT:int = 4;
		
		private var id:String = null;
		public var control:* = null;
		public var map:Object = null;
		public var keyMask:int;
		public var active:Boolean = false;
		public var callbacks:Object = null;
		public var style:Object = null;
		public var last:Pixel = null;
    	public var start:Pixel = null;
    	public var dragging:Boolean = false;
		
		public function Handler(control:*, callbacks:Object, options:Object):void {
			Util.extend(this, options);
			this.control = control;
			this.callbacks = callbacks;
			if (control.map) {
				this.setMap(control.map);
			}
			
			Util.extend(this, options);
			
			this.id = Util.createUniqueID(this.CLASS_NAME + "_");
		}
		
		public function setMap(map:Object):void {
			this.map = map;
		}
		
		public function checkModifiers(evt:MouseEvent):Boolean {
			if(this.keyMask == NaN) {
	            return true;
	        }
	        var keyModifiers =
	            (evt.shiftKey ? Handler.MOD_SHIFT : 0) |
	            (evt.ctrlKey  ? Handler.MOD_CTRL  : 0) |
	            (evt.altKey   ? Handler.MOD_ALT   : 0);

	        return (keyModifiers == this.keyMask);
		}
		
		public function activate(evt:MouseEvent = null):Boolean {
	        var events = Events.BROWSER_EVENTS;
	        for (var i = 0; i < events.length; i++) {
	        	if (this[events[i]]) {
		        	this.register(events[i], this[events[i]]); 
	         	}
	        }
	        
	        this.active = true;
	        return true;
		}
		
		public function deactivate(evt:MouseEvent = null):Boolean {
			if(!this.active) {
	            return false;
	        }
	        var events = Events.BROWSER_EVENTS;
	        for (var i = 0; i < events.length; i++) {
	            if (this[events[i]]) {
	                this.unregister(events[i], this[events[i]]); 
	            }
	        }
	        this.active = false;
	        return true;
		}
		
		public function callback(name:String, args:Object):void {
			if (this.callbacks) {
				if (this.callbacks[name]) {
	            	this.callbacks[name].apply(this.control, args);
	        	}
	  		}
		}
		
		public function register(name:String, method:Function):void {
			this.map.events.registerPriority(name, this, method);
		}
		
		public function unregister(name:String, method:Function):void {
			this.map.events.unregister(name, this, method);
		}
		
		public function destroy():void {
			this.control = null;
			this.map = null;
		}
		
		public function mouseOver(evt:MouseEvent):void {
			
		}
		
		public function doubleClick(evt:MouseEvent):void {
			
		}
		
		public function resize(evt:ResizeEvent):void {
			
		}
		
		public function focus(evt:MouseEvent):void {
			
		}
		
		public function blur(evt:MouseEvent):void {
			
		}
		
		private var CLASS_NAME:String = "FlexLayers.Handler";
		
		public function getClassName():String {
			return CLASS_NAME;
		}
	}
}