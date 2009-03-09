package edu.psu.geovista.flexlayers.control
{
	import edu.psu.geovista.flexlayers.Control;
	import edu.psu.geovista.flexlayers.Handler;
	import edu.psu.geovista.flexlayers.Util;
	import edu.psu.geovista.flexlayers.Geometry;
	import edu.psu.geovista.flexlayers.feature.Vector;
	import edu.psu.geovista.flexlayers.layer.Vector;

	public class DrawFeature extends Control
	{
		
		public var layer:edu.psu.geovista.flexlayers.layer.Vector = null;

    	public var callbacks:Object = null;

    	public var featureAdded:Function = function() {};

		public var handlerOptions:Object = null;

		public function DrawFeature(layer:edu.psu.geovista.flexlayers.layer.Vector, handler:Class, options:Object = null):void {
			super(options);
	        this.callbacks = Util.extend({done: this.drawFeature},
	                                                this.callbacks);
	        this.layer = layer;
	        this.handler = new handler(this, this.callbacks, this.handlerOptions);
		}
		
		public function drawFeature(geometry:Geometry):void {
			var feature:edu.psu.geovista.flexlayers.feature.Vector = new edu.psu.geovista.flexlayers.feature.Vector(geometry);
		    this.layer.addFeatures([feature]);
		    this.featureAdded(feature);
		}
		
		private var CLASS_NAME:String = "FlexLayers.Control.DrawFeature";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}
	}
}