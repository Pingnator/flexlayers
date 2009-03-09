package edu.psu.geovista.flexlayers.basetypes
{
	public class Pixel
	{
		
		public var x:Number = 0.0;
		public var y:Number = 0.0;
		
		public function Pixel(x:Number, y:Number):void {
			this.x = x;
			this.y = y;
		}
		
		public function toString():String {
			return "x=" + this.x + ",y=" + this.y;
		}
		
		public function clone():Pixel {
			return new Pixel(this.x, this.y);
		}
		
		public function equals(px:Pixel):Boolean {
			var equals = false;
			if (px != null) {
				equals = this.x == px.x && this.y == px.y;
			}
			return equals;
		}
		
		public function add(x:Number, y:Number):Pixel {
			return  new Pixel(this.x + x, this.y + y);
		}
		
		public function offset(px:Pixel):Pixel {
			var newPx = this.clone();
			if (px) {
				newPx = this.add(px.x, px.y);
			}
			return newPx;
		}
		
		public var CLASS_NAME:String = "Pixel";
	}
}