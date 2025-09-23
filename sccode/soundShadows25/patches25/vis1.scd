// ------------------------------------------------------
~init = {|patch|

  var colors = [Color.red, Color.yellow, Color.blue, Color.cyan, Color.green];

	// ~setOSCReset.(1);
	~setXfade.(1);

	~setPolyline.(0,1,1);
  ~setRGBColor.([1,1,1,1]); //might need to reset in globals OSC IN

	// ~setBackground0.();
	~setBackground1.(Color.blue().darken(0.4).asArray);
	// ~setBackground2.(blur:0.5, step:0.06);
	// ~setBackground3.(index:18, scale:1, rot:0, mode:31, color:Color.hsv(0.33,1,1).darken(0.89).asArray);

	// each polyline (blob)
	4.do({|i|
		// var c = Color.new(0,1/2,0.5/2,1);
		var c = Color.white();
		// var c = Color.hsv(0.2 + (0.02 * i),1,1).darken(0.5);
    // var c = colors[i];
		~setPolylineColor.(i,c.asArray); // might be broken
	});

	// ~setDisplace.(mix:0.5, x:5, y:5, period:1, noise:1, z:0);
	// ~setDisplace.(mix:0.8, x:4, y:4, period:0.1, noise:2.3, z:0);
	~setDisplace.(mix:0.0);

	// ~setFeedback.(mix:0.98, opacity:0.98, hue:0.02, x:0.0, y:0.07, dx:0.0, dy:0.0, edgeColor:Color(0,0,1).asArray, edgeBlack:0.1, edgeStength:0);
	~setFeedback.(mix:0);


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
