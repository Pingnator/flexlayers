package edu.psu.geovista.flexlayers.basetypes
{
	public class Size
	{
		public var w:Number = 0.0;
		public var h:Number = 0.0;
		
		public function Size(w:Number = NaN, h:Number = NaN):void {
			this.w = w;
			this.h = h;
		}
		
		public function toString():String {
			return "w=" + this.w + ",h=" + this.h;
		}
		
		public function clone():Size {
			return new Size(this.w, this.h);
		}
		
		public function equals(sz:Size):Boolean {
			var equals = false;
			if (sz != null) {
				equals = this.w == sz.w && this.h == sz.h;
			}
			return equals;
		}
		
		public var CLASS_NAME:String = "Size";
	}
}