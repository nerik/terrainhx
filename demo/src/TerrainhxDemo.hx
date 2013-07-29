package;

import js.Browser;
import js.three.*;
import js.three.Math in ThreeMath;
import Math in Math; //https://groups.google.com/forum/#!topic/haxelang/S6ixh4g9VWI


class TerrainhxDemo 
{
	var scene:Scene;
    var renderer:WebGLRenderer;
    var camera:PerspectiveCamera;
    var sun:PointLight;
    var projector:Projector;
    var raycaster:Raycaster;
    var colladaMeshContainer:Object3D;
	var colladaMesh:Object3D;
    var markers:Array<Mesh>;
    var w:Int;
    var halfW:Int;
    var h:Int;

	static function main() 
	{
        new TerrainhxDemo();
	} 

    function new()
    {
        w = Browser.window.innerWidth;
        halfW = Std.int(w/2);
        h = Browser.window.innerHeight;

        zoom = 30;
        cx = 0;

        scene = new Scene();
      

        sun = new PointLight(0xffffff, 1, 0);
        sun.position.set(10, 50, 130);
        scene.add(sun);


  
        camera = new PerspectiveCamera(70, w/h, 1, 1000);
        camera.position.z = 40;
        camera.position.y = 10;
        scene.add(camera);

        // 

        colladaMeshContainer = new Object3D();
        scene.add(colladaMeshContainer);


        projector = new Projector();
        // raycaster = new Raycaster();



        renderer = new WebGLRenderer({ antialias: true, stencil:true });
        renderer.setSize(w, h);
        Browser.document.body.appendChild(renderer.domElement);




        var loader = new ColladaLoader();
        loader.load('gomera/gomera.dae', onColladaLoaded);
            
    }

	function onColladaLoaded(result:ColladaLoaderResult):Void 
	{
        trace("loadsfded");
		
		colladaMesh = result.scene;
        colladaMesh.scale.y = 3;


        var gomera:Mesh = cast colladaMesh.getChildByName("gomera-mesh");

        gomera.material = new MeshLambertMaterial({shading: Three.FlatShading, color:0xff7f48});

        var gomeraBounds:Box3 = cast gomera.geometry.boundingBox;

        //make water plane
        var waterPlane = new PlaneGeometry( gomeraBounds.max.x *1 , -gomeraBounds.min.z*1 );
        var water = new Mesh(waterPlane, new MeshLambertMaterial({shading: Three.FlatShading, color:0x628dff, opacity:.8, transparent: true}));
        water.rotation.x = -Math.PI/2;
        water.position.y = .01 ;
        colladaMeshContainer.add(water);

        //recenter mesh + water
        colladaMesh.position.x  = -gomeraBounds.max.x/2;
        colladaMesh.position.z = -gomeraBounds.min.z/2;

        colladaMeshContainer.add(colladaMesh);



        // //markers
        markers = new Array();
        var markerPivots = colladaMesh.getChildByName("markers").children;

        for (i in 0...markerPivots.length) 
        {
            var markerPivot = markerPivots[i];
    
            var geometry = new Geometry();

            geometry.vertices.push( new Vector3( 0, 0, 0 ) );
            geometry.vertices.push( new Vector3( -.5, .5, 0 ) );
            geometry.vertices.push( new Vector3(  .5, .5, 0 ) );

            geometry.faces.push( new Face3( 0, 1, 2 ) );
            geometry.faces.push( new Face3( 0, 2, 1 ) );

            geometry.computeBoundingSphere();
 
            var marker = new Mesh(geometry, new MeshLambertMaterial({shading: Three.FlatShading, color:0xFF00FF } ) ); 
            marker.position.y = 1.4;
            markerPivot.add(marker);

            markers.push(marker);
        }


       


        var axes = new AxisHelper(50);
        axes.position = colladaMeshContainer.position;
        colladaMeshContainer.add(axes);

        start();

        
	}

    function start()
    {
        Browser.document.onmousemove = onMouseMove;
        Browser.document.onmousewheel = onMouseWheel;

        update(0);
    }

    function update(f:Float):Bool
    {
        trace("update");
        js.three.Three.requestAnimationFrame(update);

        var normY = 1 - cy/h;
        // var normZoom = zoom.

        var a = Math.PI/4 * normY + Math.PI/16;

        zoom = ThreeMath.clamp(zoom, 10, 80); //see imports of this class

        camera.position.z = Math.cos(a) * zoom;
        camera.position.y = Math.sin(a) * zoom;
        camera.lookAt(new js.three.Vector3(0,0,0));

        var normDX = -(cx-halfW)/50000;

        colladaMeshContainer.rotation.y += normDX;


        /*
        var vector = new Vector3( cx, cy, 1 );
        projector.unprojectVector( vector, camera );

        var raycaster = new Raycaster(camera.position, vector.sub( camera.position ).normalize() );
        // raycaster.set( camera.position, vector.sub( camera.position ).normalize() );

        var intersects = raycaster.intersectObjects( colladaMesh.children );
        trace(intersects.length);
        */



        for (i in 0...markers.length)
        {
            markers[i].rotation.y += .05;
        }



        renderer.render(scene, camera, null, null);

        
 
        return true;
    }

    var cx:Float;
    var r:Float;
    var cy:Float;
    var zoom:Float;


    function onMouseMove(e)
    {
        cx = e.x;
        // r += cx;
        cy = e.y;
    }

    function onMouseWheel(e)
    {
        zoom += e.wheelDelta/100;
    }
}

