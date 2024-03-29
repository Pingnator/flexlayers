package edu.psu.geovista.flexlayers
{
	import edu.psu.geovista.flexlayers.basetypes.LonLat;
	import edu.psu.geovista.flexlayers.basetypes.Pixel;
	import edu.psu.geovista.flexlayers.basetypes.Size;
	import flash.events.MouseEvent;
	
	public class Marker
	{
		
	    public var icon:Icon = null;

	    public var lonlat:LonLat = null;

	    public var events:Events = null;
	    
	    public var map:Object = null;
	    
	    public var drawn:Boolean = false;
	    
	    public var data:Object = null;
	    
	    public function Marker(lonlat:LonLat, icon:Icon = null, feature:Feature = null):void {
	    	this.lonlat = lonlat;
	        
	        var newIcon = (icon) ? icon : Marker.defaultIcon();
	        if (this.icon == null) {
	            this.icon = newIcon;
	        } else {
	            this.icon.url = newIcon.url;
	            this.icon.size = newIcon.size;
	            this.icon.offset = newIcon.offset;
	            this.icon.calculateOffset = newIcon.calculateOffset;
	        }
	        this.events = new Events(this, this.icon.imageCanvas, null);
	        
	        this.icon.marker = this;
	        this.data = new Object();
	    }
	    
	    public function destroy():void {
	    	this.map = null;
	
	        this.events.destroy();
	        this.events = null;
	
	        if (this.icon != null) {
	            this.icon.destroy();
	            this.icon = null;
	        }
	    }
	    
	    public function draw(px:Pixel = null):CanvasOL {
	    	return this.icon.draw(px);
	    }
	    
	    public function moveTo(px:Pixel):void {
	        if ((px != null) && (this.icon != null)) {
	            this.icon.moveTo(px);
	        }           
	        this.lonlat = this.map.getLonLatFromLayerPx(px);
     	}
     	
     	public function onScreen():Boolean {
	     	var onScreen = false;
	        if (this.map) {
	            var screenBounds = this.map.getExtent();
	            onScreen = screenBounds.containsLonLat(this.lonlat);
	        }    
	        return onScreen;
     	}
     	
     	public function inflate(inflate:Number):void {
     		if (this.icon) {
	            var newSize = new Size(this.icon.size.w * inflate,
	                                              this.icon.size.h * inflate);
	            this.icon.setSize(newSize);
	        }  
     	}
     	
     	public function setOpacity(opacity:Number):void {
     		this.icon.setOpacity(opacity);
     	}
     	
     	public function display(display:Boolean):void {
     		this.icon.display(display);
     	}
     	
     	public function setIcon(newIcon:Icon):void {
     		this.icon.url = newIcon.url;
            this.icon.size = newIcon.size;
            this.icon.offset = newIcon.offset;
            this.icon.calculateOffset = newIcon.calculateOffset;
     	}
     	
     	public static function defaultIcon():Icon {
	     	var url = Util.getImagesLocation() + "marker.png";
		    var size = new Size(21, 25);
		    var calculateOffset = function(size) {
		                    return new Pixel(-(size.w/2), -size.h);
		                 };
		
		    return new Icon(url, size, null, calculateOffset);
     	}
     	
     	private var CLASS_NAME:String = "FlexLayers.Marker";
		
		public function getClassName():String {
			return CLASS_NAME;
		}
	}
}