// ------------------------------------------------------
~init = {|patch|

  var colors = [Color.red, Color.yellow, Color.blue, Color.cyan, Color.green];

	// ~setOSCReset.(1);
	~setXfade.(1);

	~setPolyline.(1,1,1);
  ~setRGBColor.([1,1,1,1]); //might need to reset in globals OSC IN

	// ~setBackground0.(); 
	// ~setBackground1.(Color.white().darken(0.2).asArray);
	~setBackground2.(blur:0.7, step:0.1);
	// ~setBackground3.(index:25, scale:1, rot:0, mode:31, color:Color.blue.asArray);

	// each polyline (blob)
	4.do({|i|
		// var c = Color.new(0,1/2,0.5/2,1);
		var c = Color.black().lighten(0.1);
		// var c = Color.hsv(0.1 + (0.05 * i),1,1);
    // var c = colors[i];
		~setPolylineColor.(i,c.asArray); // might be broken
	});

	// ~setDisplace.(mix:1, x:3, y:10, period:0.1, noise:0.2, z:1);
	// ~setDisplace.(mix:1, x:0.1, y:3, period:0.1, noise:5, z:0);
	~setDisplace.(mix:0.0);

	~setFeedback.(mix:1, opacity:0.96, hue:0.02, x:0.0, y:0.04, dx:0.0, dy:0.0, edgeColor:Color(0,1,0).asArray, edgeBlack:0.3, edgeStength:0.9);
	// ~setFeedback.(mix:0);
  

};

//------------------------------------------------------
~deinit = {|patch|

};

//---------------------------------------------------
~onBlobInit = {|blob, blobsDict|
	// postf("blob init: % \n", blob.label);

};

//------------------------------------------------------
~onBlobUpdate = {|blob, blobsDict|
};

//------------------------------------------------------
~onBlobDeinit = {|blob, blobsDict|
	// postf("blob deinit: % \n", blob.label);

};


//------------------------------------------------------
~onPlotData = {|blobsDict|	
};

//------------------------------------------------------
~onBlobData = {|blob|
};
