package edu.psu.geovista.flexlayers.basetypes
{
	import edu.psu.geovista.flexlayers.EventOL;
	
	public class FunctionOL
	{
		
		public var func:Function;
		
		public function FunctionOL(func:Function):void {
			this.func = func;
		}
		
		public function bind(object:Object):Function {
			var __method = this, args = [], object = arguments[0];
			for (var i = 1; i < arguments.length; i++)
				args.push(arguments[i]);
			return function(moreargs) {
				for (var i = 0; i < arguments.length; i++)
					args.push(arguments[i]);
				return __method.apply(object, args);
			}
		}
		
		public function bindAsEventListener(object:Object):Function {
			var __method:Function = func;
			return function(event:EventOL):Function {
				return __method.call(object, event);
			}
		}
	}
}