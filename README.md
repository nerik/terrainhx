terrainhx
=========

Terrainhx is a small command line tool (Mac and Win) that makes a 3D model from a place on earth, using an elevation service such as Google Maps.

[WebGL demo][1]

[![Image](demo.png?raw=true)][1]

Terrainhx queries the webservice (currently only Google Maps elevation service) to get an elevation value for each of the points needed. It then builds a Collada model (.dae) that is usable in most of the 3D packages, as well as in Unity3D or with three.js for example.

 
	bin/terrainhx <path/to/folder> #this will create the folder

	#You will then be asked the following parameters interactively in this order :
	# Latitude resolution (= number of captures on the y axis, int)
	# Longitude resolution (= number of captures on the x axis, int) 
	# Start latitude - southernmost (SW) point (float)
	# Start longitude - westernmost (SW) point (float)
	# End latitude - northermost (NE) point (float)
	# End longitude - easternmost (NE) point (float)
        	
	#OR
	bin/terrainhx <path/to/folder> <latRes> <lonRes> <swLat> <swLon> <neLat> <neLon> 



## Multiple captures
Google Maps' elevation service as a daily queries limit. If you need more points than possible in one capture, you can resume a previously started capture :

	bin/terrainhx <path/to/folder>



## Adding markers

It's possible to add markers, the tool will create nodes/pivot points in the 3D model's hierarchy itself :

	# --markers <name0>,<lat0>,<lon0>,...<nameN>,<latN>,<lonN>
	bin/terrainhx <path/to/folder> --markers AltodeGarajonay,28.106692,-17.249,ValleGranRey,28.092136,-17.338584


Then get the pivot points like this (with three.js)


	var markerPivots = colladaMesh.getChildByName("markers").children;
    for (var i= 0; i < 0...markerPivots.length; i++) 
    {
        var markerPivot = markerPivots[i];
        //...
    }



## Build from source

Terrainhx is built in Haxe and compiled to Neko.
You will need mcli and msignal from haxelib, and colladawriterhx (not on haxelib, grab it directly from github : [colladawriterhx][2] )



## License

BSD 3-Clause License

All rights reserved.
Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.
* Neither the name of Poly2Tri nor the names of its contributors may be
  used to endorse or promote products derived from this software without specific
  prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


[1]: http://nerik.me/project/terrainhx
[2]: https://github.com/nerik/colladawriterhx