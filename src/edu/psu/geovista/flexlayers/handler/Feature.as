package edu.psu.geovista.flexlayers.handler
{
	import edu.psu.geovista.flexlayers.Handler;
	import edu.psu.geovista.flexlayers.feature.Vector;
	import edu.psu.geovista.flexlayers.layer.Vector;
	import edu.psu.geovista.flexlayers.Control;
	import flash.events.MouseEvent;

	public class Feature extends Handler
	{
		
		public var layerIndex:Number = NaN;

    	public var feature:edu.psu.geovista.flexlayers.feature.Vector = null;
    	
    	public var layer:edu.psu.geovista.flexlayers.layer.Vector = null;
    	
    	public function Feature(control:Control, layer:edu.psu.geovista.flexlayers.layer.Vector, callbacks:Object, options:Object = null):void {
    		super(control, callbacks, options);
    		this.layer = layer;
    	}
    	
    	public function mousedown(evt:MouseEvent):Boolean {
    		var selected = this.select("down", evt);
    		return !selected;
    	}
    	
    	public function mousemove(evt:MouseEvent):Boolean {
    		this.select("move", evt);
        	return true;
    	}
    	
    	public function mouseup(evt:MouseEvent):Boolean {
    		var selected = this.select("up", evt);
        	return !selected;
    	}
    	
    	public function doubleclick(evt:MouseEvent):Boolean {
    		var selected = this.select("doubleclick", evt);
        	return !selected;
    	}
    	
    	public function select(type:String, evt:MouseEvent):Boolean {
    		var feature = this.layer.getFeatureFromEvent(evt);
	        if(feature) {
	            if(!this.feature) {
	                this.callback("over", [feature]);
	            } else if(this.feature != feature) {
	                this.callback("out", [this.feature]);
	                this.callback("over", [feature]);
	            }
	            this.feature = feature;
	            this.callback(type, [feature]);
	            return true;
	        } else {
	            if(this.feature) {
	                // out of the last
	                this.callback("out", [this.feature]);
	                this.feature = null;
	            }
	            return false;
	        }
    	}
    	
    	override public function activate():Boolean {
	    	if(super.activate()) {
	            this.layerIndex = this.layer.canvas.zIndex;
	            this.layer.canvas.zIndex = this.map.Z_INDEX_BASE['Popup'] - 1;
	            return true;
	        } else {
	            return false;
	        }
    	}
    	
    	override public function deactivate():Boolean {
    		if(super.deactivate()) {
	            this.layer.canvas.zIndex = this.layerIndex;
	            return true;
	        } else {
	            return false;
	        }
    	}
	}
}