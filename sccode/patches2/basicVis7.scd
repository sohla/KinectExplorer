var noteAddr = "";
var globalAddr = "";
var synths = Array.fill(8,{nil});
var pairs = Dictionary.new(8);
var notes = [50,54+12,57,61+12];
var root = [0,-2,3,-4,-5].stutter(14);
var sx = 0;
var group = Group.new;
var verbSynth;
var bus = Bus.audio(s,2);

var findNextRunning = {
	var index = 0;
	synths.do({|e,i|
		if(e == nil,{
			index = i;
		});
	});
	index
};


//------------------------------------------------------
~init = {|patch|

	SynthDef(\chordal, {|out = 0, freq = 120, amp = 0.4, attack = 0.01, decay = 0.03, sustain = 0.4, release = 0.9, gate = 1, harm = 1, lfn = 200|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var	exc = LFNoise2.ar(lfn, 0.06, 1); 
		var lfo = LFCub.ar(0.1,0,0.014,1);

		var sig = (DynKlank.ar(`[
				Array.series(12, [freq,freq+0.3] * lfo, [freq,freq+0.5] * harm * lfo),
				Array.geom(12,0.9,0.2*exc),
				Array.fill(12,3)
			], exc) * 0.02).softclip;
		var tone = SinOsc.ar([freq, freq + (freq * 0.003)] * 1,0,0.2 * env);
		Out.ar(out, LeakDC.ar(sig + tone) * amp * env);
	}).add;


	SynthDef(\verb1, {|inBus = 0, outBus = 0, gate = 1|
		var in = In.ar(inBus, 2);
		var env = EnvGen.ar(Env.adsr(0.01,0.01,1,5), gate, doneAction: 2);
		var sig = JPverb.ar(in, 15, 0.1, 5, 0.7, 0.6, 3.8, 0.6,0.6,0.5);
		Out.ar(outBus, sig * env);
	}).add;


	noteAddr = patch.noteAddr;
	globalAddr  = patch.globalAddr;

	// group = Group.new;
	verbSynth  = Synth.head(group,\verb1, [\inBus, bus, \outBus,0]);


	//----------------------------------------------------------------------------
	// vis
	//----------------------------------------------------------------------------
	globalAddr.sendMsg("/xfade",1);//0 off 1 mix 

	~setPolyline.(1,3,1);

	// each polyline (blob)
	4.0.do({|i|
		var c = Color.red;
		~setPolylineColor.(i,c.asArray);
	});

	~setColorRamp.(Color.red.asArray, 120);

	// ~setBackground0.();
	~setBackground1.(Color.red.asArray);
	~setBackground2.(blur:0.98, step:0.04);
	// ~setBackground3.(index:8, scale:1, rot:0.01, mode:31, color:Color.white.asArray);

	// ~setDisplace.(mix:0.0, x:1, y:1, period:0.3, noise:1, z:0);
	~setDisplace.(mix:0.0);
	// ~setFeedback.(mix:1, opacity:0.98, hue:0.0, x:0, y:0.5, dx:0.11, dy:0.11, edgeColor:Color(0,1,1).asArray, edgeBlack:0.0, edgeStength:0.0);
	~setFeedback.(mix:0);

};

//------------------------------------------------------
~deinit = {|patch|

	postf("deinit : % \n", patch.file);

	synths.do({|o,i|
		if(o != nil,{
			o.postln;
			o.set(\gate, 0);
		});
	});
	verbSynth.set(\gate, 0);

	pairs = Dictionary.new(4);
	synths = Array.fill(8,{nil});
};
//---------------------------------------------------
~onBlobInit = {|blob, blobsDict|

	var i = findNextRunning.();

	var vizMessage = {|i|
		if(noteAddr != nil, {
			noteAddr.sendMsg("/shadow", 
				"shape", 7,
				"duration", 0.1,
				"attack", 0.03,
				"release", 1.1,
				"color", blob.center.getnSynchronous(2)[0].linlin(0,1,0,0.18),
				"scale", 1,
				"scx", 1,
				"scy", 1,
				"sx", sx,
				"sy", 0,
				"ex", sx,
				"ey", 0,
				"imageindex", 0,
				"rotstart",0,
				"rotend", 0,

				"speed", 1,//e[\speed],
				"freq", 20,
				"amp", 0.04,

				"wobble", 0,
			);
		});
	};

	if(i != nil, {
		var synth = Synth.head(group, \chordal, [\out, bus, \gate,1, \freq, (notes[0] + root[0] + [0,-12,0,0,-12].choose).midicps, \attack, 0.8, \sustain, 1.0, \decay, 0.9, \release, 0.1]);

		vizMessage.(i);
		notes = notes.rotate(-1);
		root = root.rotate(-1);
		synths.put(i,synth);

		pairs.put(blob.label, i);
	});	

};

//------------------------------------------------------
~onBlobDeinit = {|blob, blobsDict|

	var i = pairs.removeAt(blob.label);

	if(i != nil,{
		synths.at(i).set(\gate, 0);
		synths.put(i,nil);
	});


};

//------------------------------------------------------
~onBlobUpdate = {|blob, blobsDict|

	var i = pairs.at(blob.label);
	if(i != nil,{
		synths.at(i).set(\lfn, blob.rect.getnSynchronous(4)[2].linexp(20,102,200,20000));
		synths.at(i).set(\harm, blob.rect.getnSynchronous(4)[2].linexp(20,102,0.5,3.0));
		sx = blob.center.getnSynchronous(2)[0].linlin(0.31,0.72,-1,1);
	});
};

//------------------------------------------------------
~onPlotData = {|blobsDict|
	
	blobsDict.size
};

//------------------------------------------------------
~onBlobData = {|blob|
	
	var rect  = Rect.fromArray(blob.rect.getnSynchronous(4));
	// blob.rect.getnSynchronous(4)[2].postln;
	rect.width * -1
};
