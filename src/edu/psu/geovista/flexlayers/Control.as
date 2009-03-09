package edu.psu.geovista.flexlayers
{
	import edu.psu.geovista.flexlayers.basetypes.Pixel;
	import edu.psu.geovista.flexlayers.layer.Vector;
	
	public class Control
	{
		
		public static var TYPE_BUTTON:int = 1;
		public static var TYPE_TOGGLE:int = 2;
		public static var TYPE_TOOL:int = 3;
		public static var TYPES:Array = new Array(TYPE_BUTTON, TYPE_TOGGLE, TYPE_TOOL);
		
		public var id:String = null;
		public var map:Object = null;
		public var canvas:CanvasOL = null;
		public var type:Array = null;
		public var displayClass:String = "";
		public var active:Boolean = false;
		public var position:Pixel = null;
		public var outsideCanvas:CanvasOL = null;
		public var handler:Handler = null;
		public var layer:edu.psu.geovista.flexlayers.layer.Vector = null;
		public var layerZPos:int;
		public var keyMask:int;
		
		public function Control(options:Object = null):void {
			this.displayClass = this.CLASS_NAME.replace("FlexLayers.", "fl").replace(".","");
			this.position = new Pixel(0,0);
			
			Util.extend(this, options);
			
			this.id = Util.createUniqueID(this.CLASS_NAME + "_");
		}
		
		public function destroy():void {  
	        this.map = null;
		}
		
		public function setMap(map:Object):void {
			this.map = map;
	        if (this.handler) {
	            this.handler.setMap(map);
	        }
		}
		
		public function draw(px:Pixel = null, toSuper:Boolean = false):CanvasOL {
			if (this.canvas == null) {
	            this.canvas = Util.createCanvas();
	            this.canvas.id = this.id;
	            this.canvas.name = this.displayClass;
	            this.canvas.clipContent = true;
	        }
	        if (px != null) {
	            this.position = px.clone();
	        }
	        this.moveTo(this.position);        
	        return this.canvas;
		}
		
		public function moveTo(px:Pixel):void {
			if ((px != null) && (this.canvas != null)) {
	            this.canvas.x = px.x;
	            this.canvas.y = px.y;
	        }
		}
		
		public function activate():Boolean {
			if (this.active) {
	            return false;
	        }
	        if (this.handler) {
	        	this.handler.activate();
	        }
	        this.active = true;
	        return true;
		}
		
		public function deactivate():Boolean {
	        if (this.active) {
	            if (this.handler) {
	                this.handler.deactivate();
	            }
	            this.active = false;
	            return true;
	        }
	        return false;
		}
		
		private var CLASS_NAME:String = "FlexLayers.Control";
		
		public function getClassName():String {
			return CLASS_NAME;
		}
		
	}
}