
package me.nerik.terrainhx.data;

import msignal.Signal.Signal0;
import msignal.Signal.Signal1;

class GoogleElevation implements IDataProvider
{

	public var maxRequests = 2500;
	public var requestSucceed:Signal1<String>;
	public var requestFailed:Signal1<String>;
	public var maxRequestsReached:Signal0;

	var numRequests:Int = 0;


	public function new()
	{
		requestSucceed = new Signal1();
		requestFailed = new Signal1();
		maxRequestsReached = new Signal0();
	}


	var h:haxe.Http;

	public function loadElevation(coords:String)
	{
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


        numRequests++;

        var jsonRaw = haxe.Json.parse(s);
        trace(jsonRaw);

        var results = Reflect.field(jsonRaw, "results");
        // trace(results);

        if (results == null) 
        {
            requestFailed.dispatch("no results");
            return;
        }


        var e = Reflect.field(results[0], "elevation");
        if (e==null) requestFailed.dispatch("invalid result");
        
        requestSucceed.dispatch(e);

        if ( numRequests > maxRequests )
        {
        	maxRequestsReached.dispatch();
        }
    }


    function onElevationError(s) 
    {
        requestFailed.dispatch("http error : " + s);
    }

    function onElevationStatus(s) 
    {
        //trace(s);
    }


}