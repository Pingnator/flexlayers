package edu.psu.geovista.flexlayers.control
{
	import edu.psu.geovista.flexlayers.Control;
	import edu.psu.geovista.flexlayers.handler.MouseWheel;
	import edu.psu.geovista.flexlayers.handler.Click;
	import flash.events.MouseEvent;
	import edu.psu.geovista.flexlayers.Handler;
	import edu.psu.geovista.flexlayers.CanvasOL;
	import edu.psu.geovista.flexlayers.basetypes.Pixel;
	import edu.psu.geovista.flexlayers.basetypes.LonLat;

	public class Navigation extends Control
	{
		
		public var dragPan:DragPan = null;

    	//public var zoomBox:ZoomBox = null;

    	public var wheelHandler:MouseWheel = null;
    	
    	public var clickHandler:Handler = null;

    	public function Navigation(options:Object = null):void {
        	super(options);
    	}
    	
    	override public function destroy():void {
    		super.destroy();
    		this.deactivate();
	        this.dragPan.destroy();
	        this.wheelHandler.destroy();
	        this.clickHandler.destroy();
	        //this.zoomBox.destroy();
    	}
    	
    	override public function activate():Boolean {
    		this.dragPan.activate();
	        this.wheelHandler.activate();
	        this.clickHandler.activate();
	        //this.zoomBox.activate();
	        super.activate();
	        return true;
    	}
		
		override public function deactivate():Boolean {
			//this.zoomBox.deactivate();
	        this.dragPan.deactivate();
	        this.clickHandler.deactivate();
	        this.wheelHandler.deactivate();
	        super.deactivate();
	        return true;
		}
		
		override public function draw(px:Pixel = null, toSuper:Boolean = false):CanvasOL {
			this.clickHandler = new Click(this, 
	                                        { 'doubleClick': this.defaultDblClick },
	                                        {
	                                          'double': true, 
	                                          'stopDouble': true
	                                        });
	        this.dragPan = new DragPan({map: this.map});
	        //this.zoomBox = new ZoomBox(
	        //            {map: this.map, keyMask: Handler.MOD_SHIFT});
	        this.dragPan.draw();
	        //this.zoomBox.draw();
	        this.wheelHandler = new MouseWheel(
	                                    this, {"up"  : this.wheelUp,
	                                           "down": this.wheelDown} );
	        this.activate();
	        return null;
		}
		
		public function defaultDblClick(evt:MouseEvent):void {
			var newCenter = this.map.getLonLatFromViewPortPx( new Pixel(evt.stageX, evt.stageY) ); 
        	this.map.setCenter(newCenter, this.map.zoom + 1);
		}
		
		public function wheelChange(evt:MouseEvent, deltaZ):void {
			var newZoom = this.map.getZoom() + deltaZ;
	        if (!this.map.isValidZoomLevel(newZoom)) {
	            return;
	        }
	        var size    = this.map.getSize();
	        var deltaX  = size.w/2 - evt.stageX;
	        var deltaY  = evt.stageY - size.h/2;
	        var newRes  = this.map.baseLayer.resolutions[newZoom];
	        var zoomPoint = this.map.getLonLatFromPixel(new Pixel(evt.stageX, evt.stageY));
	        var newCenter = new LonLat(
	                            zoomPoint.lon + deltaX * newRes,
	                            zoomPoint.lat + deltaY * newRes );
	        this.map.setCenter( newCenter, newZoom );
		}
		
		public function wheelUp(evt:MouseEvent):void {
			this.wheelChange(evt, 1);
		}
		
		public function wheelDown(evt:MouseEvent):void {
			this.wheelChange(evt, -1);
		}
		
		private var CLASS_NAME:String = "FlexLayers.Control.Navigation";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}
	}
}