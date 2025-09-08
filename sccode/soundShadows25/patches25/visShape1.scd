var patterns = Dictionary.new(4);


// ------------------------------------------------------
~init = {|patch|

  var colors = [Color.red, Color.yellow, Color.blue, Color.cyan, Color.green];

	// ~setOSCReset.(1);
	~setXfade.(1);

	~setPolyline.(1,1,1);
  ~setRGBColor.([1,1,1,1]); //might need to reset in globals OSC IN

	// ~setBackground0.(); 
	~setBackground1.(Color.blue().darken(0.9).asArray);
	// ~setBackground2.(blur:0.5, step:0.06);
  // ~setBackground2.(blur:0.7, step:0.1);
	// ~setBackground3.(index:18, scale:1, rot:0, mode:31, color:Color.hsv(0.33,1,1).darken(0.89).asArray);

	// each polyline (blob)
	4.do({|i|
		// var c = Color.new(0,1/2,0.5/2,1);
		var c = Color.yellow().lighten(0.0);
		// var c = Color.hsv(0.2 + (0.02 * i),1,1).darken(0.5);
    // var c = colors[i];
		~setPolylineColor.(i,c.asArray); // might be broken
	});
  ~setColorRamp.(Color(1,0,0).asArray, 180);

	// ~setDisplace.(mix:1.0, x:2, y:2, period:1, noise:1, z:0);
	// ~setDisplace.(mix:0.8, x:4, y:4, period:0.1, noise:2.3, z:0);
	~setDisplace.(mix:0.0);

	// ~setFeedback.(mix:0.9, opacity:0.9, hue:0.02, x:0.00, y:-0.03, dx:0.0, dy:0.0, edgeColor:Color(0,0,1).asArray, edgeBlack:0.1, edgeStength:0);
	~setFeedback.(mix:0);
  
};

//------------------------------------------------------
~deinit = {|patch|

  patterns.do({|p,i|
    p.stop;
  });
  patterns.free;

};

//---------------------------------------------------
~onBlobInit = {|blob, blobsDict|


  var pattern = Pdef("pa_"++blob.label,
    Pbind(
      \type, \customVisualEvent,
      \dur, 0.2,
      \amp, 0,
      \note, Pseq([0,2,4,6,8,10], inf),
      \octave, Pfunc({ blob.label.asInteger.mod(4) + 2}),
      // visuals
      \modi, Pfunc({ blob.label.asInteger.mod(4)}),
      \shape, 1,
      \vdur, 1.0,
      \vatt, 0.01,
      \vrel, 0.01,
      \color, Pswitch([0.01,0.25,0.5,0.75], Pkey(\modi)),//Pfunc({blob.center.getnSynchronous(2)[0].linlin(0.3,0.7,0.1,0.9)}),
      \vscale, 1,
      \scx, 1.0,//Pfunc({blob.rect.getnSynchronous(4)[2].linlin(50,150,0.7,2)}),
		  \scy, 0.1,
      \sx, Pfunc({blob.center.getnSynchronous(2)[0].linlin(0.0,1.0,0,3.05) + 0.05}),
      \sy, -3.5, //-1 to -4.5 
      \ex, Pkey(\sx),
      \ey, Pkey(\sy) + 1.25,//Pfunc({Rect.fromArray(blob.rect.getnSynchronous(4)).height.linlin(0.0,480.0,0,3.5)}),
      // \test, Pfunc({Rect.fromArray(blob.rect.getnSynchronous(4)).height.linlin(0.0,480.0,0,1.0)}).trace,
      // \imageindex, 2,
      // \rotstart, 180,
      // \rotend, 180,
      // \speed, 10,
      // \bc, 20,
      // \wobble, 11.1,
      // \vmix, PLFTri(140,0,0.4,0.5,inf),

    )
  ).play;

  patterns.put(blob.label, pattern);
  patterns.at(blob.label).play;

	postf("blob init: %\n", blob.label);
};

//------------------------------------------------------
~onBlobUpdate = {|blob, blobsDict|
};

//------------------------------------------------------
~onBlobDeinit = {|blob, blobsDict|
	postf("blob deinit: % \n", blob.label);
  // Pdef("pa_"++blob.label).clear;
  patterns.at(blob.label).clear;
  patterns.removeAt(blob.label);

  
};


//------------------------------------------------------
~onPlotData = {|blobsDict|	
};

//------------------------------------------------------
~onBlobData = {|blob|
};
