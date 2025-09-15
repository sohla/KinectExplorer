var patterns = Dictionary.new(4);


// ------------------------------------------------------
~init = {|patch|

  var colors = [Color.red, Color.yellow, Color.blue, Color.cyan, Color.green];


SynthDef(\basicSin, {|out = 0, freq = 160, amp = 0.1, attack = 0.02, decay = 0.1, sustain = 0.1, release = 0.2, gate = 1, pan = 0, lfof = 1|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var lfo = 1;//Saw.ar(lfof,1).lag(0.03);
		var sig = SinOsc.ar(freq, 0, amp * lfo) + Saw.ar(freq * 1.007, amp * 0.2 * lfo);
		Out.ar(out, Pan2.ar(sig * env, pan));

	}).add;
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
	// ~setBackground1.(Color.blue().darken(0.3).asArray);
	// ~setBackground2.(blur:0.5, step:0.06);
  // ~setBackground2.(blur:0.7, step:0.1);
	~setBackground3.(index:24, scale:1, rot:0, mode:3, color:Color.hsv(0.27,0.6,1).asArray);

	// each polyline (blob)
	4.do({|i|
		// var c = Color.new(0,1/2,0.5/2,1);
		// var c = Color.blue(0.5).alpha_(0.1);
		var c = Color.hsv(0.27 + (0.04 * i),0.6,0.3).darken(0.5);
    // var c = colors[i];
		~setPolylineColor.(i,c.asArray); // might be broken
	});
  ~setColorRamp.(Color(0,0.8,0.3).asArray, 100);

	// ~setDisplace.(mix:1.0, x:2, y:2, period:1, noise:1, z:0);
	// ~setDisplace.(mix:0.8, x:4, y:4, period:0.1, noise:2.3, z:0);
	~setDisplace.(mix:0.0);

	~setFeedback.(mix:0.9, opacity:0.77, hue:0.02, x:0.00, y:-0.0, dx:0.0, dy:0.0, edgeColor:Color(0,0.7,0.2).asArray, edgeBlack:0.1, edgeStength:1.0);
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
      \instrument, \raindrop,
      \dur, Pexprand(0.13, 0.05, inf) * 2,
      \freq, Pexprand(1400, 770, inf),  // Random frequency for each droplet
      \amp, 0.1,
      \pan, Pwhite(-1.0, 1.0, inf),    // Random panning
      \attackTime, 0.001,
      \decayTime, Pexprand(0.11, 0.04, inf),  // Varied decay time
      \filterFreq, Pexprand(900, 2000, inf) * 2,  // Random filter frequency
      \filterRQ, Pwhite(0.5, 1.5, inf),
	    \wobble, Pwhite(3,7,inf),
      // visuals
      \modi, Pfunc({ blob.label.asInteger.mod(4)}),
      \shape, 1,
      \vdur, 0.03,
      \vatt, 0.1,
      \vrel, 0.4,
      \color, Pswitch([0.01,0.25,0.5,0.75], Pkey(\modi)),//Pfunc({blob.center.getnSynchronous(2)[0].linlin(0.3,0.7,0.1,0.9)}),
      \vscale, Pwhite(0.05,0.3),
      \scx, 1.0,//Pfunc({blob.rect.getnSynchronous(4)[2].linlin(50,150,0.7,2)}),
		  \scy, 1.0,
      \sx, Pfunc({blob.center.getnSynchronous(2)[0].linlin(0.0,1.0,0,3.05) + 0.05}) + Pwhite(-0.1,0.1),
      \sy, Pfunc({ -2.5 + Rect.fromArray(blob.rect.getnSynchronous(4)).height.linlin(0.0,480.0,0,3.5)}),//Pwhite(-2.0,-2.5), //-1 to -4.5
      \ex, Pkey(\sx),
      \ey, Pkey(\sy),//Pfunc({Rect.fromArray(blob.rect.getnSynchronous(4)).height.linlin(0.0,480.0,0,3.5)}),
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


