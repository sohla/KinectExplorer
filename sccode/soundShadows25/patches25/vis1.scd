//------------------------------------------------------
~init = {|patch|

  var colors = [Color.red, Color.yellow, Color.blue, Color.cyan, Color.green];

	~setPolyline.(1,1,1);
  ~setRGBColor.([1,1,1,1]); //might need to reset in globals OSC IN




	// each polyline (blob)
	4.do({|i|
		// var c = Color.new(1,1,0,1);
		var c = Color.hsv(0.1 + (0.05 * i),1,1);
    // var c = colors[i];
    c.asArray.postln;
		~setPolylineColor.(i,c.asArray); // might be broken
	});


	// ~setBackground0.(); 
	// ~setBackground1.(Color.white.asArray);
	~setBackground2.(blur:0.7, step:0.3);
	// ~setBackground3.(index:1, scale:1, rot:0, mode:1, color:Color.red.asArray);

	// ~setDisplace.(mix:1, x:0.1, y:3, period:0.1, noise:5, z:0);
	~setDisplace.(mix:0.0);

	// ~setFeedback.(mix:1, opacity:0.96, hue:0.1, x:0.0, y:0.0, dx:0.0, dy:0.0, edgeColor:Color(0,1,1).asArray, edgeBlack:0.0, edgeStength:0.0);
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
	blobsDict.size
};

//------------------------------------------------------
~onBlobData = {|blob|
};
