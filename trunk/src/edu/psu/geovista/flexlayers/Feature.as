package edu.psu.geovista.flexlayers
{
	import edu.psu.geovista.flexlayers.basetypes.LonLat;
	import edu.psu.geovista.flexlayers.popup.AnchoredBubble;
	import edu.psu.geovista.flexlayers.layer.Vector;
	
	public class Feature
	{
		
		private var events:Events = null;

	    public var layer:Object = null;

	    public var id:String = null;
	    
	    public var lonlat:LonLat = null;

	    public var data:Object = null;
	    
	    private var marker:Marker = null;

	    public var popup:PopupOL = null;
	    
	    public var attributes:Object = null;
	    
	    public var node:Object = null;
		
		public var selected:Boolean = false;
		
		public function Feature(layer:Layer, lonlat:LonLat, data:Object):void {
			this.layer = layer;
	        this.lonlat = lonlat;
	        this.data = (data != null) ? data : new Object();
	        this.id = Util.createUniqueID(this.CLASS_NAME + "_"); 
		}
		
		public function destroy():void {
	        if ((this.layer != null) && (this.layer.map != null)) {
	            if (this.popup != null) {
	                this.layer.map.removePopup(this.popup);
	            }
	        }
	
	        if (this.events) {
	            this.events.destroy();
	        }
	        this.events = null;
	        
	        this.layer = null;
	        this.id = null;
	        this.lonlat = null;
	        this.data = null;
	        if (this.marker != null) {
	            this.destroyMarker();
	            this.marker = null;
	        }
	        if (this.popup != null) {
	            this.destroyPopup();
	            this.popup = null;
	        }
		}
		
		public function onScreen():Boolean {
			var onScreen = false;
	        if ((this.layer != null) && (this.layer.map != null)) {
	            var screenBounds = this.layer.map.getExtent();
	            onScreen = screenBounds.containsLonLat(this.lonlat);
	        }    
	        return onScreen;
		}
		
		public function createMarker():Marker {
			var marker = null;
	        
	        if (this.lonlat != null) {
	            this.marker = new Marker(this.lonlat, this.data.icon, this);
	        }
	        return this.marker;
		}
		
		public function destroyMarker():void {
			this.marker.destroy();
		}
		
		public function createPopup(closeBox:Boolean = false):PopupOL {
			if (this.lonlat != null) {
            
	            var id = this.id + "_popup";
	            var anchor = (this.marker) ? this.marker.icon : null;
	
	            this.popup = new AnchoredBubble(id, 
                                            this.lonlat,
                                            this.data.popupSize,
                                            this.data.popupContentHTML,
                                            anchor, closeBox); 
                                        
                this.popup.feature = this;
	        }        
	        return this.popup;
		}
		
		public function destroyPopup():void {
			this.popup.destroy();
		}
		
		private var CLASS_NAME:String = "Feature";
	}
}