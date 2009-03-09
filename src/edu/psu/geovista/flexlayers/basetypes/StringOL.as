package edu.psu.geovista.flexlayers.basetypes
{
	public class StringOL
	{
		
		public static function startsWith(sStart:String):Boolean {
			return (sStart.substr(0,sStart.length) == sStart);
		}
		
		public static function conatins(str:String):Boolean {
			return (indexOf(str) != -1);
		}
		
		public static function indexOf(object:Object):int {
			 for (var i:int = 0; i < length; i++)
			     if (StringOL[i] == object) return i;
			 return -1;
		}
		
		public static function camelize(str:String):String {
			var oStringList:Array = str.split('-');
		    if (oStringList.length == 1) return oStringList[0];
		
		    var camelizedString:String = indexOf('-') == 0
		      ? oStringList[0].charAt(0).toUpperCase() + oStringList[0].substring(1)
		      : oStringList[0];
		
			var len:int = 0;
		    for (var i:int = 1, len = oStringList.length; i < len; i++) {
		      var s:String = oStringList[i];
		      camelizedString += s.charAt(0).toUpperCase() + s.substring(1);
		    }
		
		    return camelizedString;
		}
	}
}