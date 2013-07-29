
package me.nerik.terrainhx.data;

interface IDataProvider 
{

	var maxRequests:Int;

	var requestSucceed:msignal.Signal.Signal1<String>;
	var requestFailed:msignal.Signal.Signal1<String>;
	var maxRequestsReached:msignal.Signal.Signal0;


	function loadElevation(coords:String):Void;
	

}