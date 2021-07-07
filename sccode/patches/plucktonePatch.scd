var mx = Bus.control(s,1);
var my = Bus.control(s,1);
var mxs, mys;

//------------------------------------------------------
~init = {|model|
	postf("init : % \n", model.file);

	mxs = Synth(\mouseX, [\bus, mx.index]);
	mys = Synth(\mouseY, [\bus, my.index]);

	SynthDef(\plucktone, {|amp = 0.1, freq = 440, release = 5, coef = 0.1, attack = 0.02|

		var env, snd, tone;
		env = EnvGen.kr(Env.linen(attack, 0, release * 0.25), doneAction: 2);
		tone = SinOsc.ar([freq, freq + 1.5], LocalIn.ar(1) * release, amp * 0.6).tanh * env;
		snd = Pluck.ar(
		        in: WhiteNoise.ar(amp * env),
		        trig: Impulse.kr(0),

		        maxdelaytime: 0.1,
		        delaytime: freq.reciprocal,
		        decaytime: release,
		        coef: coef,
		        amp: env * 0.001);
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
		    \vib, 50,//Pwhite(1.0,16.0),
		    \vibamp, Pwhite(0.04,0.7),


		    //visuals
		    \sh, 0,
		    \param1, Pkey(\vib),//Pwhite(0,10.0),
		    \param2, Pkey(\vib),
		    \param3, 1,//Pwhite(0,7),
		    \sx, Pseq([Prand([-1.2, 1.2], 1), 	Prand([-1, 1], 1), 	Pwhite(-1.3, 1.3, 1)	].stutter(6), inf),
		    \sy, Pseq([Pwhite(-0.9,0.9,1), 		Pwhite(-0.5,0.5,1), 1.25 				].stutter(6), inf),
		    \ex, Pseq([Pkey(\sx,1), 			Pkey(\sx,1).neg,	Pkey(\sx,1)		 	].stutter(6), inf),
		    \ey, Pseq([Pwhite(0.0,0.2,1), 		0,					-1.25				].stutter(6), inf),

		    // osc out
			\osc, Pfunc{|e| 
				//var clock = ptn.source.asStream.clock;
				//e.proxy.key.postln;
				// clock.bar.mod(4).postln; //!! somewhere in the bar !!
				// netAddr.sendBundle(0.0, ["/shadow", 0, e.note, e.dur, e.attack, e.decay, e.coef]);
				//["/shadow",e.sh, e.dur, e.attack, e.rel, e.param1, e.octave.linlin(3,5,1,2).reciprocal * 2 , e.sx, e.sy, e.ex, e.ey].postln;
				// model.netAddr.sendMsg("/shadow", e.sh, e.dur, e.attack, e.rel, 
				// 	e.param1, e.octave.linlin(3,7,0.5,4).reciprocal * 2,
				// 	e.sx, e.sy, e.ex, e.ey
				// );
				model.netAddr.sendMsg("/shadow", 
					"note", e.sh,
					"duration", e.dur,
					"attack", e.attack,
					"release", e.rel,
					"par1", e.param1,
					"par2", e.octave.linlin(3,7,0.5,4).reciprocal * 2,
					"par3", e.sx,
					"par4", e.sy,
					"par5", e.ex,
					"par6", e.ey,
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

