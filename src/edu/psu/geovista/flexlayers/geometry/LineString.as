package edu.psu.geovista.flexlayers.geometry
{
	import edu.psu.geovista.flexlayers.Geometry;
	
	public class LineString extends Curve
	{
		
		public function LineString(points:Object = null):void {
			super(points);
		}
		
		override public function removeComponent(point:Object):void {
	        if ( this.components && (this.components.length > 2)) {
	            super.removeComponent(point);
	        }
		}
		
		private var CLASS_NAME:String = "FlexLayers.Geometry.LineString";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}
		
	}
}