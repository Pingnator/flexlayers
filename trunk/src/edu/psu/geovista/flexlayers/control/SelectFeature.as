package edu.psu.geovista.flexlayers.control
{
	import edu.psu.geovista.flexlayers.Control;
	import edu.psu.geovista.flexlayers.layer.Vector;
	import edu.psu.geovista.flexlayers.feature.Vector;
	import edu.psu.geovista.flexlayers.handler.Feature;
	import edu.psu.geovista.flexlayers.Util;

	public class SelectFeature extends Control
	{
	
		public var multiple:Boolean = false; 

    	public var hover:Boolean = false;
    
    	public var onSelect:Function = new Function();

    	public var onUnselect:Function = new Function();

    	public var layer:edu.psu.geovista.flexlayers.layer.Vector = null;

    	public var callbacks:Object = null;
    	
    	public var selectStyle:Object = edu.psu.geovista.flexlayers.feature.Vector.style['select'];

		public function SelectFeature(layer:edu.psu.geovista.flexlayers.layer.Vector, options:Object):void {
	        super([options]);
	        this.callbacks = Util.extend({
	                                                  down: this.downFeature,
	                                                  over: this.overFeature,
	                                                  out: this.outFeature
	                                                }, this.callbacks);
	        this.layer = layer;
	        this.handler = new Feature(this, layer, this.callbacks);
			
		}
		
		public function downFeature(feature:edu.psu.geovista.flexlayers.feature.Vector):void {
			if(this.hover) {
	            return;
	        }
	        if (this.multiple) {
	            if(Util.indexOf(this.layer.selectedFeatures, feature) > -1) {
	                this.unselect(feature);
	            } else {
	                this.select(feature);
	            }
	        } else {
	            if(Util.indexOf(this.layer.selectedFeatures, feature) > -1) {
	                this.unselect(feature);
	            } else {
	                if (this.layer.selectedFeatures) {
	                    for (var i = 0; i < this.layer.selectedFeatures.length; i++) {
	                        this.unselect(this.layer.selectedFeatures[i]);
	                    }
	                }
	                this.select(feature);
	            }
	        }
		}
		
		public function overFeature(feature:edu.psu.geovista.flexlayers.feature.Vector):void {
			if(!this.hover) {
	            return;
	        }
	        if(!(Util.indexOf(this.layer.selectedFeatures, feature) > -1)) {
	            this.select(feature);
	        }
		}
		
		public function outFeature(feature:edu.psu.geovista.flexlayers.feature.Vector):void {
			if(!this.hover) {
	            return;
	        }
	        this.unselect(feature);
		}
		
		public function select(feature:edu.psu.geovista.flexlayers.feature.Vector):void {
	        if(feature.originalStyle == null) {
	            feature.originalStyle = feature.style;
	        }
	        this.layer.selectedFeatures.push(feature);
	        this.layer.drawFeature(feature, this.selectStyle);
	        this.onSelect(feature);
		}
		
		public function unselect(feature:edu.psu.geovista.flexlayers.feature.Vector):void {
	        if(feature.originalStyle == null) {
	            feature.originalStyle = feature.style;
	        }
	        this.layer.drawFeature(feature, feature.originalStyle);
	        Util.removeItem(this.layer.selectedFeatures, feature);
	        this.onUnselect(feature);
		}
		
		override public function setMap(map:Object):void {
			this.handler.setMap(map);
			super.setMap(map);
		}
		
		private var CLASS_NAME:String = "FlexLayers.Control.SelectFeature";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}
	}
}