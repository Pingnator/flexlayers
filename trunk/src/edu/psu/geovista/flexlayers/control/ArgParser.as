package edu.psu.geovista.flexlayers.control
{
	import edu.psu.geovista.flexlayers.Control;
	import edu.psu.geovista.flexlayers.basetypes.LonLat;
	import edu.psu.geovista.flexlayers.Map;
	import edu.psu.geovista.flexlayers.Util;
	import edu.psu.geovista.flexlayers.Layer;
	
	public class ArgParser extends Control
	{
		
		private var center:LonLat = null;
		private var zoom:int = -1;
		private var layers:Array = null;
		
		public function ArgParser(element:Object = null, base:String = null):void {
			var options:Object = {element: element, base: base};
			super(options);
		}
		
		override public function setMap(map:Map):void {
			super.setMap(map);

	        for(var i=0; i< this.map.controls.length; i++) {
	            var control = this.map.controls[i];
	            if ( (control != this) &&
	                 (control.CLASS_NAMEA == "ArgParser") ) {
	                break;
	            }
	        }
	        if (i == this.map.controls.length) {
	
	            var args = Util.getArgs();
	            if (args.lat && args.lon) {
	                this.center = new LonLat(parseFloat(args.lon),
	                                                    parseFloat(args.lat));
	                if (args.zoom) {
	                    this.zoom = parseInt(args.zoom);
	                }
	    
	                // when we add a new baselayer to see when we can set the center
	                this.map.events.register('changebaselayer', this, 
	                                         this.setCenter);
	                this.setCenter();
	            }
	    
	            if (args.layers) {
	                this.layers = args.layers;
	    
	                // when we add a new layer, set its visibility 
	                this.map.events.register('addlayer', this, 
	                                         this.configureLayers);
	                this.configureLayers();
	            }
	        }
		}
		
		public function setCenter():void {
			if (this.map.baseLayer) {
	            this.map.events.unregister('changebaselayer', this, 
	                                       this.setCenter);
	                                       
	            this.map.setCenter(this.center, this.zoom);
	        }
		}
		
		public function configureLayers():void {
	        if (this.layers.length == this.map.layers.length) { 
	            this.map.events.unregister('addlayer', this, this.configureLayers);
	
	            for(var i:int=0; i < this.layers.length; i++) {
	                
	                var layer:Layer = this.map.layers[i];
	                var c:String = this.layers.charAt(i);
	                
	                if (c == "B") {
	                    this.map.setBaseLayer(layer);
	                } else if ( (c == "T") || (c == "F") ) {
	                    layer.setVisibility(c == "T");
	                }
	            }
	        }
		}
		
		private var CLASS_NAME:String = "FlexLayers.Control.ArgParser";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}
		
	}
}