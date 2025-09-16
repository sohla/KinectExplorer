
var synths = Dictionary.new(4);
var octaves = [36,48,60];
var roots = [0,3,-4].stutter(24);
var notes = [0,7,16,14,11];


// ------------------------------------------------------
~init = {|patch|

  var colors = [Color.red, Color.yellow, Color.blue, Color.cyan, Color.green];

	SynthDef(\bowedSun, { |out, freq=111, gate=0, amp = 0.4, ffrq = 1000, pan = 0|

		var env = EnvGen.ar(Env.asr(1.1,1.0,3.0), gate, doneAction:Done.freeSelf);
		var env2 = EnvGen.ar(Env.perc(0.003,2.8), gate);
		var exc = BrownNoise.ar([0.007,0.007]) * max(0, LFNoise1.kr(exprand(0.125,0.5), 0.6, 0.4));
		var tone = SinOsc.ar(freq * LFCub.ar(5,0,0.07 * env2,1), 0, 0.04 * env2);
		var sig = (Klank.ar(`[
					Array.series(12, freq, freq),
					Array.geom(12,1,rrand(0.7,0.9)),
					Array.fill(12, {rrand(1.0,3.0)})
				], exc) * 0.1).softclip;
		var res = Resonz.ar(sig, ffrq.lag(1), 0.3, 4, sig * 0.4);
		Out.ar(out, Pan2.ar((res  * env) + tone, pan) * amp);
	}).add;

	// ~setOSCReset.(1);
	~setXfade.(1);

	~setPolyline.(1,1,1);
  ~setRGBColor.([1,1,1,1]); //might need to reset in globals OSC IN

	// ~setBackground0.();
	// ~setBackground1.(Color.white().darken(0.8).asArray);
	// ~setBackground2.(blur:0.5, step:0.06);
	// ~setBackground2.(blur:0.5, step:0.06, index:1, color:Color.black.asArray);
	~setBackground2.(blur:0.7, step:0.1, index:31, color:Color.hsv(0.14,1,1).lighten(0.5).asArray);

	// ~setBackground3.(index:24, scale:1, rot:0, mode:31, color:Color.hsv(0.73,1,1).lighten(0.69).asArray);

	// each polyline (blob)
	4.do({|i|
		// var c = Color.new(0,1/2,0.5/2,1);
		// var c = Color.blue().lighten(0.1);
		var c = Color.hsv(0.55 + (0.02 * i),1,1).darken(0.5);
    // var c = colors[i];
		~setPolylineColor.(i,c.asArray); // might be broken
	});

	// ~setDisplace.(mix:1, x:0, y:10.1, period:1, noise:1, z:0);
	~setDisplace.(mix:0.1, x:0, y:10, period:10, noise:3, z:0.0);
	// ~setDisplace.(mix:0.0);

	~setFeedback.(mix:1, opacity:0.9, hue:0.2, x:-0.0, y:1.0, dx:0.0, dy:10.0, edgeColor:Color.yellow.asArray, edgeBlack:0.1, edgeStength:0.0);
	// ~setFeedback.(mix:0);


};

//------------------------------------------------------
~deinit = {|patch|
  synths.do({|p,i|
    p.set(\gate, 0);
  });
  synths.free;

};

//---------------------------------------------------
~onBlobInit = {|blob, blobsDict|
	// postf("blob init: % \n", blob.label);

  var synth = Synth(\bowedSun, [\gate, 1, \freq, (notes.choose + octaves.choose + roots[0]).midicps]);
  synths.put(blob.label, synth);
	// notes = notes.rotate(-1);
	roots = roots.rotate(-1);

};

//------------------------------------------------------
~onBlobUpdate = {|blob, blobsDict|
  synths.at(blob.label).set(\ffrq, blob.center.getnSynchronous(2)[0].linexp(0.002,1.0,50,9700));
  synths.at(blob.label).set(\pan, blob.center.getnSynchronous(2)[0].linlin(0.002,1.0,-1,1));
};

//------------------------------------------------------
~onBlobDeinit = {|blob, blobsDict|
	// postf("blob deinit: % \n", blob.label);
	synths.at(blob.label).set(\gate, 0);
  synths.removeAt(blob.label);

};


//------------------------------------------------------
~onPlotData = {|blobsDict|
};

//------------------------------------------------------
~onBlobData = {|blob|
};
