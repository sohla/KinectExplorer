



//------------------------------------------------------
~init = {|model|
	postf("init : % \n", model.file);


	SynthDef(\conex, {|out = 0, gate = 1, amp = 0.5, freq = 120, attack = 0.007, release = 0.9, vib = 2|


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
			[1,1.012], 0 ,MouseX.kr(0.01,0.99)) ;
		Out.ar(out, sig * amp * env * 50);

	}).add;
	
	Ndef(\conexPtn,
		Pbind(
			\instrument, \conex,
			\octave, Prand([3,4,5,6,7], inf),
			\note, Prand([0,2,-2,-4,5,7], inf),
			\root, Pseq([0].stutter(12), inf),
			\dur, Prand([1/4,1/4,1/8] * 1.4, inf),
			// \dur, Prand([1/3], inf),
			\amp, 0.6,
			\attack, Pwhite(0.003,0.01),
			\release, Pwhite(0.1,5.6),
			\vib, Pwhite(1,5),


		    \attack, Pwhite(0.001,0.01),
		    \release, Pwhite(0.05,1.3),
		    \rel, Pkey(\release),

		 //    //visuals
		    \sh, 4,
		    \param1, Pwhite(0.0,0.99),//Pwhite(0,10.0),
		    \param2, Pkey(\vib),
		    \param3, 1,//Pwhite(0,7),
		    \sx, Pseq([Prand([-1.2, 1.2], 1), 	Prand([-1, 1], 1), 	Pwhite(-1.3, 1.3, 1)	].stutter(6), inf),
		    \sy, Pseq([Pwhite(-0.9,0.9,1), 		Pwhite(-0.5,0.5,1), 1.25 				].stutter(6), inf),
		    \ex, Pseq([Pkey(\sx,1), 			Pkey(\sx,1).neg,	Pkey(\sx,1)		 	].stutter(6), inf),
		    \ey, Pseq([Pwhite(0.0,0.2,1), 		0,					-1.25				].stutter(6), inf),

		    // osc out
			\osc, Pfunc{|e| 
				model.netAddr.sendMsg("/shadow", 

					"shape", e.sh,
					"duration", e.dur,
					"attack", e.attack,
					"release", e.rel * 2,

					"color", e.param1,
					"scale", e.octave.linlin(3,7,2,9).reciprocal * 10,
					"sy", 0,//((e.note + (e.octave * 12)).linlin(30,90,-4,4).floor / 8) * 0.2,
					"sx", 0,
					"ey", 0,//((e.note + (e.octave * 12)).linlin(30,90,-4,4).floor / 8) * 0.2,
					"ex", 0,

					"par7", e.vib
				);
			},

		)
	).play;

	Ndef(\conexPtn).fadeTime = model.fade; 

};

//------------------------------------------------------
~update = {|blobs,i|

};

//------------------------------------------------------
~deinit = {|model|
	postf("deinit : % \n", model.file);
	Ndef(\conexPtn).end;

};

//------------------------------------------------------
~reload = {|model|
	postf("reload : % \n", model.file);
	if(Ndef(\conexPtn).isPlaying, {Ndef(\conexPtn).stop; ~init.(model) });

};

//------------------------------------------------------
~onData = {

};

