package edu.psu.geovista.flexlayers.basetypes
{
	public class LonLat
	{
		
		public var lon:Number = 0.0;
		public var lat:Number = 0.0;
		
		public function LonLat(lon:Number, lat:Number):void {
			this.lon = lon;
			this.lat = lat;
		}
		
		public function toString():String {
			return "lon=" + this.lon + ",lat=" + this.lat;
		}
		
		public function toShortString():String {
			return this.lon + ", " + this.lat;
		}
		
		public function clone():LonLat {
			return new LonLat(this.lon, this.lat);
		}
		
		public function add(lon:Number, lat:Number):LonLat {
			return new LonLat(this.lon + lon, this.lat + lat);
		}
		
		public function equals(ll:LonLat):Boolean {
			var equals:Boolean = false;
	        if (ll != null) {
	            equals = this.lon == ll.lon && this.lat == ll.lat;
	        }
	        return equals;
		}
		
		public function fromString(str:String):LonLat {
			var pair:Array = str.split(",");
			return new LonLat(Number(pair[0]), Number(pair[1]));
		}
		
		public var CLASS_NAME:String = "LonLat";
		
	}
}