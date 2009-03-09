package edu.psu.geovista.flexlayers
{
	import mx.containers.Canvas;
	import edu.psu.geovista.flexlayers.basetypes.Size;
	import edu.psu.geovista.flexlayers.basetypes.Pixel;
	import edu.psu.geovista.flexlayers.basetypes.Bounds;
	import edu.psu.geovista.flexlayers.basetypes.StringOL;
	import edu.psu.geovista.flexlayers.basetypes.LonLat;
	import mx.utils.ArrayUtil;
	import mx.formatters.NumberFormatter;
	
	public class Layer
	{
		
		public var id:String = null;
		
		public var name:String = null;
		
		public var canvas:CanvasOL = null;
		
		public var parent:Canvas = null;
		
		public var EVENT_TYPES:Array = ["loadstart", "loadend", "loadcancel", "visibilitychanged"];
		
		public var events:Events = null;
		
		public var map:Object = null;
		
		public var isBaseLayer:Boolean = false;
		
		public var isAnnoLayer:Boolean = false;
		
		public var isDynamicLayer:Boolean = false;
		
		public var alpha:Boolean = false;
		
		public var displayInLayerSwitcher:Boolean = true;
		
		public var visibility:Boolean = true;
		
		public var inRange:Boolean = false;
		
		public var imageSize:Size = null;
		
		public var imageOffset:Pixel = null;
		
		public var options:Object = null;
		
		public var gutter:Number = 0;
		
		public var projection:String = null;
		
		public var units:String = null;
		
		public var scales:Array = null;
		
		public var resolutions:Array = null;
		
		public var maxExtent:Bounds = null;
		
		public var maxResolution:Number;
		
		public var minResolution:Number;
		
		public var numZoomLevels:Number;
		
		public var minScale:Number;
		
		public var maxScale:Number;
		
		public var minZoomLevel:Number;
		
		public var displayOutsideMaxExtent:Boolean = false;
		
		public var isFixed:Boolean = false;
		
		public var tileSize:Size = null;
		
		public var opacity:Number = -1;
		
		public var buffer:Number = 2;
		
		public var featureNS:String;
		
		public var reportError:Boolean = false;
		
		public var geometry_column:String = null;
		
		public var canvaszindex:int = -1;
		
		public var markers:Array = null;
		
		public function Layer(name:String, options:Object):void {
			
			addOptions(options);
			
			this.name = name;
			
			if (this.id == null) {
				
				this.id = Util.createUniqueID(this.CLASS_NAME + "_"); 
				
				this.canvas = Util.createCanvas();
				this.canvas.percentWidth = 100;
				this.canvas.percentHeight = 100;
				this.canvas.id = this.id;
				
				this.events = new Events(this, this.canvas, this.EVENT_TYPES);
			}
		}
		
		public function destroy(setNewBaseLayer:Boolean = true):void {
			if (this.map != null) {
				this.map.removeLayer(this, setNewBaseLayer);
			}
			this.map = null;
			this.name = null;
			this.canvas = null;
			this.options = null;
			
			if (this.events) {
				this.events.destroy();
			}
			this.events = null;
		}
		
		public function addOptions(newOptions:Object):void {
			if (this.options == null) {
	            this.options = new Object();
	        }
	        
	       	Util.extend(this.options, newOptions);

	        Util.extend(this, newOptions);
		}
		
		public function onMapResize():void {
			
		}
		
		public function redraw():Boolean {
			var redrawn = false;
	        if (this.map) {
	
	            // min/max Range may have changed
	            this.inRange = this.calculateInRange();
	
	            // map's center might not yet be set
	            var extent = this.getExtent();
	
	            if (extent && this.inRange && this.visibility) {
	                this.moveTo(extent, true, false);
	                redrawn = true;
	            }
	        }
	        return redrawn;
		}
		
		public function setMap(map:Map):void {
			if (this.map == null) {
        
	            this.map = map;

	            this.maxExtent = this.maxExtent || this.map.maxExtent;
	            this.projection = this.projection || this.map.projection;
	            this.units = this.units || this.map.units;
	            
	            this.initResolutions();
	            
	            if (!this.isBaseLayer) {
	                this.inRange = this.calculateInRange();
	                var show:Boolean = ((this.visibility) && (this.inRange));
	                this.canvas.style.display = (show ? "" : "none");
	            }

	            this.setTileSize();
	        }
		}
		
		public function setTileSize(size:Size = null):void {
	        var tileSize:Size = (size) ? size :
                        ((this.tileSize) ? this.tileSize :
                                           this.map.getTileSize());
	        this.tileSize = tileSize;
	        if(this.gutter) {
	            // layers with gutters need non-null tile sizes
	            //if(tileSize == null) {
	            //    OpenLayers.console.error("Error in layer.setMap() for " +
	            //                              this.name + ": layers with gutters " +
	            //                              "need non-null tile sizes");
	            //}
	            this.imageOffset = new Pixel(-this.gutter, -this.gutter); 
	            this.imageSize = new Size(tileSize.w + (2 * this.gutter), 
	                                                 tileSize.h + (2 * this.gutter)); 
	        } else {
	            // layers without gutters may have null tile size - as long
	            // as they don't rely on Tile.Image
	            this.imageSize = tileSize;
	            this.imageOffset = new Pixel(0, 0);
	        }
		}
		
		public function getVisibility():Boolean {
			return this.visibility;
		}
		
		public function setVisibility(visibility:Boolean, noEvent:Boolean = true):void {
			if (visibility != this.visibility) {
	            this.visibility = visibility;
	            this.display(visibility);
	            this.redraw();
	            if ((this.map != null) && 
	                ((noEvent == true) || (noEvent == false))) {
	                this.map.events.triggerEvent("changelayer");
	            }
	            this.events.triggerEvent("visibilitychanged");
	        }
		}
		
		public function initResolutions():void {
			
	        var props:Array = new Array(
	          'projection', 'units',
	          'scales', 'resolutions',
	          'maxScale', 'minScale', 
	          'maxResolution', 'minResolution', 
	          'minExtent', 'maxExtent',
	          'numZoomLevels', 'maxZoomLevel'
	        );
	
	        var confProps:Object = new Object();        
	        for(var i:int=0; i < props.length; i++) {
	            var property:String = props[i];
	            confProps[property] = this.options[property] || this.map[property];
	        }

	        if ( (!confProps.numZoomLevels) && (confProps.maxZoomLevel) ) {
	            confProps.numZoomLevels = confProps.maxZoomLevel + 1;
	        }

	        if ((confProps.scales != null) || (confProps.resolutions != null)) {
	            if (confProps.scales != null) {
	                confProps.resolutions = new Array();
	                for(var i = 0; i < confProps.scales.length; i++) {
	                    var scale = confProps.scales[i];
	                    confProps.resolutions[i] = 
	                       new Util().getResolutionFromScale(scale, 
	                                                              confProps.units);
	                }
	            }
	            confProps.numZoomLevels = confProps.resolutions.length;
	
	        } else {
	            
	            confProps.resolutions = new Array();
	           
	            if (confProps.minScale) {
	                confProps.maxResolution = 
	                    new Util().getResolutionFromScale(confProps.minScale, 
	                                                           confProps.units);
	            } else if (confProps.maxResolution == "auto") {
	                var viewSize = this.map.getSize();
	                var wRes = confProps.maxExtent.getWidth() / viewSize.w;
	                var hRes = confProps.maxExtent.getHeight()/ viewSize.h;
	                confProps.maxResolution = Math.max(wRes, hRes);
	            } 

	            if (confProps.maxScale) {           
	                confProps.minResolution = 
	                    new Util().getResolutionFromScale(confProps.maxScale);
	            } else if ( (confProps.minResolution == "auto") && 
	                        (!confProps.minExtent) ) {
	                var viewSize = this.map.getSize();
	                var wRes = confProps.minExtent.getWidth() / viewSize.w;
	                var hRes = confProps.minExtent.getHeight()/ viewSize.h;
	                confProps.minResolution = Math.max(wRes, hRes);
	            } 

	            if (confProps.minResolution) {
	                var ratio = confProps.maxResolution / confProps.minResolution;
	                confProps.numZoomLevels = 
	                    Math.floor(Math.log(ratio) / Math.log(2)) + 1;
	            }

	            for (var i=0; i < confProps.numZoomLevels; i++) {
	                var res = confProps.maxResolution / Math.pow(2, i)
	                confProps.resolutions.push(res);
	            }    
	        }
	        
	        confProps.resolutions.sort(Array.NUMERIC | Array.DESCENDING);
	
	        this.resolutions = confProps.resolutions;
	        this.maxResolution = confProps.resolutions[0];
	        var lastIndex = confProps.resolutions.length - 1;
	        this.minResolution = confProps.resolutions[lastIndex];
	        
	        this.scales = new Array();
	        for(var i = 0; i < confProps.resolutions.length; i++) {
	            this.scales[i] = 
	               Util.getScaleFromResolution(confProps.resolutions[i], 
	                                                      confProps.units);
	        }
	        this.minScale = this.scales[0];
	        this.maxScale = this.scales[this.scales.length - 1];
	        
	        this.numZoomLevels = confProps.numZoomLevels;

		}
		
		public function clone(obj:Object):Object {
			if (obj == null) {
	            obj = new Layer(this.name, this.options);
	        } 
	        
	        Util.applyDefaults(obj, this);

	        obj.map = null;
	        
	        return obj;
		}
		
		public function getExtent():Bounds {
			return this.map.calculateBounds();
		}
		
		public function getZoomForExtent(extent:Bounds):Number {
			var viewSize:Size = this.map.getSize();
	        var idealResolution:Number = Math.max( extent.getWidth()  / viewSize.w,
	                                        extent.getHeight() / viewSize.h );
	
	        return this.getZoomForResolution(idealResolution);
		}
		
		public function getZoomForResolution(resolution:Number):Number {
			for(var i:int=1; i < this.resolutions.length; i++) {
	            if ( this.resolutions[i] < resolution) {
	                break;
	            }
	        }
	        return (i - 1);
		}
		
		public function getLonLatFromViewPortPx(viewPortPx:Pixel):LonLat {
			var lonlat:LonLat = null;
	        if (viewPortPx != null) {
	            var size:Size = this.map.getSize();
	            var center:LonLat = this.map.getCenter();
	            if (center) {
	                var res:Number  = this.map.getResolution();
	        
	                var delta_x:Number = viewPortPx.x - (size.w / 2);
	                var delta_y:Number = viewPortPx.y - (size.h / 2);
	            
	                lonlat = new LonLat(center.lon + delta_x * res ,
	                                             center.lat - delta_y * res); 
	            }
	        }
	        return lonlat;
		}
		
		public function getViewPortPxFromLonLat(lonlat:LonLat):Pixel {
			var px:Pixel = null; 
	        if (lonlat != null) {
	            var resolution:Number = this.map.getResolution();
	            var extent:Bounds = this.map.getExtent();
	            px = new Pixel(
	                           Math.round(1/resolution * (lonlat.lon - extent.left)),
	                           Math.round(1/resolution * (extent.top - lonlat.lat))
	                           );    
	        }
	        return px;
		}
		
		public function display(display:Boolean):void {
			if (display != this.canvas.visible) {
	            this.canvas.visible = display;
	        }
		}
		
		public function moveTo(bounds:Bounds, zoomChanged:Boolean, dragging:Boolean = false):void {
			var display:Boolean = this.visibility;
	        if (!this.isBaseLayer) {
	            display = display && this.inRange;
	        }
	        this.display(display);
		}
		
		public function calculateInRange():Boolean {
			var inRange:Boolean = false;
	        if (this.map) {
	            var resolution:Number = this.map.getResolution();
	            inRange = ( (resolution >= this.minResolution) &&
	                        (resolution <= this.maxResolution) );
	        }
	        return inRange;
		}
		
		public function adjustBoundsByGutter(bounds:Bounds):Bounds {
			var mapGutter = this.gutter * this.map.getResolution();
	        bounds = new Bounds(bounds.left - mapGutter,
	                                       bounds.bottom - mapGutter,
	                                       bounds.right + mapGutter,
	                                       bounds.top + mapGutter);
	        return bounds;
		}
		
		public function setZIndex(zIdx:int):void {
			this.canvas.creationIndex = zIdx;
		}
		
		public function getResolution():Number {	
	        var zoom:Number = this.map.getZoom();
	        return this.resolutions[zoom];
		}
		
		public function getURL(bounds:Bounds):String {
			return null;
		}
		
		public function getImageSize():Size {
			return (this.imageSize || this.tileSize); 
		}
		
		private var CLASS_NAME:String = "FlexLayers.Layer";
		
		public function getClassName():String {
			return CLASS_NAME;
		}
		
	}
}