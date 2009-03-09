package edu.psu.geovista.flexlayers.handler
{
	import edu.psu.geovista.flexlayers.CanvasOL;
	import edu.psu.geovista.flexlayers.Control;
	import edu.psu.geovista.flexlayers.Handler;
	import edu.psu.geovista.flexlayers.Util;
	import edu.psu.geovista.flexlayers.basetypes.Pixel;
	import edu.psu.geovista.flexlayers.basetypes.Bounds;
	
	import flash.events.MouseEvent;

	public class Box extends Handler
	{
		
		public var dragHandler:Drag = null;
		
		public var zoomBox:CanvasOL = null;
		
		public function Box(control:Control, callbacks:Object, options:Object):void {
			super(control, callbacks, options);
			var callbacks = {
	            "down": this.startBox, 
	            "move": this.moveBox, 
	            "out":  this.removeBox,
	            "up":   this.endBox
	        };
	        this.dragHandler = new Drag(
	                                this, callbacks, {keyMask: this.keyMask});
		}
		
		override public function setMap(map:Object):void {
			super.setMap(map);
			if (this.dragHandler) {
            	this.dragHandler.setMap(map);
        	}
		}
		
		public function startBox(xy:Pixel):void {
			this.zoomBox = Util.createCanvas("zoomBox",
                                                 this.dragHandler.start);
            this.zoomBox.setStyle("borderStyle", "solid");
            this.zoomBox.setStyle("borderColor", 0xff0000);
            this.zoomBox.setStyle("borderWidth", 1);
	        this.map.viewPortCanvas.addChild(this.zoomBox);
		}
		
		public function moveBox(xy:Pixel) {
			var startX = this.dragHandler.start.x;
	        var startY = this.dragHandler.start.y;
	        var deltaX = Math.abs(startX - xy.x);
	        var deltaY = Math.abs(startY - xy.y);
	        this.zoomBox.width = Math.max(1, deltaX);
	        this.zoomBox.height = Math.max(1, deltaY);
	        this.zoomBox.x = xy.x < startX ? xy.x : startX;
	        this.zoomBox.y = xy.y < startY ? xy.y : startY;
		}
		
		public function endBox(end:Pixel):void {
			var result;
	        if (Math.abs(this.dragHandler.start.x - end.x) > 5 ||    
	            Math.abs(this.dragHandler.start.y - end.y) > 5) {   
	            var start = this.dragHandler.start;
	            var top = Math.min(start.y, end.y);
	            var bottom = Math.max(start.y, end.y);
	            var left = Math.min(start.x, end.x);
	            var right = Math.max(start.x, end.x);
	            result = new Bounds(left, bottom, right, top);
	        } else {
	            result = this.dragHandler.start.clone(); // i.e. OL.Pixel
	        } 
	        this.removeBox();
	
	        this.callback("done", [result]);
		}
		
		public function removeBox():void {
			this.map.viewPortCanvas.removeChild(this.zoomBox);
        	this.zoomBox = null;
		}
		
		override public function activate(evt:MouseEvent=null):Boolean {
			if (super.activate(evt)) {
				this.dragHandler.activate();
				return true;
			} else {
				return false;
			}
		}
		
		override public function deactivate(evt:MouseEvent=null):Boolean {
			if (super.deactivate(evt)) {
				this.dragHandler.deactivate();
				return true;
			} else {
				return false;
			}
		}
		
		public function mouseDown(evt:MouseEvent):Boolean {
			return true;
		}
		
		public function mouseMove(evt:MouseEvent):Boolean {
			return true;
		}
		
		public function mouseUp(evt:MouseEvent):Boolean {
			return true;
		}
		
		public function mouseOut(evt:MouseEvent):Boolean {
			return true;
		}
		
		public function rollOver(evt:MouseEvent):Boolean {
			return true;
		}
		
		public function rollOut(evt:MouseEvent):Boolean {
			return true;
		}
		
		public function click(evt:MouseEvent):Boolean {
			return true;
		}
		
		private var CLASS_NAME:String = "FlexLayers.Handler.Box";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}
	}
}