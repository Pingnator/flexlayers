package edu.psu.geovista.flexlayers.renderer
{
	import edu.psu.geovista.flexlayers.Renderer;
	import edu.psu.geovista.flexlayers.CanvasOL;
	import edu.psu.geovista.flexlayers.EventOL;
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	import edu.psu.geovista.flexlayers.SpriteOL;
	import mx.core.UIComponent;
	
	public class Elements extends Renderer
	{
		
		public var rendererRoot:CanvasOL = null;

	    public var root:CanvasOL = null;

	    public var xmlns:String = null;
	    
	    public function Elements(container:CanvasOL):void {
	    	super(container);

	        this.rendererRoot = this.createRendererRoot();
	        this.root = this.createRoot();
	        
	        this.rendererRoot.addChild(this.root);
	        this.container.addChild(this.rendererRoot);
	        
	       // this.container.addChild(this.root);
	    }
	    
	    override public function destroy():void {
	        this.clear(); 
	
	        this.rendererRoot = null;
	        this.root = null;
	        this.xmlns = null;
	
	        super.destroy();
	    }
	    
	    override public function clear():void {
	    	if (this.root) {
	            while (this.root.rawChildren.numChildren > 0) {
	            	this.root.rawChildren.removeChildAt(this.root.rawChildren.numChildren-1);
	            }
	        }
	    }
	    
	    public function getNodeType(geometry:Object):String {
	    	return null;
	    }
	    
	    override public function drawGeometry(geometry:Object, style:Object, featureId:String):Object {
		    if ((geometry.getClassName() == "FlexLayers.Geometry.MultiPoint") ||
	            (geometry.getClassName() == "FlexLayers.Geometry.MultiLineString") ||
	            (geometry.getClassName() == "FlexLayers.Geometry.MultiPolygon")) {
	            for (var i = 0; i < geometry.components.length; i++) {
	                this.drawGeometry(geometry.components[i], style, featureId);
	            }
	            return null;
	        };
	
	        //first we create the basic node and add it to the root
	        var nodeType = this.getNodeType(geometry);
	        var node:SpriteOL = this.nodeFactory(geometry.id, nodeType, geometry);
	        node._featureId = featureId;
	        node._geometryClass = geometry.getClassName();
	        node._style = style;
	        this.root.rawChildren.addChild(node);

	        this.drawGeometryNode(node, geometry);
	        
	        for (var i=0; i < this.map.controls.length; i++) {
	        	var control = this.map.controls[i];
	        	if (control.getClassName() == "FlexLayers.Control.SelectFeatureNeo") {
	        		if (control.active) {
	        			for (var func in control.handler.callbacks) {
	        				var callback = control.handler.callbacks[func];
	        				new EventOL().observe(node, MouseEvent.CLICK, callback); 
	        			}
	        		}
	        	}
	        }
	        
	        return node;
	    }
	    
	    override public function redrawGeometry(node:*, geometry:Object, style:Object, featureId:String):Object {
		    if ((geometry.getClassName() == "FlexLayers.Geometry.MultiPoint") ||
	            (geometry.getClassName() == "FlexLayers.Geometry.MultiLineString") ||
	            (geometry.getClassName() == "FlexLayers.Geometry.MultiPolygon")) {
	            for (var i = 0; i < geometry.components.length; i++) {
	                this.redrawGeometry(node, geometry.components[i], style, featureId);
	            }
	            return null;
	        };

	        this.drawGeometryNode(node, geometry, style);
	        
	        return node;
	    }
	    
	    override public function moveGeometry(geometry:Object):void {
	    	var node = this.root.rawChildren.getChildAt(this.root.rawChildren.numChildren - 1);
	    	this.moveGeometryNode(node, geometry);
	    }
	    
	    public function moveGeometryNode(node:SpriteOL, geometry:Object):void {
	    	node.graphics.clear();
	    	this.drawGeometryNode(node, geometry);
	    }
    
    	public function drawGeometryNode(node:SpriteOL, geometry:Object, style:Object = null):void {
    		style = style || node._style;

	        var options = {
	            'isFilled': true,
	            'isStroked': true
	        };
	        
	        if (geometry.getClassName() == "FlexLayers.Geometry.LineString") {
	        	options.isFilled = false;
	        }
	        
	        this.setStyle(node, style, options);
	        
	        switch (geometry.getClassName()) {
	            case "FlexLayers.Geometry.Point":
	                this.drawPoint(node, geometry);
	                break;
	            case "FlexLayers.Geometry.LineString":
	                this.drawLineString(node, geometry);
	                break;
	            case "FlexLayers.Geometry.LinearRing":
	                this.drawLinearRing(node, geometry);
	                break;
	            case "FlexLayers.Geometry.Polygon":
	                this.drawPolygon(node, geometry);
	                break;
	            case "FlexLayers.Geometry.Surface":
	                this.drawSurface(node, geometry);
	                break;
	            case "FlexLayers.Geometry.Rectangle":
	                this.drawRectangle(node, geometry);
	                break;
	            default:
	                break;
	        }
	        
	        this.removeStyle(node, style, options);
	
	        node._style = style; 
	        node._options = options; 
    	}
    
		public function setStyle(node:SpriteOL, style:Object, options:Object):void {	
	        style = style  || node._style;
	        options = options || node._options;
	
	        if (node._geometryClass == "FlexLayers.Geometry.Point") {
	            node.attributes.r = style.pointRadius;
	        }
	        
	        if (options.isFilled) {
	            node.attributes.fill = style.fillColor;
	            node.attributes.fillOpacity = style.fillOpacity;
	        } else {
	            node.attributes.fill = "none";
	        }
	
	        if (options.isStroked) {
	            node.attributes.stroke = style.strokeColor;
	            node.attributes.strokeOpacity = style.strokeOpacity;
	            node.attributes.strokeWidth = style.strokeWidth;
	            node.attributes.strokeLinecap = style.strokeLinecap;
	        } else {
	            node.attributes.stroke = "none";
	        }
	        
	        if (style.pointerEvents) {
	            node.attributes.pointerEvents = style.pointerEvents;
	        }
	        
	        if (style.cursor) {
	            node.attributes.cursor = style.cursor;
	        }
		}
		
		public function removeStyle(node:SpriteOL, style:Object, options:Object):void {};
		
        public function drawPoint(node:SpriteOL, geometry:Object):void {};
        public function drawLineString(node:SpriteOL, geometry:Object):void {};
        public function drawLinearRing(node:SpriteOL, geometry:Object):void {};
        public function drawPolygon(node:SpriteOL, geometry:Object):void {};
        public function drawRectangle(node:SpriteOL, geometry:Object):void {};
        public function drawCircle(node:SpriteOL, geometry:Object, radius:Number):void {};
        public function drawCurve(node:SpriteOL, geometry:Object):void {};
        public function drawSurface(node:SpriteOL, geometry:Object):void {};
    
    	override public function getFeatureIdFromEvent(evt:MouseEvent):String {
	        var node = evt.currentTarget;
	        return node._featureId;
    	}
    	
    	override public function eraseGeometry(geometry:Object):void {
    		if ((geometry.getClassName() == "FlexLayers.Geometry.MultiPoint") ||
	            (geometry.getClassName() == "FlexLayers.Geometry.MultiLineString") ||
	            (geometry.getClassName() == "FlexLayers.Geometry.MultiPolygon")) {
	            for (var i = 0; i < geometry.components.length; i++) {
	                this.eraseGeometry(geometry.components[i]);
	            }
	        } else {    
	            var element = geometry.id;
	            if (element && element.parent) {
	                if (element.geometry) {
	                    element.geometry.destroy();
	                    element.geometry = null;
	                }
	                element.parent.removeChild(element);
	            }
	        }
	    }
	    
	    public function nodeFactory(id:String, type:String, geometry:Object):SpriteOL {
	    	var node = this.root.getChildByName(id);
	        if (node) {
	            if (!this.nodeTypeCompare(node, type)) {
	                node.parent.removeChild(node);
	                node = this.nodeFactory(id, type, geometry);
	            }
	        } else {
	            node = this.createNode(type, id);
	        }
	        return node;
	    }

		public function nodeTypeCompare(node:SpriteOL, type:String):Boolean {
			return null;
		}
		
		public function createNode(type:Object, id:Object):SpriteOL { 
			return null;
		}
	    
	    public function createRendererRoot():CanvasOL {	
			return null; 
		}
		
		public function createRoot():CanvasOL {
			return null;
		}
		
		private var CLASS_NAME:String = "FlexLayers.Renderer.Elements";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}
    
	}
}