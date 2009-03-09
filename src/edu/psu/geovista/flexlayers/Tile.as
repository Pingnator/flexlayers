package edu.psu.geovista.flexlayers
{
	import mx.controls.Image;
	import edu.psu.geovista.flexlayers.basetypes.Pixel;
	import edu.psu.geovista.flexlayers.basetypes.Size;
	import edu.psu.geovista.flexlayers.basetypes.Bounds;

	public class Tile
	{
		
		public var EVENT_TYPES:Array = ["loadstart", "loadend", "reload"];
		public var events:Events = null;
		public var id:String = null;
		public var layer:Object = null;
		public var url:String = null;
		public var bounds:Bounds = null;
		public var size:Size = null;
		public var position:Pixel = null;
		public var drawn:Boolean = false;
		public var postBody:Object = null;
		public var BBOX:Bounds = null;
		public var onLoadStart:Function = null;
		public var onLoadEnd:Function = null;
		
		public function Tile(layer:Layer, position:Pixel, bounds:Bounds, url:String, size:Size, params:Object = null):void {
			this.layer = layer;
	        this.position = position;
	        this.bounds = bounds;
	        this.url = url;
	        this.size = size;
	        if (params != null) {
	        	this.postBody = params.postBody;
	        	this.BBOX = params.BBOX;
	        }

	        this.id = Util.createUniqueID("Tile_");
	        
	        this.events = new Events(this, null, this.EVENT_TYPES);
		}
		
		public function destroy():void {
			this.layer = null;
	        this.bounds = null;
	        this.size = null;
	        this.position = null;
	        
	        this.events.destroy();
	        this.events = null;
		}
		
		public function draw():Boolean {
	        this.clear();
        	return ((this.layer.displayOutsideMaxExtent
                || (this.layer.maxExtent
                    && this.bounds.intersectsBounds(this.layer.maxExtent, false)))
                && !(this.layer.buffer == 0
                     && !this.bounds.intersectsBounds(this.layer.map.getExtent(), false)));
		}
		
		public function moveTo(bounds:Bounds, position:Pixel, redraw:Boolean = true):void {
	
	        this.clear();
	        this.bounds = bounds.clone();
	        this.position = position.clone();
	        if (redraw) {
	            this.draw();
	        }	
		}
		
		public function clear():void {
			this.drawn = false;
		}
		
		public function getBoundsFromBaseLayer(position:Pixel):Bounds {
			var topLeft = this.layer.map.getLonLatFromLayerPx(position); 
	        var bottomRightPx = position.clone();
	        bottomRightPx.x += this.size.w;
	        bottomRightPx.y += this.size.h;
	        var bottomRight = this.layer.map.getLonLatFromLayerPx(bottomRightPx); 
	        if (topLeft.lon > bottomRight.lon) {
	            if (topLeft.lon < 0) {
	                topLeft.lon = -180 - (topLeft.lon+180);
	            } else {
	                bottomRight.lon = 180+bottomRight.lon+180;
	            }        
	        }
	        bounds = new Bounds(topLeft.lon, bottomRight.lat, bottomRight.lon, topLeft.lat);  
	        return bounds;
		}
		
		private var CLASS_NAME:String = "FlexLayers.TileNeo";
		
		public function getClassName():String {
			return CLASS_NAME;
		}
	}
}