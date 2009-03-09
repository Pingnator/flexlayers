package edu.psu.geovista.flexlayers.handler
{
	import edu.psu.geovista.flexlayers.Handler;
	import edu.psu.geovista.flexlayers.basetypes.Pixel;
	import edu.psu.geovista.flexlayers.Control;
	import flash.events.MouseEvent;
	import edu.psu.geovista.flexlayers.EventOL;

	public class MouseWheel extends Handler
	{
		
		public var wheelListener:Function = null;

    	public var mousePosition:Pixel = null;
    	
    	public function MouseWheel(control:Control, callbacks:Object, options:Object = null):void {
    		super(control, callbacks, options);
    		this.wheelListener = this.onWheelEvent;
    	}
    	
    	override public function destroy():void {
    		super.destroy();
    		this.wheelListener = null;
    	}
    	
    	public function onWheelEvent(evt:MouseEvent):void {
	        if (!this.checkModifiers(evt)) {
	            return;
	        }

	        var inMap = false;
	        var elem = evt.currentTarget;
	        while(elem != null) {
	            if (this.map && elem == this.map.can) {
	                inMap = true;
	                break;
	            }
	            elem = elem.parent;
	        }
	        
	        if (inMap) {
	            var delta = 0;
	            if (evt.delta) {
	                delta = evt.delta/120; 
	            }
	            if (delta) {
	                if (delta < 0) {
	                   this.callback("down", [evt]);
	                } else {
	                   this.callback("up", [evt]);
	                }
	            }

	            EventOL.stop(evt);
	        }

    	}
		
		public function mouseMove(evt:MouseEvent):void {
			this.mousePosition = new Pixel(evt.stageX, evt.stageY);
		}
		
		override public function activate(evt:MouseEvent = null):Boolean {
			if (super.activate()){
				var wheelListener = this.wheelListener;
				new EventOL().observe(this.map.can, MouseEvent.MOUSE_WHEEL, wheelListener);
				return true;
			} else {
				return false;
			}
		}
		
		override public function deactivate(evt:MouseEvent = null):Boolean {
			if (super.deactivate()) {
				var wheelListener = this.wheelListener;
				new EventOL().stopObserving(this.map.can, MouseEvent.MOUSE_WHEEL, wheelListener);
				return true;
			} else {
				return false;
			}
		}
		
		public function mouseDown(evt:MouseEvent):void {
			
		}
		
		public function mouseOut(evt:MouseEvent):void {
			
		}
		
		public function click(evt:MouseEvent):void {
			
		}
		
		public function mouseUp(evt:MouseEvent):void {
		}
		
		public function rollOver(evt:MouseEvent):Boolean {
			return true;
		}
		
		public function rollOut(evt:MouseEvent):Boolean {
			return true;
		}
	}
}