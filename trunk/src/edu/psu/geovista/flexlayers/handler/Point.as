package edu.psu.geovista.flexlayers.handler
{
	import edu.psu.geovista.flexlayers.Handler;
	import edu.psu.geovista.flexlayers.feature.Vector;
	import edu.psu.geovista.flexlayers.layer.Vector;
	import edu.psu.geovista.flexlayers.basetypes.Pixel;
	import edu.psu.geovista.flexlayers.Control;
	import edu.psu.geovista.flexlayers.Util;
	import edu.psu.geovista.flexlayers.geometry.Point;
	import flash.events.MouseEvent;

	public class Point extends Handler
	{
		
		public var point:edu.psu.geovista.flexlayers.feature.Vector = null;

    	public var layer:edu.psu.geovista.flexlayers.layer.Vector = null;

    	public var drawing:Boolean = false;

    	public var mouseDown:Boolean = false;

    	public var lastDown:Pixel = null;

    	public var lastUp:Pixel = null;

		public function Point(control:Control = null, callbacks:Object = null, options:Object = null):void {
			this.style = Util.extend(edu.psu.geovista.flexlayers.feature.Vector.style['default'], {});

       		super(control, callbacks, options);
		}
		
		override public function activate():Boolean {
			if(!super.activate()) {
	            return false;
	        }
	        var options = {displayInLayerSwitcher: false};
	        this.layer = new edu.psu.geovista.flexlayers.layer.Vector(this.CLASS_NAME, options);
	        this.map.addLayer(this.layer);
	        
	        return true;
		}
		
		public function createFeature():void {
	        this.point = new edu.psu.geovista.flexlayers.feature.Vector(
                                      new edu.psu.geovista.flexlayers.geometry.Point());
		}
		
		override public function deactivate():Boolean {
			if(!super.deactivate()) {
		        return false;
		    }
		    if(this.drawing) {
		        this.cancel();
		    }
		    this.map.removeLayer(this.layer, false);
		    this.layer.destroy();
		    return true;
		}
		
		public function destroyFeature():void {
			this.point.destroy();
		}
		
		public function finalize():void {
			this.layer.renderer.clear();
	        this.callback("done", [this.geometryClone()]);
	        this.destroyFeature();
	        this.drawing = false;
	        this.mouseDown = false;
	        this.lastDown = null;
	        this.lastUp = null;
		}
		
		public function cancel():void {
			this.layer.renderer.clear();
	        this.callback("cancel", [this.geometryClone()]);
	        this.destroyFeature();
	        this.drawing = false;
	        this.mouseDown = false;
	        this.lastDown = null;
	        this.lastUp = null;
		}
		
		public function doubleclick(evt:MouseEvent):Boolean {
			evt.stopPropagation();
	        return false;
		}
		
		public function drawFeature():void {
			this.layer.drawFeature(this.point, this.style);
		}
		
		public function geometryClone():Object {
			return this.point.geometry.clone();
		}
		
		public function mousedown(evt:MouseEvent):Boolean {
		    if(!this.checkModifiers(evt)) {
	            return true;
	        }
	        var xy:Pixel = this.map.accountForOffset(evt.stageX, evt.stageY);
	        if(this.lastDown && this.lastDown.equals(xy)) {
	            return true;
	        }
	        if(this.lastDown == null) {
	            this.createFeature();
	        }
	        this.lastDown = xy;
	        this.drawing = true;
	        var lonlat = this.map.getLonLatFromPixel(xy);
	        this.point.geometry.x = lonlat.lon;
	        this.point.geometry.y = lonlat.lat;
	        this.drawFeature();
	        return false;
		}
		
		public function mousemove(evt:MouseEvent):Boolean {
			if(this.drawing) {
				var xy:Pixel = this.map.accountForOffset(evt.stageX, evt.stageY);
	            var lonlat = this.map.getLonLatFromPixel(xy);
	            this.point.geometry.x = lonlat.lon;
	            this.point.geometry.y = lonlat.lat;
	            this.drawFeature();
	        }
	        return true;
		}
		
		public function mouseup(evt:MouseEvent):Boolean {
			if(this.drawing) {
	            this.finalize();
	            return false;
	        } else {
	            return true;
	        }
		}
		
		private var CLASS_NAME:String = "FlexLayers.Handler.Point";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}
	}
}