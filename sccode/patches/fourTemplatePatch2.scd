var oct = 0;
var note = 0;
var scale = 1;
var poolSize = 4;
var isPlayingBlob = Array.fill(poolSize, false);
var patterns = Array.new(poolSize);
var cb = [Bus.control(s,1),Bus.control(s,1),Bus.control(s,1),Bus.control(s,1),Bus.control(s,1)];
var binds = Array.new(poolSize);
var notes = [Bus.control(s,1),Bus.control(s,1),Bus.control(s,1),Bus.control(s,1),Bus.control(s,1)];
var oscSender;
var vizMessage;

//------------------------------------------------------
~init = {|model|

	postf("init : % \n", model.file);
	oscSender = model.netAddr;


	vizMessage = {|e, i|
		oscSender.sendMsg("/shadow", 

			"shape", e.sh,

			"duration", e.dur,
			"attack", e.attack * 1,
			"release", e.rel *1,

			"color", i.linlin(0,3,0,0.99),

			"scale", 1,

			"sx", cb[i].getSynchronous.(),
			"sy", -0.0,
			"ex", cb[i].getSynchronous.(),
			"ey", -0.0,

			"imageindex", e.ii,

			"rotstart",45,
			"rotend", 45,

			"amp", 0.13,
			"speed", 3,
			"freq", 4,

			"wobble", 100,
		);
	};

	SynthDef(\a, {|out = 0, freq = 160, amp = 0.3, attack = 0.01, decay = 4.02, sustain = 0.8, release = 0.9, gate = 1, ff = 500, rf = 1|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var sig = SinOsc.ar([freq,freq + 7.rand], LocalIn.ar(2) * LFNoise1.ar(0.1,5), amp) * env;
		var filter = MoogFF.ar(sig, ff.lag(0.1), rf);
		LocalOut.ar(filter);
		Out.ar(out, filter);

	}).add;

	SynthDef(\b, {|out = 0, freq = 160, amp = 0.3, attack = 0.01, decay = 4.02, sustain = 0.8, release = 0.9, gate = 1, ff = 500, rf = 1|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var sig = Saw.ar([freq,freq + 2.rand], amp) * env;
		var filter = MoogFF.ar(sig, ff.lag(0.1), rf);
		LocalOut.ar(filter);
		Out.ar(out, filter);

	}).add;
	

	SynthDef(\c, {|out = 0, freq = 160, amp = 0.3, attack = 0.01, decay = 4.02, sustain = 0.8, release = 0.9, gate = 1, ff = 500, rf = 1|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var sig = Pulse.ar([freq,freq + 3.rand], 0.5, amp) * env;
		var filter = MoogFF.ar(sig, ff.lag(0.1), rf);
		LocalOut.ar(sig);
		Out.ar(out, filter);

	}).add;


	SynthDef(\d, {|out = 0, freq = 160, amp = 0.3, attack = 0.01, decay = 4.02, sustain = 0.8, release = 0.9, gate = 1, ff = 500, rf = 1|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var sig = Blip.ar([freq,freq + 3.rand], LocalIn.ar(2) * LFNoise1.ar(20,1) * freq, amp) * env;
		var filter = MoogFF.ar(sig, ff.lag(0.1), rf);
		LocalOut.ar(sig);
		Out.ar(out, filter);

	}).add;


	poolSize.do({|i|
	
		var bi =	Pbind(

		    \instrument, Pswitch([\a, \b, \c, \d], i, inf),
		    \amp, Pwhite(0.3, 0.2),
		    \root, 0,
		    \scale, 1,
		     \octave, Pfunc{ 2 + i },
		    \note, Pfunc{ notes[i].getSynchronous.()},
		    \dur, Pswitch([0.4, Pseq([0.2, 0.2, 0.4], inf), Pseq([0.2, 0.8, 0.4], inf), Pseq([0.8, 0.2, 0.2], inf)], i, inf),
		    \attack, Pwhite(0.001,0.01),
		    \decay, Pwhite(0.2,0.9),
		    \release, 1.2,
		    \rel, Pkey(\release),
		    \ff, Pwhite(300, 7000),
		    \rf, Pseq([3,0,3,1,1,3,1], inf),

		    \sh, 10,//Pswitch([3, 4, 6, 10], i, inf),

		    \ii, Pswitch([1, 4, 7, 10], i, inf),

		    // osc out for viz
			\osc, Pfunc{|e| 
				if(isPlayingBlob[i] == true, { vizMessage.(e, i)});
				true
			},
	    );

		binds = binds.add(bi);

	});



	// •• do we just need a pool of patterns we can use...?

	n = [\aaPtn, \bbPtn, \ccPtn, \ddPtn];

	patterns = Array.fill(poolSize, {|i|
		Ndef(n[i], binds[i]).quant_(0.2);
	});



	// problem is we need multi channels for data streams

	// Ndef(\bbPtn).set(\dur, 0.1);
	// Ndef(\bbPtn).set(\release, 0.1);
	// Ndef(\ccPtn).set(\dur, 0.4);
	// Ndef(\ddPtn).set(\dur, 0.3);
	// Ndef(\ddPtn).set(\release, 0.1);
	// Ndef(\ddPtn).set(\dur, 0.2);
	// Ndef(\ddPtn).set(\release, 0.1);

	// s.queryAllNodes;
	// patterns.size.postln;

};

//------------------------------------------------------
~reload = {|model|

	postf("reload : % \n", model.file);

	patterns.do{|p|
		if(p != nil,{
			p.end(0.1);
		});
	};

	patterns = [];

	Ndef.clear(0.1);

	~init.(model);

};

//------------------------------------------------------
~deinit = {|model|

	postf("deinit : % \n", model.file);

	patterns.do{|p|
		if(p != nil,{
			p.end(0.1);
		});
	};

	patterns = [];

	// need this for reloading or patterns after an edit
	Ndef.clear;

};

//---------------------------------------------------
~onInit = {|blob, blobsDict|

	var l = (blob.label.mod(patterns.size));

	isPlayingBlob[l] = true;


	if(patterns[l].isMonitoring == false,{
		// s.queryAllNodes;
		// patterns[l].rebuild;
		patterns[l].play(0.1);
		postf("playing : (%)[%] % \n", blob.label, l, patterns[l]);
	});
	patterns[l].group.postln;
	// oscSender.sendMsg("/shadow", 

	// 					"shape", 9,

	// 					"duration", 1,
	// 					"attack", 0.1,
	// 					"release", 1,

	// 					"color", 0,//i.linlin(0,4,0,0.99),//(e.note + (e.octave * 12)).linlin(30,80,0,0.99),

	// 					"scale", 1,//(e.note + (e.oct * 12)).linexp(0,127,2,0.2),

	// 					"sx", 0,//(e.note + (e.octave * 12)).linlin(30,80,-1.8,1.8),
	// 					"sy", 0,
	// 					"ex", 0,//(e.note + (e.octave * 12)).linlin(30,80,-1.8,1.8),
	// 					"ey", 0,

	// 					"imageindex", 13,

	// 					"rotstart", 45,
	// 					"rotend", 135,


	// 					"wobble", 100,//e.param2.linlin(1,6,0.1,1), // wobble
	// 				);

};

//------------------------------------------------------
~onDeinit = {|blob, blobsDict|

	var l = (blob.label.mod(patterns.size));

	isPlayingBlob[l] = false;

	if(patterns[l].isMonitoring == true,{
		patterns[l].stop(0.3);
		postf("ending : (%)[%] % \n", blob.label, l, patterns[l]);
	});

};

//------------------------------------------------------
~onUpdate = {|blob, blobsDict, model|

	var l = (blob.label.mod(patterns.size));
	// var notes = [0,7,12,16];
	notes[l].value = blob.center.x.linlin(100,550,0,12).floor * 4;
	// oct = blobsDict.values[0].area.linexp(1.0,16.0,6,3).floor;
	// patterns[l].set(\note, note);
	// patterns[l].set(\octave, oct);
	// patterns[l].set(\ff, blob.area.linexp(1.0,8.0,400,6000));

	cb[l].value = blob.center.x.linlin(0,600,-1.5,1.5);
	

};

//------------------------------------------------------
~onData = {|blobsDict|
	[blobsDict.values[0].area.linexp(1.0,16.0,4,2).floor];
};

