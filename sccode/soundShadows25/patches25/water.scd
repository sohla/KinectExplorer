var patterns = Dictionary.new(4);
// ------------------------------------------------------
~init = {|patch|

  var colors = [Color.red, Color.yellow, Color.blue, Color.cyan, Color.green];

SynthDef(\plob, {|out = 0, freq = 150, amp = 0.3, pan = 0, gate = 1, sl = 0.3|
	var slide = XLine.ar(1.0, 10.0, sl,doneAction: 2);
	var env = EnvGen.ar(Env.perc(0.03,2), gate);
	var sig = SinOsc.ar(freq + (freq * slide)) * env;
  var filtered = RLPF.ar(sig, freq * 1.5, 0.3);
  var dly = filtered;//CombL.ar(filtered, 0.3, 0.3, 3.0);
  dly = LPF.ar(dly, 800);
  DetectSilence.ar(dly, doneAction: 2);
  Out.ar(out, Pan2.ar(dly * amp, pan));
}).add;


	// ~setOSCReset.(1);
	~setXfade.(1);

	~setPolyline.(1,2,1);
  ~setRGBColor.([1,1,1,1]); //might need to reset in globals OSC IN

  ~setColorRamp.(Color(0.5,0.5,0.9).asArray, 200);
	// ~setBackground0.();
	// ~setBackground1.(Color.white().darken(0.2).asArray);
	// ~setBackground2.(blur:0.7, step:0.1);
	~setBackground3.(index:32, scale:1, rot:0, mode:31, color:Color.blue.lighten(0.4).asArray);

	// each polyline (blob)
	4.do({|i|
		// var c = Color.new(0,1/2,0.5/2,1);
		var c = Color.hsv(0.64,0.8,0.05);
		// var c = Color.hsv(0.3 + (0.05 * i),0.7,0.7);
    // var c = colors[i];
		~setPolylineColor.(i,c.asArray); // might be broken
	});

	~setDisplace.(mix:0.2, x:10, y:0, period:1, noise:1, z:0);
	// ~setDisplace.(mix:1, x:0.1, y:3, period:0.1, noise:5, z:0);
	// ~setDisplace.(mix:0.0);

	// ~setFeedback.(mix:0.9, opacity:0.94, hue:0.03, x:0.0, y:0.03, dx:0.0, dy:0.0, edgeColor:Color(0,0.3,1).asArray, edgeBlack:0.0, edgeStength:0.0);
	~setFeedback.(mix:0);


};

//------------------------------------------------------
~deinit = {|patch|

  patterns.do({|p,i|
    p.stop;
  });
  patterns.free;
	~setPolyline.(0,1,1);

};

//---------------------------------------------------
~onBlobInit = {|blob, blobsDict|


  var pattern = Pdef("pa_"++blob.label,
    Pbind(
      \type, \customVisualEvent,
      \instrument, \plob,
      \dur, Pexprand(0.3, 0.7, inf),
      \freq, Pwhite(20,44).midicps,
      \sl, Pwhite(0.3,2.7),
      \amp, Pwhite(0.01,0.1),
      \pan, Pwhite(-1.0, 1.0, inf),    // Random panning
      \attackTime, 0.001,
      \decayTime, Pexprand(0.11, 0.04, inf),  // Varied decay time
      \filterFreq, Pexprand(900, 2000, inf) * 2,  // Random filter frequency
      \filterRQ, Pwhite(0.5, 1.5, inf),
	    \wobble, Pwhite(3,7,inf),
      // visuals
      \modi, Pfunc({ blob.label.asInteger.mod(4)}),
      \shape, 2,
      \vdur, Pwhite(0.3,0.9),
      \vatt, 0.1,
      \vrel, 0.4,
      \color, Pswitch([0.01,0.25,0.5,0.75], Pkey(\modi)),//Pfunc({blob.center.getnSynchronous(2)[0].linlin(0.3,0.7,0.1,0.9)}),
      \vscale, Pexprand(0.01,0.1, inf),//Pwhite(0.01,0.1),
      \scx, 1,//Pfunc({blob.rect.getnSynchronous(4)[2].linlin(50,150,0.7,2)}),
		  \scy, 1,
      \sx, Pfunc({blob.center.getnSynchronous(2)[0].linlin(0.0,1.0,0,3.05) + 0.05}) + Pwhite(-0.1,0.1),
      \sy, Pfunc({ -3.4 + Rect.fromArray(blob.rect.getnSynchronous(4)).height.linlin(0.0,480.0,0,3.5)}),//Pwhite(-2.0,-2.5), //-1 to -4.5
      \ex, Pkey(\sx),
      \ey, Pkey(\sy) + 1,//Pfunc({Rect.fromArray(blob.rect.getnSynchronous(4)).height.linlin(0.0,480.0,0,3.5)}),
      // \test, Pfunc({Rect.fromArray(blob.rect.getnSynchronous(4)).height.linlin(0.0,480.0,0,1.0)}).trace,
      // \imageindex, 2,
      // \rotstart, 180,
      // \rotend, 180,
      // \speed, 10,
      // \bc, 20,
      \wobble, 1,
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


