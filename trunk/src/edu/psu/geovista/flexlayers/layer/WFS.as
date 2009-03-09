package edu.psu.geovista.flexlayers.layer
{
	import mx.rpc.events.ResultEvent;
	import edu.psu.geovista.flexlayers.Map;
	import edu.psu.geovista.flexlayers.basetypes.Bounds;
	import edu.psu.geovista.flexlayers.Util;
	import edu.psu.geovista.flexlayers.Tile;
	import edu.psu.geovista.flexlayers.basetypes.LonLat;
	import edu.psu.geovista.flexlayers.format.WFS;
	import edu.psu.geovista.flexlayers.layer.WFS;
	import edu.psu.geovista.flexlayers.tile.WFS;
	import edu.psu.geovista.flexlayers.feature.Vector;
	import edu.psu.geovista.flexlayers.RequestOL;
	import mx.controls.Alert;
	import edu.psu.geovista.flexlayers.FlexLayers;
	
	public class WFS extends edu.psu.geovista.flexlayers.layer.Vector
	{
		
		public var ratio:Number = 2;
	
	    public var DEFAULT_PARAMS:Object = { service: "WFS",
	                      version: "1.1.0",
	                      request: "GetFeature" };
	                      
		public var vectorMode:Boolean = true;
		
		public var params:Object = null;
		
		public var url:String = null;
		
		public var tile:Tile = null;
		
		public var writer:Object = null;
			                    
	    public function WFS(name:String, url:String, params:Object, options:Object = null):void {
	        if (options == null) { options = {}; } 
	        
	        if (options.featureClass || !edu.psu.geovista.flexlayers.layer.Vector || !edu.psu.geovista.flexlayers.feature.Vector) {
	            this.vectorMode = false;
	        }    

	        Util.extend(options, {'reportError': false});
	        super(name, options);
	        
	        if (!this.renderer || !this.vectorMode) {
	            this.vectorMode = false; 
	            if (!options.featureClass) {
	                options.featureClass = edu.psu.geovista.flexlayers.feature.WFS;
	            }   
	        }
	        
	        if (this.params && this.params.typename && !this.options.typename) {
	            this.options.typename = this.params.typename;
	        }
	        
	        if (!this.options.geometry_column) {
	            this.options.geometry_column = "the_geom";
	        }    
	        
	        this.params = params;
	        Util.applyDefaults(this.params, Util.upperCaseObject(this.DEFAULT_PARAMS));
	        this.url = url;
	    }
	    
	    override public function destroy(setNewBaseLayer:Boolean = true):void {
	        if (this.vectorMode) {
	            super.destroy();
	        }
	    }
	    
	    override public function setMap(map:Map):void {
	        if (this.vectorMode) {
	            super.setMap(map);
	        }
	    }
	    
	    override public function moveTo(bounds:Bounds, zoomChanged:Boolean, dragging:Boolean = false):void {
	        if (this.vectorMode) {
	            super.moveTo(bounds, zoomChanged, dragging);
	        }  
	        
	        if (dragging) {
	        } else {
		        
		        if ( zoomChanged ) {
		            if (this.vectorMode) {
		                this.renderer.clear();
		            }
		        }
	
		        if (this.options.minZoomLevel && this.map.getZoom() < this.options.minZoomLevel) {

		        
			        if (bounds == null) {
			            bounds = this.map.getExtent();
			        }
			
			        var firstRendering = (this.tile == null);
			
			        var outOfBounds = (!firstRendering &&
			                           !this.tile.bounds.containsBounds(bounds));
			
			        if ( zoomChanged || firstRendering || (!dragging && outOfBounds) ) {
			            var center = bounds.getCenterLonLat();
			            var tileWidth = bounds.getWidth() * this.ratio;
			            var tileHeight = bounds.getHeight() * this.ratio;
			            var tileBounds = 
			                new Bounds(center.lon - (tileWidth / 2),
			                                      center.lat - (tileHeight / 2),
			                                      center.lon + (tileWidth / 2),
			                                      center.lat + (tileHeight / 2));
			
			            var tileSize = this.map.getSize();
			            tileSize.w = tileSize.w * this.ratio;
			            tileSize.h = tileSize.h * this.ratio;
		
			            var ul = new LonLat(tileBounds.left, tileBounds.top);
			            var pos = this.map.getLayerPxFromLonLat(ul);
		
			            var url = this.getFullRequestString();
			        
			            var params = { BBOX:tileBounds.toBBOX() };
			            url += "&" + Util.getParameterString(params);
			
			            if (!this.tile) {
			                this.tile = new edu.psu.geovista.flexlayers.tile.WFS(this, pos, tileBounds, 
			                                                     url, tileSize);
			                this.tile.draw();
			            } else {
			                if (this.vectorMode) {
			                    this.destroyFeatures();
			                    this.renderer.clear();
			                }
			                this.tile.destroy();
			                
			                this.tile = null;
			                this.tile = new edu.psu.geovista.flexlayers.tile.WFS(this, pos, tileBounds, 
			                                                     url, tileSize);
			                this.tile.draw();
			            } 
			        }
			 	}
	        }
	    }
	    
	    override public function onMapResize():void {	
	        if(this.vectorMode) {
	            super.onMapResize();
	        }
	    }
	    
	    override public function clone(obj:Object):Object {
	        if (obj == null) {
	            obj = new WFS(this.name,
                               this.url,
                               this.params,
                               this.options);
	        }

	        if (this.vectorMode) {
	            obj = super.clone([obj]);
	        }
	
	        return obj;
	    }
	    
		public function getFullRequestString(newParams:Object = null, altUrl:String = null):String {
	        var projection = this.map.getProjection();
	        this.params.SRS = (projection == "none") ? null : projection;
	
	        return new Grid(this.name, this.url, this.params, this.options).getFullRequestString(newParams, altUrl);
		}
		
		public function commit():void {
			if (!this.writer) {
	            this.writer = new edu.psu.geovista.flexlayers.format.WFS({},this);
	        }
	
	        var data = this.writer.write(this.features);
	        
	        var url = this.url;
	        var proxy:String;
	        
	        if (FlexLayers.ProxyHost && this.url.indexOf("http") == 0) {
	            proxy = FlexLayers.ProxyHost;
	        }
	
	        var successfailure = commitSuccessFailure;
	        
	        new RequestOL(url, 
	                         {   method: 'post', 
	                             postBody: data,
	                             onComplete: successfailure
	                          },
	                          proxy
	                         );
		}
		
		public function commitSuccessFailure(evt:ResultEvent):void {
			var response = evt.result as String;
	        if (response.indexOf('SUCCESS') != -1) {
	            this.commitReport('WFS Transaction: SUCCESS', response);
	            
	            for(var i = 0; i < this.features.length; i++) {
	                i.state = null;
	            }    
	            // TBD redraw the layer or reset the state of features
	            // foreach features: set state to null
	        } else if (response.indexOf('FAILED') != -1 ||
	            response.indexOf('Exception') != -1) {
	            this.commitReport('WFS Transaction: FAILED', response);
	        }
		}
		
		public function commitFailure(response:ResultEvent):void {
			
		}
		
		public function commitReport(string:String, response:String){
			Alert.show(string);
		}
		
		public function refresh():void {
			if (this.tile) {
	            if (this.vectorMode) {
	                this.renderer.clear();
	                Util.clearArray(this.features);
	            }
	            this.tile.draw();
	        }
		}
		
		private var CLASS_NAME:String = "FlexLayers.Layer.WFS";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}
		
	}
}