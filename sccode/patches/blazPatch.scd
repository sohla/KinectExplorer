



//------------------------------------------------------
~init = {|model|
	postf("init : % \n", model.file);


	SynthDef(\blaz, {|out = 0, freq = 120, amp = 0.5, attack = 0.01, decay = 0.3, sustain = 0.1, release = 0.9, gate = 1, harm = 1|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var sig = (BHiPass.ar(
			LFNoise2.ar(2)**1.4,
			[freq, freq + (freq * 0.01)],
			MouseX.kr(0.001,0.3,\exponential),
			MouseY.kr(20,10900,\exponential) - freq)
		).tanh  * 0.5;
		var vib = LFCub.ar(freq * harm, 0, env, 1);
		Out.ar(out, LeakDC.ar(sig) * amp * env * vib) ;
	}).add;

	Ndef(\blazPtn,
		Pbind(
			\instrument, \blaz,
			\octave, Prand([2,3,4,5], inf),
			\note, Prand([0,4,5,7,10,12], inf),
			\root, Pseq([0,3,-2].stutter(8*8), inf),
			\dur, Prand([1/6,1/6,Rest(1/6),1/6] * 0.8, inf),

			\amp, 0.3,
			\harm, Prand([1,2,3,4,5,6,7,8], inf),

			 \attack, Pwhite(0.001,0.01),
		    \release, Pwhite(0.05,1.3),
		    // \attack, Pwhite(0.1,0.5),
		    // \release, Pwhite(0.5,1.3),
		    \rel, Pkey(\release),

		 //    //visuals
		    \sh, 8,
		    \param1, Pkey(\harm),//Pwhite(0,10.0),
		    \param2, Pkey(\harm),
		    \param3, 1,//Pwhite(0,7),
		    \sx, 0,//Pwhite(-0.2,0.2),
		    \sy, 0,//Pwhite(-0.2,0.2),
		    \ex, 0,//Pkey(\sx) * 2,
		    \ey, 0,//Pkey(\sy) * 2,
		    \scal, Pwhite(15,9),

		    // osc out
			\osc, Pfunc{|e| 
				// //var clock = ptn.source.asStream.clock;
				// // e.rel.postln;
				// // clock.bar.mod(4).postln; //!! somewhere in the bar !!
				// // netAddr.sendBundle(0.0, ["/shadow", 0, e.note, e.dur, e.attack, e.decay, e.coef]);
				// //["/shadow",e.sh, e.dur, e.attack, e.rel, e.param1, e.octave.linlin(3,5,1,2).reciprocal * 2 , e.sx, e.sy, e.ex, e.ey].postln;
				// model.netAddr.sendMsg("/shadow", e.sh, e.dur, e.attack, e.rel, 
				// 	e.param1, e.octave.linlin(3,7,0.5,4).reciprocal * 2,
				// 	e.sx, e.sy, e.ex, e.ey
				// );
				if(e.dur.class == Rest,{
					// don't send a rest
					"rest".postln;
				},{

					model.netAddr.sendMsg("/shadow", 
						
						"shape", e.sh,
						
						"duration", e.dur,
						"attack", e.attack * 1.2,
						"release", e.rel * 0.7,
						
						"color", (e.note + (e.octave * 12)).linlin(20,70,0,0.99),
						"scale", 0.5,
						"sx", 0,
						"sy", 0,
						"ex", 0,
						"ey", -0.2,
						
						"par7", 0.0, // wobble
						"scx", (e.note + (e.octave * 12)).linlin(20,74,3,0.001),
						"scy", (e.note + (e.octave * 12)).linlin(20,74,0.001,3),
					);
				});

			},
		)
	).play;

	Ndef(\blazPtn).fadeTime = model.fade; 

};

//------------------------------------------------------
~update = {|blobs,i|

};
//------------------------------------------------------
~deinit = {|model|
	postf("deinit : % \n", model.file);
	Ndef(\blazPtn).end;

};

//------------------------------------------------------
~reload = {|model|
	postf("reload : % %\n", model.file, Ndef(\blazPtn).isPlaying);
	if(Ndef(\blazPtn).isPlaying, {Ndef(\blazPtn).stop; ~init.(model) });
};

//------------------------------------------------------
~onData = {

};





