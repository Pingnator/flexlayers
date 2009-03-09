package edu.psu.geovista.flexlayers.handler
{
	import edu.psu.geovista.flexlayers.Handler;
	import edu.psu.geovista.flexlayers.Control;
	import edu.psu.geovista.flexlayers.basetypes.Pixel;
	import flash.events.MouseEvent;
	import edu.psu.geovista.flexlayers.EventOL;
	import edu.psu.geovista.flexlayers.Util;

	public class Drag extends Handler
	{
		public var started:Boolean = false;
    
    	public var stopDown:Boolean = true;

    	public var oldOnselectstart:Function = null;

		public static var onselectstart:Function = null;

		public function Drag(control:*, callbacks:Object, options:Object = null):void {
			super(control, callbacks, options);
		}
		
		public function down(evt:MouseEvent):void {
			
		}
		
		public function move(evt:MouseEvent):void {
			
		}
		
		public function up(evt:MouseEvent):void {
			
		}
		
		public function out(evt:MouseEvent):void {
			
		}
		
		public function mouseDown(evt:MouseEvent):Boolean {
			var propagate = true;
	        this.dragging = false;
	        if (this.checkModifiers(evt) && EventOL.isLeftClick(evt)) {
	            this.started = true;
	            this.start = new Pixel(evt.localX, evt.localY);
	            this.last = new Pixel(evt.localX, evt.localY);
	            this.map.can.buttonMode = true;
	            this.map.can.useHandCursor = true;
	            this.down(evt);
	            this.callback("down", [new Pixel(evt.localX, evt.localY)]);
	            
	            if(!this.oldOnselectstart) {
	                this.oldOnselectstart = (Drag.onselectstart) ? Drag.onselectstart : function() { return true; };
                	Drag.onselectstart = function() {return false;};
	            }
	            
	            propagate = !this.stopDown;
	        } else {
	            this.started = false;
	            this.start = null;
	            this.last = null;
	        }
	        return propagate;
		}
		
		public function mouseMove(evt:MouseEvent):Boolean {
			if (this.started) {
	            if(evt.localX != this.last.x || evt.localY != this.last.y) {
	                this.dragging = true;
	                this.move(evt);
	                this.callback("move", [new Pixel(evt.localX, evt.localY)]);
	                if(!this.oldOnselectstart) {
	                    this.oldOnselectstart = Drag.onselectstart;
	                    Drag.onselectstart = function() {return false;};
	                }
	                this.last = new Pixel(evt.localX, evt.localY);
	            }
	        }
	        return true;
		}
		
		public function mouseUp(evt:MouseEvent):Boolean {
			if (this.started) {
	            var dragged = (this.start != this.last);
	            this.started = false;
	            this.dragging = false;
	            this.map.can.useHandCursor = false;
	            this.map.can.buttonMode = false;
	            this.up(evt);
	            this.callback("up", [new Pixel(evt.localX, evt.localY)]);
	            if(dragged) {
	                this.callback("done", [new Pixel(evt.localX, evt.localY)]);
	            }
	            Drag.onselectstart = this.oldOnselectstart;
	        }
	        return true;
		}
		
		public function mouseOut(evt:MouseEvent):Boolean {
			if (this.started && Util.mouseLeft(evt, this.map.can)) {
	            var dragged = (this.start != this.last);
	            this.started = false; 
	            this.dragging = false;
	            this.map.can.useHandCursor = false;
	            this.out(evt);
	            this.callback("out", []);
	            if(dragged) {
	                this.callback("done", [new Pixel(evt.localX, evt.localY)]);
	            }
	            if(Drag.onselectstart) {
	                Drag.onselectstart = this.oldOnselectstart;
	            }
	        }
	        return true;
		}
		
		public function rollOver(evt:MouseEvent):Boolean {
			return true;
		}
		
		public function rollOut(evt:MouseEvent):Boolean {
			return true;
		}
		
		public function click(evt:MouseEvent):Boolean {
			return (this.start == this.last);
		}
		
		override public function activate(evt:MouseEvent=null):Boolean {
			var activated = false;
	        if(super.activate(evt)) {
	            this.dragging = false;
	            activated = true;
	        }
	        return activated;
		}
		
		override public function deactivate(evt:MouseEvent=null):Boolean {
			var deactivated = false;
	        if(super.deactivate(evt)) {
	            this.started = false;
	            this.dragging = false;
	            this.start = null;
	            this.last = null;
	            deactivated = true;
	        }
	        return deactivated;
		}
		
		private var CLASS_NAME:String = "FlexLayers.Handler.Drag";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}
	}
}