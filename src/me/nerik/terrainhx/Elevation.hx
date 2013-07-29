package me.nerik.terrainhx;


class Elevation
{
	static function main() 
	{
		new Elevation();
		

	}


	static var RES:Int = 3;

	static var MAX_REQUESTS:Int = 2400;

	static var SW_LAT = 28.0011; //y
	static var SW_LON = -17.3512; //x

	static var NE_LAT = 28.232;
	static var NE_LON = -17.1;

	var data:Array<Array<String>>;
	var currentRow:Int;
	var currentCol:Int;
	var filename:String;

	var numRequests:Int;

	public function new() 
	{


		numRequests = 0;

		filename = "elevation_"+RES+".json";


		data = new Array();

		if (sys.FileSystem.exists(filename))
		{
			data = readData(sys.io.File.getContent(filename));

			getCurrentPos();

			if (currentRow == null || currentCol == null) 
			{
				Sys.println("already completed");
				return;
			}

			trace(currentRow);
			trace(currentCol);

		}
		else
		{
			currentRow = currentCol = 0;
		}
		
	
		loadElevation();


		// var data = sys.io.File.getContent(filename);
		// trace(data);

		// var fileOutput = sys.io.File.write( filename );

		// fileOutput.writeString("caca");
	}

	var h:haxe.Http;

	function loadElevation() 
	{
		trace(currentRow + "," + currentCol);
		

		var coords:String = lerp(currentRow/(RES-1), NE_LAT, SW_LAT) +","+lerp(currentCol/(RES-1), SW_LON, NE_LON);

		trace(coords);
		
		h = new haxe.Http("http://maps.googleapis.com/maps/api/elevation/json");
		h.setParameter("sensor","false");
		h.onData = onElevationLoaded;
		h.onError = onElevationError;
		h.onStatus = onElevationStatus;
		
		h.setParameter("locations",coords);

		h.request(false);




	}

	function onElevationLoaded(s:String) 
	{

		if ( data[currentRow] == null ) data[currentRow] = new Array();

		numRequests++;

		var jsonRaw = haxe.Json.parse(s);
		trace(jsonRaw);

		var results = Reflect.field(jsonRaw, "results");
		trace(results);

		if (results == null) return;


		var e = Reflect.field(results[0], "elevation");
		if (e==null) return;
		
		data[currentRow][currentCol] = e;
		//data[currentRow][currentCol] = currentRow + "," + currentCol + " " + Math.random();

		if (currentCol == RES-1)
		{
			if (currentRow == RES-1)
			{
				Sys.println("complete.");
				saveData();
				return;
			}
			currentRow++;
			currentCol = 0;

			saveData();

			if ( (numRequests + RES) > MAX_REQUESTS )
			{
				Sys.println("daily limit reached. - " + numRequests);
				return;
			}

			
		}
		else currentCol++;

		Sys.sleep(.3);
		loadElevation();

		
	}


	function onElevationError(s) 
	{
		trace("----ERR-----");
		trace(s);

		loadElevation();
	}

	function onElevationStatus(s) 
	{
		//trace(s);
	}


	function saveData() 
	{
		var fileOutput = sys.io.File.write( filename );

		var h:Map<String, Dynamic> = new Map<String, Dynamic>();
		h.set( "data", data );

		// var s = hxjson2.JSON.encode(h);
		var s = haxe.Json.stringify(h);


		fileOutput.writeString( s ) ;
		fileOutput.close();
	}


	function readData(rawData) 
	{
		var jsonData = haxe.Json.parse(rawData);


		return jsonData.data;

	}

	function getCurrentPos() 
	{
		for (i in 0...RES) 
		{
			var row = data[i];

			if (row == null)
			{
				currentRow = i;
				currentCol = 0;
				return;
			}

			for (j in 0...RES) 
			{
				if (row[j] == null)
				{
					currentRow = i;
					currentCol = j;
					trace(currentRow);
					trace(currentCol);
					return;
				}
			}
		}
	}

	static function lerp(value:Float, low:Float, high:Float):Float {return value * (high - low)+low;}

}