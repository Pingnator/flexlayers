package edu.psu.geovista.flexlayers.control
{
	import edu.psu.geovista.flexlayers.Control;
	import edu.psu.geovista.flexlayers.CanvasOL;
	import edu.psu.geovista.flexlayers.EventOL;
	import edu.psu.geovista.flexlayers.Map;
	import mx.controls.RadioButton;
	import mx.controls.CheckBox;
	import flash.events.MouseEvent;
	import mx.controls.Label;
	import edu.psu.geovista.flexlayers.Util;
	import edu.psu.geovista.flexlayers.basetypes.Size;
	import flash.events.Event;
	import edu.psu.geovista.flexlayers.basetypes.Pixel;
	import edu.psu.geovista.flexlayers.Layer;
	import mx.controls.Text;
	import edu.psu.geovista.flexlayers.RadioButtonOL;
	import edu.psu.geovista.flexlayers.CheckBoxOL;
	
	public class LayerSwitcher extends Control
	{
		
		public var activeColor:String = "#00008B";
	    
	    public var layersCanvas:CanvasOL = null;

	    public var baseLayersCanvas:CanvasOL = null;

	    public var baseLayers:Array = null;

	    public var dataLbl:Text = null;
	    
	    public var dataLayersCanvas:CanvasOL = null;

	    public var dataLayers:Array = null;

	    public var minimizeCanvas:CanvasOL = null;

	    public var maximizeCanvas:CanvasOL = null;

	    public var ascending:Boolean = true;
	    
	    public var mouseDown:Boolean;
	    
	    public var canWidth:Number;
	    
	    public var baseLayerCount:int = 0;
	    
	    public var dataLayerCount:int = 0;

		public function LayerSwitcher(options:Object = null):void {
			super(options);
			this.layersCanvas = new CanvasOL();
			this.baseLayersCanvas = new CanvasOL();
			this.dataLayersCanvas = new CanvasOL();
		}
		
		override public function destroy():void {
			EventOL.stopObservingElement("click", this.canvas);

	        EventOL.stopObservingElement("click", this.minimizeCanvas);
	        EventOL.stopObservingElement("click", this.maximizeCanvas);
	        
	        this.clearLayersArray("base");
	        this.clearLayersArray("data");
	        
	        this.map.events.unregister("addlayer", this, this.redraw);
	        this.map.events.unregister("changelayer", this, this.redraw);
	        this.map.events.unregister("removelayer", this, this.redraw);
	        this.map.events.unregister("changebaselayer", this, this.redraw);
	        
	        super.destroy();
		}
		
		override public function setMap(map:Object):void {
			super.setMap(map);

	        this.map.events.register("addlayer", this, this.redraw);
	        this.map.events.register("changelayer", this, this.redraw);
	        this.map.events.register("removelayer", this, this.redraw);
	        this.map.events.register("changebaselayer", this, this.redraw);
		}
		
		override public function draw(px:Pixel = null, toSuper:Boolean = false):CanvasOL {
			super.draw();

	        this.redraw();
	        
	        this.loadContents();    
	
	        return this.canvas;
		}
		
		public function clearLayersArray(layersType:String):void {
			var layers = this[layersType + "Layers"];
	        if (layers) {
	            for(var i=0; i < layers.length; i++) {
	                var layer = layers[i];
	                EventOL.stopObservingElement("click", layer.inputElem);
	                EventOL.stopObservingElement("click", layer.labelSpan);
	            }
	        }
	        this[layersType + "Layers"] = new Array();
		}
		
		public function redraw(obt:Object = null):CanvasOL {
	        this.clearLayersArray("base");
	        this.clearLayersArray("data");
	        baseLayerCount = 0;
	        dataLayerCount = 0;
	        
	        var containsOverlays:Boolean = false;
	        
	        var layers = this.map.layers.slice();
	        if (!this.ascending) { layers.reverse(); }
	        for( var i = 0; i < layers.length; i++) {
	            var layer = layers[i];
	            var baseLayer = layer.isBaseLayer;
	
	            if (baseLayer || layer.displayInLayerSwitcher) {
	
	                if (!baseLayer) {
	                    containsOverlays = true;
	                }
	
	                var checked = (baseLayer) ? (layer == this.map.baseLayer)
	                                          : layer.getVisibility();

					var type:String = (baseLayer) ? "radio" : "checkbox";
	                var inputElem = createElement(type);
	                inputElem.id = "input_" + layer.name;
	                inputElem.name = (baseLayer) ? "baseLayers" : layer.name;
	                inputElem.selected = checked;
	                inputElem.label = layer.name;
	                var layerCount = (baseLayer) ? baseLayerCount : dataLayerCount;
	                inputElem.y = layerCount * 20;
	
	                if (!baseLayer && !layer.inRange) {
	                    inputElem.enabled = false;
	                }
	                var context = {
	                    'inputElem': inputElem,
	                    'layer': layer,
	                    'layerSwitcher': this
	                }
	                inputElem.context = context;
	                new EventOL().observe(inputElem, MouseEvent.CLICK, 
	                              onInputClick);	    
	                
	                var groupArray = (baseLayer) ? this.baseLayers
	                                             : this.dataLayers;
	                groupArray.push({
	                    'layer': layer,
	                    'inputElem': inputElem
	                });
	                                                     
	    
	                var groupCanvas = (baseLayer) ? this.baseLayersCanvas
	                                           : this.dataLayersCanvas;
	                if (baseLayer) {
	                	baseLayerCount++;
	                } else {
	                	dataLayerCount++;
	                }
	                groupCanvas.addChild(inputElem);
	            }
	        }    
	
			this.canvas.width = 200;
			this.canvas.height = (baseLayerCount + dataLayerCount) * 25 + 60;
			if (this.position) {
				this.canvas.x =  this.position.x;
				this.canvas.y =  this.position.y;	
			}
	        return this.canvas;
		}
		
		public function createElement(type:String):Object {
			var element:Object = null;
			if (type == "radio") {
				element = new RadioButtonOL();
				element.styleName = "layerinput";
			} else if (type == "checkbox") {
				element = new CheckBoxOL();
				element.styleName = "layerinput";
			}
			return element;
		}
		
		public function onInputClick(e:MouseEvent):void {
			var inputElem = e.currentTarget;
			if (inputElem.enabled) {
				var context = inputElem.context;
	            if (inputElem is RadioButtonOL) {
	                inputElem.selected = true;
	                context.layer.map.setBaseLayer(context.layer, true);
	                context.layer.map.events.triggerEvent("changebaselayer");
	            } else {
	                inputElem.selected = !inputElem.selected;
	                context.layerSwitcher.updateMap();
	            }
	        }
	        //EventOL.stop(e);
		}
		
		public function onLayerClick(e:MouseEvent):void {
			this.updateMap();
		}
		
		public function updateMap():void {    
	        for(var i=0; i < this.baseLayers.length; i++) {
	            var layerEntry = this.baseLayers[i];
	            if (layerEntry.inputElem.selected) {
	                this.map.setBaseLayer(layerEntry.layer, false);
	            }
	        }

	        for(var i=0; i < this.dataLayers.length; i++) {
	            var layerEntry = this.dataLayers[i];   
	            layerEntry.layer.setVisibility(layerEntry.inputElem.selected, true);
	        }
		}
		
		public function maximizeControl(e:MouseEvent = null):void {
			this.canvas.width = 200;
	        this.canvas.height = (baseLayerCount + dataLayerCount) * 25 + 60;
	        this.canvas.x = this.position.x;
	
	        this.showControls(false);
		}
		
		public function minimizeControl(e:MouseEvent = null):void {
	        this.canvas.width = 20;
			this.canvas.height = 0;
			this.canvas.x = this.position.x + 200 - 20;
	
	        this.showControls(true);
		}
		
		public function showControls(minimize):void {
			this.maximizeCanvas.visible = !minimize;
	        this.minimizeCanvas.visible = minimize;

		}
		
		public function loadContents():void {
	        this.canvas.y = 0;
	        this.canvas.setStyle("fontFamily", "Verdana, Arial");
	        this.canvas.setStyle("fontWeight", "bold");
	        this.canvas.setStyle("fontSize", 10);
	        this.canvas.setStyle("color", "#FFFFFF");
	    
	        new EventOL().observe(this.canvas, MouseEvent.MOUSE_UP, 
	                      this.mouseUpF);
	        new EventOL().observe(this.canvas, MouseEvent.CLICK,
	                      this.ignoreEvent);
	        new EventOL().observe(this.canvas, MouseEvent.MOUSE_DOWN,
	                      this.mouseDownF);
	        new EventOL().observe(this.canvas, MouseEvent.DOUBLE_CLICK, this.ignoreEvent);
	  
	        this.layersCanvas = new CanvasOL();
	        this.layersCanvas.horizontalScrollPolicy = "off";
	        this.layersCanvas.verticalScrollPolicy = "off";
	        this.layersCanvas.id = "layersCanvas";
	        this.layersCanvas.setStyle("backgroundColor", this.activeColor);
	        this.layersCanvas.setStyle("backgroundAlpha", 0.75);
	        
	        // had to set width/height to get transparency in IE to work.
	        // thanks -- http://jszen.blogspot.com/2005/04/ie6-opacity-filter-caveat.html
	        //
	        this.layersCanvas.percentWidth = 100;
	        this.layersCanvas.percentHeight = 100;
	
	        var baseLbl:Label = new Label();
	        baseLbl.htmlText = "<u>Base Layer</u>";
	        
	        this.baseLayersCanvas = new CanvasOL();
	        this.baseLayersCanvas.horizontalScrollPolicy = "off";
	        this.baseLayersCanvas.verticalScrollPolicy = "off";
	        this.baseLayersCanvas.percentWidth = 100;
	                     
	
	        this.dataLbl = new Text();
	        this.dataLbl.htmlText = "<u>Overlays</u>";
	        this.dataLbl.x = 3;
	        this.dataLbl.y = 3;
	        
	        this.dataLayersCanvas = new CanvasOL();
	        this.dataLayersCanvas.horizontalScrollPolicy = "off";
	        this.dataLayersCanvas.verticalScrollPolicy = "off";
	        this.dataLayersCanvas.percentWidth = 100;
	
			if (this.ascending) {
				baseLbl.x = 3;
				baseLbl.y = 23;
				this.baseLayersCanvas.x = 3;
				this.baseLayersCanvas.y = 43;
				this.dataLbl.x = 3;
				this.dataLbl.y = 83;
				this.dataLayersCanvas.x = 3;
				this.dataLayersCanvas.y = 103;
			} else {
				this.dataLbl.x = 3;
				this.dataLbl.y = 23;
				this.dataLayersCanvas.x = 3;
				this.dataLayersCanvas.y = 43;
				baseLbl.x = 3;
				baseLbl.y = 83;
				this.baseLayersCanvas.x = 3;
				this.baseLayersCanvas.y = 103;
			}
	
            this.layersCanvas.addChild(baseLbl);
            this.layersCanvas.addChild(this.baseLayersCanvas);
            this.layersCanvas.addChild(this.dataLbl);
            this.layersCanvas.addChild(this.dataLayersCanvas); 
 
	        this.canvas.addChild(this.layersCanvas);
	
			this.layersCanvas.setStyle("cornerRadius", 5);

	        var sz = new Size(18,18);        
	
	        var img = Util.getImagesLocation() + 'layer-switcher-maximize.png';
	        this.maximizeCanvas = Util.createAlphaImageCanvas(
	                                    "FlexLayers_Control_MaximizeDiv", 
	                                    null, 
	                                    sz, 
	                                    img, 
	                                    "absolute");
	        this.maximizeCanvas.y = 5;
	        this.maximizeCanvas.x = 3;
	        this.maximizeCanvas.visible = false;
	        new EventOL().observe(this.maximizeCanvas, 
	                      MouseEvent.CLICK, 
	                      this.maximizeControl);
	        
	        this.canvas.addChild(this.maximizeCanvas);

	        var img = Util.getImagesLocation() + 'layer-switcher-minimize.png';
	        var sz:Size = new Size(18,18);        
	        this.minimizeCanvas = Util.createAlphaImageCanvas(
	                                    "FlexLayers_Control_MinimizeDiv", 
	                                    null, 
	                                    sz, 
	                                    img, 
	                                    "absolute");
	        this.minimizeCanvas.y = 5;
	        this.minimizeCanvas.x = 3;
	        this.minimizeCanvas.visible = true;
	        new EventOL().observe(this.minimizeCanvas, 
	                      MouseEvent.CLICK, 
	                      this.minimizeControl);
	
	        this.canvas.addChild(this.minimizeCanvas);
		}
		
		public function ignoreEvent(evt:Event):void {
			EventOL.stop(evt);
		}
		
		public function mouseDownF(evt:Event):void {
			this.mouseDown = true;
        	this.ignoreEvent(evt);
		}
		
		public function mouseUpF(evt:Event):void {
			if (this.mouseDown) {
	            this.mouseDown = false;
	            this.ignoreEvent(evt);
	        }
		}
		
		private var CLASS_NAME:String = "FlexLayers.Control.LayerSwitcher";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}
	}
}