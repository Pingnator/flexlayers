package edu.psu.geovista.flexlayers.renderer
{
	import edu.psu.geovista.flexlayers.CanvasOL;
	import edu.psu.geovista.flexlayers.basetypes.Bounds;
	import edu.psu.geovista.flexlayers.basetypes.Size;
	import edu.psu.geovista.flexlayers.SpriteOL;
	import mx.core.UIComponent;
	
	public class AS extends Elements
	{
		
		public var localResolution:Number = 99999;
		public var left:Number;
		public var right:Number;
		public var top:Number;
		public var bottom:Number;
		public var maxPixel:Number;
		
		public function AS(container:CanvasOL):void {
			super(container);
		}
		
		override public function destroy():void {
			super.destroy();
		}
		
		override public function setExtent(extent:Bounds):void {
			super.setExtent(extent);
	        
	        var resolution = this.getResolution();

	        if (!this.localResolution || resolution != this.localResolution) {
	            this.left = -extent.left / resolution;
	            this.top = extent.top / resolution;
	        }
	
	        
	        var left = 0;
	        var top = 0;
	
	        // If the resolution has not changed, we already have features, and we need
	        // to adjust the viewbox to fit them.
	        if (this.localResolution && resolution == this.localResolution) {
	            left = (this.left) - (-extent.left / resolution);
	            top  = (this.top) - (extent.top / resolution);
	        }    
	        
	        // Store resolution for use later.
	        this.localResolution = resolution;
	        
	        // Set the viewbox -- the left/top will be pixels-dragged-since-res change,
	        // the width/height will be pixels.
	        var extentString = left + " " + top + " " + 
	                             extent.getWidth() / resolution + " " + extent.getHeight() / resolution;
	        //var extentString = extent.left / resolution + " " + -extent.top / resolution + " " + 
	        this.rendererRoot.viewBox = extentString;
		}
		
		override public function setSize(size:Size):void {
			super.setSize(size);
	        
	        this.rendererRoot.width = this.size.w;
	        this.rendererRoot.height = this.size.h;
		}
		
		override public function getNodeType(geometry:Object):String {
			var nodeType = null;
	        switch (geometry.getClassName()) {
	            case "FlexLayers.Geometry.Point":
	                nodeType = "circle";
	                break;
	            case "FlexLayers.Geometry.Rectangle":
	                nodeType = "rect";
	                break;
	            case "FlexLayers.Geometry.LineString":
	                nodeType = "line";
	                break;
	            case "FlexLayers.Geometry.LinearRing":
	                nodeType = "line";
	                break;
	            case "FlexLayers.Geometry.Polygon":
	            case "FlexLayers.Geometry.Curve":
	            case "FlexLayers.Geometry.Surface":
	                nodeType = "line";
	                break;
	            default:
	                break;
	        }
	        return nodeType;
		}
		
		override public function setStyle(node:SpriteOL, style:Object, options:Object):void {	
	        style = style  || node._style;
	        options = options || node._options;
	
	        if (node._geometryClass == "FlexLayers.Geometry.Point") {
	            node.attributes.r = style.pointRadius;
	        }
	        
	        if (options.isFilled) {
	            node.graphics.beginFill(style.fillColor, style.fillOpacity);
	        } else {
	            node.graphics.endFill();
	        }
	
	        if (options.isStroked) {
	        	node.graphics.lineStyle(style.strokeWidth, style.strokeColor, style.strokeOpacity, false, "normal", style.strokeLinecap);
	        } else {
	            //don't draw the line
	        }
	        
	        if (style.pointerEvents) {
	            node.attributes.pointerEvents = style.pointerEvents;
	        }
	        
	        if (style.cursor) {
	            node.attributes.cursor = style.cursor;
	        }
		}
		
		override public function removeStyle(node:SpriteOL, style:Object, options:Object):void {
	        style = style  || node._style;
	        options = options || node._options;
	        
	        if (options.isFilled) {
	            node.graphics.beginFill(style.fillColor, style.fillOpacity);
	        }
	        
		}
		
		override public function drawPoint(node:SpriteOL, geometry:Object):void {
			this.drawCircle(node, geometry, node.attributes.r);
		}
		
		override public function drawCircle(node:SpriteOL, geometry:Object, radius:Number):void {
			var resolution = this.getResolution();
	        var x = (geometry.x / resolution + this.left);
	        var y = (this.top - geometry.y / resolution);
	        var draw = true;
	        if (x < -this.maxPixel || x > this.maxPixel) { draw = false; }
	        if (y < -this.maxPixel || y > this.maxPixel) { draw = false; }
	
	        if (draw) { 
	            node.graphics.drawCircle(x, y, radius);
	        } else {
	            this.root.rawChildren.removeChild(node);
	        } 
		}
		
		override public function drawLineString(node:SpriteOL, geometry:Object):void {
			for (var i = 0; i < geometry.components.length; i++) {
				var componentString:String = this.getShortString(geometry.components[i]);
				var componentPoint:Array = componentString.split(",");
				if (i==0) {
					node.graphics.moveTo(int(componentPoint[0]), int(componentPoint[1]));
				} else {
					node.graphics.lineTo(int(componentPoint[0]), int(componentPoint[1])); 
				}
			}  
		}
		
		override public function drawPolygon(node:SpriteOL, geometry:Object):void {
	        var draw = true;
	        for (var j = 0; j < geometry.components.length; j++) {
	            var linearRing = geometry.components[j];
	            for (var i = 0; i < linearRing.components.length; i++) {
	                var component = this.getShortString(linearRing.components[i])
	                if (component) {
	                	var coords:Array = component.split(",");
	                	if (i==0) {
	                    	node.graphics.moveTo(int(coords[0]), int(coords[1]));
	                 	} else {
	                 		node.graphics.lineTo(int(coords[0]), int(coords[1]));
	                 	}
	                } else {
	                    draw = false;
	                    node.graphics.clear();
	                }    
	            }
	        } 
		}
		
		override public function drawRectangle(node:SpriteOL, geometry:Object):void {
	        var x = (geometry.x / resolution + this.left);
	        var y = (geometry.y / resolution - this.top);
	        var draw = true;
	        if (x < -this.maxPixel || x > this.maxPixel) { draw = false; }
	        if (y < -this.maxPixel || y > this.maxPixel) { draw = false; }
	        if (draw) {
	            node.graphics.drawRect(x, y, geometry.width, geometry.height);
	        } else {
	            node.graphics.drawRect(0, 0, 0, 0);
	        }
		}
		
		override public function drawCurve(node:SpriteOL, geometry:Object):void {
			var d = null;
	        var draw = true;
	        for (var i = 0; i < geometry.components.length; i++) {
	            if ((i%3) == 0 && (i/3) == 0) {
	                var component = this.getShortString(geometry.components[i]);
	                if (!component) { draw = false; }
	                d = "M " + component;
	            } else if ((i%3) == 1) {
	                var component = this.getShortString(geometry.components[i]);
	                if (!component) { draw = false; }
	                d += " C " + component;
	            } else {
	                var component = this.getShortString(geometry.components[i]);
	                if (!component) { draw = false; }
	                d += " " + component;
	            }
	        }
	        if (draw) {
	            node.attributes.d = d;
	        } else {
	            node.attributes.d = "";
	        }    
		}
		
		public function getComponentsString(components:Object):String {
			var strings = [];
	        for(var i = 0; i < components.length; i++) {
	            var component = this.getShortString(components[i]);
	            if (component) {
	                strings.push(component);
	            }
	        }
	        return strings.join(",");
		}
		
		public function getShortString(point:Object):String {
	        var resolution = this.getResolution();
	        var x = (point.x / resolution + this.left);
	        var y = (this.top - point.y / resolution);
	        if (x < -this.maxPixel || x > this.maxPixel) { return null; }
	        if (y < -this.maxPixel || y > this.maxPixel) { return null; }
	        var string =  x + "," + y;  
	        return string;
		}
		
		override public function supported():Boolean {
			return true;
		}
		
		override public function createNode(type:Object, id:Object):SpriteOL {
			var node:SpriteOL = new SpriteOL();
			node.id = String(id);
			node.name = String(id);
			node.type = String(type);
			node.alpha = 1.0;
	        return node;    
		}
		
		override public function createRendererRoot():CanvasOL {
			var id = this.container.id + "_asRoot";
	        var rendererRoot:CanvasOL = new CanvasOL();
	        rendererRoot.id = id;
	        rendererRoot.name = id;
	        rendererRoot.percentWidth = 100;
	        rendererRoot.percentHeight = 100;
	        return rendererRoot; 
		}
		
		override public function createRoot():CanvasOL {
			var id = this.container.id + "_root";
	
	        var root:CanvasOL = new CanvasOL();
	        root.id = id;
	        root.name = id;
	        root.percentWidth = 100;
	        root.percentHeight = 100;
	
	        return root;
		}
		
		override public function nodeTypeCompare(node:SpriteOL, type:String):Boolean {
			return (type == node.type);
		}
		
		override public function eraseGeometry(geometry:Object):void {
			if ((geometry.getClassName() == "FlexLayers.Geometry.MultiPoint") ||
	            (geometry.getClassName() == "FlexLayers.Geometry.MultiLineString") ||
	            (geometry.getClassName() == "FlexLayers.Geometry.MultiPolygon")) {
	            for (var i = 0; i < geometry.components.length; i++) {
	                this.eraseGeometry(geometry.components[i]);
	            }
	        } else {    
	            var element = this.root.rawChildren.getChildByName(geometry.id);
	            if (element && element.parent) {
	                if (element.geometry) {
	                    element.geometry.destroy();
	                    element.geometry = null;
	                }
	                element.parent.removeChild(element);
	            }
	        }
		}
		
		override public function clearNode(node:Object):void {
			node.graphics.clear();
		}
	}
}