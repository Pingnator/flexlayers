package edu.psu.geovista.flexlayers.layer
{
	import edu.psu.geovista.flexlayers.basetypes.Size;
	import edu.psu.geovista.flexlayers.Map;
	import edu.psu.geovista.flexlayers.basetypes.Bounds;
	import edu.psu.geovista.flexlayers.basetypes.Pixel;
	import edu.psu.geovista.flexlayers.Util;
	import mx.containers.Canvas;
	import edu.psu.geovista.flexlayers.CanvasOL;
	import edu.psu.geovista.flexlayers.tile.Image;
	import edu.psu.geovista.flexlayers.basetypes.LonLat;
	import edu.psu.geovista.flexlayers.Tile;
	
	public class Grid extends HTTPRequestOL
	{
		
		public var tileSizeG:Size = null;
		
		public var grid:Array = null;
		
		//public var buffer:int = 2;
		
		public var singleTile:Boolean = false;
		
		public var ratio:Number = 1.5;
		
		public var numLoadingTiles:int = 0;
		
		private var origin:Pixel = null;
		
		public var typename:String = null;
		
		public var proxy:String = null;
		
		public var style:Object = null;
		
		public function Grid(name:String = null, url:String = null, params:Object = null, options:Object = null):void {
			super(name, url, params, options);
			
			this.events.addEventType("tileloaded");
			
			this.grid = new Array();
		}
		
		override public function destroy(newBaseLayer:Boolean = true):void {
			this.clearGrid();
	        this.grid = null;
	        this.tileSizeG = null;
	        super.destroy(); 
		}
		
		public function clearGrid():void {
			if (this.grid) {
	            for(var iRow=0; iRow < this.grid.length; iRow++) {
	                var row:String = this.grid[iRow];
	                for(var iCol=0; iCol < row.length; iCol++) {
	                    var tile = row[iCol];
	                    this.removeTileMonitoringHooks(tile);
	                    tile.destroy();
	                }
	            }
	            this.grid = [];
	        }
		}
		
		override public function clone(obj:Object):Object {
			if (obj == null) {
	            obj = new Grid(this.name,
                                this.url,
                                this.params,
                                this.options);
	        }
	
	        obj = super.clone([obj]);

	        if (this.tileSizeG != null) {
	            obj.tileSize = this.tileSize.clone();
	        }

	        obj.grid = new Array();
	
	        return obj;
		}
		
		override public function setMap(map:Map):void {
			super.setMap(map);
	        if (this.tileSize == null) {
	            this.tileSize = map.getTileSize();
	        }
		}
		
		override public function moveTo(bounds:Bounds, zoomChanged:Boolean, dragging:Boolean = false):void {
			super.moveTo(bounds, zoomChanged, dragging);
	        
	        if (bounds == null) {
	            bounds = this.map.getExtent();
	        }
	        if (bounds != null) {

				var forceReTile = !this.grid.length || zoomChanged;

	            var tilesBounds = this.getTilesBounds();            
	      
	            if (this.singleTile) {
	                
	                if ( forceReTile || 
	                     (!dragging && !tilesBounds.containsBounds(bounds))) {
	                    this.initSingleTile(bounds);
	                }
	            } else {
	                if (forceReTile || !tilesBounds.containsBounds(bounds, true)) {
	                    this.initGriddedTiles(bounds);
	                } else {
	                    this.moveGriddedTiles(bounds);
	                }
	            }
	        }
		}
		
		override public function setTileSize(size:Size = null):void {
	        if (this.singleTile) {
	            var size = this.map.getSize().clone();
	            size.h = int(size.h * this.ratio);
	            size.w = int(size.w * this.ratio);
	        } 
	        super.setTileSize(size);	
		}
		
		private function getGridBounds():Bounds {
			var bottom = this.grid.length - 1;
		    var bottomLeftTile = this.grid[bottom][0];
		
		    var right = this.grid[0].length - 1; 
		    var topRightTile = this.grid[0][right];
		
		    return new Bounds(bottomLeftTile.bounds.left, 
		                                 bottomLeftTile.bounds.bottom,
		                                 topRightTile.bounds.right, 
		                                 topRightTile.bounds.top);
		}
		
		public function getTilesBounds():Bounds {
	        var bounds = null; 
	        
	        if (this.grid.length) {
	            var bottom = this.grid.length - 1;
	            var bottomLeftTile = this.grid[bottom][0];
	    
	            var right = this.grid[0].length - 1; 
	            var topRightTile = this.grid[0][right];
	    
	            bounds = new Bounds(bottomLeftTile.bounds.left, 
	                                           bottomLeftTile.bounds.bottom,
	                                           topRightTile.bounds.right, 
	                                           topRightTile.bounds.top);
	            
	        }   
	        return bounds;
		}
		
		public function initSingleTile(bounds:Bounds):void {
	        var center = bounds.getCenterLonLat();
	        var tileWidth = bounds.getWidth() * this.ratio;
	        var tileHeight = bounds.getHeight() * this.ratio;
	                                       
	        var tileBounds = 
	            new Bounds(center.lon - (tileWidth/2),
	                                  center.lat - (tileHeight/2),
	                                  center.lon + (tileWidth/2),
	                                  center.lat + (tileHeight/2));
	  
	        var ul = new LonLat(tileBounds.left, tileBounds.top);
	        var px = this.map.getLayerPxFromLonLat(ul);
	
	        if (!this.grid.length) {
	            this.grid[0] = [];
	        }
	
	        var tile = this.grid[0][0];
	        if (!tile) {
	            tile = this.addTile(tileBounds, px);
	            
	            this.addTileMonitoringHooks(tile);
	            tile.draw();
	            this.grid[0][0] = tile;
	        } else {
	            tile.moveTo(tileBounds, px);
	        }           

	        this.removeExcessTiles(1,1);
		}
		
		public function initGriddedTiles(bounds:Bounds):void {
	        var viewSize = this.map.getSize();
	        var minRows = Math.ceil(viewSize.h/this.tileSize.h) + 
	                      Math.max(1, 2 * this.buffer);
	        var minCols = Math.ceil(viewSize.w/this.tileSize.w) +
	                      Math.max(1, 2 * this.buffer);
	        
	        var extent = this.map.getMaxExtent();
	        var resolution = this.map.getResolution();
	        var tilelon = resolution * this.tileSize.w;
	        var tilelat = resolution * this.tileSize.h;
	        
	        var offsetlon = bounds.left - extent.left;
	        var tilecol = Math.floor(offsetlon/tilelon) - this.buffer;
	        var tilecolremain = offsetlon/tilelon - tilecol;
	        var tileoffsetx = -tilecolremain * this.tileSize.w;
	        var tileoffsetlon = extent.left + tilecol * tilelon;
	        
	        var offsetlat = bounds.top - (extent.bottom + tilelat);  
	        var tilerow = Math.ceil(offsetlat/tilelat) + this.buffer;
	        var tilerowremain = tilerow - offsetlat/tilelat;
	        var tileoffsety = -tilerowremain * this.tileSize.h;
	        var tileoffsetlat = extent.bottom + tilerow * tilelat;
	        
	        tileoffsetx = Math.round(tileoffsetx); // heaven help us
	        tileoffsety = Math.round(tileoffsety);
	
	        this.origin = new Pixel(tileoffsetx, tileoffsety);
	
	        var startX = tileoffsetx; 
	        var startLon = tileoffsetlon;
	
	        var rowidx = 0;
	    
	        do {
	            var row = this.grid[rowidx++];
	            if (!row) {
	                row = [];
	                this.grid.push(row);
	            }
	
	            tileoffsetlon = startLon;
	            tileoffsetx = startX;
	            var colidx = 0;
	 
	            do {
	                var tileBounds = 
	                    new Bounds(tileoffsetlon, 
	                                          tileoffsetlat, 
	                                          tileoffsetlon + tilelon,
	                                          tileoffsetlat + tilelat);
	
	                var x = tileoffsetx;
	                x -= int(this.map.layerContainerCanvas.x);
	
	                var y = tileoffsety;
	                y -= int(this.map.layerContainerCanvas.y);
	
	                var px = new Pixel(x, y);
	                var tile = row[colidx++];
	                if (!tile) {
	                    tile = this.addTile(tileBounds, px);
	                    this.addTileMonitoringHooks(tile);
	                    row.push(tile);
	                } else {
	                    tile.moveTo(tileBounds, px, false);
	                }
	     
	                tileoffsetlon += tilelon;       
	                tileoffsetx += this.tileSize.w;
	            } while ((tileoffsetlon <= bounds.right + tilelon * this.buffer)
	                     || colidx < minCols)  
	             
	            tileoffsetlat -= tilelat;
	            tileoffsety += this.tileSize.h;
	        } while((tileoffsetlat >= bounds.bottom - tilelat * this.buffer)
	                || rowidx < minRows)
	        
	        this.removeExcessTiles(rowidx, colidx);
	
	        this.spiralTileLoad();
		}
		
		private function _initTiles():void {
	        var viewSize:Size = this.map.getSize();
	        var minRows:Number = Math.ceil(viewSize.h/this.tileSize.h) + 1;
	        var minCols:Number = Math.ceil(viewSize.w/this.tileSize.w) + 1;
	        
	        var bounds:Bounds = this.map.getExtent();
	        var extent:Bounds = this.map.getMaxExtent();
	        var resolution:Number = this.map.getResolution();
	        var tilelon:Number = resolution * this.tileSize.w;
	        var tilelat:Number = resolution * this.tileSize.h;
	        
	        var offsetlon:Number = bounds.left - extent.left;
	        var tilecol:Number = Math.floor(offsetlon/tilelon) - this.buffer;
	        var tilecolremain:Number = offsetlon/tilelon - tilecol;
	        var tileoffsetx:Number = -tilecolremain * this.tileSize.w;
	        var tileoffsetlon:Number = extent.left + tilecol * tilelon;
	        
	        var offsetlat:Number = bounds.top - (extent.bottom + tilelat);  
	        var tilerow:Number = Math.ceil(offsetlat/tilelat) + this.buffer;
	        var tilerowremain:Number = tilerow - offsetlat/tilelat;
	        var tileoffsety:Number = -tilerowremain * this.tileSize.h;
	        var tileoffsetlat:Number = extent.bottom + tilerow * tilelat;
	        
	        tileoffsetx = Math.round(tileoffsetx);
	        tileoffsety = Math.round(tileoffsety);
	
	        this.origin = new Pixel(tileoffsetx, tileoffsety);
	
	        var startX:Number = tileoffsetx; 
	        var startLon:Number = tileoffsetlon;
	
	        var rowidx = 0;
	    
	        do {
	            var row = this.grid[rowidx++];
	            if (!row) {
	                row = new Array();
	                this.grid.push(row);
	            }
	
	            tileoffsetlon = startLon;
	            tileoffsetx = startX;
	            var colidx = 0;
	 
	            do {
	                var tileBounds:Bounds = new Bounds(tileoffsetlon, 
	                                                      tileoffsetlat, 
	                                                      tileoffsetlon + tilelon,
	                                                      tileoffsetlat + tilelat);
	
	                var x:Number = tileoffsetx;
	                x -= int(this.map.layerContainerCanvas.x);
	
	                var y:Number = tileoffsety;
	                y -= int(this.map.layerContainerCanvas.y);
	
	                var px:Pixel = new Pixel(x, y);
	                var tile:Tile = row[colidx++];
	                if (!tile) {
	                    tile = this.addTile(tileBounds, px);
	                    row.push(tile);
	                } else {
	                    tile.moveTo(tileBounds, px, false);
	                }
	     
	                tileoffsetlon += tilelon;       
	                tileoffsetx += this.tileSize.w;
	            } while ((tileoffsetlon <= bounds.right + tilelon * this.buffer)
	                     || colidx < minCols)  
	             
	            tileoffsetlat -= tilelat;
	            tileoffsety += this.tileSize.h;
	        } while((tileoffsetlat >= bounds.bottom - tilelat * this.buffer)
	                || rowidx < minRows)

	        while (this.grid.length > rowidx) {
	            var row = this.grid.pop();
	            for (var i=0, l=row.length; i<l; i++) {
	                row[i].destroy();
	            }
	        }

	        while (this.grid[0].length > colidx) {
	            for (var i=0, l=this.grid.length; i<l; i++) {
	                var row = this.grid[i];
	                var tile = row.pop();
	                tile.destroy();
	            }
	        }

	        this.spiralTileLoad();
		}
		
		private function spiralTileLoad():void {
			var tileQueue:Array = new Array();
 
	        var directions:Array = ["right", "down", "left", "up"];
	
	        var iRow:int = 0;
	        var iCell:int = -1;
	        var direction:int = Util.indexOf(directions, "right");
	        var directionsTried:int = 0;
	        
	        while( directionsTried < directions.length) {
	
	            var testRow = iRow;
	            var testCell = iCell;
	
	            switch (directions[direction]) {
	                case "right":
	                    testCell++;
	                    break;
	                case "down":
	                    testRow++;
	                    break;
	                case "left":
	                    testCell--;
	                    break;
	                case "up":
	                    testRow--;
	                    break;
	            } 

	            var tile = null;
	            if ((testRow < this.grid.length) && (testRow >= 0) &&
	                (testCell < this.grid[0].length) && (testCell >= 0)) {
	                tile = this.grid[testRow][testCell];
	            }
	            
	            if ((tile != null) && (!tile.queued)) {
	                tileQueue.unshift(tile);
	                tile.queued = true;

	                directionsTried = 0;
	                iRow = testRow;
	                iCell = testCell;
	            } else {
	                direction = (direction + 1) % 4;
	                directionsTried++;
	            }
	        } 

	        for(var i=0; i < tileQueue.length; i++) {
	            var tile = tileQueue[i]
	            tile.draw();
	            tile.queued = false;       
	        }
		}
		
		public function addTile(bounds:Bounds, position:Pixel):Object {
			return null;
		}
		
		public function addTileMonitoringHooks(tile:Tile):void {
			tile.onLoadStart = function() {
	            //if that was first tile then trigger a 'loadstart' on the layer
	            if (this.numLoadingTiles == 0) {
	                this.events.triggerEvent("loadstart");
	            }
	            this.numLoadingTiles++;
	        };
	        tile.events.register("loadstart", this, tile.onLoadStart);
	      
	        tile.onLoadEnd = function() {
	            this.numLoadingTiles--;
	            this.events.triggerEvent("tileloaded");
	            //if that was the last tile, then trigger a 'loadend' on the layer
	            if (this.numLoadingTiles == 0) {
	                this.events.triggerEvent("loadend");
	            }
	        };
	        tile.events.register("loadend", this, tile.onLoadEnd);
		}
		
		public function removeTileMonitoringHooks(tile:Tile):void {
			tile.events.unregister("loadstart", this, tile.onLoadStart);
        	tile.events.unregister("loadend", this, tile.onLoadEnd);
		}
		
		public function moveGriddedTiles(bounds:Bounds):void {
			var buffer = this.buffer || 1;
	        while (true) {
	            var tlLayer = this.grid[0][0].position;
	            var tlViewPort = 
	                this.map.getViewPortPxFromLayerPx(tlLayer);
	            if (tlViewPort.x > -this.tileSize.w * (buffer - 1)) {
	                this.shiftColumn(true);
	            } else if (tlViewPort.x < -this.tileSize.w * buffer) {
	                this.shiftColumn(false);
	            } else if (tlViewPort.y > -this.tileSize.h * (buffer - 1)) {
	                this.shiftRow(true);
	            } else if (tlViewPort.y < -this.tileSize.h * buffer) {
	                this.shiftRow(false);
	            } else {
	                break;
	            }
	        };
	        if (this.buffer == 0) {
	            for (var r=0, rl=this.grid.length; r<rl; r++) {
	                var row = this.grid[r];
	                for (var c=0, cl=row.length; c<cl; c++) {
	                    var tile = row[c];
	                    if (!tile.drawn && 
	                        tile.bounds.intersectsBounds(bounds, false)) {
	                        tile.draw();
	                    }
	                }
	            }
	        }
		}
		
		override public function mergeNewParams(newArguments:Array):void {
	        super.mergeNewParams([newArguments]);
	
	        if (this.map != null) {
	            this._initTiles();
	        }
		}
		
		private function shiftRow(prepend:Boolean):void {
			var modelRowIndex = (prepend) ? 0 : (this.grid.length - 1);
	        var modelRow = this.grid[modelRowIndex];
	
	        var resolution = this.map.getResolution();
	        var deltaY = (prepend) ? -this.tileSize.h : this.tileSize.h;
	        var deltaLat = resolution * -deltaY;
	
	        var row = (prepend) ? this.grid.pop() : this.grid.shift();
	
	        for (var i=0; i < modelRow.length; i++) {
	            var modelTile = modelRow[i];
	            var bounds = modelTile.bounds.clone();
	            var position = modelTile.position.clone();
	            bounds.bottom = bounds.bottom + deltaLat;
	            bounds.top = bounds.top + deltaLat;
	            position.y = position.y + deltaY;
	            row[i].moveTo(bounds, position);
	        }
	
	        if (prepend) {
	            this.grid.unshift(row);
	        } else {
	            this.grid.push(row);
	        }
		}
		
		private function shiftColumn(prepend:Boolean):void {
			var deltaX = (prepend) ? -this.tileSize.w : this.tileSize.w;
	        var resolution = this.map.getResolution();
	        var deltaLon = resolution * deltaX;
	
	        for (var i=0; i<this.grid.length; i++) {
	            var row = this.grid[i];
	            var modelTileIndex = (prepend) ? 0 : (row.length - 1);
	            var modelTile = row[modelTileIndex];
	            
	            var bounds = modelTile.bounds.clone();
	            var position = modelTile.position.clone();
	            bounds.left = bounds.left + deltaLon;
	            bounds.right = bounds.right + deltaLon;
	            position.x = position.x + deltaX;
	
	            var tile = prepend ? this.grid[i].pop() : this.grid[i].shift()
	            tile.moveTo(bounds, position);
	            if (prepend) {
	                this.grid[i].unshift(tile);
	            } else {
	                this.grid[i].push(tile);
	            }
	        }
		}
		
		public function removeExcessTiles(rows:int, columns:int):void {
	        while (this.grid.length > rows) {
	            var row = this.grid.pop();
	            for (var i=0, l=row.length; i<l; i++) {
	                var tile = row[i];
	                this.removeTileMonitoringHooks(tile)
	                tile.destroy();
	            }
	        }
	        
	        while (this.grid[0].length > columns) {
	            for (var i=0, l=this.grid.length; i<l; i++) {
	                var row = this.grid[i];
	                var tile = row.pop();
	                this.removeTileMonitoringHooks(tile);
	                tile.destroy();
	            }
	        }
		}
		
		override public function onMapResize():void {
			if (this.singleTile) {
				this.clearGrid();
				this.setTileSize();
				this.initSingleTile(this.map.getExtent());
			}			
		}
		
		public function getTileBounds(viewPortPx:Pixel):Bounds {
	        var maxExtent = this.map.getMaxExtent();
	        var resolution = this.getResolution();
	        var tileMapWidth = resolution * this.tileSize.w;
	        var tileMapHeight = resolution * this.tileSize.h;
	        var mapPoint = this.getLonLatFromViewPortPx(viewPortPx);
	        var tileLeft = maxExtent.left + (tileMapWidth *
	                                         Math.floor((mapPoint.lon -
	                                                     maxExtent.left) /
	                                                    tileMapWidth));
	        var tileBottom = maxExtent.bottom + (tileMapHeight *
	                                             Math.floor((mapPoint.lat -
	                                                         maxExtent.bottom) /
	                                                        tileMapHeight));
	        return new Bounds(tileLeft, tileBottom,
	                                     tileLeft + tileMapWidth,
	                                     tileBottom + tileMapHeight);
		}
		
		private var CLASS_NAME:String = "FlexLayers.Layer.GridNeo";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}
	}
}