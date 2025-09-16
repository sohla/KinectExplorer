var patterns = Dictionary.new(4);
var synths = Dictionary.new(4);
// ------------------------------------------------------
~init = {|patch|

  var colors = [Color.red, Color.yellow, Color.blue, Color.cyan, Color.green];

  SynthDef(\sheet3, {
    |out=0, amp=0.5, density=0.5, strength=0.5,
    filterFreq=400, filterQ=0.5,
    reverbMix=0.5, reverbRoom=0.5, reverbDamp=0.2, gate=0, my=0.5, mx=0.5,pan=0|

    var wind, filtered, reverbed;
    var densityMod, strengthMod;
    var env = EnvGen.ar(Env.asr(1.3,1.0,3 ), gate, doneAction:2);
    var klank;

    densityMod = LFNoise2.kr(0.1).range(0.8, 1.2) * mx.lag(5);
    strengthMod = LFNoise2.kr(0.2).range(0.8, 1.2) * my.lag(3.5);
    wind = [WhiteNoise.ar(1),WhiteNoise.ar(1)];
    wind = Dust.ar(densityMod * 10000) * wind;
    wind = wind * strengthMod;
    klank = Klank.ar(`[[800, 1071, 1153, 1723] * 0.4, nil, [1, 0.4,0.1,0.03]], wind) * 0.6;

    filtered = RLPF.ar(wind, filterFreq.lag(3)  * strengthMod.linexp(0, 1, 0.5, 2), filterQ);
    reverbed = FreeVerb.ar(filtered, reverbMix, reverbRoom, reverbDamp);
    reverbed = Balance2.ar(reverbed[0],reverbed[1],pan.lag(3));
    Out.ar(out, reverbed * amp.lag(0.0001) * env);

  }).add;
	// ~setOSCReset.(1);
	~setXfade.(1);

	~setPolyline.(1,1,1);
  ~setRGBColor.([1,1,1,1]); //might need to reset in globals OSC IN

	// ~setBackground0.();
	// ~setBackground1.(Color.white().darken(0.2).asArray);
	// ~setBackground2.(blur:0.7, step:0.1);
	~setBackground3.(index:23, scale:1, rot:0, mode:31, color:Color.white.asArray);

	// each polyline (blob)
	4.do({|i|
		// var c = Color.new(0,1/2,0.5/2,1);
		var c = Color.white().lighten(0.1);
		// var c = Color.hsv(0.1 + (0.05 * i),1,1);
    // var c = colors[i];
		~setPolylineColor.(i,c.asArray); // might be broken
	});
  ~setColorRamp.(Color(1.0,1.0,1.0).asArray, 200);
	// ~setDisplace.(mix:0.2, x:3, y:3, period:0.1, noise:0.2, z:1);
	// ~setDisplace.(mix:1, x:0.1, y:3, period:0.1, noise:5, z:0);
	~setDisplace.(mix:0.0);

	~setFeedback.(mix:0.5, opacity:0.86, hue:0.02, x:0.2, y:0.2, dx:0.0, dy:0, edgeColor:Color(0,0,0).asArray, edgeBlack:0.3, edgeStength:0.3);
	// ~setFeedback.(mix:0);



};

//------------------------------------------------------
~deinit = {|patch|

  patterns.do({|p,i|
    p.stop;
  });
  patterns.free;

  synths.do({|p,i|
    p.set(\gate, 0);
  });
  synths.free;

	~setPolyline.(0,1,1);

};

//---------------------------------------------------
~onBlobInit = {|blob, blobsDict|


  var pattern = Pdef("pa_"++blob.label,
    Pbind(
      \type, \customVisualEvent,
      \dur, Pwhite(0.2,0.3),
      \freq, Pexprand(1400, 770, inf),  // Random frequency for each droplet
      \amp, 0,
      \pan, Pwhite(-1.0, 1.0, inf),    // Random panning
      \attackTime, 0.001,
      \decayTime, Pexprand(0.11, 0.04, inf),  // Varied decay time
      \filterFreq, Pexprand(900, 2000, inf) * 2,  // Random filter frequency
      \filterRQ, Pwhite(0.5, 1.5, inf),
	    \wobble, Pwhite(3,7,inf),
      // visuals
      \modi, Pfunc({ blob.label.asInteger.mod(4)}),
      \shape, 5,
      \vdur, 0.6,//Pwhite(0.1,0.2) * 2,
      \vatt, 0.1,
      \vrel, 0.8,
      \color, Pswitch([0.01,0.25,0.5,0.75], Pkey(\modi)),//Pfunc({blob.center.getnSynchronous(2)[0].linlin(0.3,0.7,0.1,0.9)}),
      \vscale, 0.1,
      \scx, 1,//Pfunc({blob.rect.getnSynchronous(4)[2].linlin(50,150,0.7,2)}),
		  \scy, 1,
      \sx, Pfunc({blob.center.getnSynchronous(2)[0].linlin(0.0,1.0,0,3.05) + 0.05}) + Pwhite(-0.1,0.1),
      \sy, Pwhite(-2,-3.5),
      \ex, Pfunc({blob.center.getnSynchronous(2)[0].linlin(0.0,1.0,0,3.05) + 0.05}) + Pwhite(0.7,0.9),
      \ey, Pfunc({ -2 + Rect.fromArray(blob.rect.getnSynchronous(4)).height.linlin(0.0,480.0,0,3.5)}),
    )
  ).play;

  var synth = Synth(\sheet3, [\gate, 1]);
  synths.put(blob.label, synth);

  patterns.put(blob.label, pattern);
  patterns.at(blob.label).play;


	postf("blob init: %\n", blob.label);

};

//------------------------------------------------------
~onBlobUpdate = {|blob, blobsDict|
  synths.at(blob.label).set(\filterFreq, blob.center.getnSynchronous(2)[0].linexp(0,1.0,300,1700));
  synths.at(blob.label).set(\mx, blob.center.getnSynchronous(2)[1].linexp(0,2.0,0.2,0.9));
  synths.at(blob.label).set(\my, blob.center.getnSynchronous(2)[1].linexp(0,2.0,0.2,0.9));
};

//------------------------------------------------------
~onBlobDeinit = {|blob, blobsDict|
	postf("blob deinit: % \n", blob.label);
  // Pdef("pa_"++blob.label).clear;
  patterns.at(blob.label).clear;
  patterns.removeAt(blob.label);

  synths.at(blob.label).set(\gate, 0);
  synths.removeAt(blob.label);

};


