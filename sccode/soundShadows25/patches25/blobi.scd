var patterns = Dictionary.new(4);
// ------------------------------------------------------
~init = {|patch|

  var colors = [Color.red, Color.yellow, Color.blue, Color.cyan, Color.green];


SynthDef(\raindrop, {
    |out=0, freq=1000, amp=0.1, pan=0, gate=1, attackTime=0.001, decayTime=0.05,
	filterFreq=3000, filterRQ=1, wobble=10,
 	reverbMix=0.3, reverbRoom=0.03, reverbDamp=0.5|

	var sig, env;
    var verb;

    // Envelope for the droplet shape
    env = EnvGen.ar(Env.perc(attackTime, decayTime), gate);

    // Basic droplet sound
    sig = SinOsc.ar(freq * LFPar.ar(wobble,pi/2, 0.2,1)) * env;

    // Apply bandpass filter
    sig = BPF.ar(sig, filterFreq, filterRQ);
    verb = FreeVerb.ar(sig, reverbMix, reverbRoom, reverbDamp);

	DetectSilence.ar(verb, doneAction: 2);
    Out.ar(out, PanAz.ar(2, verb, pan, 1, 2, 0.5) * amp);
}).add;

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
		// var c = Color.black().lighten(0.1);
		// var c = Color.hsv(0.1 + (0.05 * i),1,1);
    var c = colors[i];
		~setPolylineColor.(i,c.asArray); // might be broken
	});
  ~setColorRamp.(Color(0.0,1.0,1.0).asArray, 120);
	// ~setDisplace.(mix:1, x:3, y:10, period:0.1, noise:0.2, z:1);
	// ~setDisplace.(mix:1, x:0.1, y:3, period:0.1, noise:5, z:0);
	~setDisplace.(mix:0.0);

	// ~setFeedback.(mix:1, opacity:0.96, hue:0.02, x:0.0, y:0.04, dx:0.0, dy:0.0, edgeColor:Color(0,1,0).asArray, edgeBlack:0.3, edgeStength:0.9);
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
      \instrument, \raindrop,
      \dur, 0.25,//Pexprand(0.13, 0.3, inf) ,
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
      \shape, 0,
      \vdur, 1.2,
      \vatt, 0.3,
      \vrel, 0.3,
      \color, Pswitch([0.01,0.25,0.5,0.75], Pkey(\modi)),//Pfunc({blob.center.getnSynchronous(2)[0].linlin(0.3,0.7,0.1,0.9)}),
      \vscale, 1.0,
      \scx, 0.3,//Pfunc({blob.rect.getnSynchronous(4)[2].linlin(50,150,0.7,2)}),
		  \scy, 1,
      \sx, Pfunc({blob.center.getnSynchronous(2)[0].linlin(0.0,1.0,0,3.05) + 0.05}),
      \ey, 0, 
      \ex, Pkey(\sx),
      \sy, Pfunc({ -3 + Rect.fromArray(blob.rect.getnSynchronous(4)).height.linlin(0.0,480.0,0,3.5)}),
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


