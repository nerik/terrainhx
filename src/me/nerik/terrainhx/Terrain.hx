package me.nerik.terrainhx;

import me.nerik.terrainhx.data.*;
import me.nerik.collada.Collada;

typedef Params = 
{
    latRes:Int,
    lonRes:Int,
    swLat:Float,
    swLon:Float,
    neLat:Float,
    neLon:Float
}

//lat and lon values in Markers are between 0 (SW) and 1 (NE)
typedef Marker = 
{
    name:String,
    lat:Float,
    lon:Float
}

class Terrain extends mcli.CommandLine
{
	static function main() 
	{
		new mcli.Dispatch(Sys.args()).dispatch(new Terrain());
	}

    var path:String;
    var name:String;
    var dataProvider:IDataProvider;

    static var JSON_FILENAME:String = "elevation.json";

    var params:Params;

    var currentLatInc:Int = 0;
    var currentLonInc:Int = 0;

    var data:Array<Array<String>>;

    public var markers:String;

    /*
    TODO : 
    - save each x captures instead of each row
    - handle errors from Google instead of a hard limit
    - clean up collada writer
    */

	public function runDefault(path:String, varArgs:Array<String>)
    {

        this.path = path;

        var r = ~/\w+$/g;
        r.match(path);
        name = r.matched(0);


        dataProvider = new GoogleElevation();
        dataProvider.requestSucceed.add( onProviderRequestSucceed );
        dataProvider.requestFailed.add( onProviderRequestFailed );
        dataProvider.maxRequestsReached.add( onProviderMaxRequestsReached );

        

        // name += "_" + Std.string( lonRes ) + "x" + Std.string( latRes );
        // trace(name);

        if (sys.FileSystem.exists(path))    
        {   
            Sys.println('It seems that a capture was already started for "' + name + '". Continue previous capture, restart or abort? (continue/restart/abort)');

            var prompt = Sys.stdin().readLine();

            switch( prompt ) 
            {
                case 'continue', 'c' :
                    Sys.println('Continuing capture...');
                    continueCapture();

                case 'restart', 'r' :
                    Sys.println('Restarting capture...');
                    startCapture(varArgs);
              
                default:
                    Sys.println('Aborting.');
                    Sys.exit(0);
            }

         }

         else startCapture(varArgs);

         	
    }


    function getParamsFromArgs(varArgs:Array<String>)
    {

        params = { 
            latRes : Std.parseInt(varArgs[0]),
            lonRes : Std.parseInt(varArgs[1]),
            swLat : Std.parseFloat( varArgs[2] ),
            swLon : Std.parseFloat( varArgs[3] ),
            neLat : Std.parseFloat( varArgs[4] ),
            neLon : Std.parseFloat( varArgs[5] )
        };
    }

    function getParamsInteractively()
    {
    
        Sys.println('Latitude resolution (= number of captures on the y axis, int) : ');
        var latRes = Std.parseInt( Sys.stdin().readLine() );

        Sys.println('Longitude resolution (= number of captures on the x axis, int) : ');
        var lonRes = Std.parseInt( Sys.stdin().readLine() );


        var numRequests = lonRes * latRes;

        Sys.println('The total number of requests needed is : ' + numRequests);


        if (numRequests>dataProvider.maxRequests)
        {
            Sys.println('WARNING : total number of requests exceeds daily API limits (' + dataProvider.maxRequests + ')');
            Sys.println('You will have to wait one or more days to complete the request. Proceed anyway? (y/n)');
            
            var prompt = Sys.stdin().readLine();
            if (prompt != 'y') Sys.exit(0);
        }



        Sys.println('Start latitude - southernmost (SW) point (float) : ');
        var swLat = Std.parseFloat( Sys.stdin().readLine() );

        Sys.println('Start longitude - westernmost (SW) point (float) : ');
        var swLon = Std.parseFloat( Sys.stdin().readLine() );

        Sys.println('End latitude - northermost (NE) point (float) : ');
        var neLat = Std.parseFloat( Sys.stdin().readLine() );

        Sys.println('End longitude - easternmost (NE) point (float) : ');
        var neLon = Std.parseFloat( Sys.stdin().readLine() );

        params = { 
            latRes : latRes,
            lonRes : lonRes,
            swLat : swLat,
            swLon : swLon,
            neLat : neLat,
            neLon : neLon
        };

    }


    function getParamsFromJson(json):Bool
    {
        data = Reflect.field(json, "data" );

        params = Reflect.field(json, "params");

        currentLatInc = Reflect.field(json, "currentLatInc" );
        currentLonInc = Reflect.field(json, "currentLonInc" );

        return cast( Reflect.field(json, "completed"), Bool );

    }


    public function help()
    {
        Sys.println(this.showUsage());

    }

    





    function startCapture(varArgs:Array<String>)
    {

        if ( varArgs.length > 0)
        {
            if (varArgs.length != 6)
            {
                Sys.println("Error : see --help for details");
                Sys.exit(0);
            }

            getParamsFromArgs(varArgs);
        }
        else
        {
            getParamsInteractively();
        }



        sys.FileSystem.createDirectory(path);
        Sys.setCwd(path);

        data = new Array();

        loadElevation();


    }


    function continueCapture()
    {
       
        Sys.setCwd(path);

        var json = haxe.Json.parse((sys.io.File.getContent(JSON_FILENAME)));

        var completed = getParamsFromJson(json);

        if (completed) 
        {
            Sys.println("Capture already completed.");
            makeMesh();
        }

        else loadElevation();

    }

   



    //-----------------------------------CAPTURE-----------------------------------
    

    function loadElevation() 
    {
        trace(currentLatInc + "," + currentLonInc);

    
        //TODO : handle the case where longitude overlaps the 180th meridian (-180°+180°)
        var lat = lerp( currentLatInc/(params.latRes-1), params.swLat, params.neLat );
        var lon = lerp( currentLonInc/(params.lonRes-1), params.swLon, params.neLon );
        
        var coords = lat +","+ lon;

        trace(coords);
        
        dataProvider.loadElevation(coords);
    }


    function onProviderRequestSucceed(elevationStr:String) 
    {
        //create column if it doesn't exist yet
        if ( data[currentLatInc] == null ) data[currentLatInc] = new Array();

        data[currentLatInc][currentLonInc] = elevationStr;


        if (currentLonInc == params.lonRes-1)
        {
            if (currentLatInc == params.latRes-1)
            {
                Sys.println("complete.");
                saveData(true);
                makeMesh();
                return;
            }
            currentLatInc++;
            currentLonInc = 0;

            saveData();
           
        }

        else currentLonInc++;

        Sys.sleep(.1);
        loadElevation();

        
    }

    function onProviderRequestFailed(err:String)
    {
        loadElevation();
    }

    function onProviderMaxRequestsReached()
    {
        saveData();
    }



    function saveData(completed = false) 
    {
        var fileOutput = sys.io.File.write( JSON_FILENAME );

        var h:Map<String, Dynamic> = new Map<String, Dynamic>();
        h.set( "data", data );
        h.set("params", params);
        h.set( "currentLatInc", currentLatInc );        
        h.set( "currentLonInc", currentLonInc );        
        h.set( "completed", completed );        

        var s = haxe.Json.stringify(h);

        fileOutput.writeString( s ) ;
        fileOutput.close();
    }


    function makeMesh() 
    {
        Sys.println("Now making Collada file...");

        var rawData = sys.io.File.getContent(JSON_FILENAME);
        var data = haxe.Json.parse(rawData);

        var latDeltaKm = getDistanceBetweenCoords(params.swLat, params.swLon, params.neLat, params.swLon);
        var lonDeltaKm = getDistanceBetweenCoords(params.swLat, params.swLon, params.swLat, params.neLon);

        var markersList = (markers != null) ? getMarkers() : null;

        var collada = ConvertToMesh.convert(data, name, params.latRes, params.lonRes, latDeltaKm, lonDeltaKm, markersList);
        


        var filename = name+".dae";
        var fout = sys.io.File.write(filename);
        fout.writeString(collada.export().toString());
        fout.close();

        Collada.prettifyXml(filename);


        Sys.exit(0);
    }


    function getMarkers():Array<Marker>
    {
        var markerStrs = markers.split(",");

        var markersList = new Array();

        for (i in 0...markerStrs.length) 
        {
            if (i%3 != 0) continue;

            var lat = remap( Std.parseFloat(markerStrs[i+1]), params.swLat, params.neLat, 0, 1 );
            var lon = remap( Std.parseFloat(markerStrs[i+2]), params.swLon, params.neLon, 0, 1 );

            markersList.push ( { name: markerStrs[i], lat: lat, lon: lon} );

        }

        return markersList;
    }





    //Utils -----------

    static function lerp(value:Float, low:Float, high:Float):Float {return value * (high - low)+low;}

    static function remap(value:Float, low1:Float, high1:Float, low2:Float, high2:Float) 
    {
        return low2 + (high2 - low2) * (value - low1) / (high1 - low1);
    }

    //Spherical Law of Cosines
    //http://www.movable-type.co.uk/scripts/latlong.html
    static function getDistanceBetweenCoords(lat1:Float, lon1:Float, lat2:Float, lon2:Float)
    {
        var R = 6371; // km
        lat1 = degToRad(lat1);
        lat2 = degToRad(lat2);

        var d = Math.acos(Math.sin(lat1) * Math.sin(lat2) + 
                Math.cos(lat1) * Math.cos(lat2) *
                Math.cos(degToRad(lon2)-degToRad(lon1))) * R;

        return d;
    }

    public inline static function degToRad(deg:Float):Float
    {
        return Math.PI / 180 * deg;
    }


    
  
}
