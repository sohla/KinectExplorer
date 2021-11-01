var mx = Bus.control(s,1);
var my = Bus.control(s,1);
var mxs, mys;
var oct = 0;

//------------------------------------------------------
~init = {|model|
	postf("init : % \n", model.file);

	mxs = Synth(\mouseX, [\bus, mx.index]);
	mys = Synth(\mouseY, [\bus, my.index]);


	SynthDef(\long, {|out = 0, freq = 160, amp = 0.3, attack = 0.01, decay = 4.02, sustain = 0.8, release = 0.9, gate = 1, ns = 9, vibamp = 1, vibfreq = 5|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var vib = LFCub.ar(vibfreq, 0, vibamp * env);

		var sig = SinOsc.ar([freq,freq + 2.rand],0, amp) + Saw.ar([freq,freq + 7.rand], vib) * env * 0.5;
		Out.ar(out, sig);

	}).add;


	Ndef(\longPtn,
		Pbind(
			\args, #[],
			// musics
		    \instrument, Pseq([\long].stutter(6),inf),
		    \amp, Pwhite(0.3, 0.4),
		    \root, Pseq([6,2,4].stutter(46), inf),
		    \direction, Pseq([-1,1].stutter(46), inf),
		    \octave, Prand([4,5,6].stutter(7),inf),
		    \note, Prand([0,4,7,11], inf),
		    \dur,Pfunc{mx.getSynchronous.linlin(0,1.0,0.75,0.04)},//Pfunc{ 2.pow(mx.getSynchronous.linlin(0,1.0,1,5).floor).reciprocal},
		    \attack, Pwhite(0.001,0.005),
		    \decay, Pwhite(0.002,0.3),
		    \release, Pfunc{ my.getSynchronous.linlin(0,1.0,0.1,4.5)},//Pwhite(0.05,1.3),
		    \rel, Pkey(\release),
		    \vibfreq, Pwhite(1,6),
		    \vibamp, Pwhite(0.4,0.2),
		    \oct, Pkey(\octave),


		    //visuals
		    \sh, 3,
		    \sx, Pseq(Array.fill(10*pi, {|i| sin(i*0.2) * 0.7}), inf),
		    \sy, Pseq(Array.fill(10*pi, {|i| cos(i*0.2)} * 0.7), inf),
		    \ex, Pseq(Array.fill(10*pi, {|i| sin((i+1) * 0.2) * 0.1}), inf),
		    \ey, Pseq(Array.fill(10*pi, {|i| cos((i+1) * 0.2) * 0.1}), inf),
		    \image, Pseq([0,1,2,3,4,5,6,7,8,9,0,11], inf),
		    \angle, Pwhite(-70,70),

		    // osc out
			\osc, Pfunc{|e| 

				if(e.dur.class == Rest,{
					// don't send a rest
					"rest".postln;
				},{

					model.netAddr.sendMsg("/shadow", 
						"shape", e.sh,
						"duration", e.dur,
						"attack", e.attack * 0.01,
						"release", e.rel * 1,
						"color", (e.note).linlin(0,12,0,0.99),//e.param1,//colour
						"scale", 0.4,//(e.note + (oct * 12)).linexp(0,127,2,0.2),//scale
						"sx", e.sx,//sx
						"sy", e.sy,//sy
						"ex", e.ex,//ex
						"ey", e.ey,//ey
						
						"par7", 0,//e.param2.linlin(1,6,0.1,1), // wobble
						"par8", 5,//e.octave.linlin(3,6,28,10),
						"par9", (e.note + (e.octave * 12)).linlin(0,127,6,1),
						"img", e.image,
						"angle", e.angle,
					);
					});
			},


	    )
	).play;

	// Ndef(\viztestPtn).set(\octave, 4);
	// Pdef(\viztestPtn, Pbind( 
	// 	\octave, 4)
	// );

	Ndef(\longPtn).fadeTime = model.fade; 

};

//------------------------------------------------------
~update = {|blobs,i|
	oct = blobs[0].center.x.linlin(0,650,0,6).floor * 2;
	 Ndef(\longPtn).set(\note, oct);
	// Ndef(\viztestPtn, Pbind( 
	// 	\octave, x.floor)
	// );

};
//------------------------------------------------------
~deinit = {|model|
	postf("deinit : % \n", model.file);
	Ndef(\longPtn).end;
	// Synth(\mouseX).free;
	// Synth(\mouseY).free;
	// mx.getSynchronous.free;
	// my.getSynchronous.free;

};

//------------------------------------------------------
~reload = {|model|
	postf("reload : % \n", model.file);
	if(Ndef(\longPtn).isPlaying, {
		Ndef(\longPtn).stop; 
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

