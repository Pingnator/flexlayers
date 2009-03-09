package edu.psu.geovista.flexlayers.control
{
	import edu.psu.geovista.flexlayers.Control;
	import edu.psu.geovista.flexlayers.basetypes.Pixel;
	import edu.psu.geovista.flexlayers.EventOL;
	import edu.psu.geovista.flexlayers.CanvasOL;
	import edu.psu.geovista.flexlayers.basetypes.Size;
	import edu.psu.geovista.flexlayers.Util;
	import edu.psu.geovista.flexlayers.basetypes.FunctionOL;
	import mx.containers.Canvas;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	public class PanZoom extends Control
	{
		
		public static var X:int = 4;
		public static var Y:int = 4;
		public var slideFactor:int = 50;
		public var buttons:Array = null;
		
		public function PanZoom(options = null):void {
		    super(options);
		    
		    if (this.position == null) {
		    	this.position = new Pixel(PanZoom.X,
		    					PanZoom.Y);
		    }
		}
		
		override public function destroy():void {
			super.destroy();
	        while(this.buttons.length) {
	            var btn = this.buttons.shift();
	            btn.map = null;
	            EventOL.stopObservingElement(MouseEvent.CLICK, btn);
	        }
	        this.buttons = null;
	        this.position = null;
		}
		
		override public function draw(px:Pixel = null, toSuper:Boolean = false):CanvasOL {
	        super.draw(px);
	        if (!toSuper) {
		        px = this.position;
		
		        // place the controls
		        this.buttons = new Array();
		
		        var sz = new Size(18,18);
		        var centered = new Pixel(px.x+sz.w/2, px.y);
		
		        this._addButton("panup", Util.getImagesLocation() + "north-mini.png", centered, sz);
		        px.y = centered.y+sz.h;
		        this._addButton("panleft", Util.getImagesLocation() + "west-mini.png", px, sz);
		        this._addButton("panright", Util.getImagesLocation() + "east-mini.png", px.add(sz.w, 0), sz);
		        this._addButton("pandown", Util.getImagesLocation() + "south-mini.png", 
		                        centered.add(0, sz.h*2), sz);
		        this._addButton("zoomin", Util.getImagesLocation() + "zoom-plus-mini.png", 
		                        centered.add(0, sz.h*3+5), sz);
		        this._addButton("zoomworld", Util.getImagesLocation() + "zoom-world-mini.png", 
		                        centered.add(0, sz.h*4+5), sz);
		        this._addButton("zoomout", Util.getImagesLocation() + "zoom-minus-mini.png", 
		                        centered.add(0, sz.h*5+5), sz);
	        }
	        return this.canvas;
		}
		
		public function _addButton(id:String, img:String, xy:Pixel, sz:Size, alt:String = null):CanvasOL {
	        var btn:CanvasOL = Util.createAlphaImageCanvas(
	                                    "OpenLayers_Control_PanZoom_" + id, 
	                                    xy, sz, img, "absolute");
	        btn.clipContent = true;
	        if (alt != null) {                            
	        	btn.toolTip = alt;
	        }
	
	        this.canvas.addChild(btn);
	
	        new EventOL().observe(btn, MouseEvent.CLICK, 
                                 this.buttonDown, true);
        	//new EventOL().observe(btn, MouseEvent.MOUSE_UP, 
             //                    this.doubleClick, true);
        	new EventOL().observe(btn, MouseEvent.DOUBLE_CLICK, 
                                 this.doubleClick, true);
        /*	new EventOL().observe(btn, MouseEvent.CLICK, 
                                 this.doubleClick, true);*/
	        btn.action = id;
	        btn.map = this.map;
	        btn.slideFactor = this.slideFactor;
	
	        //we want to remember/reference the outer div
	        this.buttons.push(btn);
	        return btn;
		}
		
		public function doubleClick(evt:Event):Boolean {
			evt.stopPropagation();
        	return false;
		}
		
		public function buttonDown(evt:Event):void {
			if (!(evt.type == MouseEvent.CLICK)) return;
		
			var btn:CanvasOL = evt.currentTarget as CanvasOL;
	
	        switch (btn.action) {
	            case "panup": 
	                this.map.pan(0, -50);
	                break;
	            case "pandown": 
	                this.map.pan(0, 50);
	                break;
	            case "panleft": 
	                this.map.pan(-50, 0);
	                break;
	            case "panright": 
	                this.map.pan(50, 0);
	                break;
	            case "zoomin": 
	                this.map.zoomIn(); 
	                break;
	            case "zoomout": 
	                this.map.zoomOut(); 
	                break;
	            case "zoomworld": 
	                this.map.zoomToMaxExtent(); 
	                break;
	        }
		}
		
		private var CLASS_NAME:String = "FlexLayers.Control.PanZoom";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}
		
	}
}