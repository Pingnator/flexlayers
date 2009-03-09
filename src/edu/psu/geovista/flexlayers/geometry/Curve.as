package edu.psu.geovista.flexlayers.geometry
{
	public class Curve extends MultiPoint
	{
		
		private var componentTypes:Array = ["FlexLayers.Geometry.Point"];
		
		public function Curve(points:Object):void {
			super(points);
		}
		
		override public function getLength():Number {
			var length = 0.0;
	        if ( this.components && (this.components.length > 1)) {
	            for(var i=1; i < this.components.length; i++) {
	                length += this.components[i-1].distanceTo(this.components[i]);
	            }
	        }
	        return length;
		}
		
		private var CLASS_NAME:String = "FlexLayers.Geometry.Curve";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}
		
		override public function getComponentTypes():Array {
			return componentTypes;
		}
	}
}