package edu.psu.geovista.flexlayers.layer
{
	import edu.psu.geovista.flexlayers.Layer;
	import edu.psu.geovista.flexlayers.Renderer;
	import edu.psu.geovista.flexlayers.Util;
	import edu.psu.geovista.flexlayers.Map;
	import edu.psu.geovista.flexlayers.basetypes.Bounds;
	import edu.psu.geovista.flexlayers.feature.Vector;
	import flash.events.Event;
	import mx.controls.Alert;
	import flash.utils.getQualifiedClassName;
	import edu.psu.geovista.flexlayers.EventOL;
	import edu.psu.geovista.flexlayers.renderer.AS;
	import flash.events.MouseEvent;
	
	public class Vector extends Layer
	{

	    private var isVector:Boolean = true;
	
	    public var features:Array = null;

	    public var selectedFeatures:Array = null;
	
	    public var style:Object = null;
		
		private var renderers:Array = ['AS'];

	    public var renderer:Renderer = null;

	    private var geometryType:String = null;

	    private var drawn:Boolean = false;
	    
	    public var onFeatureInsert:Function = null;
	    
	    public var preFeatureInsert:Function = null;
	    
	    public function Vector(name:String, options:Object = null):void {
	    	var defaultStyle:Object = edu.psu.geovista.flexlayers.feature.Vector.style['default'];
	        this.style = Util.extend({}, defaultStyle);
	        
	        this.onFeatureInsert = new Function();
	        this.preFeatureInsert = new Function();
	
	        super(name, options);
	        
	        if (!this.renderer || !this.renderer.supported()) {  
	            this.assignRenderer();
	        }

	        if (!this.renderer || !this.renderer.supported()) {
	            this.renderer = null;
	            this.displayError();
	        } 
	
	        this.features = new Array();
	        this.selectedFeatures = new Array();
	    }
	    
	    override public function destroy(setNewBaseLayer:Boolean = true):void {
	        super.destroy();  
	
	        this.destroyFeatures();
	        this.features = null;
	        this.selectedFeatures = null;
	        if (this.renderer) {
	            this.renderer.destroy();
	        }
	        this.renderer = null;
	        this.geometryType = null;
	        this.drawn = false;
	    }
	    
	    private function assignRenderer():void {
	       	var rendererClass:Class = edu.psu.geovista.flexlayers.renderer.AS;
	     	this.renderer = new rendererClass(this.canvas);
	    }
	    
	    private function displayError():void {
	    	if (this.reportError) {
	            var message = "Your browser does not support vector rendering. " + 
	                            "Currently supported renderers are:\n";
	            message += this.renderers.join("\n");
	            Alert.show(message);
	        } 
	    }
	    
	    override public function setMap(map:Map):void {
	    	super.setMap(map);
	
	        if (!this.renderer) {
	            this.map.removeLayer(this);
	        } else {
	            this.renderer.map = this.map;
	            this.renderer.setSize(this.map.getSize());
	        }
	    }
	    
	    override public function onMapResize():void {
	    	super.onMapResize();
        	this.renderer.setSize(this.map.getSize());
	    }
	    
	    override public function moveTo(bounds:Bounds, zoomChanged:Boolean, dragging:Boolean = false):void {
	    	super.moveTo(bounds, zoomChanged, dragging);
	    	
	    	if (zoomChanged) {
	    		this.eraseFeatures(this.features);
	    	}
        
	        if (!dragging) {
	            this.canvas.x = - int(this.map.layerContainerCanvas.style.left);
	            this.canvas.y = - int(this.map.layerContainerCanvas.style.top);
	            var extent = this.map.getExtent();
	            this.renderer.setExtent(extent);
	        }
	
	        if (!this.drawn || zoomChanged) {
	            this.drawn = true;
	            for(var i = 0; i < this.features.length; i++) {
	                var feature = this.features[i];
	                this.drawFeature(feature);
	            }
	        }
	    }
	    
	    public function addFeatures(features:Object):void {
	    	if (!(features instanceof Array)) {
	            features = [features];
	        }
	
	        for (var i = 0; i < features.length; i++) {
	            var feature = features[i];
	            
	            if (this.geometryType &&
	                !(feature.geometry instanceof this.geometryType)) {
	                    var throwStr = "addFeatures : component should be an " + 
	                                    flash.utils.getQualifiedClassName(this.geometryType);
	                    throw throwStr;
	                }
	
	            this.features.push(feature);
	            
	            feature.layer = this;
	
	            if (!feature.style) {
	                feature.style = Util.extend({}, this.style);
	            }
	
	            this.preFeatureInsert(feature);
	
	            if (this.drawn) {
	                this.drawFeature(feature);
	            }
	            
	            this.onFeatureInsert(feature);
	        }
	    }
	    
	    public function removeFeatures(features:Object):void {
	    	if (!(features instanceof Array)) {
	            features = [features];
	        }
	
	        for (var i = features.length - 1; i >= 0; i--) {
	            var feature = features[i];
	            this.features = Util.removeItem(this.features, feature);
	
	            if (feature.geometry) {
	                this.renderer.eraseGeometry(feature.geometry);
	            }

	            if (Util.indexOf(this.selectedFeatures, feature) != -1){
	                Util.removeItem(this.selectedFeatures, feature);
	            }
	        }
	    }
	    
	    public function destroyFeatures():void {
	    	this.selectedFeatures = new Array();
	        for (var i = this.features.length - 1; i >= 0; i--) {
	            this.features[i].destroy();
	        }
	    }
	    
	    public function drawFeature(feature:edu.psu.geovista.flexlayers.feature.Vector, style:Object = null):void {
	    	if(style == null) {
	            if(feature.style) {
	                style = feature.style;
	            } else {
	                style = this.style;
	            }
	        }
	        this.renderer.drawFeature(feature, style);
	    }
	    
	    public function eraseFeatures(feature:Array):void {
	    	this.renderer.eraseFeatures(features);
	    }
	    
	    public function getFeatureFromEvent(evt:MouseEvent):edu.psu.geovista.flexlayers.feature.Vector {
	    	var featureId = this.renderer.getFeatureIdFromEvent(evt);
        	return this.getFeatureById(featureId);
	    }
	    
	    public function getFeatureById(featureId:String):edu.psu.geovista.flexlayers.feature.Vector {
	    	var feature:edu.psu.geovista.flexlayers.feature.Vector = null;
	        for(var i=0; i<this.features.length; ++i) {
	            if(this.features[i].id == featureId) {
	                feature = this.features[i];
	                break;
	            }
	        }
	        return feature;
	    }
	    
	    public function clearSelection():void {
	    	var vectorLayer = this.map.vectorLayer;
	        for (var i = 0; i < this.map.featureSelection.length; i++) {
	            var featureSelection = this.map.featureSelection[i];
	            vectorLayer.drawFeature(featureSelection, vectorLayer.style);
	        }
	        this.map.featureSelection = [];
	    }
	    
	    private var CLASS_NAME:String = "FlexLayers.Layer.Vector";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}
	    
	}
}