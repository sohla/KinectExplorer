var mx = Bus.control(s,1);
var my = Bus.control(s,1);
var mxs, mys;

//------------------------------------------------------
~init = {|model|
	postf("init : % \n", model.file);

	mxs = Synth(\mouseX, [\bus, mx.index]);
	mys = Synth(\mouseY, [\bus, my.index]);


	SynthDef(\viztest, {|out = 0, freq = 160, amp = 0.3, attack = 0.01, decay = 4.02, sustain = 0.8, release = 0.9, gate = 1, ns = 9|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var sig = SinOsc.ar([freq,freq + 2.rand], [pi.rand, pi.rand], amp) * env;
		Out.ar(out, sig);

	}).add;


	Ndef(\viztestPtn,
		Pbind(

			// musics
		    \instrument, Pseq([\viztest].stutter(6),inf),
		    \amp, Pwhite(0.1, 0.2),
		    \root, Pseq([0].stutter(18), inf),
		    \octave,Prand([0,1,2,3,4,5,6,7,8,9,10].stutter(7),inf),
		    \note, Prand([0,2,4,5,7,9,11], inf),
		    \dur, Pfunc{ 2.pow(mx.getSynchronous.linlin(0,1.0,1,6).floor).reciprocal * 2.5},
		    \attack, Pwhite(0.001,0.01),
		    \decay, Pwhite(0.002,0.7),
		    \release, Pfunc{ my.getSynchronous.linlin(0,1.0,0.02,4.5)},//Pwhite(0.05,1.3),
		    \rel, Pkey(\release),
		    \vib, Pwhite(1,6),
		    \vibamp, Pwhite(0.04,0.7),


		    //visuals
		    \sh, 6,
		    \param1, 1,
		    \param2, 2,
		    \param3, 3,
		    \sx, 0,
		    \sy, 0,
		    \ex, Prand([-1.5,1.5], inf),
		    \ey, Prand([-1.5,1.5], inf),

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
					"shape", e.sh,
					"duration", e.dur,
					"attack", e.attack * 1,
					"release", e.rel * 4,
					"par1", (e.note + (e.octave * 12)).linlin(0,127,0,0.99),//e.param1,//colour
					"par2",0.2,//scale
					"par3", (e.note + (e.octave * 12)).linlin(0,127,-0.5,0.5),//sx
					"par4", 0,//sy
					"par5", (e.note + (e.octave * 12)).linlin(0,127,-1.5,1.5),//ex
					"par6", 0,//ey
					"par7", 0,//e.param2.linlin(1,6,0.1,1), // wobble
					"par8", 5,//e.octave.linlin(3,6,28,10),
					"par9", (e.note + (e.octave * 12)).linlin(0,127,6,1),
				);
			},


	    )
	).play;

	Ndef(\viztestPtn).fadeTime = model.fade; 

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

