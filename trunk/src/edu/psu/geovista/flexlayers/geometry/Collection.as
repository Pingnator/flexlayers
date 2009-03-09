package edu.psu.geovista.flexlayers.geometry
{
	import edu.psu.geovista.flexlayers.Geometry;
	import edu.psu.geovista.flexlayers.basetypes.Bounds;
	import edu.psu.geovista.flexlayers.Util;
	
	public class Collection extends Geometry
	{
		
		public var components:Array = null;
		
    	private var componentTypes:Array = null;
    	
    	public function Collection(components:Object):void {
    		super();
	        this.components = new Array();
	        if (components != null) {
	            this.addComponents(components);
	        }
    	}
    	
    	override public function destroy():void {
	        this.components.length = 0;
	        this.components = null;
    	}
		
		public function clone():Object {
			var geometry = "new " + this.getClassName() + "()";
	        for(var i=0; i<this.components.length; i++) {
	            geometry.addComponent(this.components[i].clone());
	        }
	        
	        Util.applyDefaults(geometry, this);
	        
	        return geometry;
		}
		
		public function getComponentsString():String {
			var strings = [];
	        for(var i = 0; i < this.components.length; i++) {
	            strings.push(this.components[i].toShortString()); 
	        }
	        return strings.join(",");
		}
		
		override public function calculateBounds():void {
			this.bounds = null;
	        if ( !this.components || (this.components.length > 0)) {
	            this.setBounds(this.components[0].getBounds());
	            for (var i = 1; i < this.components.length; i++) {
	                this.extendBounds(this.components[i].getBounds());
	            }
	        }
		}
		
		public function addComponents(components:Object):void {
			if(!(components instanceof Array)) {
	            components = [components];
	        }
	        for(var i=0; i < components.length; i++) {
	            this.addComponent(components[i]);
	        }
		}
		
		public function addComponent(component:Object, index:Number = NaN):Boolean {
			var added = false;
	        if(component) {
	            if(!(component is Array) && (this.getComponentTypes() == null ||
	               (Util.indexOf(this.getComponentTypes(),
	                                        component.getClassName()) > -1))) {
	
	                if(index != NaN && (index < this.components.length)) {
	                    var components1 = this.components.slice(0, index);
	                    var components2 = this.components.slice(index, 
	                                                           this.components.length);
	                    components1.push(component);
	                    this.components = components1.concat(components2);
	                } else {
	                    this.components.push(component);
	                }
	                component.parent = this;
	                this.clearBounds();
	                added = true;
	            }
	        }
	        return added;
		}
		
		public function removeComponents(components:Object):void {
			if(!(components instanceof Array)) {
	            components = [components];
	        }
	        for (var i = 0; i < components.length; i++) {
	            this.removeComponent(components[i]);
	        }
		}
		
		public function removeComponent(component:Object):void {    
	        Util.removeItem(this.components, component);
	        
	        this.clearBounds();
		}
		
		override public function getLength():Number {
			var length = 0.0;
	        for (var i = 0; i < this.components.length; i++) {
	            length += this.components[i].getLength();
	        }
	        return length;
		}
		
		override public function getArea():Number {
	        var area = 0.0;
	        for (var i = 0; i < this.components.length; i++) {
	            area += this.components[i].getArea();
	        }
	        return area;
		}
		
		public function move(x:Number, y:Number):void {
			for(var i = 0; i < this.components.length; i++) {
	            this.components[i].move(x, y);
	        }
		}
		
		public function equals(geometry:Object):Boolean {
			var equivalent = true;
	        if(!geometry.getClassName() || (this.getClassName() != geometry.getClassName())) {
	            equivalent = false;
	        } else if(!(geometry.components instanceof Array) ||
	                  (geometry.components.length != this.components.length)) {
	            equivalent = false;
	        } else {
	            for(var i=0; i<this.components.length; ++i) {
	                if(!this.components[i].equals(geometry.components[i])) {
	                    equivalent = false;
	                    break;
	                }
	            }
	        }
	        return equivalent;
		}
		
		private var CLASS_NAME:String = "FlexLayers.Geometry.Collection";
		
		override public function getClassName():String {
			return CLASS_NAME;
		}
		
		public function getComponentTypes():Array {
			return componentTypes;
		}
	}
}