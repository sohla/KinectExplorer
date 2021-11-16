var oct = 0;
var note = 0;
var scale = 1;

var patterns = Array.new(4);

var bind;
//------------------------------------------------------
~init = {|model|
	postf("init : % \n", model.file);

	SynthDef(\long, {|out = 0, freq = 160, amp = 0.3, attack = 0.01, decay = 4.02, sustain = 0.8, release = 0.9, gate = 1, ns = 9, vibamp = 1, vibfreq = 5|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var vib = LFCub.ar(vibfreq, 0, vibamp * env);

		var sig = SinOsc.ar([freq,freq + 2.rand],0, amp) + Saw.ar([freq,freq + 7.rand], vib) * env * 0.5;
		Out.ar(out, sig);

	}).add;

	SynthDef(\aa, {|out = 0, freq = 160, amp = 0.3, attack = 0.01, decay = 4.02, sustain = 0.8, release = 0.9, gate = 1, ff = 500, rf = 1|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var sig = SinOsc.ar([freq,freq + 3.rand],0, amp) + Saw.ar([freq,freq + 6.rand], amp) * env;
		var filter = MoogFF.ar(sig, ff.lag(0.1), rf);
		Out.ar(out, filter);

	}).add;

	bind =	Pbind(
			\args, #[],
			// musics
		    \instrument, \aa,
		    \amp, Pwhite(0.3, 0.2),
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
		    \pp, Pwhite(100, 300),


		    //visuals
		    \sh, 6,
		    \param1, 1,
		    \param2, 2,
		    \param3, 3,
		    \sx, 0,
		    \sy, 0,
		    \ex, Prand([-1.5,1.5], inf),
		    \ey, Prand([-1.5,1.5], inf),
		    // \oct, Pkey(\octave),

		    // osc out
			\osc, Pfunc{|e| 
	
				// a = {e.scale}.defer;
				 // {e.pp.postln}.defer;

				model.netAddr.sendMsg("/shadow", 
					"shape", e.sh,
					"duration", e.dur,
					"attack", e.attack * 1,
					"release", e.rel * 0.5,
					"color", (note + (oct * 12)).linlin(30,80,0,0.99),//e.param1,//colour
					"scale", scale,//(e.note + (e.oct * 12)).linexp(0,127,2,0.2),//scale
					"sx", (note + (oct * 12)).linlin(30,80,-1.8,1.8),//sx
					"sy", 0,//sy
					"ex", (note + (oct * 12)).linlin(30,80,-1.8,1.8),//ex
					"ey", 0.2,//ey
					
					"par7", 10,//e.param2.linlin(1,6,0.1,1), // wobble
					"par8", 0,//e.octave.linlin(3,6,28,10),
					// "par9", (e.note + (oct * 12)).linlin(0,127,6,1),
				);
			},


	    );

	// •• do we just need a pool of patterns we can use...?
	patterns = Array.with(
		Ndef(\aaPtn, bind).quant_(0.2),
		Ndef(\bbPtn, bind).quant_(0.2),
		Ndef(\ccPtn, bind).quant_(0.2),
		Ndef(\ddPtn, bind).quant_(0.2),
		Ndef(\eePtn, bind).quant_(0.2)
	);

	Ndef(\bbPtn).set(\dur, 0.1);
	Ndef(\bbPtn).set(\release, 0.1);
	Ndef(\ccPtn).set(\dur, 0.4);
	Ndef(\ddPtn).set(\dur, 0.1);
	Ndef(\ddPtn).set(\release, 0.1);
	// Ndef(\eePtn).set(\instrument, \long);

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
			p.end(2);
		});
	};

	patterns = [];

	// need this for reloading or patterns after an edit
	Ndef.clear(0.1);

};

//---------------------------------------------------
~onInit = {|blob, blobsDict|

	var l = (blob.label.mod(patterns.size));
	postf("playing : (%)[%] % \n", blob.label, l, patterns[l]);

	// patterns[l].play(0.1);

};

//------------------------------------------------------
~onDeinit = {|blob, blobsDict|

	var l = (blob.label.mod(patterns.size));
	postf("ending : (%)[%] % \n", blob.label, l, patterns[l]);

	if(patterns[l] != nil,{patterns[l].end(0.8)});

};

//------------------------------------------------------
~onUpdate = {|blob, blobsDict|

	var l = (blob.label.mod(patterns.size));
	var notes = [0,7,12,16];
	note = blob.center.x.linlin(100,550,0,8).floor * 3;
	oct = blobsDict.values[0].area.linexp(1.0,16.0,6,3).floor;
	patterns[l].set(\note, note);
	patterns[l].set(\octave, oct);
	patterns[l].set(\ff, blob.area.linexp(1.0,8.0,400,6000));

};

//------------------------------------------------------
~onData = {|blobsDict|
	[blobsDict.values[0].area.linexp(1.0,16.0,4,2).floor];
};

