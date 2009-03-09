package edu.psu.geovista.flexlayers.control
{
	import edu.psu.geovista.flexlayers.CanvasOL;
	import edu.psu.geovista.flexlayers.EventOL;
	import edu.psu.geovista.flexlayers.Events;
	import edu.psu.geovista.flexlayers.Util;
	import edu.psu.geovista.flexlayers.basetypes.Pixel;
	import edu.psu.geovista.flexlayers.basetypes.Size;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	public class PanZoomBar extends PanZoom
	{
		
	    public var zoomStopWidth:Number = 18;

	    public var zoomStopHeight:Number = 11;

	    public var slider:DisplayObject = null;

	    public var sliderEvents:Events = null;

	    public var zoomBarCanvas:CanvasOL = null;

	    public var canvasEvents:Events = null;
	    
	    public var startTop:Number = NaN;
	    
	    public var mouseDragStart:Pixel = null;
	    
	    public var zoomStart:Pixel = null;
	    
	    public function PanZoomBar(options:Object = null):void {
	    	super(options);
	    }
	    
	    override public function destroy():void {
	    	this.canvas.removeChild(this.slider);
	        this.slider = null;
	
	        this.sliderEvents.destroy();
	        this.sliderEvents = null;
	        
	        this.canvas.removeChild(this.zoomBarCanvas);
	        this.zoomBarCanvas = null;
	
	        this.canvasEvents.destroy();
	        this.canvasEvents = null;
	
	        this.map.events.unregister("zoomend", this, this.moveZoomBar);
	        this.map.events.unregister("changebaselayer", this, this.redraw)
	
	        super.destroy();
	    }
	    
	    override public function setMap(map:Object):void {
	    	super.setMap(map);
	    	this.map.events.register("changebaselayer", this, this.redraw);
	    }
	    
	    public function redraw(obt:Object = null):void {
	    	if (this.canvas != null) {
	    		this.canvas.removeAllChildren();
	    	}
	    	this.draw();
	    }
	    
	    override public function draw(px:Pixel=null, toSuper:Boolean = true):CanvasOL {
	        super.draw(px, toSuper);
	        px = this.position.clone();

	        this.buttons = [];
	
	        var sz = new Size(18,18);
	        var centered = new Pixel(px.x+sz.w/2, px.y);
	
	        this._addButton("panup", Util.getImagesLocation() + "north-mini.png", centered, sz, "Pan Up");
	        px.y = centered.y+sz.h;
	        this._addButton("panleft", Util.getImagesLocation() + "west-mini.png", px, sz, "Pan Left");
	        this._addButton("panright", Util.getImagesLocation() + "east-mini.png", px.add(sz.w, 0), sz, "Pan Right");
	        this._addButton("pandown", Util.getImagesLocation() + "south-mini.png", centered.add(0, sz.h*2), sz, "Pan Down");
	        this._addButton("zoomin", Util.getImagesLocation() + "zoom-plus-mini.png", centered.add(0, sz.h*3+5), sz, "Zoom In");
	        centered = this._addZoomBar(centered.add(0, sz.h*4 + 5));
	        this._addButton("zoomout", Util.getImagesLocation() + "zoom-minus-mini.png", centered, sz, "Zoom Out");
	        return this.canvas;
	    }
	    
	    public function _addZoomBar(centered:Pixel):Pixel {
        
	        var id = "FlexLayers_Control_PanZoomBar_Slider" + this.map.id;
	        var zoomsToEnd = this.map.getNumZoomLevels() - 1 - this.map.getZoom();
	        var slider:CanvasOL = Util.createAlphaImageCanvas(id,
	                       centered.add(-1, zoomsToEnd * this.zoomStopHeight), 
	                       new Size(20,9), 
	                       Util.getImagesLocation()+"slider.png",
	                       "absolute");
	        slider.toolTip = "Zoom Slider";
	        this.slider = slider;
	        
	        new EventOL().observe(slider, MouseEvent.MOUSE_DOWN, this.zoomBarDown, true);
	        new EventOL().observe(slider, MouseEvent.MOUSE_MOVE, this.zoomBarDrag, true);
	        new EventOL().observe(slider, MouseEvent.MOUSE_UP, this.zoomBarUp, true);
	        new EventOL().observe(slider, MouseEvent.MOUSE_OUT, this.zoomBarUp, true);
	        new EventOL().observe(slider, MouseEvent.DOUBLE_CLICK, this.doubleClick, true);
	        new EventOL().observe(slider, MouseEvent.CLICK, this.doubleClick, true);
	        slider.doubleClickEnabled = true;
	        
	        var sz = new Size();
	        sz.h = this.zoomStopHeight * this.map.getNumZoomLevels();
	        sz.w = this.zoomStopWidth;
	        var canvas = Util.createCanvas(
	                        'FlexLayers_Control_PanZoomBar_Zoombar' + this.map.id,
	                        centered,
	                        sz,
	                        Util.getImagesLocation() + "zoombar.png");
	        canvas.toolTip = "Zoom Bar";
	        canvas.clipContent = true;
	        this.zoomBarCanvas = canvas;
	        
	      /*  this.canvasEvents = new Events(this, canvas, null, true);
	        this.canvasEvents.register(MouseEvent.MOUSE_DOWN, this, this.canvasClick);
	        this.canvasEvents.register(MouseEvent.MOUSE_MOVE, this, this.passEventToSlider);
	        this.canvasEvents.register(MouseEvent.DOUBLE_CLICK, this, this.doubleClick);
	        this.canvasEvents.register(MouseEvent.CLICK, this, this.doubleClick); */
	        new EventOL().observe(canvas, MouseEvent.MOUSE_DOWN, this.canvasClick, true);
	        //new EventOL().observe(canvas, MouseEvent.MOUSE_MOVE, this.passEventToSlider);
	        new EventOL().observe(canvas, MouseEvent.DOUBLE_CLICK, this.doubleClick, true);
	        new EventOL().observe(canvas, MouseEvent.CLICK, this.doubleClick, true);
	        
	        this.canvas.addChild(canvas);
	
	        this.startTop = int(canvas.y);
	        this.canvas.addChild(slider);
	
	        this.map.events.register("zoomend", this, this.moveZoomBar);
	
	        centered = centered.add(0, 
	            this.zoomStopHeight * this.map.getNumZoomLevels());
	        return centered; 
	    }
	    
	    public function passEventToSlider(evt:MouseEvent):void {
	    	//this.sliderEvents.handleBrowserEvent(evt);
	    }
	    
	    public function canvasClick(evt:MouseEvent):void {
	    	if (!EventOL.isLeftClick(evt)) return;
	        var y = evt.stageY;
	        var top = Util.pagePosition(evt.currentTarget)[1];
	        var levels = Math.floor((y - top)/this.zoomStopHeight);
	        this.map.zoomTo((this.map.getNumZoomLevels() -1) -  levels);
	        EventOL.stop(evt);
	    }
	    
	    public function zoomBarDown(evt:MouseEvent):void {
	    	if (!EventOL.isLeftClick(evt)) return;
	        this.map.events.register(MouseEvent.MOUSE_MOVE, this, this.passEventToSlider);
	        this.map.events.register(MouseEvent.MOUSE_UP, this, this.passEventToSlider);
	        this.map.events.register(MouseEvent.MOUSE_OUT, this, this.passEventToSlider);
	        this.mouseDragStart = new Pixel(evt.stageX, evt.stageY);
	        this.zoomStart = new Pixel(evt.stageX, evt.stageY);
	        this.canvas.useHandCursor = true;
	        
	        this.zoomBarCanvas.offsets = null; 
	        EventOL.stop(evt);
	    }
	    
	    public function zoomBarDrag(evt:MouseEvent):void {
	    	if (this.mouseDragStart != null) {
	            var deltaY = this.mouseDragStart.y - evt.stageY;
	            var offsets = Util.pagePosition(this.zoomBarCanvas);
	            if ((evt.stageY - offsets[1]) > 0 && 
	                (evt.stageY - offsets[1]) < int(this.zoomBarCanvas.height) - 2) {
	                var newTop = int(this.slider.y) - deltaY;
	                this.slider.y = newTop;
	            }
	            this.mouseDragStart = new Pixel(evt.stageX, evt.stageY);
	            EventOL.stop(evt);
	        }
	    }
	    
	    public function zoomBarUp(evt:MouseEvent):void {
	    	if (!EventOL.isLeftClick(evt)) return;
	        if (this.zoomStart) {
	            this.canvas.useHandCursor = false;
	            this.map.events.unregister(MouseEvent.MOUSE_UP, this, this.passEventToSlider);
	            this.map.events.unregister(MouseEvent.MOUSE_OUT, this, this.passEventToSlider);
	            this.map.events.unregister(MouseEvent.MOUSE_MOVE, this, this.passEventToSlider);
	            var deltaY = this.zoomStart.y - evt.stageY;
	            this.map.zoomTo(this.map.zoom + Math.round(deltaY/this.zoomStopHeight));
	            this.moveZoomBar();
	            this.mouseDragStart = null;
	            EventOL.stop(evt);
	        }
	    }
	    
	    public function moveZoomBar(evt:MouseEvent = null):void {
		   	var newTop = 
	            ((this.map.getNumZoomLevels()-1) - this.map.getZoom()) * 
	            this.zoomStopHeight + this.startTop + 1;
	        this.slider.y = newTop;
	    }
	    
	    private var CLASS_NAME:String = "FlexLayers.Control.PanZoomBar";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}

	}
}