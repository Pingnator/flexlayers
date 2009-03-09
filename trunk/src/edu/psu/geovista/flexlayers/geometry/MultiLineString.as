package edu.psu.geovista.flexlayers.geometry
{
	public class MultiLineString extends Collection
	{
		
		private var componentTypes:Array = ["FlexLayers.Geometry.LineString"];
		
		public function MultiLineString(components:Object = null):void {
			super(components);
		}
		
		private var CLASS_NAME:String = "FlexLayers.Geometry.MultiLineString";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}
		
		override public function getComponentTypes():Array {
			return componentTypes;
		}
	}
}