package edu.psu.geovista.flexlayers
{
	import flash.display.Sprite;

	public class SpriteOL extends Sprite
	{
		
		public var id:String = null;
		public var attributes:Object = new Object();
		public var _featureId = null;
		public var _geometryClass = null;
		public var _style:Object = new Object();
		public var _options:Object = new Object();
		public var type:String = null;
		public var classNameOL:String = null;
		public var feature:Feature = null;
		public var popup:PopupOL = null;
		public var geometry:Geometry = null;
		public var _eventCacheID:Object = null;
		
	}
}