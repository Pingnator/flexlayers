package edu.psu.geovista.flexlayers.geometry
{
	import edu.psu.geovista.flexlayers.Geometry;
	
	public class LinearRing extends LineString
	{
		
		private var componentTypes:Array = ["FlexLayers.Geometry.Point"];
		
		public function LinearRing(points:Array = null):void {
			super(points);
		}
		
		override public function addComponent(point:Object, index:Number=NaN):Boolean {
			var added = false;

	        var lastPoint = this.components[this.components.length-1];
	        super.removeComponent([lastPoint]);
	
	        if(index != NaN || !point.equals(lastPoint)) {
	            added = super.addComponent(point, index);
	        }

	        var firstPoint = this.components[0];
	        super.addComponent([firstPoint.clone()]);
	
	        return added;
		}
		
		private var CLASS_NAME:String = "FlexLayers.Geometry.LinearRing";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}
		
		override public function getComponentTypes():Array {
			return componentTypes;
		}
		
	}
}