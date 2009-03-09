package edu.psu.geovista.flexlayers.control
{
	import edu.psu.geovista.flexlayers.Control;
	import edu.psu.geovista.flexlayers.handler.Box;
	import edu.psu.geovista.flexlayers.basetypes.Bounds;
	import edu.psu.geovista.flexlayers.basetypes.Pixel;
	import edu.psu.geovista.flexlayers.CanvasOL;

	public class ZoomBox extends Control
	{
		
		public var ctype:int = Control.TYPE_TOOL;

    	public var out:Boolean = false;
    	
    	public function ZoomBox(options:Object = null):void {
    		
    	}
    	
    	override public function draw(px:Pixel = null, toSuper:Boolean = false):CanvasOL {
    		this.handler = new Box( this,
                            {done: this.zoomBox}, {keyMask: this.keyMask} );
            return null;
    	}
    	
    	public function zoomBox(position:*):void {
    		if (position is Bounds) {
	            if (!this.out) {
	                var minXY = this.map.getLonLatFromPixel(
	                            new Pixel(position.left, position.bottom));
	                var maxXY = this.map.getLonLatFromPixel(
	                            new Pixel(position.right, position.top));
	                var bounds = new Bounds(minXY.lon, minXY.lat,
	                                               maxXY.lon, maxXY.lat);
	            } else {
	                var pixWidth = Math.abs(position.right-position.left);
	                var pixHeight = Math.abs(position.top-position.bottom);
	                var zoomFactor = Math.min((this.map.size.h / pixHeight),
	                    (this.map.size.w / pixWidth));
	                var extent = map.getExtent();
	                var center = this.map.getLonLatFromPixel(
	                    position.getCenterPixel());
	                var xmin = center.lon - (extent.getWidth()/2)*zoomFactor;
	                var xmax = center.lon + (extent.getWidth()/2)*zoomFactor;
	                var ymin = center.lat - (extent.getHeight()/2)*zoomFactor;
	                var ymax = center.lat + (extent.getHeight()/2)*zoomFactor;
	                var bounds = new Bounds(xmin, ymin, xmax, ymax);
	            }
	            this.map.zoomToExtent(bounds);
	        } else { // it's a pixel
	            if (!this.out) {
	                this.map.setCenter(this.map.getLonLatFromPixel(position),
	                               this.map.getZoom() + 1);
	            } else {
	                this.map.setCenter(this.map.getLonLatFromPixel(position),
	                               this.map.getZoom() - 1);
	            }
	        }
    	}
    	
    	private var CLASS_NAME:String = "FlexLayers.Control.ZoomBox";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}
		
	}
}