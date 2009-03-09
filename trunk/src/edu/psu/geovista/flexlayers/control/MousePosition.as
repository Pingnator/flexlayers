package edu.psu.geovista.flexlayers.control
{
	import edu.psu.geovista.flexlayers.Control;
	import edu.psu.geovista.flexlayers.CanvasOL;
	import flash.events.Event;
	import mx.controls.Label;
	import edu.psu.geovista.flexlayers.Map;
	import flash.events.MouseEvent;
	import edu.psu.geovista.flexlayers.basetypes.Pixel;
	import edu.psu.geovista.flexlayers.basetypes.LonLat;

	public class MousePosition extends Control
	{
		
		public var element:CanvasOL = null;
		
		public var label:Label = null;

    	public var prefix:String = "";
    	
    	public var separator:String = ", ";
    
    	public var suffix:String = "";

 	   	public var numdigits:Number = 5;
 
    	public var granularity:int = 10;
    	
    	public var lastXy:Pixel = null;
    	  	
    	public function MousePosition(options:Object = null):void {
    		super(options);
    	}
    	
    	override public function draw(px:Pixel = null, toSuper:Boolean = false):CanvasOL {
	    	super.draw(px);
	
	        if (!toSuper) {
		        if (!this.element) {
		            this.canvas.x = this.map.can.width - 150;
		            this.canvas.y = this.map.can.height - 30;
		            this.canvas.classNameOL = this.displayClass;
		            this.element = this.canvas;
		            this.label = new Label();
		            this.element.addChild(label);
		        }
	        
	        	this.redraw();
	        }
	        return this.canvas;
    	}
    	
    	public function redraw(evt:MouseEvent = null):void {
    		var lonLat:LonLat;

	        if (evt == null) {
	            lonLat = new LonLat(0, 0);
	        } else {
	            if (this.lastXy == null ||
	                Math.abs(evt.localX - this.lastXy.x) > this.granularity ||
	                Math.abs(evt.localY - this.lastXy.y) > this.granularity)
	            {
	                this.lastXy = new Pixel(evt.localX, evt.localY);
	                return;
	            }
	
	            lonLat = this.map.getLonLatFromPixel(new Pixel(evt.localX, evt.localY));
	            this.lastXy = new Pixel(evt.localX, evt.localY);
	        }
	        
	        var digits = int(this.numdigits);
	        var newHtml =
	            this.prefix +
	            lonLat.lon.toFixed(digits) +
	            this.separator + 
	            lonLat.lat.toFixed(digits) +
	            this.suffix;
	
	        if (newHtml != this.label.htmlText) {
	            this.label.htmlText = newHtml;
	        }
    	}
		
		override public function setMap(map:Object):void {
			super.setMap(map);
			this.map.events.register(MouseEvent.MOUSE_MOVE, this, this.redraw);
		}
		
		private var CLASS_NAME:String = "FlexLayers.Control.MousePosition";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}
	}
}