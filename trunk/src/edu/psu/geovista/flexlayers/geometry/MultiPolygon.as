package edu.psu.geovista.flexlayers.geometry
{
	public class MultiPolygon extends Collection
	{
		
		private var componentTypes:Array = ["FlexLayers.Geometry.Polygon"];
		
		public function MultiPolygon(components:Object = null):void {
			super(components);
		}
		
		private var CLASS_NAME:String = "FlexLayers.Geometry.MultiPolygon";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}
		
		override public function getComponentTypes():Array {
			return componentTypes;
		}
		
	}
}