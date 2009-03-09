package edu.psu.geovista.flexlayers
{
	import edu.psu.geovista.flexlayers.basetypes.Size;
	import edu.psu.geovista.flexlayers.basetypes.Bounds;
	import edu.psu.geovista.flexlayers.feature.Vector;
	import flash.events.MouseEvent;
	import edu.psu.geovista.flexlayers.basetypes.LonLat;
	
	public class Renderer
	{
		
		public var container:CanvasOL = null;
		
	    public var extent:Bounds = null;
	    
	    public var size:Size = null;
	    
	    public var resolution:Number;

	    public var map:Object = null;
	    
	    public function Renderer(container:CanvasOL):void {
	    	this.container = container;
	    }
	    
	    public function destroy():void {
	    	this.container = null;
	        this.extent = null;
	        this.size =  null;
	        this.resolution = null;
	        this.map = null;
	    }
	    
	    public function supported():Boolean {
	    	return false;
	    }
	    
	    public function setExtent(extent:Bounds):void {
	    	this.extent = extent.clone();
        	this.resolution = null;
	    }
	    
	    public function setSize(size:Size):void {
        	this.size = size.clone();
        	this.resolution = null;
	    }
		
		public function getResolution():Number {
			this.resolution = this.resolution || this.map.getResolution();
        	return this.resolution;
		}
		
		public function drawFeature(feature:Vector, style:Object):void {
			if(style == null) {
	            style = feature.style;
	        }
	        var node = this.drawGeometry(feature.geometry, style, feature.id);
		}
		
		public function redrawFeature(feature:Vector, style:Object):void {
			if(style == null) {
	            style = feature.style;
	        }
	        this.clearNode(feature.node);
	        this.redrawGeometry(feature.node, feature.geometry, style, feature.id);
		}
		
		public function moveFeature(feature:Vector):void {
			this.moveGeometry(feature.geometry);
		}
		
		public function drawGeometry(geometry:Object, style:Object, featureId:String):Object {
			return null;
		}
		
		public function redrawGeometry(node:*, geometry:Object, style:Object, featureId:String):Object {
			return null;
		}
		
		public function moveGeometry(geometry:Object):void {
		}
		
		public function clearNode(node:Object):void {
			
		}
		
		public function clear():void {
			
		}
		
		public function getFeatureIdFromEvent(evt:MouseEvent):String {
			return null;
		}
		
		public function eraseFeatures(features:Object):void {
			if(!(features is Array)) {
	            features = [features];
	        }
	        for(var i=0; i<features.length; ++i) {
	            this.eraseGeometry(features[i].geometry);
	        }
		}
		
		public function eraseGeometry(geometry:Object):void {
			
		}
		
		private var CLASS_NAME:String = "FlexLayers.Renderer";
		
		public function getClassName():String {
			return CLASS_NAME;
		}
	}
}