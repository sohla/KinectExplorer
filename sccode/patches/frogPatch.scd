



//------------------------------------------------------
~init = {|model|
	postf("init : % \n", model.file);


	SynthDef(\frog, {|attack = 0.004, release = 1.9, freq = 120, gate = 1, vib = 1|

		var env = EnvGen.ar(Env.perc(attack, release, 1, -7), gate, doneAction: 2);
		var sig = MoogFF.ar(
			LFSaw.ar(
				[freq, freq + (freq * LFCub.ar(freq*MouseY.kr(0.5, 3, lag: 0.3), 0, 0.49, 0.006) )], 
				[0,0.5], 
				0.4),
			env.linlin(0,1,500, MouseX.kr(100, 10000, lag: 0.3)),
			-4
		);
		var sub = SinOsc.ar(freq, [0,1.36], 0.4);
		Out.ar(0, (sig + sub) * env);
	}).add;

	
	Ndef(\frogPtn,
		Pbind(
			\instrument, \frog,
			\octave, Pseq([2,4,5,4,5], inf),
			\note, Pseq([0,7,11,16], inf),
			\root, Pseq([0,4,-1, 2].stutter(20), inf),
			\dur, Pseq([1/5, 1/5, 1/2.5, 1/5], inf),
			\amp, 0.5,
			\attack, Pwhite(0.001,0.006, inf),
			\release, Pwhite(0.3,1.9, inf),
		    \rel, Pkey(\release),
		    \vib, 50,//Pwhite(1.0,16.0),

		 //    //visuals
		    \sh, 6,
		    \param1, Prand([3,4,5,6,7], inf),
		    \param2, 3 ,
		    \param3, 3,
		    \sx,  0,
		    \sy,  0,
		    \ex, Prand([0,-0.8,0.8], inf),
		    \ey, Pseq([0,-0.8,0.8], inf),

		    // osc out
			\osc, Pfunc{|e| 
				//var clock = ptn.source.asStream.clock;
				 // e.postln;
				// clock.bar.mod(4).postln; //!! somewhere in the bar !!
				// netAddr.sendBundle(0.0, ["/shadow", 0, e.note, e.dur, e.attack, e.decay, e.coef]);
				//["/shadow",e.sh, e.dur, e.attack, e.rel, e.param1, e.octave.linlin(3,5,1,2).reciprocal * 2 , e.sx, e.sy, e.ex, e.ey].postln;
				// model.netAddr.sendMsg("/shadow", e.sh, e.dur, e.attack, e.rel, 
				// 	e.param1, e.param2,
				// 	e.sx, e.sy, e.ex, e.ey
				// );
				model.netAddr.sendMsg("/shadow", 
					"shape", e.sh,
					"duration", e.dur,
					"attack", e.attack,
					"release", e.rel,
					"par1", (e.note + (e.octave * 12)).linlin(0,127,0,0.99),//e.param1,//colour
					"par2", e.octave.linlin(3,7,0.2,9).reciprocal * 2,
					"par3", (e.note + (e.octave * 12)).linlin(20,80,-1.5,1.5),//sx
					"par4", -1,//e.sy,
					"par5", (e.note + (e.octave * 12)).linlin(20,80,-1.5,1.5),//sx,
					"par6", -1,//e.ey,
					"par7", 0,//e.param2.linlin(1,6,0.1,1), // wobble
					"par8", 5,//e.octave.linlin(3,6,28,10),
					"par9", (e.note + (e.octave * 12)).linlin(0,127,6,1),

				);
				
			},

		)
	).play;

	Ndef(\frogPtn).fadeTime = model.fade; 

};

//------------------------------------------------------
~update = {|blobs,i|

};

//------------------------------------------------------
~deinit = {|model|
	postf("deinit : % \n", model.file);
	Ndef(\frogPtn).end;

};

//------------------------------------------------------
~reload = {|model|
	postf("reload : % \n", model.file);
	if(Ndef(\frogPtn).isPlaying, {Ndef(\frogPtn).stop; ~init.(model) });

};

//------------------------------------------------------
~onData = {

};

// FreqScope.new(400, 200, 0, server: s);