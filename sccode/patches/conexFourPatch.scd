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
			"release", e.rel * 0.4,

			"color", i.linlin(0,3,0,0.99),

			"scale", 1,

			"sx", cb[i].getSynchronous.(),
			"sy", 0,
			"ex", cb[i].getSynchronous.(),
			"ey", 0,

			"imageindex", e.ii,

			"rotstart",45,
			"rotend", 45,

			"amp", 0.43,
			"speed", 2,
			"freq", 3,

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
		Out.ar(out, filter * 0.7);

	}).add;


	SynthDef(\d, {|out = 0, freq = 160, amp = 0.3, attack = 0.01, decay = 4.02, sustain = 0.8, release = 0.9, gate = 1, ff = 500, rf = 1|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var sig = Blip.ar([freq,freq + 3.rand], LocalIn.ar(2) * LFNoise2.ar(0.2,40) * env, amp) * env;
		var filter = MoogFF.ar(sig, ff.lag(0.1), rf);
		LocalOut.ar(filter);
		Out.ar(out, filter);

	}).add;

	SynthDef(\frog, {|out = 0, attack = 0.01, decay = 4.02, sustain = 0.8, release = 0.9, freq = 120, gate = 1, vib = 1, amp = 0.3, filter = 100|

		// var env = EnvGen.ar(Env.perc(attack, release, 1, -7), gate, doneAction: 2);
		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var sig = MoogFF.ar(
			LFSaw.ar(
				[freq + (freq * LFCub.ar(freq*MouseY.kr(0.001, 3, lag: 0.3), 0, 0.49, 0.008) ), freq + (freq * LFCub.ar(freq*MouseY.kr(0.001, 3, lag: 0.3), pi/3, 0.49, 0.008) )], 
				[0,0.5], 
				0.4),
			env.linlin(0,1,500, filter.lag(0.4)),
			-4
		);
		var sub = SinOsc.ar(freq, [0,1.36], 0.4);
		Out.ar(out, (sig + sub) * env * amp);
	}).add;

	SynthDef(\long, {|out = 0, freq = 160, amp = 0.3, attack = 0.01, decay = 4.02, sustain = 0.8, release = 0.9, gate = 1, ns = 9, vibamp = 1, vibfreq = 5|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);

		var vib = LFCub.ar(vibfreq.lag(0.4), 0, vibamp.lag(0.4) * env);

		var sig = SinOsc.ar([freq,freq + 2.rand],0, amp) + Saw.ar([freq,freq + 7.rand], vib) * env * 0.5;
		Out.ar(out, sig * amp);

	}).add;
	
	SynthDef(\blaz, {|out = 0, freq = 120, amp = 0.5, attack = 0.01, decay = 0.3, sustain = 0.1, release = 0.9, gate = 1, harm = 1, fltrel = 0.3|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var sig = (BHiPass.ar(
			LFNoise2.ar(2)**1.4,
			[freq, freq + (freq * 0.01)],
			fltrel.lag(0.3),//MouseX.kr(0.001,0.3,\exponential),
			MouseY.kr(20,10900,\exponential) - freq)
		).tanh  * 0.5;
		var vib = LFCub.ar(freq * harm, 0, env, 1);
		Out.ar(out, LeakDC.ar(sig) * amp * env * vib * 0.5) ;
	}).add;

	SynthDef(\conex, {|out = 0, gate = 1, amp = 0.5, freq = 120, attack = 0.007, release = 0.9, vib = 2, klang = 1|


		var fs = Array.geom(5, freq, 2.01);
		var as = [0.7,0.5,0.05,0.02,0.01,0.005];
		var ff = Array.rand(5, vib, vib + (vib/4));
		var rs = Array.series(5, 16, -1.3);
		var env = EnvGen.ar(Env.perc(attack, release), gate, doneAction: 2);
		var nenv = EnvGen.ar(Env.perc(attack * 0.01, release * 0.01));
		var venv = EnvGen.ar(Env.perc(attack * 2, release * 2));
		var imp = BLowShelf.ar(HPF.ar( LPF.ar(PinkNoise.ar((0.007 * nenv)), 16000), 240), 40, 1, -2).clip;
		var sig = DynKlank.ar(
			`[fs * LFCub.ar(ff,0,MouseY.kr(0.01,0.9)*env*0.1,1), as, rs], 
			imp,
			[1,1.012], 0, klang.lag(0.4));
		Out.ar(out, sig * amp * env * 40);

	}).add;

	poolSize.do({|i|
	
		var bi =	Pbind(

		    \instrument, \conex, //Pswitch([\b, \c, \a, \d], i, inf),
		    \amp, Pswitch([0.8, 0.4, 0.15, 0.13], i, inf),
		    \root, Pseq([0,3,-2].stutter(30)+4, inf),//Pfunc{ notes[i].getSynchronous.()},
		    \scale, 1,

		    \octave, Pswitch([2, 4, 5, 6], i, inf),

		    \note, Pswitch(
		    
		    	[Pseq([0,0,0,-2,-2,-2], inf), 
		    	Pseq([4,5,4,7], inf), 
		    	Pseq([0,10,4,7,2,5,4].stutter(5), inf), 
		    	Pseq([0,12,10], inf)], i, inf),
		    \stretch, 1.0,
		    \dur, Pswitch(
		    
		    	[Pseq([0.6,Rest(0.15), 0.3,Rest(0.15)], inf), 
		    	Pseq([0.3, 0.15,Rest(0.3) , 0.3,Rest(3)], inf), 
		    	Pseq([0.15], inf), 
		    	Pseq([0.3], inf)], i, inf),

		    \klang, Pswitch(
		    
		    	[Pwhite(0.1, 0.03, inf), 
		    	Pseq([0.06], inf), 
		    	Pwhite(0.03,0.4, inf), 
		    	Pwhite(0.8,0.4, inf)], i, inf),

		    \attack, Pswitch(
		    
		    	[Pseq([0.01], inf), 
		    	Pseq([0.002], inf), 
		    	Pseq([0.03], inf), 
		    	Pseq([0.01], inf)], i, inf),

		    \rel, 0.2,//Pkey(\release),

		    \sh, 6,//Pswitch([3, 4, 6, 10], i, inf),

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

	n = [\aPtn, \bPtn, \cPtn, \dPtn];

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
	// Ndef.clear;

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

	// 					"shape", 10,

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
	notes[l].value = blob.center.x.linlin(100,550,3,7).floor;

	//blobsDict.values[0].rect.width.linlin(0,120,0,10)

	// oct = blobsDict.values[0].area.linexp(1.0,16.0,6,3).floor;
	// patterns[l].set(\note, note);
	// patterns[l].set(\octave, oct);
	patterns[l].set(\vib, blobsDict.values[0].rect.width.linlin(80,120,0.0,12));

	cb[l].value = blob.center.x.linlin(0,600,-3.5,2.5);

	// patterns[l].set(\
	
	

};

//------------------------------------------------------
~onData = {|blobsDict|
	[blobsDict.values[0].rect.width.linlin(80,120,0,10)];
};

