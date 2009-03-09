package edu.psu.geovista.flexlayers.tile
{
	import edu.psu.geovista.flexlayers.Tile;
	import edu.psu.geovista.flexlayers.Layer;
	import edu.psu.geovista.flexlayers.basetypes.Pixel;
	import edu.psu.geovista.flexlayers.basetypes.Bounds;
	import edu.psu.geovista.flexlayers.basetypes.Size;
	import edu.psu.geovista.flexlayers.RequestOL;
	import edu.psu.geovista.flexlayers.FlexLayers;
	import edu.psu.geovista.flexlayers.format.GML;
	import mx.rpc.events.ResultEvent;
	
	public class WFS extends Tile
	{
		
		private var features:Array = null;

    	private var urlW:String = null;
		
		
		public function WFS(layer:Layer, position:Pixel, bounds:Bounds, url:String, size:Size):void {
			super(layer, position, bounds, url, size);
			this.urlW = url;        
        	this.features = new Array();
		}
		
		override public function destroy():void {
			super.destroy();
	        this.destroyAllFeatures();
	        this.features = null;
	        this.urlW = null;
		}
		
		override public function clear():void {
			super.clear();
        	this.destroyAllFeatures();
		}
		
		override public function draw():Boolean {
			if (super.draw()) {
	            this.loadFeaturesForRegion(this.requestSuccess);
	        }
	        return null;
		}
		
		public function loadFeaturesForRegion(success:Function):void {
			FlexLayers.loadURL(this.url, null, this, success);
		}
		
		public function requestSuccess(result:ResultEvent):void {
			var doc:XML = result.result as XML;
			
	        if (this.layer.vectorMode) {
	            var gml = new GML({extractAttributes: this.layer.options.extractAttributes});
	            this.layer.addFeatures(gml.read(doc));
	        } else {
	            var resultFeatures = doc..*::featureMember;
	            this.addResults(resultFeatures);
	        }
		}
		
		public function addResults(results:Object):void {
			for (var i=0; i < results.length; i++) {
	            var feature = new this.layer.featureClass(this.layer, 
	                                                      results[i]);
	            this.features.push(feature);
	        }
		}
		
		public function destroyAllFeatures():void {
			while(this.features.length > 0) {
	            var feature = this.features.shift();
	            feature.destroy();
	        }
		}
		
		private var CLASS_NAME:String = "FlexLayers.Tile.WFS";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}
	}
}