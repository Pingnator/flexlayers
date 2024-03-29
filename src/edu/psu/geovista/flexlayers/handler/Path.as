package edu.psu.geovista.flexlayers.handler
{
	import edu.psu.geovista.flexlayers.feature.Vector;
	import edu.psu.geovista.flexlayers.Control;
	import edu.psu.geovista.flexlayers.geometry.LineString;
	import edu.psu.geovista.flexlayers.geometry.Point;
	import flash.events.MouseEvent;
	import edu.psu.geovista.flexlayers.basetypes.Pixel;
	
	public class Path extends edu.psu.geovista.flexlayers.handler.Point
	{
		
		public var line:Vector = null;
    
    	public var freehand:Boolean = false;

    	public var freehandToggle:String = "shiftKey";
    	
    	public function Path (control:Control, callbacks:Object, options:Object, attributes:Object = null):void {
    		super(control, callbacks, options);
    	}

		override public function createFeature():void {
			this.line = new Vector(new LineString());
			
			this.point = new Vector(new edu.psu.geovista.flexlayers.geometry.Point());
		}
		
		public function destoryFeature():void {
			this.line.destroy();
			this.point.destroy();
		}
		
		public function addPoint():void {
			this.line.geometry.addComponent(this.point.geometry.clone(), this.line.geometry.components.length);
			
			this.callback("point", [this.point.geometry]);
		}
		
		public function freehandMode(evt:MouseEvent):Boolean {
			return (this.freehandToggle && evt[this.freehandToggle]) ? !this.freehand : this.freehand;
		}
		
		public function modifyFeature():void {
			var index = this.line.geometry.components.length - 1;
	        this.line.geometry.components[index].x = this.point.geometry.x;
	        this.line.geometry.components[index].y = this.point.geometry.y;
		}
		
		override public function drawFeature():void {
			this.layer.drawFeature(this.line, this.style);
			this.layer.drawFeature(this.point, this.style);
		}
		
		override public function geometryClone():Object {
			return this.line.geometry.clone();
		}
		
		override public function mousedown(evt:MouseEvent):Boolean {
			var xy:Pixel = this.map.accountForOffset(evt.stageX, evt.stageY);
	        if (this.lastDown && this.lastDown.equals(xy)) {
	            return false;
	        }
	        if(this.lastDown == null) {
	            this.createFeature();
	        }
	        this.mouseDown = true;
	        this.lastDown = xy;
	        var lonlat = this.control.map.getLonLatFromPixel(xy);
	        this.point.geometry.x = lonlat.lon;
	        this.point.geometry.y = lonlat.lat;
	        if((this.lastUp == null) || !this.lastUp.equals(xy)) {
	            this.addPoint();
	        }
	        this.drawFeature();
	        this.drawing = true;
	        return false;
		}
		
		override public function mousemove(evt:MouseEvent):Boolean {
			var xy:Pixel = this.map.accountForOffset(evt.stageX, evt.stageY);
			if(this.drawing) { 
	            var lonlat = this.map.getLonLatFromPixel(xy);
	            this.point.geometry.x = lonlat.lon;
	            this.point.geometry.y = lonlat.lat;
	            if(this.mouseDown && this.freehandMode(evt)) {
	                this.addPoint();
	            } else {
	                this.modifyFeature();
	            }
	            this.drawFeature();
	        }
	        return true;
		}
		
		override public function mouseup(evt:MouseEvent):Boolean {
			var xy:Pixel = this.map.accountForOffset(evt.stageX, evt.stageY);
			this.mouseDown = false;
	        if(this.drawing) {
	            if(this.freehandMode(evt)) {
	                this.finalize();
	            } else {
	                if(this.lastUp == null) {
	                   this.addPoint();
	                }
	                this.lastUp = xy;
	            }
	            return false;
	        }
	        return true;
		}
		
		override public function doubleclick(evt:MouseEvent):Boolean {
			if(!this.freehandMode(evt)) {
	            var index = this.line.geometry.components.length - 1;
	            this.line.geometry.removeComponent(this.line.geometry.components[index]);
	            this.finalize();
	        }
	        return false;
		}
		
		private var CLASS_NAME:String = "FlexLayers.Handler.Path";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}
	}
}