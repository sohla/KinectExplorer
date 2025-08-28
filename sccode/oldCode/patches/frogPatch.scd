



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
		    \ey, 0,

		    // osc out
			\osc, Pfunc{|e| 

				model.netAddr.sendMsg("/shadow", 

					"shape", e.sh,
					
					"duration", e.dur,
					"attack", e.attack,
					"release", e.rel * 0.6,
					

					"color", (e.note + (e.octave * 12)).linlin(30,90,0,0.99),
					"scale", e.octave.linlin(3,7,0.7,6).reciprocal * 1,
					"sx", (e.note + (e.octave * 12)).linlin(20,80,-1.2,1.2),
					"sy", e.sy,
					"ex", (e.note + (e.octave * 12)).linlin(20,80,-1.2,1.2),
					"ey", e.ey,
					
					"par7", 0,//e.param2.linlin(1,6,0.1,0.2), // wobble
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