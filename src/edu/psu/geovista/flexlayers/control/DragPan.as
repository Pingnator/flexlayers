package edu.psu.geovista.flexlayers.control
{
	import edu.psu.geovista.flexlayers.Control;
	import edu.psu.geovista.flexlayers.handler.Drag;
	import edu.psu.geovista.flexlayers.basetypes.Pixel;
	import edu.psu.geovista.flexlayers.CanvasOL;

	public class DragPan extends Control
	{
		
		public var ctype:int = Control.TYPE_TOOL;

    	public var panned:Boolean = false;
    	
    	public var done:Boolean = false;
    	
    	public var move:Boolean = false;
    	
    	public function DragPan(options:Object = null):void {
    		super(options);
    	}
    	
    	override public function draw(px:Pixel = null, toSuper:Boolean = false):CanvasOL {
    		this.handler = new Drag(this,
                            {"move": this.panMap, "done": this.panMapDone});
            return null;
    	}
    	
    	public function panMap(xy:Pixel):void {
    		this.panned = true;
	        var deltaX = this.handler.last.x - xy.x;
	        var deltaY = this.handler.last.y - xy.y;
	        var size = this.map.getSize();
	        var newXY = new Pixel(size.w / 2 + deltaX,
	                                         size.h / 2 + deltaY);
	        var newCenter = this.map.getLonLatFromViewPortPx( newXY );
	        this.map.setCenter(newCenter, NaN, this.handler.dragging);
    	}
    	
    	public function panMapDone(xy:Pixel):void {
    		if(this.panned) {
	            this.panMap(xy);
	            this.panned = false;
	        }
    	}
    	
    	private var CLASS_NAME:String = "FlexLayers.Control.DragPan";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}
		
	}
}