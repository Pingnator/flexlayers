package edu.psu.geovista.flexlayers
{
	import edu.psu.geovista.flexlayers.basetypes.Bounds;
	import edu.psu.geovista.flexlayers.basetypes.LonLat;
	import edu.psu.geovista.flexlayers.feature.Vector;
	import edu.psu.geovista.flexlayers.format.WKT;
	
	public class Geometry
	{
		
		public var id:String = null;

	    public var parent:Geometry = null;

	    public var bounds:Bounds = null;
		
		public function Geometry():void {
			this.id = Util.createUniqueID(this.CLASS_NAME+ "_");
		}
		
		public function destroy():void {
			this.id = null;

        	this.bounds = null;
		}
		
		public function setBounds(bounds:Bounds):void {
			if (bounds) {
	            this.bounds = bounds.clone();
	        }
		}
		
		public function clearBounds():void {
	        this.bounds = null;
	        if (this.parent) {
	            this.parent.clearBounds();
	        }   
		}
		
		public function extendBounds(newBounds:Bounds):void {
			var bounds = this.getBounds();
	        if (!bounds) {
	            this.setBounds(newBounds);
	        } else {
	            this.bounds.extend(newBounds);
	        }
		}
		
		public function getBounds():Bounds {
			if (this.bounds == null) {
	            this.calculateBounds();
	        }
	        return this.bounds;
		}
		
		public function calculateBounds():void {
			
		}
		
		public function atPoint(lonlat:LonLat, toleranceLon:Number, toleranceLat:Number):Boolean {
			var atPoint = false;
	        var bounds = this.getBounds();
	        if ((bounds != null) && (lonlat != null)) {
	
	            var dX = (toleranceLon != NaN) ? toleranceLon : 0;
	            var dY = (toleranceLat != NaN) ? toleranceLat : 0;
	    
	            var toleranceBounds = 
	                new Bounds(this.bounds.left - dX,
	                                      this.bounds.bottom - dY,
	                                      this.bounds.right + dX,
	                                      this.bounds.top + dY);
	
	            atPoint = toleranceBounds.containsLonLat(lonlat);
	        }
	        return atPoint;
		}
		
		public function getLength():Number {
			return 0.0;
		}
		
		public function getArea():Number {
			return 0.0;
		}
		
		public function toString():String {
			return new WKT().write(
	            new Vector(this)
	        ).toString();
		}
		
		private var CLASS_NAME:String = "FlexLayers.Geometry";
		
		public function getClassName():String {
			return CLASS_NAME;
		}
	}
}