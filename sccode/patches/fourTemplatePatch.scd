var oct = 0;
var note = 0;
var scale = 1;
var poolSize = 4;
var isPlayingBlob = Array.fill(poolSize, false);
var patterns = Array.new(poolSize);
var cb = [Bus.control(s,1),Bus.control(s,1),Bus.control(s,1),Bus.control(s,1),Bus.control(s,1)];
var binds = Array.new(poolSize);
var notes = [Bus.control(s,1),Bus.control(s,1),Bus.control(s,1),Bus.control(s,1),Bus.control(s,1)];


//------------------------------------------------------
~init = {|model|
	postf("init : % \n", model.file);

{

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
	
	s.sync
}.fork;


	poolSize.do({|i|
	
		var bi =	Pbind(
				// \args, #[],
			// musics
		    \instrument, \long,
		    \amp, Pwhite(0.3, 0.2),
		    \root, 0,//Pseq([0,3,6,-3].stutter(27), inf),
		    \scale, 6,
		     \octave, Pfunc{ 3 + i },//Prand([0,1,2,3,4,5,6,7,8,9,10].stutter(7),inf),
		    \note, Pfunc{ notes[i].getSynchronous.()},//Pseq([0], inf),
		    \dur, Pseq([0.1], inf),//Pfunc{ 2.pow(mx.getSynchronous.linlin(0,1.0,1,6).floor).reciprocal * 2.5},
		    \attack, Pwhite(0.001,0.01),
		    \decay, Pwhite(0.2,0.9),
		    \release, 1.2,//Pfunc{ my.getSynchronous.linlin(0,1.0,0.005,4.5)},//Pwhite(0.05,1.3),
		    \rel, Pkey(\release),
		    \ff, 700,//Pfunc{ mx.getSynchronous.linexp(0,1.0,100,12000)},
		    \rf, Pseq([3,0,3,1,1,3,1], inf),//Pfunc{ my.getSynchronous.linlin(0,1.0,0,4)},


		    //visuals
		    \sh, 1

		    ,
		    \param1, 1,
		    \param2, 2,
		    \param3, 3,
		    \sx, 0,//Pfunc{ cb.getSynchronous.().linlin(0,8,-1,1)},//(Pkey(\note) + (Pkey(\octave) * 12)).linlin(30,80,-1.8,1.8),
		    \sy, 0,
		    \ex, Pkey(\sx),
		    \ey, Prand([-1.5,1.5], inf),
		    // \oct, Pkey(\octave),
		    \pp, 999,

		    // osc out
			\osc, Pfunc{|e| 
	
				if(isPlayingBlob[i] == true,{
				
					model.netAddr.sendMsg("/shadow", 
						"shape", 3,
						"duration", e.dur,
						"attack", e.attack * 1,
						"release", e.rel * 0.2,
						"color", 0.19 * i,//i.linlin(0,4,0,0.99),//(e.note + (e.octave * 12)).linlin(30,80,0,0.99),//e.param1,//colour
						"scale", 0.2,//(e.note + (e.oct * 12)).linexp(0,127,2,0.2),//scale
						"sx", cb[i].getSynchronous.(),//(e.note + (e.octave * 12)).linlin(30,80,-1.8,1.8),//sx
						"sy", 0,//sy
						"ex", cb[i].getSynchronous.(),//(e.note + (e.octave * 12)).linlin(30,80,-1.8,1.8),//ex
						"ey", 0,//ey
						"imageindex", 14,
						"blur", 0.5,
						
						"par7", 0,//e.param2.linlin(1,6,0.1,1), // wobble
						"par8", 0,//e.octave.linlin(3,6,28,10),
						// "par9", (e.note + (oct * 12)).linlin(0,127,6,1),
					);
				});
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
		patterns[l].play(0.4);
		postf("playing : (%)[%] % \n", blob.label, l, patterns[l]);
	});

};

//------------------------------------------------------
~onDeinit = {|blob, blobsDict|

	var l = (blob.label.mod(patterns.size));

	isPlayingBlob[l] = false;

	if(patterns[l].isMonitoring == true,{
		patterns[l].end;
		postf("ending : (%)[%] % \n", blob.label, l, patterns[l]);
	});

};

//------------------------------------------------------
~onUpdate = {|blob, blobsDict, model|

	var l = (blob.label.mod(patterns.size));
	// var notes = [0,7,12,16];
	notes[l].value = blob.center.x.linlin(100,550,0,12).floor * 2;
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

