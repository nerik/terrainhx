package;

@:native("THREE.ColladaLoader")
extern class ColladaLoader
{
    public function new() : Void;
    public function load(url:String, readyCallback:ColladaLoaderResult->Void):Void;
}
