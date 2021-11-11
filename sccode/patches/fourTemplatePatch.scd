var mx = Bus.control(s,1);
var my = Bus.control(s,1);
var mxs, mys;
var oct = 0;
var scale = 1;

var patterns = Array.new(4);

var bind;
//------------------------------------------------------
~init = {|model|
	postf("init : % \n", model.file);

	mxs = Synth(\mouseX, [\bus, mx.index]);
	mys = Synth(\mouseY, [\bus, my.index]);

	SynthDef(\long, {|out = 0, freq = 160, amp = 0.3, attack = 0.01, decay = 4.02, sustain = 0.8, release = 0.9, gate = 1, ns = 9, vibamp = 1, vibfreq = 5|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var vib = LFCub.ar(vibfreq, 0, vibamp * env);

		var sig = SinOsc.ar([freq,freq + 2.rand],0, amp) + Saw.ar([freq,freq + 7.rand], vib) * env * 0.5;
		Out.ar(out, sig);

	}).add;
	SynthDef(\aa, {|out = 0, freq = 160, amp = 0.3, attack = 0.01, decay = 4.02, sustain = 0.8, release = 0.9, gate = 1, ff = 500, rf = 1|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var sig = SinOsc.ar([freq,freq + 2.rand],0, amp) + Saw.ar([freq,freq + 2.rand], amp) * env;
		var filter = MoogFF.ar(sig, ff, rf);
		Out.ar(out, filter);

	}).add;


	bind =	Pbind(
			\args, #[],
			// musics
		    \instrument, \aa,
		    \amp, Pwhite(0.3, 0.4),
		    \root, 0,//Pseq([0,3,6,-3].stutter(27), inf),
		    \scale, 3,
		     \octave, 4,//Prand([0,1,2,3,4,5,6,7,8,9,10].stutter(7),inf),
		    \note, Pseq([0], inf),
		    \dur, 0.2,//Pfunc{ 2.pow(mx.getSynchronous.linlin(0,1.0,1,6).floor).reciprocal * 2.5},
		    \attack, Pwhite(0.001,0.01),
		    \decay, Pwhite(0.2,0.9),
		    \release, 1.2,//Pfunc{ my.getSynchronous.linlin(0,1.0,0.005,4.5)},//Pwhite(0.05,1.3),
		    \rel, Pkey(\release),
		    \ff, 700,//Pfunc{ mx.getSynchronous.linexp(0,1.0,100,12000)},
		    \rf, Pseq([3,0,3,1,1,3,1], inf),//Pfunc{ my.getSynchronous.linlin(0,1.0,0,4)},



		    //visuals
		    \sh, 6,
		    \param1, 1,
		    \param2, 2,
		    \param3, 3,
		    \sx, 0,
		    \sy, 0,
		    \ex, Prand([-1.5,1.5], inf),
		    \ey, Prand([-1.5,1.5], inf),
		    \oct, Pkey(\octave),

		    // osc out
			\osc, Pfunc{|e| 
	
				// a = {e.scale}.defer;
				 // {e.label.postln}.defer;

				model.netAddr.sendMsg("/shadow", 
					"shape", e.sh,
					"duration", e.dur,
					"attack", e.attack * 1,
					"release", e.rel * 0.5,
					"color", (e.note + (oct * 12)).linlin(30,127,0,0.99),//e.param1,//colour
					"scale", scale,//(e.note + (e.oct * 12)).linexp(0,127,2,0.2),//scale
					"sx", (e.note + (oct * 12)).linlin(0,127,-2.2,1.9),//sx
					"sy", 0,//sy
					"ex", (e.note + (oct * 12)).linlin(0,127,-2.2,1.9),//ex
					"ey", 0,//ey
					
					"par7", 0,//e.param2.linlin(1,6,0.1,1), // wobble
					"par8", 5,//e.octave.linlin(3,6,28,10),
					// "par9", (e.note + (oct * 12)).linlin(0,127,6,1),
				);
			},


	    );

	// •• do we just need a pool of patterns we can use...?
	patterns = Array.with(
		Ndef(\aaPtn, bind).quant_(0.2),
		Ndef(\bbPtn, bind).quant_(0.2),
		// Ndef(\ccPtn, bind).quant_(0.2),
		// Ndef(\ddPtn, bind).quant_(0.2)
	);

	// Ndef(\bbPtn).set(\root, 3);
	// Ndef(\ccPtn).set(\root, 6);
	// Ndef(\ddPtn).set(\root, -3);

};

//------------------------------------------------------
~reload = {|model|
	postf("reload : % \n", model.file);

	patterns.do{|p|
		p.end;
	};
	patterns.removeAll;
	Ndef.clear(0.1);
	mxs.free;
	mys.free;
	mx.getSynchronous.free;
	my.getSynchronous.free;
	~init.(model); 

};

//------------------------------------------------------
~deinit = {|model|
	postf("deinit : % \n", model.file);
	// Ndef(\aaPtn).end;
	patterns.do{|p|
		p.end;
	};
	patterns = [];
	Ndef.clear;
	
};

//---------------------------------------------------
~onInit = {|blob, blobsDict|

	("start :" + (blob.label.mod(patterns.size)) ).postln;
	// patterns[(blob.label.mod(patterns.size))].set(\label, blob.label);

	// simple use of label as an index to array of patterns
	patterns[(blob.label.mod(patterns.size))].play(0.4);
	patterns[(blob.label.mod(patterns.size))].set(\octave, blob.label.mod(3)+3);


};
//------------------------------------------------------
~onDeinit = {|blob, blobsDict|

	patterns[(blob.label.mod(patterns.size))].end(0.8);
	patterns[(blob.label.mod(patterns.size))].set(\label, -1);	

	("stop :" + (blob.label.mod(patterns.size)) ).postln;

};
//------------------------------------------------------
~onUpdate = {|blob, blobsDict|

	// blob.label.postln;
	// var blob = blobsDict.values[0]; //•• first one for now
	// oct = blob.center.x.linlin(0,650,0,6).floor * 2;
	// Ndef(\viztestPtn).set(\note, oct);

	oct = blob.center.x.linlin(150,550,2,11).floor;

	patterns[(blob.label.mod(patterns.size))].set(\octave, oct);
	// patterns[(blob.label.mod(patterns.size))].set(\ff, blob.area.linexp(0.0,10.0,100,10000));


};

//------------------------------------------------------
~onData = {|blobsDict|
	[blobsDict.values[0].center.x.linlin(150,550,1,10)];
};

