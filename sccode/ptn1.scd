(
	var window;
	var netAddr = NetAddr.new("127.0.0.1", 10001);    // create the NetAddr
	var o;
	var mx = Bus.control(s,1);
	var my = Bus.control(s,1);
	var ptn;
	var scope;
	//------------------------------------------------------
	SynthDef(\mouseX, { |bus| Out.kr(bus, MouseX.kr(0,1.0))}).add;
	SynthDef(\mouseY, { |bus| Out.kr(bus, MouseY.kr(0,1.0))}).add;

	//------------------------------------------------------
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
	    Out.ar(0, [snd + tone, snd + tone]);
	}).add;

	//------------------------------------------------------
	SynthDef(\simple, {|amp = 0.1, freq = 440, gate = 1, coef = 0.1, attack = 0.02, decay = 0.1, sustain = 0.5, release = 0.2, vib = 16, vibamp = 0.04|

		var env, tone;
		// env = EnvGen.kr(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		env = EnvGen.kr(Env.linen(attack, 0, release), doneAction: 2);
		tone = SinOsc.ar([freq, freq + 1.5], LFSaw.ar([freq*3,freq*3.01],0,0.1),  LFCub.ar(vib * env,0,vibamp * amp *2) + amp * 0.5 * env).tanh;
	    Out.ar(0, tone);
	}).add;

	//------------------------------------------------------
	SynthDef(\kalimba, {|out = 0, freq = 440, amp = 1, mix = 0.2, attack = 0.02, release = 0.2, vib = 16, vibamp = 0.04|
	    var env, snd, click;
	    env = EnvGen.ar(Env.perc(attack, release, 1, -7), doneAction: 2);
	    snd = SinOsc.ar([freq, freq + 5] * 2, 0 ,  LFCub.ar(vib * env * 0.5,0,vibamp * amp *5) + amp * 1 * env) ;
		snd = HPF.ar( LPF.ar(snd, 380), 120);
		click = DynKlank.ar(`[
	        [240*ExpRand(0.87, 1.12), 2020*ExpRand(0.87, 1.12), 3151*ExpRand(0.87, 1.12)],
	        [-9, -3, -5].dbamp,
	        [0.8, 0.07, 0.08] + 0.2
		], BPF.ar(PinkNoise.ar, 6500, 0.1) * EnvGen.ar(Env.perc(attack, 0.02))) * 0.1;
		snd = (snd*mix) + (click*(1-mix));
		//snd = Mix( snd );
	    Out.ar(0, (snd*amp*20));
	}).add;	

	//------------------------------------------------------
	ptn = Ndef(\pe,
		Pbind(

			// musics
		    \instrument, Pseq([\kalimba].stutter(6),inf),
		    \amp, Pwhite(0.1, 0.3),
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
		    \sh, Pseq([0,1,2,3,4].stutter(6), inf),
		    \param1, Pkey(\vib),//Pwhite(0,10.0),
		    \param2, Pkey(\vib),
		    \param3, 1,//Pwhite(0,7),
		    \sx, Pseq([Prand([-1.2, 1.2], 1), 	Prand([-1, 1], 1), 	Pwhite(-1.3, 1.3, 1)	].stutter(6), inf),
		    \sy, Pseq([Pwhite(-0.9,0.9,1), 		Pwhite(-0.5,0.5,1), 1.25 				].stutter(6), inf),
		    \ex, Pseq([Pkey(\sx,1), 			Pkey(\sx,1).neg,	Pkey(\sx,1)		 	].stutter(6), inf),
		    \ey, Pseq([Pwhite(0.0,0.2,1), 		0,					-1.25				].stutter(6), inf),

		    // osc out
			\osc, Pfunc{|e| 
				var clock = ptn.source.asStream.clock;
				// e.rel.postln;
				// clock.bar.mod(4).postln; //!! somewhere in the bar !!
				// netAddr.sendBundle(0.0, ["/shadow", 0, e.note, e.dur, e.attack, e.decay, e.coef]);
				//["/shadow",e.sh, e.dur, e.attack, e.rel, e.param1, e.octave.linlin(3,5,1,2).reciprocal * 2 , e.sx, e.sy, e.ex, e.ey].postln;


				// netAddr.sendMsg("/shadow", e.sh, e.dur, e.attack, e.rel, 
				// 	e.param1, e.octave.linlin(3,7,0.5,4).reciprocal * 2,
				// 	e.sx, e.sy, e.ex, e.ey
				// );
//	vals = [ 'note', 0, 'duration', 2, 'attack', 1, 'release', 1, 
//'par1', random.random(), 'par2', random.random(), 'par3', random.random(), 'par4', random.random(), 'par5', random.random(), 'par6', random.random() ]

				netAddr.sendMsg("/shadow", 
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
		);
	);
	
	ptn.fadeTime = 2.2;
	
	Synth(\mouseX, [\bus, mx.index]);
	Synth(\mouseY, [\bus, my.index]);

	//------------------------------------------------------

	QtGUI.palette = QPalette.dark; 
	window = Window("",Rect(0,0,Window.screenBounds.width/4, Window.screenBounds.height/4)
		.center_(Window.availableBounds.leftBottom)
	).front;
	//------------------------------------------------------
	window.onClose = ({
		scope.kill;	
		ptn.fadeTime = 0;
		ptn.clear;
		Ndef.clear;
		o.free;
		s.freeAll;
	});
	CmdPeriod.doOnce({window.close});
	scope = FreqScopeView(window, window.view.bounds).active_(true);
	window.layout = HLayout(
		Button()
			.states_([["off"],["on"]])
			.action_({|b|
				if(b.value == 1,{
					ptn.play();
				},{
					ptn.end();
				}); 
			})
			.valueAction_(1)
	);
)



