package edu.psu.geovista.flexlayers
{
	import mx.controls.CheckBox;

	public class CheckBoxOL extends CheckBox
	{
		
		public var _eventCacheID:String;
		public var context:Object;
		
		private var CLASS_NAME:String = "FlexLayers.CheckBoxOL";
		
		public function getClassName():String {
			return CLASS_NAME;
		}
	}
}