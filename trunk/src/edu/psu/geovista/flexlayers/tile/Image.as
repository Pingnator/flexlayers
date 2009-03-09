package edu.psu.geovista.flexlayers.tile
{
	import edu.psu.geovista.flexlayers.Tile;
	import edu.psu.geovista.flexlayers.Layer;
	import edu.psu.geovista.flexlayers.basetypes.Pixel;
	import edu.psu.geovista.flexlayers.basetypes.Bounds;
	import edu.psu.geovista.flexlayers.basetypes.Size;
	import edu.psu.geovista.flexlayers.CanvasOL;
	import edu.psu.geovista.flexlayers.Util;
	import edu.psu.geovista.flexlayers.ImageOL;
	import flash.display.DisplayObjectContainer;
	import edu.psu.geovista.flexlayers.FrameOL;
	import flash.display.DisplayObject;
	import mx.containers.Canvas;
	import flash.events.Event;
	import mx.rpc.soap.LoadEvent;
	import edu.psu.geovista.flexlayers.EventOL;
	
	public class Image extends Tile
	{
		private var urlI:String = null;
		private var imgCanvas:Object = null;
		private var img:ImageOL = null;
		private var frame:FrameOL = null;
		public var queued:Boolean = false;
		
		public function Image(layer:Layer, position:Pixel, bounds:Bounds, url:String, size:Size):void {
			super(layer, position, bounds, url, size);
			this.urlI = url;
			this.frame = new FrameOL();
			this.frame.percentWidth = 100;
			this.frame.percentHeight = 100;
			this.frame.style.overflow = "hidden";
			this.frame.style.position = "absolute";
		}
		
		override public function destroy():void {
	        if (this.imgCanvas != null)  {
	            EventOL.stopObservingElement(LoadEvent.LOAD, this.imgCanvas);
	            if (this.imgCanvas.parent == this.frame) {
	                this.frame.removeChild(DisplayObject(this.imgCanvas));
	                this.imgCanvas.map = null;
	            }
	        }
	        this.imgCanvas = null;
	        this.img = null;
	        if ((this.frame != null) && (this.frame.parent as DisplayObject == this.layer.canvas)) { 
	            (this.layer.canvas as Canvas).removeChild(this.frame); 
	        }
	        this.frame = null; 
	        super.destroy();
		}
		
		override public function draw():Boolean {
		    if (this.layer != this.layer.map.baseLayer) {
	            this.bounds = this.getBoundsFromBaseLayer(this.position);
	        }
	        if (!super.draw()) {
	            return false;    
	        }
	        if (this.imgCanvas == null) {
	            this.initImgCanvas();
	        }
	
	        this.imgCanvas.viewRequestID = this.layer.map.viewRequestID;
	        
	        this.urlI = this.layer.getURL(this.bounds);
	        // position the frame 
	        Util.modifyFlexElement(this.frame, 
	                                         null, this.position, this.size);
	        this.frame.visible = true;   
	
	        if (this.layer.alpha) {
	            Util.modifyAlphaImageCanvas(this.imgCanvas,
	                    null, null, this.layer.imageSize, this.urlI);
	        } else {
	         	this.imgCanvas.source = this.urlI;
	            Util.modifyFlexElement(this.imgCanvas,
	                    null, null, this.layer.imageSize) ;
	        }
	        this.drawn = true;
	        return true;
		}
		
		override public function clear():void {
			super.clear();
	        if(this.frame) {
	            this.frame.visible = false;
	        }
		}
		
		public function initImgCanvas():void {
	        if (this.layer.alpha) {
	            this.imgCanvas = Util.createAlphaImageCanvas(null,
	                                                           this.layer.imageOffset,
	                                                           this.layer.imageSize,
	                                                           null,
	                                                           "relative",
	                                                           null,
	                                                           null,
	                                                           null,
	                                                           true);
	        } else {
	            this.imgCanvas = Util.createImage(null,
	                                                      this.layer.imageOffset,
	                                                      this.layer.imageSize,
	                                                      null,
	                                                      "relative",
	                                                      null,
	                                                      null,
	                                                      true);
	        }
	
	        /* checkImgURL used to be used to called as a work around, but it
	           ended up hiding problems instead of solving them and broke things
	           like relative URLs. See discussion on the dev list:
	           http://openlayers.org/pipermail/dev/2007-January/000205.html
	
	        OpenLayers.Event.observe( this.imgDiv, "load",
	                        this.checkImgURL.bindAsEventListener(this) );
	        */
	        
	        this.frame.addChild(DisplayObject(this.imgCanvas));
	        this.layer.canvas.addChild(this.frame); 
	
	        if(this.layer.opacity != -1) {
	            if (imgCanvas != null) {
	     			Util.modifyFlexElement(this.imgCanvas, null, null, null,
	                                             null, null, null, 
	                                             this.layer.opacity);
		        } else if (img != null) {
		        	Util.modifyFlexElement(this.img, null, null, null,
	                                             null, null, null, 
	                                             this.layer.opacity);
		        }
	        }
	
	        // we need this reference to check back the viewRequestID
	        if (imgCanvas != null) {
	        	this.imgCanvas.map = this.layer.map;
	        } else if (img != null) {
	        	this.img.map = this.layer.map;
	        }

		}
	}
}