package edu.psu.geovista.flexlayers
{
	import edu.psu.geovista.flexlayers.feature.Vector;
	import mx.controls.Alert;
	
	public class Format
	{
		
		public function Format(options:Object = null):void {
			Util.extend(this, options);
		}
		
		public function read(data:Object):Object {
			Alert.show("Read not implemented.");
			return null;
		}
		
		public function write(features:Object):Object {
			Alert.show("Write not implemented.");
			return null;
		}
		
		private var CLASS_NAME:String = "FlexLayers.Format";
		
		public function getClassName():String {
			return CLASS_NAME;
		}
		
	}
}