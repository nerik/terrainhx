(function () { "use strict";
var TerrainhxDemo = function() {
	this.w = js.Browser.window.innerWidth;
	this.halfW = this.w / 2 | 0;
	this.h = js.Browser.window.innerHeight;
	this.zoom = 30;
	this.cx = 0;
	this.scene = new THREE.Scene();
	this.sun = new THREE.PointLight(16777215,1,0);
	this.sun.position.set(10,50,130);
	this.scene.add(this.sun);
	this.camera = new THREE.PerspectiveCamera(70,this.w / this.h,1,1000);
	this.camera.position.z = 40;
	this.camera.position.y = 10;
	this.scene.add(this.camera);
	this.colladaMeshContainer = new THREE.Object3D();
	this.scene.add(this.colladaMeshContainer);
	this.projector = new THREE.Projector();
	this.renderer = new THREE.WebGLRenderer({ antialias : true, stencil : true});
	this.renderer.setSize(this.w,this.h);
	js.Browser.document.body.appendChild(this.renderer.domElement);
	var loader = new THREE.ColladaLoader();
	loader.load("gomera/gomera.dae",$bind(this,this.onColladaLoaded));
};
TerrainhxDemo.main = function() {
	new TerrainhxDemo();
}
TerrainhxDemo.prototype = {
	onMouseWheel: function(e) {
		this.zoom += e.wheelDelta / 100;
	}
	,onMouseMove: function(e) {
		this.cx = e.x;
		this.cy = e.y;
	}
	,update: function(f) {
		console.log("update");
		js.Browser.window.requestAnimationFrame($bind(this,this.update));
		var normY = 1 - this.cy / this.h;
		var a = Math.PI / 4 * normY + Math.PI / 16;
		this.zoom = THREE.Math.clamp(this.zoom,10,80);
		this.camera.position.z = Math.cos(a) * this.zoom;
		this.camera.position.y = Math.sin(a) * this.zoom;
		this.camera.lookAt(new THREE.Vector3(0,0,0));
		var normDX = -(this.cx - this.halfW) / 50000;
		this.colladaMeshContainer.rotation.y += normDX;
		var _g1 = 0, _g = this.markers.length;
		while(_g1 < _g) {
			var i = _g1++;
			this.markers[i].rotation.y += .05;
		}
		this.renderer.render(this.scene,this.camera,null,null);
		return true;
	}
	,start: function() {
		js.Browser.document.onmousemove = $bind(this,this.onMouseMove);
		js.Browser.document.onmousewheel = $bind(this,this.onMouseWheel);
		this.update(0);
	}
	,onColladaLoaded: function(result) {
		console.log("loadsfded");
		this.colladaMesh = result.scene;
		this.colladaMesh.scale.y = 3;
		var gomera = this.colladaMesh.getChildByName("gomera-mesh");
		gomera.material = new THREE.MeshLambertMaterial({ shading : 1, color : 16744264});
		var gomeraBounds = gomera.geometry.boundingBox;
		var waterPlane = new THREE.PlaneGeometry(gomeraBounds.max.x,-gomeraBounds.min.z);
		var water = new THREE.Mesh(waterPlane,new THREE.MeshLambertMaterial({ shading : 1, color : 6458879, opacity : .8, transparent : true}));
		water.rotation.x = -Math.PI / 2;
		water.position.y = .01;
		this.colladaMeshContainer.add(water);
		this.colladaMesh.position.x = -gomeraBounds.max.x / 2;
		this.colladaMesh.position.z = -gomeraBounds.min.z / 2;
		this.colladaMeshContainer.add(this.colladaMesh);
		this.markers = new Array();
		var markerPivots = this.colladaMesh.getChildByName("markers").children;
		var _g1 = 0, _g = markerPivots.length;
		while(_g1 < _g) {
			var i = _g1++;
			var markerPivot = markerPivots[i];
			var geometry = new THREE.Geometry();
			geometry.vertices.push(new THREE.Vector3(0,0,0));
			geometry.vertices.push(new THREE.Vector3(-.5,.5,0));
			geometry.vertices.push(new THREE.Vector3(.5,.5,0));
			geometry.faces.push(new THREE.Face3(0,1,2));
			geometry.faces.push(new THREE.Face3(0,2,1));
			geometry.computeBoundingSphere();
			var marker = new THREE.Mesh(geometry,new THREE.MeshLambertMaterial({ shading : 1, color : 16711935}));
			marker.position.y = 1.4;
			markerPivot.add(marker);
			this.markers.push(marker);
		}
		var axes = new THREE.AxisHelper(50);
		axes.position = this.colladaMeshContainer.position;
		this.colladaMeshContainer.add(axes);
		this.start();
	}
}
var js = {}
js.Browser = function() { }
js.three = {}
js.three.Face = function() { }
js.three.Mapping = function() { }
js.three.Renderer = function() { }
js.three.Three = function() { }
js.three.Three.requestAnimationFrame = function(f) {
	return js.Browser.window.requestAnimationFrame(f);
}
js.three.Three.cancelAnimationFrame = function(f) {
	js.Browser.window.cancelAnimationFrame(id);
}
var $_, $fid = 0;
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $fid++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; o.hx__closures__[m.__id__] = f; } return f; };
Math.__name__ = ["Math"];
Math.NaN = Number.NaN;
Math.NEGATIVE_INFINITY = Number.NEGATIVE_INFINITY;
Math.POSITIVE_INFINITY = Number.POSITIVE_INFINITY;
Math.isFinite = function(i) {
	return isFinite(i);
};
Math.isNaN = function(i) {
	return isNaN(i);
};
js.Browser.window = typeof window != "undefined" ? window : null;
js.Browser.document = typeof window != "undefined" ? window.document : null;
js.three.Three.CullFaceNone = 0;
js.three.Three.CullFaceBack = 1;
js.three.Three.CullFaceFront = 2;
js.three.Three.CullFaceFrontBack = 3;
js.three.Three.FrontFaceDirectionCW = 0;
js.three.Three.FrontFaceDirectionCCW = 1;
js.three.Three.BasicShadowMap = 0;
js.three.Three.PCFShadowMap = 1;
js.three.Three.PCFSoftShadowMap = 2;
js.three.Three.FrontSide = 0;
js.three.Three.BackSide = 1;
js.three.Three.DoubleSide = 2;
js.three.Three.NoShading = 0;
js.three.Three.FlatShading = 1;
js.three.Three.SmoothShading = 2;
js.three.Three.NoColors = 0;
js.three.Three.FaceColors = 1;
js.three.Three.VertexColors = 2;
js.three.Three.NoBlending = 0;
js.three.Three.NormalBlending = 1;
js.three.Three.AdditiveBlending = 2;
js.three.Three.SubtractiveBlending = 3;
js.three.Three.MultiplyBlending = 4;
js.three.Three.CustomBlending = 5;
js.three.Three.AddEquation = 100;
js.three.Three.SubtractEquation = 101;
js.three.Three.ReverseSubtractEquation = 102;
js.three.Three.ZeroFactor = 200;
js.three.Three.OneFactor = 201;
js.three.Three.SrcColorFactor = 202;
js.three.Three.OneMinusSrcColorFactor = 203;
js.three.Three.SrcAlphaFactor = 204;
js.three.Three.OneMinusSrcAlphaFactor = 205;
js.three.Three.DstAlphaFactor = 206;
js.three.Three.OneMinusDstAlphaFactor = 207;
js.three.Three.DstColorFactor = 208;
js.three.Three.OneMinusDstColorFactor = 209;
js.three.Three.SrcAlphaSaturateFactor = 210;
js.three.Three.MultiplyOperation = 0;
js.three.Three.MixOperation = 1;
js.three.Three.AddOperation = 2;
js.three.Three.RepeatWrapping = 1000;
js.three.Three.ClampToEdgeWrapping = 1001;
js.three.Three.MirroredRepeatWrapping = 1002;
js.three.Three.NearestFilter = 1003;
js.three.Three.NearestMipMapNearestFilter = 1004;
js.three.Three.NearestMipMapLinearFilter = 1005;
js.three.Three.LinearFilter = 1006;
js.three.Three.LinearMipMapNearestFilter = 1007;
js.three.Three.LinearMipMapLinearFilter = 1008;
js.three.Three.UnsignedByteType = 1009;
js.three.Three.ByteType = 1010;
js.three.Three.ShortType = 1011;
js.three.Three.UnsignedShortType = 1012;
js.three.Three.IntType = 1013;
js.three.Three.UnsignedIntType = 1014;
js.three.Three.FloatType = 1015;
js.three.Three.UnsignedShort4444Type = 1016;
js.three.Three.UnsignedShort5551Type = 1017;
js.three.Three.UnsignedShort565Type = 1018;
js.three.Three.AlphaFormat = 1019;
js.three.Three.RGBFormat = 1020;
js.three.Three.RGBAFormat = 1021;
js.three.Three.LuminanceFormat = 1022;
js.three.Three.LuminanceAlphaFormat = 1023;
js.three.Three.RGB_S3TC_DXT1_Format = 2001;
js.three.Three.RGBA_S3TC_DXT1_Format = 2002;
js.three.Three.RGBA_S3TC_DXT3_Format = 2003;
js.three.Three.RGBA_S3TC_DXT5_Format = 2004;
js.three.Three.LineStrip = 0;
js.three.Three.LinePieces = 1;
TerrainhxDemo.main();
})();

//@ sourceMappingURL=terrainhxdemo.js.map