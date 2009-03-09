package edu.psu.geovista.flexlayers.geometry
{
	public class MultiPoint extends Collection
	{
		
		private var componentTypes:Array = ["FlexLayers.Geometry.Point"];
		
		public function MultiPoint(components:Object = null):void {
			super(components);
		}
		
		
	    public function addPoint(point:Object, index:Number) {
	        this.addComponent(point, index);
	    }
	    
		public function removePoint(point:Object){
	        this.removeComponent(point);
	    }
	    
	    private var CLASS_NAME:String = "FlexLayers.Geometry.MultiPoint";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}
		
		override public function getComponentTypes():Array {
			return componentTypes;
		}
	}
}