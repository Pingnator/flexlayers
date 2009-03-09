package edu.psu.geovista.flexlayers.format
{
	import edu.psu.geovista.flexlayers.Format;
	import edu.psu.geovista.flexlayers.feature.Vector;
	import edu.psu.geovista.flexlayers.geometry.Point;
	import edu.psu.geovista.flexlayers.geometry.MultiPoint;
	import edu.psu.geovista.flexlayers.geometry.MultiLineString;
	import edu.psu.geovista.flexlayers.geometry.LinearRing;
	import edu.psu.geovista.flexlayers.geometry.Polygon;
	import edu.psu.geovista.flexlayers.geometry.MultiPolygon;
	import edu.psu.geovista.flexlayers.geometry.LineString;
	
	public class WKT extends Format
	{
		
		private var regExes:Object;
		
		public function WKT(options:Object = null):void {
			
	        this.regExes = {
	            'typeStr': /^\s*(\w+)\s*\(\s*(.*)\s*\)\s*$/,
	            'spaces': /\s+/,
	            'parenComma': /\)\s*,\s*\(/,
	            'doubleParenComma': /\)\s*\)\s*,\s*\(\s*\(/,
	            'trimParens': /^\s*\(?(.*?)\)?\s*$/
	        };
	        super(options);
		}
		
		override public function read(wkt:Object):Object {
			var features, type, str;
	        var matches = this.regExes.typeStr.exec(wkt);
	        if(matches) {
	            type = matches[1].toLowerCase();
	            str = matches[2];
	            if(this.parse[type]) {
	                features = this.parse[type].apply(this, [str]);
	            }
	        }
	        return features;
		}
		
		override public function write(features:Object):Object {
			var collection, geometry, type, data, isCollection;
	        if(features.constructor == Array) {
	            collection = features;
	            isCollection = true;
	        } else {
	            collection = [features];
	            isCollection = false;
	        }
	        var pieces = [];
	        if(isCollection) {
	            pieces.push('GEOMETRYCOLLECTION(');
	        }
	        for(var i=0; i<collection.length; ++i) {
	            if(isCollection && i>0) {
	                pieces.push(',');
	            }
	            geometry = collection[i].geometry;
	            type = geometry.getClassName().split('.')[2].toLowerCase();
	            if(!extract[type]) {
	                return null;
	            }
	            data = extract[type]([geometry]);
	            pieces.push(type.toUpperCase() + '(' + data + ')');
	        }
	        if(isCollection) {
	            pieces.push(')');
	        }
	        return pieces.join('');
		}
		
		public var extract:Object = {
	        'point': function(point) {
	            return point.x + ' ' + point.y;
	        },
	        'multipoint': function(multipoint) {
	            var array = [];
	            for(var i=0; i<multipoint.components.length; ++i) {
	                array.push(this.extract.point.apply(this, [multipoint.components[i]]));
	            }
	            return array.join(',');
	        },
	        
	        /**
	         * Return a comma delimited string of point coordinates from a line.
	         * @param {OpenLayers.Geometry.LineString} linestring
	         * @returns {String} A string of point coordinate strings representing
	         *                  the linestring
	         */
	        'linestring': function(linestring) {
	            var array = [];
	            for(var i=0; i<linestring.components.length; ++i) {
	                array.push(this.extract.point.apply(this, [linestring.components[i]]));
	            }
	            return array.join(',');
	        },
	
	        /**
	         * Return a comma delimited string of linestring strings from a multilinestring.
	         * @param {OpenLayers.Geometry.MultiLineString} multilinestring
	         * @returns {String} A string of of linestring strings representing
	         *                  the multilinestring
	         */
	        'multilinestring': function(multilinestring) {
	            var array = [];
	            for(var i=0; i<multilinestring.components.length; ++i) {
	                array.push('(' +
	                           this.extract.linestring.apply(this, [multilinestring.components[i]]) +
	                           ')');
	            }
	            return array.join(',');
	        },
	        
	        /**
	         * Return a comma delimited string of linear ring arrays from a polygon.
	         * @param {OpenLayers.Geometry.Polygon} polygon
	         * @returns {String} An array of linear ring arrays representing the polygon
	         */
	        'polygon': function(polygon) {
	            var array = [];
	            for(var i=0; i<polygon.components.length; ++i) {
	                array.push('(' +
	                           this.extract.linestring.apply(this, [polygon.components[i]]) +
	                           ')');
	            }
	            return array.join(',');
	        },
	
	        /**
	         * Return an array of polygon arrays from a multipolygon.
	         * @param {OpenLayers.Geometry.MultiPolygon} multipolygon
	         * @returns {Array} An array of polygon arrays representing
	         *                  the multipolygon
	         */
	        'multipolygon': function(multipolygon) {
	            var array = [];
	            for(var i=0; i<multipolygon.components.length; ++i) {
	                array.push('(' +
	                           this.extract.polygon.apply(this, [multipolygon.components[i]]) +
	                           ')');
	            }
	            return array.join(',');
	        }
		};
		
		public var parse:Object = {
			
        'point': function(str) {
            var coords = str.trim().split(this.regExes.spaces);
            return new Vector(
                new Point(coords[0], coords[1])
            );
        },

        'multipoint': function(str) {
            var points = str.trim().split(',');
            var components = [];
            for(var i=0; i<points.length; ++i) {
                components.push(this.parse.point.apply(this, [points[i]]).geometry);
            }
            return new Vector(
                new MultiPoint(components)
            );
        },

        'linestring': function(str) {
            var points = str.trim().split(',');
            var components = [];
            for(var i=0; i<points.length; ++i) {
                components.push(this.parse.point.apply(this, [points[i]]).geometry);
            }
            return new Vector(
                new LineString(components)
            );
        },

        'multilinestring': function(str) {
            var line;
            var lines = str.trim().split(this.regExes.parenComma);
            var components = [];
            for(var i=0; i<lines.length; ++i) {
                line = lines[i].replace(this.regExes.trimParens, '$1');
                components.push(this.parse.linestring.apply(this, [line]).geometry);
            }
            return new Vector(
                new MultiLineString(components)
            );
        },
        
        'polygon': function(str) {
            var ring, linestring, linearring;
            var rings = str.trim().split(this.regExes.parenComma);
            var components = [];
            for(var i=0; i<rings.length; ++i) {
                ring = rings[i].replace(this.regExes.trimParens, '$1');
                linestring = this.parse.linestring.apply(this, [ring]).geometry;
                linearring = new LinearRing(linestring.components)
                components.push(linearring);
            }
            return new Vector(
                new Polygon(components)
            );
        },

        'multipolygon': function(str) {
            var polygon;
            var polygons = str.trim().split(this.regExes.doubleParenComma);
            var components = [];
            for(var i=0; i<polygons.length; ++i) {
                polygon = polygons[i].replace(this.regExes.trimParens, '$1');
                components.push(this.parse.polygon.apply(this, [polygon]).geometry);
            }
            return new Vector(
                new MultiPolygon(components)
            );
        },

        'geometrycollection': function(str) {
            str = str.replace(/,\s*([A-Za-z])/g, '|$1');
            var wktArray = str.trim().split('|');
            var components = [];
            for(var i=0; i<wktArray.length; ++i) {
                components.push(new WKT().read([wktArray[i]]));
            }
            return components;
        }

    };
		
	}
}