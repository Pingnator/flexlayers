package edu.psu.geovista.flexlayers.geometry
{
	public class Polygon extends Collection
	{
		
		private var componentTypes:Array = ["FlexLayers.Geometry.LinearRing"];
		
		public function Polygon(components:Object = null):void {
			super(components);
		}
		
		override public function getArea():Number {
			var area = 0.0;
	        if ( this.components && (this.components.length > 0)) {
	            area += Math.abs(this.components[0].getArea());
	            for (var i = 1; i < this.components.length; i++) {
	                area -= Math.abs(this.components[i].getArea());
	            }
	        }
	        return area;
		}
		
		private var CLASS_NAME:String = "FlexLayers.Geometry.Polygon";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}
		
		override public function getComponentTypes():Array {
			return componentTypes;
		}
		
	}
}