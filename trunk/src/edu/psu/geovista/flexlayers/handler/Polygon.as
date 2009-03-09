package edu.psu.geovista.flexlayers.handler
{
	import edu.psu.geovista.flexlayers.feature.Vector;
	import edu.psu.geovista.flexlayers.Control;
	import edu.psu.geovista.flexlayers.geometry.LinearRing;
	import flash.events.MouseEvent;
	
	public class Polygon extends Path
	{
		
		public var polygon:Vector = null;
		
		public function Polygon(control:Control, callbacks:Object, options:Object, attributes:Object = null):void {
			super(control, callbacks, options);
		}
		
		override public function createFeature():void {
	        this.polygon = new Vector(new edu.psu.geovista.flexlayers.geometry.Polygon());
	        this.line = new Vector(new LinearRing());
	        this.polygon.geometry.addComponent(this.line.geometry);
	        this.point = new Vector(new edu.psu.geovista.flexlayers.geometry.Point());
		}
		
		override public function destoryFeature():void {
			this.polygon.destroy();
	        this.point.destroy();
		}
		
		override public function modifyFeature():void {
			var index = this.line.geometry.components.length - 2;
	        this.line.geometry.components[index].x = this.point.geometry.x;
	        this.line.geometry.components[index].y = this.point.geometry.y;
		}
		
		override public function drawFeature():void {
			this.layer.drawFeature(this.polygon, this.style);
	        this.layer.drawFeature(this.point, this.style);
		}
		
		override public function geometryClone():Object {
			return this.polygon.geometry.clone();
		}
		
		override public function doubleclick(evt:MouseEvent):Boolean {
			if(!this.freehandMode(evt)) {
	            var index = this.line.geometry.components.length - 2;
	            this.line.geometry.removeComponent(this.line.geometry.components[index]);
	            this.finalize();
	        }
	        return false;
		}
		
		private var CLASS_NAME:String = "FlexLayers.Handler.Polygon";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}
	}
}