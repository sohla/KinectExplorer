var patterns = Dictionary.new(4);
// ------------------------------------------------------
~init = {|patch|

  var colors = [Color.red, Color.yellow, Color.blue, Color.cyan, Color.green];


	SynthDef(\wingChimes2, {|freq = 1000, pulseFreq = 1, amp = 0, rq = 0.0008, att = 0.07, dec = 0.3, sus = 0.3, rel = 3, gate = 1, numHarms = 10, pan =0|
		var snd, env;
		env = EnvGen.kr(Env.adsr(att, dec, sus, rel), gate: gate, doneAction: 2);
		snd = BPF.ar(
			in: WhiteNoise.ar(Select.ar(0,
				[
					Blip.ar(pulseFreq, numHarms, 0.5),
					LFPulse.ar(pulseFreq,0,0.5) * 0.1
				]
			)),
			freq: (freq * [1,1.003]),
			rq: Lag.kr(rq, 1));
		snd = snd * env * Lag.kr(amp, 1) * 20;
		snd = Clip.ar(snd, -0.5, 0.5);
		snd = BLowShelf.ar(snd,200,1,4);
		Out.ar(0, Pan2.ar(snd, pan));
	}).add;


	// ~setOSCReset.(1);
	~setXfade.(1);

	~setPolyline.(1,1,1);
  ~setRGBColor.([1,1,1,1]); //might need to reset in globals OSC IN

	// ~setBackground0.();
	// ~setBackground1.(Color.white().darken(0.2).asArray);
	// ~setBackground2.(blur:0.7, step:0.1);
	~setBackground3.(index:29, scale:1, rot:0, mode:31, color:Color.white.darken(0.8).asArray);

	// each polyline (blob)
	4.do({|i|
		// var c = Color.new(0,1/2,0.5/2,1);
		var c = Color.white().darken(0.8);
		// var c = Color.hsv(0.1 + (0.05 * i),1,1);
    // var c = colors[i];
		~setPolylineColor.(i,c.asArray); // might be broken
	});
  ~setColorRamp.(Color(1.0,1.0,1.0).asArray, 200);
	// ~setDisplace.(mix:0.2, x:3, y:3, period:0.1, noise:0.2, z:1);
	~setDisplace.(mix:0.5, x:0.1, y:0.1, period:0.1, noise:5, z:0);
	// ~setDisplace.(mix:0.0);

	~setFeedback.(mix:1, opacity:0.96, hue:0.02, x:0.0, y:0.04, dx:0.0, dy:0.0, edgeColor:Color(1,1,1).asArray, edgeBlack:0.3, edgeStength:0.1);
	// ~setFeedback.(mix:0);



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
      \instrument, \wingChimes2,
      \dur, Pwhite(0.3,0.5),
      \root, Pseq([4,2,0,-2].stutter(8), inf),
      \octave, Pseq([7,6,5].stutter(3), inf) - 2,
      \note, Pseq([0,4,8,12].reverse, inf),
      \amp, 0,
      \pan, Pwhite(-1.0, 1.0, inf),    // Random panning
      \attackTime, 0.001,
      \rq, Pwhite(0.0008, 0.0012),

      // visuals
      \modi, Pfunc({ blob.label.asInteger.mod(4)}),
      \shape, 3,
      \vdur, 0.01,//Pwhite(0.1,0.2) * 2,
      \vatt, 0.02,
      \vrel, 1.8,
      \color, Pswitch([0.01,0.25,0.5,0.75], Pkey(\modi)),//Pfunc({blob.center.getnSynchronous(2)[0].linlin(0.3,0.7,0.1,0.9)}),
      \vscale, Pwhite(0.004,0.03) * 20,
      \scx, 1,//Pfunc({blob.rect.getnSynchronous(4)[2].linlin(50,150,0.7,2)}),
		  \scy, 1,
      \sx, Pfunc({blob.center.getnSynchronous(2)[0].linlin(0.0,1.0,0,3.05) + 0.05}) + Pwhite(-0.1,0.1),
      \sy, -1,
      \ex, Pkey(\sx),
      \ey, -4.5//Pfunc({ -5 + Rect.fromArray(blob.rect.getnSynchronous(4)).height.linlin(0.0,480.0,0,3.5)}),
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


