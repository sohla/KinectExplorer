var mx = Bus.control(s,1);
var my = Bus.control(s,1);
var mxs, mys;

//------------------------------------------------------
~init = {|model|
	postf("init : % \n", model.file);

	mxs = Synth(\mouseX, [\bus, mx.index]);
	mys = Synth(\mouseY, [\bus, my.index]);

	SynthDef(\plucktone, {|amp = 0.1, freq = 440, release = 5, coef = 0.1, attack = 0.02, vib = 0.2|

		var env, snd, tone;
		env = EnvGen.kr(Env.linen(attack, 0, release * 0.25), doneAction: 2);
		tone = SinOsc.ar([freq, freq + 1.5] * LFCub.ar(vib,0,0.03,1), LocalIn.ar(1) * release, amp).tanh * env;
		snd = Pluck.ar(
		        in: WhiteNoise.ar(amp * env),
		        trig: Impulse.kr(0),

		        maxdelaytime: 0.1,
		        delaytime: freq.reciprocal,
		        decaytime: release,
		        coef: coef,
		        mul: env * 0.001);
		LocalOut.ar(snd + tone);

	    Out.ar(0, snd + tone, snd + tone);
	}).add;

	Ndef(\plucktonePtn,
		Pbind(

			// musics
		    \instrument, Pseq([\plucktone].stutter(6),inf),
		    \amp, Pwhite(0.05, 0.1),
		    \coef, Pfunc{ my.getSynchronous.linlin(0,1.0,0.01,0.99)},
		    \root, Pseq([0,3,-2,1,-4,-2].stutter(18), inf),
		    \octave,Prand([3,5,4,5,5,5,5,6,6],inf),
		    \note, Pseq([0,2,4,9,7,11], inf),
		    \dur, Pfunc{ 2.pow(mx.getSynchronous.linlin(0,1.0,1,6).floor).reciprocal * 2.5},
		    \attack, Pwhite(0.001,0.01),
		    \decay, Pwhite(0.02,1.2),
		    \release, Pfunc{ my.getSynchronous.linlin(0,1.0,0.02,5.5)},//Pwhite(0.05,1.3),
		    \rel, Pkey(\release),
		    \vib, Pwhite(1,6),
		    \vibamp, Pwhite(0.04,0.7),


		    //visuals
		    \sh, 6,
		    \sx, Pwhite(-1.7,1.7),
		    \sy, Pwhite(-1.3,1.3),
		    \ex, Pkey(\sx),
		    \ey, Pkey(\sy),

		    // osc out
			\osc, Pfunc{|e| 
				model.netAddr.sendMsg("/shadow", 
					
					"shape", e.sh,
					
					"duration", e.dur,
					"attack", e.attack * 1,
					"release", e.rel * 0.26,
					
					"color", (e.note + (e.octave * 12)).linlin(30,90,-0.11,0.99),//e.param1,//colour
					"scale", (e.note + (e.octave * 12)).linexp(30,90,0.5,0.04),//scale
					
					"sx", 0,
					"sy", (e.note + (e.octave * 12)).linlin(0,127,-2,2.5),
					"ex", 0,
					"ey", (e.note + (e.octave * 12)).linlin(0,127,-2,2.5),

					"par7", 0,//e.param2.linlin(1,6,0.1,1), // wobble
					"par8", 5,//e.octave.linlin(3,6,28,10),
					"par9", (e.note + (e.octave * 12)).linlin(30,90,6,1),
					
					"scx", (e.note + (e.octave * 12)).linlin(30,90,10, 1),
					"scy", (e.note + (e.octave * 12)).linlin(30,90,3, 0.01),
					"tx", 0,
					"ty", 0,
					"tz", 0,
					"imageindex", 0,
				);
			},


	    )
	).play;

	Ndef(\plucktonePtn).fadeTime = model.fade; 

};


//------------------------------------------------------
~deinit = {|model|
	postf("deinit : % \n", model.file);
	Ndef(\plucktonePtn).end;
	// Synth(\mouseX).free;
	// Synth(\mouseY).free;
	// mx.getSynchronous.free;
	// my.getSynchronous.free;

};

//------------------------------------------------------
~reload = {|model|
	postf("reload : % \n", model.file);
	if(Ndef(\plucktonePtn).isPlaying, {
		Ndef(\plucktonePtn).stop; 
		mxs.free;
		mys.free;
		mx.getSynchronous.free;
		my.getSynchronous.free;
		~init.(model); 
	});

};

//------------------------------------------------------
~onData = {

};

