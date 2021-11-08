var mx = Bus.control(s,1);
var my = Bus.control(s,1);
var mxs, mys;
var oct = 0;
var scale = 1;

//------------------------------------------------------
~init = {|model|
	postf("init : % \n", model.file);

	mxs = Synth(\mouseX, [\bus, mx.index]);
	mys = Synth(\mouseY, [\bus, my.index]);


	SynthDef(\viztest, {|out = 0, freq = 160, amp = 0.3, attack = 0.01, decay = 4.02, sustain = 0.8, release = 0.9, gate = 1, ff = 500, rf = 1|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var sig = SinOsc.ar([freq,freq + 2.rand],0, amp) + Saw.ar([freq,freq + 2.rand], amp) * env;
		var filter = MoogFF.ar(sig, ff, rf);
		Out.ar(out, filter);

	}).add;


	Ndef(\viztestPtn,
		Pbind(
			\args, #[],
			// musics
		    \instrument, Pseq([\viztest].stutter(6),inf),
		    \amp, Pwhite(0.1, 0.2),
		    \root, Pseq([0].stutter(18), inf),
		    \scale, 3,
		     \octave, Prand([3], inf),//Prand([0,1,2,3,4,5,6,7,8,9,10].stutter(7),inf),
		    \note, 0,//Prand([0,2,4,5,7,9,11], inf),
		    \dur, 0.1,//Pfunc{ 2.pow(mx.getSynchronous.linlin(0,1.0,1,6).floor).reciprocal * 2.5},
		    \attack, Pwhite(0.001,0.01),
		    \decay, Pwhite(0.002,0.9),
		    \release, 0.02,//Pfunc{ my.getSynchronous.linlin(0,1.0,0.005,4.5)},//Pwhite(0.05,1.3),
		    \rel, Pkey(\release),
		    \ff, 100,//Pfunc{ mx.getSynchronous.linexp(0,1.0,100,12000)},
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
				 // {e.scale.postln}.defer;

				model.netAddr.sendMsg("/shadow", 
					"shape", e.sh,
					"duration", e.dur,
					"attack", e.attack * 1,
					"release", e.rel * 3,
					"color", (e.note + (oct * 12)).linlin(0,127,0,0.99),//e.param1,//colour
					"scale", scale,//(e.note + (e.oct * 12)).linexp(0,127,2,0.2),//scale
					"sx", (e.note + (oct * 12)).linlin(0,127,-1.5,1.5),//sx
					"sy", 0,//sy
					"ex", (e.note + (oct * 12)).linlin(0,127,-1.5,1.5),//ex
					"ey", 0,//ey
					
					"par7", 0,//e.param2.linlin(1,6,0.1,1), // wobble
					"par8", 5,//e.octave.linlin(3,6,28,10),
					// "par9", (e.note + (oct * 12)).linlin(0,127,6,1),
				);
			},


	    )
	).play;

	// Ndef(\viztestPtn).set(\octave, 4);
	// Pdef(\viztestPtn, Pbind( 
	// 	\octave, 4)
	// );

	Ndef(\viztestPtn).fadeTime = model.fade; 
};

~play = {

	Ndef(\viztestPtn).play;
};

~stop = {

	Ndef(\viztestPtn).stop;
};
//------------------------------------------------------
~update = {|blobs,i|

	oct = blobs[0].center.x.linlin(0,650,0,6).floor * 2;
	Ndef(\viztestPtn).set(\note, oct);

	scale = blobs[0].area.linexp(0.0,10.0,0.1,12);
	Ndef(\viztestPtn).set(\ff, blobs[0].area.linexp(0.0,10.0,100,10000));
	// blobs[0].area.linexp(0.0,10.0,100,10000).postln;
};

//------------------------------------------------------
~deinit = {|model|
	postf("deinit : % \n", model.file);
	Ndef(\viztestPtn).end;
	// Synth(\mouseX).free;
	// Synth(\mouseY).free;
	// mx.getSynchronous.free;
	// my.getSynchronous.free;

};

//------------------------------------------------------
~reload = {|model|
	postf("reload : % \n", model.file);
	if(Ndef(\viztestPtn).isPlaying, {
		Ndef(\viztestPtn).stop; 
		Ndef.clear(0.1);
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

