package edu.psu.geovista.flexlayers.geometry
{
	import edu.psu.geovista.flexlayers.Geometry;

	public class Surface extends Geometry
	{
		
		public function Surface():void {
			super();
		}
		
		private var CLASS_NAME:String = "FlexLayers.Geometry.Surface";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}
		
	}
}