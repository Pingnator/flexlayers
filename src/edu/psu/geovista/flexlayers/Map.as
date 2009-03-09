package edu.psu.geovista.flexlayers
{
	import edu.psu.geovista.flexlayers.basetypes.Size;
	import edu.psu.geovista.flexlayers.basetypes.LonLat;
	import edu.psu.geovista.flexlayers.basetypes.Bounds;
	import edu.psu.geovista.flexlayers.basetypes.Pixel;
	import edu.psu.geovista.flexlayers.basetypes.Element;
	import edu.psu.geovista.flexlayers.basetypes.FunctionOL;
	import flash.geom.Point;
	
	public class Map
	{
		
		var TILE_WIDTH:Number = 256;
		var TILE_HEIGHT:Number = 256;
		//var TILE_WIDTH:int = 128;
		//var TILE_HEIGHT:int = 128;
		
		public var Z_INDEX_BASE:Object = {BaseLayer: 100, Overlay:325, Popup:750, Control: 1000};
		
		var EVENT_TYPES:Array = [
        "addlayer", "removelayer", "changelayer", "movestart", "move", 
        "moveend", "zoomend", "popupopen", "popupclose",
        "addmarker", "removemarker", "clearmarkers", "mouseOver",
        "mouseOut", "mouseMove", "dragstart", "drag", "dragend",
        "changebaselayer", "changeannolayer"];
		
		public var id:String = null;
		
		public var events:Events = null;
		
		private var unloadDestroy:Function = null;
		
		var size:Size = null;
		
		public var viewPortCanvas:CanvasOL = null;
		
		var layerContainerOrigin:LonLat = null;
		
		public var popupContainer:CanvasOL = null;
		
		public var layerContainerCanvas:CanvasOL = null;
		
		public var layers:Array = null;
		
		public var controls:Array = null;
		
		public var popups:Array = null;
		
		public var baseLayer:Object = null;
		
		public var can:Object = null;
		
		public var center:LonLat = null;
		
		public var zoom:Number = 0;
		
		public var viewRequestID:int = 0;
		
		public var tileSize:Size = null;
		
		public var projection:String = "EPSG:4326";
		
		public var units:String = "degrees";
		
		public var maxResolution:Object = 1.40625;
		
		public var minResolution:Object;
		
		public var maxScale:Number;
		
		public var minScale:Number;
		
		public var maxExtent:Bounds = null;
		
		public var minExtent:Bounds = null;
		
		public var numZoomLevels:Number = 16;
		
		public var fallThrough:Boolean = false;
		
		public var scales:Object = null;
		
		public var resolutions:Object = null;
		
		public var maxZoomLevel:Object = null;
		
		public var vectorLayer:Layer = null;
		
		public var featureSelection:Array = null;
		
		public var canPos:Pixel = null;
		
		public function Map(can:Object, canvas:CanvasOL, options:Object = null):void {
			this.setOptions(options);
			
			this.id = Util.createUniqueID("Map_");
			
			this.can = canvas;
			
			var topleft = this.can.localToGlobal(new Point(0, 0));
			this.canPos = new Pixel(topleft.x, topleft.y);
			
			var id:String = this.can.id + "_FlexLayers_ViewPort";
			this.viewPortCanvas = Util.createCanvas(id, null, null, null, "relative", null, "hidden");
			this.viewPortCanvas.percentWidth = 100;
			this.viewPortCanvas.percentHeight = 100;
			this.can.addChildAt(this.viewPortCanvas, this.viewPortCanvas.style.zIndex);
			
			id = this.can.id + "_FlexLayers_Container";
			this.layerContainerCanvas = Util.createCanvas(id);
			this.layerContainerCanvas.percentWidth = 100;
			this.layerContainerCanvas.percentHeight = 100;
			this.layerContainerCanvas.creationIndex = this.Z_INDEX_BASE.Popup-1;
			
			id = this.can.id + "_FlexLayers_Popup_Container";
			this.popupContainer = Util.createCanvas(id);
			this.popupContainer.percentWidth = 100;
			this.popupContainer.percentHeight = 100;
			
			this.popupContainer.addChild(this.layerContainerCanvas);
			
			this.viewPortCanvas.addChild(this.popupContainer);
			
			this.layers = new Array();
			
			this.events = new Events(this, this.can, this.EVENT_TYPES, this.fallThrough);
	        this.updateSize();
	 
	        // update the map size and location before the map moves
	        //this.events.register("movestart", this, this.updateSize);
	        //this.canvas.addEventListener("resize", this.updateSize);

			this.layers = [];
			
			if (this.controls == null) {
	            if (Control != null) {
	                this.controls = new Array();
	            } else {
	                this.controls = new Array();
	            }
	        }
	        
		    for(var i=0; i < this.controls.length; i++) {
	            this.addControlToMap(this.controls[i]);
	        }
	        
	        this.popups = [];

		}
		
		private function destroy():Boolean {
	        if (!this.unloadDestroy) {
	            return false;
	        }
	        
	       // new EventOL().stopObserving(this.can.parentApplication, 'unload', this.unloadDestroy);
	        this.unloadDestroy = null;
	
	        if (this.layers != null) {
	            for (var i = this.layers.length - 1; i>=0; --i) {
	                //pass 'false' to destroy so that map wont try to set a new 
	                // baselayer after each baselayer is removed
	                this.layers[i].destroy(false);
	            } 
	            this.layers = null;
	        }
	        if (this.controls != null) {
	            for (var i = this.controls.length - 1; i>=0; --i) {
	                this.controls[i].destroy();
	            } 
	            this.controls = null;
	        }
	        if (this.viewPortCanvas) {
	            this.can.removeChild(this.viewPortCanvas);
	        }
	        this.viewPortCanvas = null;
	
	        this.events.destroy();
	        this.events = null;
	        return true;
		}
		
		public function setOptions(options:Object):void {
			this.tileSize = new Size(this.TILE_WIDTH, this.TILE_HEIGHT);
			
			//this.maxExtent = new Bounds(-77.90,40.77,-77.81,40.83);
			this.maxExtent = new Bounds(-180,-90,180,90);
			
			Util.extend(this, options);
			
		}
		
		public function getTileSize():Size {
			return this.tileSize;
		}
		
		public function getLayer(id:String):Layer {
			var foundLayer:Layer = null;
			for (var i = 0; i < this.layers.length; i++) {
				var layer = this.layers[i];
				if (layer.id == id) {
					foundLayer = layer;
				}
			}
			return foundLayer;
		}
		
		public function getLayerByName(name:String):Layer {
			var foundLayer:Layer = null;
			for (var i = 0; i < this.layers.length; i++) {
				var layer = this.layers[i];
				if (layer.name == name) {
					foundLayer = layer;
				}
			}
			return foundLayer;
		}
		
		public function setLayerZindex(layer:Object, zIdx:int):void {
			layer.setZIndex(
	            this.Z_INDEX_BASE[layer.isBaseLayer ? 'BaseLayer' : 'Overlay']
	            + zIdx * 5 );
		}
		
		public function addLayer(layer:Object):Boolean {
			for(var i=0; i < this.layers.length; i++) {
	            if (this.layers[i] == layer) {
	                return false;
	            }
	        }
	        layer.canvas.style.overflow = "";
	        if (layer.canvas.creationIndex < 0) {
	        	this.setLayerZindex(layer, this.layers.length);
	        }
	        
	        if (layer.isFixed) {
	            this.viewPortCanvas.addChild(layer.canvas);
	        } else {
	         	this.layerContainerCanvas.addChild(layer.canvas);
	        }
	        
	        this.layers.push(layer);
	        layer.setMap(this);
	        
	        if (layer.isBaseLayer) {
				if (this.baseLayer == null) {
					this.setBaseLayer(layer);
				} else {
					layer.setVisibility(false);
				}
	        } else {
	        	layer.redraw();
	        }
	        
	        this.events.triggerEvent("addlayer");
	        
	        return true;
	        
		}
		
		public function addLayers(layers:Array):void {
	        for (var i = 0; i <  layers.length; i++) {
	            this.addLayer(layers[i]);
	        }
		}
		
		public function removeLayer(layer:Layer, setNewBaseLayer:Boolean = true) {
			if (layer.isFixed) {
				this.viewPortCanvas.removeChild(layer.canvas);
			} else {
				this.layerContainerCanvas.removeChild(layer.canvas);
			}
			layer.map = null;
			Util.removeItem(this.layers, layer);
			
	        if (setNewBaseLayer && (this.baseLayer == layer)) {
            	this.baseLayer = null;
	            for(var i:int=0; i < this.layers.length; i++) {
	                var iLayer = this.layers[i];
	                if (iLayer.isBaseLayer) {
	                    this.setBaseLayer(iLayer);
	                    break;
	                }
	            }
	        }
	        this.events.triggerEvent("removelayer");	
		}
		
		public function getNumLayers():Number {
			return this.layers.length;
		}
		
		public function getLayerIndex(layer:Layer):int {
			return Util.indexOf(this.layers, layer);
		}
		
		public function setLayerIndex(layer:Layer, idx:int):void {
	        var base:int = this.getLayerIndex(layer);
	        if (idx < 0) 
	            idx = 0;
	        else if (idx > this.layers.length)
	            idx = this.layers.length;
	        if (base != idx) {
	            this.layers.splice(base, 1);
	            this.layers.splice(idx, 0, layer);
	            for (var i = 0; i < this.layers.length; i++)
	                this.setLayerZIndex(this.layers[i], i);
	            this.events.triggerEvent("changelayer");
	        }
		}
		
		public function addControl(control:Control, px:Pixel = null):void {
			this.controls.push(control);
        	this.addControlToMap(control, px);
		}
		
		public function addControlToMap(control:Control, px:Pixel = null):void {
	        control.setMap(this);
	        var canvas:CanvasOL = control.draw(px);
	        if (canvas) {
	            if(!control.outsideCanvas) {
	                canvas.style.zIndex = this.Z_INDEX_BASE['Control'] +
	                                    this.controls.length;
	                this.viewPortCanvas.addChild( canvas );
	            }
	        }
		}
		
		public function setLayerZIndex(layer:Layer, zIdx:int):void {
	        layer.setZIndex(
	            this.Z_INDEX_BASE[layer.isBaseLayer ? 'BaseLayer' : 'Overlay']
	            + zIdx * 5 );
  		}
		public function raiseLayer(layer, delta):void {
			var idx:int = this.getLayerIndex(layer) + delta;
			this.setLayerIndex(layer, idx);
		}
		
		public function setBaseLayer(newBaseLayer, noEvent:Boolean = false):void {
			var oldExtent:Bounds = null;
			if (this.baseLayer != null) {
				oldExtent = this.baseLayer.getExtent();
			}
			
			if (newBaseLayer != this.baseLayer) {
				
				if (Util.indexOf(this.layers, newBaseLayer) != -1) {
					
					if (this.baseLayer != null) {
						this.baseLayer.setVisibility(false, noEvent);
					}
					
					this.baseLayer = newBaseLayer;
					
					this.viewRequestID++;
					this.baseLayer.visibility = true;
					
					var center:LonLat = this.getCenter();
					if (center != null) {
						if (oldExtent == null) {
							this.setCenter(center, this.getZoom(), false, true);
						} else {
							this.setCenter(oldExtent.getCenterLonLat(), 
                                       this.getZoomForExtent(oldExtent),
                                       false, true);
						}
					}
					
					if ((noEvent == null) || (noEvent == false)) {
						this.events.triggerEvent("changebaselayer");
					}
					
				}
			}
		}
		
		    /** 
	    * @param {OpenLayers.Popup} popup
	    * @param {Boolean} exclusive If true, closes all other popups first
	    */
	    public function addPopup(popup:PopupOL, exclusive:Boolean = true):void {
	
	        if (exclusive) {
	            //remove all other popups from screen
	            for(var i=0; i < this.popups.length; i++) {
	                this.removePopup(this.popups[i]);
	            }
	        }
	
	        popup.map = this;
	        this.popups.push(popup);
	        var popupCanvas = popup.draw();
	        if (popupCanvas) {
	            popupCanvas.style.zIndex = this.Z_INDEX_BASE['Popup'] +
	                                    this.popups.length;
	            this.popupContainer.addChild(popupCanvas);
	        }
	    }

	    public function removePopup(popup:PopupOL):void {
	        Util.removeItem(this.popups, popup);
	        if (popup.canvas) {
	            try { this.popupContainer.removeChild(popup.canvas); }
	            catch (e) { } 
	        }
	        popup.map = null;
	    }
			
		public function getSize():Size {
			var size:Size = null;
	        if (this.size != null) {
	            size = this.size.clone();
	        }
	        return size;
		}
		
		public function updateSize():void {
	        this.events.element.offsets = null;
	        var newSize = this.getCurrentSize();
	        var oldSize = this.getSize();
	        if (oldSize == null)
	            this.size = oldSize = newSize;
	        if (!newSize.equals(oldSize)) {
	            
	            this.size = newSize;
	
	            for(var i=0; i < this.layers.length; i++) {
	                this.layers[i].onMapResize();                
	            }
	
	            if (this.baseLayer != null) {
	                var center = new Pixel(newSize.w /2, newSize.h / 2);
	                var centerLL = this.getLonLatFromViewPortPx(center);
	                var zoom = this.getZoom();
	                this.zoom = null;
	                this.setCenter(this.getCenter(), zoom);
	            }
	
	        }
		}
		
		public function getCurrentSize():Size {
	        var size = new Size(this.can.width, this.can.height);

	        if (size.w == 0 && size.h == 0) {
	            var dim = Element.getDimensions(this.can);
	            size.w = dim.width;
	            size.h = dim.height;
	        }
	        if (size.w == 0 && size.h == 0) {
	            size.w = int(this.can.width);
	            size.h = int(this.can.height);
	        }
	        return size;
		}
		
		public function calculateBounds(center:LonLat = null, resolution:Number = -1):Bounds {
			var extent:Bounds = null;
        
	        if (center == null) {
	            center = this.getCenter();
	        }                
	        if (resolution == -1) {
	            resolution = this.getResolution();
	        }
	    
	        if ((center != null) && (resolution != -1)) {
	
	            var size = this.getSize();
	            var w_deg = size.w * resolution;
	            var h_deg = size.h * resolution;
	        
	            extent = new Bounds(center.lon - w_deg / 2,
	                                           center.lat - h_deg / 2,
	                                           center.lon + w_deg / 2,
	                                           center.lat + h_deg / 2);
	        
	        }
	
	        return extent;
		}
		
		public function getCenter():LonLat {
			return this.center;
		}
		
		public function getZoom():int {
			return this.zoom;
		}
		
		public function pan(dx:int, dy:int):void {
			var centerPx:Pixel = this.getViewPortPxFromLonLat(this.getCenter());
	
	        // adjust
	        var newCenterPx:Pixel = centerPx.add(dx, dy);
	        
	        // only call setCenter if there has been a change
	        if (!newCenterPx.equals(centerPx)) {
	            var newCenterLonLat:LonLat = this.getLonLatFromViewPortPx(newCenterPx);
	            this.setCenter(newCenterLonLat);
	        }
		}
		
		public function setCenter(lonlat:LonLat, zoom:Number = NaN, dragging:Boolean = false, forceZoomChange:Boolean = false):void {
			if (!this.center && !this.isValidLonLat(lonlat)) {
	            lonlat = this.maxExtent.getCenterLonLat();
	        }
	        
	        var zoomChanged = forceZoomChange || (
	                            (this.isValidZoomLevel(zoom)) && 
	                            (zoom != this.getZoom()) );
	
	        var centerChanged = (this.isValidLonLat(lonlat)) && 
	                            (!lonlat.equals(this.center));
	

	        if (zoomChanged || centerChanged || !dragging) {
	
	            if (!dragging) { this.events.triggerEvent("movestart"); }
	
	            if (centerChanged) {
	                if ((!zoomChanged) && (this.center)) { 
	                    this.centerLayerContainer(lonlat);
	                }
	                this.center = lonlat.clone();
	            }

	            if ((zoomChanged) || (this.layerContainerOrigin == null)) {
	                this.layerContainerOrigin = this.center.clone();
	                this.layerContainerCanvas.x = 0;
	                this.layerContainerCanvas.y = 0;
	            }
	
	            if (zoomChanged) {
	                this.zoom = zoom;

	                this.viewRequestID++;
	            } 
	            
	            var bounds = this.getExtent();
  	
	            this.baseLayer.moveTo(bounds, zoomChanged, dragging);
	            for (var i = 0; i < this.layers.length; i++) {
	                var layer = this.layers[i];
	                if (!layer.isBaseLayer) {
	                    
	                    var moveLayer;
	                    var inRange = layer.calculateInRange();
	                    if (layer.inRange != inRange) {
	                        layer.inRange = inRange;
	                        moveLayer = true;
	                        this.events.triggerEvent("changelayer");
	                    } else {
	                        moveLayer = (layer.visibility && layer.inRange);
	                    }
	
	                    if (moveLayer) {
	                        layer.moveTo(bounds, zoomChanged, dragging);
	                    }
	                }                
	            }
	            
	            if (zoomChanged) {
	                for (var i = 0; i < this.popups.length; i++) {
	                    this.popups[i].updatePosition();
	                }
	            }
	            
	            this.events.triggerEvent("move");
	    
	            if (zoomChanged) { this.events.triggerEvent("zoomend"); }
	        }

	        if (!dragging) { this.events.triggerEvent("moveend"); }
		}
		
		public function centerLayerContainer(lonlat:LonLat):void {
			var originPx = this.getViewPortPxFromLonLat(this.layerContainerOrigin);
	        var newPx = this.getViewPortPxFromLonLat(lonlat);
	
	        if ((originPx != null) && (newPx != null)) {
	            this.layerContainerCanvas.x = (originPx.x - newPx.x);
	            this.layerContainerCanvas.y  = (originPx.y - newPx.y);
	        }
		}
		
		public function isValidZoomLevel(zoomLevel:Number):Boolean {
			var isValid = ( (zoomLevel != NaN) &&
	            (zoomLevel >= 0) && 
	            (zoomLevel < this.getNumZoomLevels()) );
		    return isValid;
		}
		
		public function isValidLonLat(lonlat:LonLat):Boolean {
	        var valid = false;
	        if (lonlat != null) {
	            var maxExtent = this.getMaxExtent();
	            valid = maxExtent.containsLonLat(lonlat);        
	        }
	        return valid;
		}
		
		public function getProjection():String {
	        var projection:String = null;
	        if (this.baseLayer != null) {
	            projection = this.baseLayer.projection;
	        }
	        return projection;
		}
		
		public function getMaxResolution():String {
	        var maxResolution = null;
	        if (this.baseLayer != null) {
	            maxResolution = this.baseLayer.maxResolution;
	        }
	        return maxResolution;
		}
		
		public function getMaxExtent():Bounds {
	        var maxExtentH:Bounds = null;
	        if (this.baseLayer != null) {
	            maxExtentH = this.baseLayer.maxExtent;
	        }        
	        return maxExtentH;	
		}
		
		public function getNumZoomLevels():int {	
	        var numZoomLevels:int = null;
	        if (this.baseLayer != null) {
	            numZoomLevels = this.baseLayer.numZoomLevels;
	        }
	        return numZoomLevels;
		}
		
		public function getExtent():Bounds {
	        var extent:Bounds = null;
	        if (this.baseLayer != null) {
	            extent = this.baseLayer.getExtent();
	        }
	        return extent;
		}
		
		public function getResolution():Number {
	        var resolution:Number = null;
	        if (this.baseLayer != null) {
	            resolution = this.baseLayer.getResolution();
	        }
	        return resolution;
		}
		
		public function getScale():Number {
			var scale:Number = null;
	        if (this.baseLayer != null) {
	            var res:Number = this.getResolution();
	            var units:String = this.baseLayer.units;
	            scale = Util.getScaleFromResolution(res, units);
	        }
	        return scale;
		}
		
		public function getZoomForExtent(bounds:Bounds):Number {
			var zoom:int = -1;
	        if (this.baseLayer != null) {
	            zoom = this.baseLayer.getZoomForExtent(bounds);
	        }
	        return zoom;
		}
		
		public function getZoomForResolution(resolution:Number):Number {
			var zoom:int = -1;
	        if (this.baseLayer != null) {
	            zoom = this.baseLayer.getZoomForResolution(resolution);
	        }
	        return zoom;
		}
		
		public function zoomTo(zoom):void {
	        if (this.isValidZoomLevel(zoom)) {
	            this.setCenter(null, zoom);
	        }
		}
		
		public function zoomIn() {
			this.zoomTo(this.getZoom() + 1);
		}
		
		public function zoomOut() {
			this.zoomTo(this.getZoom() - 1);
		}
		
		public function zoomToExtent(bounds:Bounds):void {
	        this.setCenter(bounds.getCenterLonLat(), this.getZoomForExtent(bounds));
		}
		
		public function zoomToMaxExtent():void {
			this.zoomToExtent(this.getMaxExtent());
		}
		
		public function zoomToScale(scale:Number):void {
			var res = new Util().getResolutionFromScale(scale, this.baseLayer.units);
	        var size = this.getSize();
	        var w_deg = size.w * res;
	        var h_deg = size.h * res;
	        var center = this.getCenter();
	
	        var extent = new Bounds(center.lon - w_deg / 2,
	                                           center.lat - h_deg / 2,
	                                           center.lon + w_deg / 2,
	                                           center.lat + h_deg / 2);
	        this.zoomToExtent(extent);
		}
		
		public function getLonLatFromViewPortPx(viewPortPx):LonLat {
	        var lonlat:LonLat = null; 
	        if (this.baseLayer != null) {
	            lonlat = this.baseLayer.getLonLatFromViewPortPx(viewPortPx);
	        }
	        return lonlat;
		}
		
		public function getViewPortPxFromLonLat(lonlat:LonLat):Pixel {
			var px:Pixel = null; 
	        if (this.baseLayer != null) {
	            px = this.baseLayer.getViewPortPxFromLonLat(lonlat);
	        }
	        return px;
		}
		
		public function getLonLatFromPixel(px:Pixel):LonLat {
			return this.getLonLatFromViewPortPx(px);
		}
		
		public function getPixelFromLonLat(lonlat:LonLat):Pixel {
			return this.getViewPortPxFromLonLat(lonlat);
		}
		
		public function getViewPortPxFromLayerPx(layerPx:Pixel):Pixel {
			var viewPortPx:Pixel = null;
	        if (layerPx != null) {
	            var dX:int = int(this.layerContainerCanvas.x);
	            var dY:int = int(this.layerContainerCanvas.y);
	            viewPortPx = layerPx.add(dX, dY);            
	        }
	        return viewPortPx;
		}
		
		public function getLayerPxFromViewPortPx(viewPortPx:Pixel):Pixel {
			var layerPx:Pixel = null;
	        if (viewPortPx != null) {
	            var dX:int = -int(this.layerContainerCanvas.x);
	            var dY:int = -int(this.layerContainerCanvas.y);
	            layerPx = viewPortPx.add(dX, dY);
	        }
	        return layerPx;
		}
		
		public function getLonLatFromLayerPx(px:Pixel):LonLat {
			px = this.getViewPortPxFromLayerPx(px);
	    	return this.getLonLatFromViewPortPx(px); 
		}
		
		public function getLayerPxFromLonLat(lonlat:LonLat):Pixel {
	    	var px = this.getViewPortPxFromLonLat(lonlat);
	    	return this.getLayerPxFromViewPortPx(px);
		}

		private var CLASS_NAME:String = "FlexLayers.Map";
		
		public function getClassName():String {
			return CLASS_NAME;
		}
	}
}