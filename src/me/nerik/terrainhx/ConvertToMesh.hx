package me.nerik.terrainhx;

import me.nerik.collada.*;


class ConvertToMesh
{
    /*
    latSubLength and lonSubLength : distance in km that separate two subdivisions/points
    */
	public static function convert( data:Dynamic, name:String, latRes:Int, lonRes:Int, latDelta:Float, lonDelta:Float, markers:Array<Terrain.Marker> = null )
	{

        var latSubLength = latDelta/latRes;
        var lonSubLength = lonDelta/lonRes;

		var geom  = readPoints( Reflect.field( data, "data" ), name, latSubLength, lonSubLength );

        var collada = new Collada();
        collada.geometries = [geom];


        var visualScene = new VisualScene();
        visualScene.id = "scene";
        var mainNode = Node.build(geom.id);
            
        
        var markersContainerNode = new Node();
        markersContainerNode.id = "markers";
        visualScene.nodes = [mainNode, markersContainerNode];  

        for (i in 0...markers.length) 
        {
            var m = markers[i];
            var mx = lonDelta*m.lon;
            var mz = -latDelta*m.lat;
            var my = getElevationAtMarker(m.lat, m.lon);
            var node = new Node();
            node.id = m.name;
            node.translate = Translate.build({x:mx, y:my, z:mz });

            markersContainerNode.nodes.push(node);
        }


        collada.visualScenes = [visualScene];
        collada.scene = Scene.buildDefault(visualScene.id);

        return collada;
	}


    static function getElevationAtMarker(lat, lon)
    {
        return 0;
    }



	static function readPoints ( points:Dynamic, name:String, latSubLength:Float, lonSubLength:Float ) 
    {

        var vertices:Array<Float> = new Array();
        var tris:Array<Int> = new Array();

        var curIndex = 0;

        var latRes = points.length;

        for (lat in 0...points.length) 
        {
            if (points[lat]==null) 
            {
                //return geometry;
            }

           for (lon in 0...points[lat].length) 
            {
                if (points[lat][lon]==null )
                {
                    //console.log(i +"+"+j);
                    //return geometry;  
                } 

                var e = points[lat][lon];

                //ignore elevation below 0 ?
                // var e = Math.max(e, 0);


                vertices.push( lon*lonSubLength );
                vertices.push( e/1000 ); //meters->km
                vertices.push( -lat*latSubLength );


                if (lat>0 && lon>0)
                {
                   
                    tris.push( curIndex );
                    tris.push( curIndex-1 );
                    tris.push( curIndex-1-latRes );
                                        
                    tris.push( curIndex );
                    tris.push( curIndex-1-latRes );
                    tris.push( curIndex-latRes );
                    
                }

                curIndex++;
            }
        }

        var geom = Geometry.buildGeometry(name, vertices, tris);

        return geom;

    }
}