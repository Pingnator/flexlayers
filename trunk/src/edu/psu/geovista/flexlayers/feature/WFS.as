package edu.psu.geovista.flexlayers.feature
{
	import edu.psu.geovista.flexlayers.Feature;
	import edu.psu.geovista.flexlayers.Layer;
	import flash.xml.XMLNode;
	import edu.psu.geovista.flexlayers.FlexLayers;
	import edu.psu.geovista.flexlayers.Util;
	import edu.psu.geovista.flexlayers.basetypes.LonLat;
	
	public class WFS extends edu.psu.geovista.flexlayers.Feature
	{
		
		public function WFS(layer:Layer, xmlNode:XML):void {
			var newArguments = arguments;
	        var data = this.processXMLNode(xmlNode);
	        super(layer, data.lonlat, data);
		}
		
		override public function destroy():void {
	        super.destroy();
		}
		
		public function processXMLNode(xmlNode:XML):Object {
	        var point = xmlNode.elements("gml::Point");
	        var text  = Util.getXmlNodeValue(point[0].elements("gml::coordinates")[0]);
	        var floats = text.split(",");
	        return {lonlat: new LonLat(Number(floats[0]),
	                                              Number(floats[1])),
	                id: null};
		}
		
		private var CLASS_NAME:String = "FlexLayers.Feature.WFS";
		
	}
}