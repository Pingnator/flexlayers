package edu.psu.geovista.flexlayers.layer
{
	import edu.psu.geovista.flexlayers.Feature;
	import edu.psu.geovista.flexlayers.Icon;
	import edu.psu.geovista.flexlayers.FlexLayers;
	import edu.psu.geovista.flexlayers.basetypes.LonLat;
	import edu.psu.geovista.flexlayers.Marker;
	import edu.psu.geovista.flexlayers.basetypes.Size;
	import flash.events.MouseEvent;
	import edu.psu.geovista.flexlayers.EventOL;
	import edu.psu.geovista.flexlayers.Util;
	import mx.rpc.events.ResultEvent;
	
	public class GeoRSS extends Markers
	{
	
		public var location:String = null;

    	public var features:Array = null;

    	public var selectedFeature:Feature = null;

    	public var icon:Icon = null;
    	
    	public function GeoRSS(name:String, location:String, options:Object = null):void {
	        super(name, options);
	        this.location = location;
	        this.features = [];
	        FlexLayers.loadURL(location, null, this, this.parseData);
    	}

		override public function destroy(setNewBaseLayer:Boolean = true):void {
			this.clearFeatures();
        	this.features = null;
        	super.destroy();
		}
		
		public function parseData(resultEvt:ResultEvent):void {
			var doc = resultEvt.result as XML;
	        
	        this.name = null;
	        try {
	            this.name = doc.*::title[0].firstChild.nodeValue;
	        }
	        catch (e) {
	            this.name = doc.title[0].firstChild.nodeValue;
	        }
	        
	        var itemlist:XMLList = null;
	        try {
	            itemlist = doc.*::item;
	        }
	        catch (e) {
	            itemlist = doc.item;
	        }
	
	        if (itemlist.length == 0) {
	            try {
	                itemlist = doc.*::entry;
	            }
	            catch(e) {
	                itemlist = doc.entry;
	            }
	        }
	
	        for (var i = 0; i < itemlist.length; i++) {
	            var data = {};
	            var point = itemlist[i].*::point;
	            var lat = itemlist[i].*::lat;
	            var lon = itemlist[i].*::long;
	            if (point.length > 0) {
	                var location = point[0].firstChild.nodeValue.split(" ");
	                
	                if (location.length != 2) {
	                    var location = point[0].firstChild.nodeValue.split(",");
	                }
	            } else if (lat.length > 0 && lon.length > 0) {
	                var location = [Number(lat[0].firstChild.nodeValue), Number(lon[0].firstChild.nodeValue)];
	            } else {
	                continue;
	            }
	            var location = new LonLat(Number(location[1]), Number(location[0]));

	            var title = "Untitled";
	            try {
	              title = itemlist[i].title[0].firstChild.nodeValue;
	            }
	            catch (e) { title="Untitled"; }

	            var descr_nodes = null;
	            try {
	                descr_nodes = itemlist[i].*::description;
	            }
	            catch (e) {
	                descr_nodes = itemlist[i].description;
	            }
	            if (descr_nodes.length == 0) {
	                try {
	                    descr_nodes = itemlist[i].*::summary;
	                }
	                catch (e) {
	                    descr_nodes = itemlist[i].summary;
	                }
	            }
	
	            var description = "No description.";
	            try {
	              description = descr_nodes[0].firstChild.nodeValue;
	            }
	            catch (e) { description="No description."; }
	
				var link = null;
	            try {
	              link = itemlist[i].link[0].firstChild.nodeValue;
	            } 
	            catch (e) {
	              try {
	                link = itemlist[i].link[0].@href;
	              }
	              catch (e) {}
	            }
	
				if (link != null) {
					this.icon = new Icon(link);
				}
	
	            data.icon = this.icon == null ? 
	                                     Marker.defaultIcon() : 
	                                     this.icon.clone();
	            data.popupSize = new Size(250, 120);
	            if ((title != null) && (description != null)) {
	                var contentHTML = '<div class="olLayerGeoRSSClose">[x]</div>'; 
	                contentHTML += '<div class="olLayerGeoRSSTitle">';
	                if (link) contentHTML += '<a class="link" href="'+link+'" target="_blank">';
	                contentHTML += title;
	                if (link) contentHTML += '</a>';
	                contentHTML += '</div>';
	                contentHTML += '<div style="" class="olLayerGeoRSSDescription">';
	                contentHTML += description;
	                contentHTML += '</div>';
	                data['popupContentHTML'] = contentHTML;                
	            }
	            var feature = new Feature(this, location, data);
	            this.features.push(feature);
	            var marker = feature.createMarker();
	            marker.events.register('click', feature, this.markerClick);
	            this.addMarker(marker);
	        }
		}
		
		public function markerClick(evt:MouseEvent):void {
			var markerClicked = evt.currentTarget as Marker;
			var sameMarkerClicked = (markerClicked == markerClicked.layer.selectedFeature);
	        markerClicked.layer.selectedFeature = (!sameMarkerClicked) ? this : null;
	        for(var i=0; i < markerClicked.layer.map.popups.length; i++) {
	            markerClicked.layer.map.removePopup(markerClicked.layer.map.popups[i]);
	        }
	        if (!sameMarkerClicked) {
	            var popup = markerClicked.createPopup();
	            new EventOL().observe(popup.div, "click",
	            function() { 
	              for(var i=0; i < markerClicked.layer.map.popups.length; i++) { 
	                markerClicked.layer.map.removePopup(markerClicked.layer.map.popups[i]); 
	              } 
	            });
	            markerClicked.layer.map.addPopup(popup); 
	        }
	        EventOL.stop(evt);
		}
		
		public function clearFeatures():void {
			if (this.features != null) {
	            while(this.features.length > 0) {
	                var feature = this.features[0];
	                Util.removeItem(this.features, feature);
	                feature.destroy();
	            }
	        } 
		}
		
		private var CLASS_NAME:String = "FlexLayers.Layer.GeoRSS";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}
	}
}