(
	var window;
	var midiOut;
	var netAddr = NetAddr.new("127.0.0.1", 10000);    // create the NetAddr
	var o;
	var mx = Bus.control(s,1);
	var my = Bus.control(s,1);
	var ptn;
	//------------------------------------------------------
	MIDIClient.init;
	midiOut = MIDIOut.newByName("IAC Driver", "Bus 1", dieIfNotFound: true);
	midiOut.latency_(0.00);
	//------------------------------------------------------
	SynthDef(\mouseX, { |bus| Out.kr(bus, MouseX.kr(0,1.0))}).add;
	SynthDef(\mouseY, { |bus| Out.kr(bus, MouseY.kr(0,1.0))}).add;

	SynthDef(\plucktone, {|amp = 0.1, freq = 440, decay = 5, coef = 0.1, attack = 0.02|

		var env, snd, tone;
		env = EnvGen.kr(Env.linen(attack, 0, decay * 0.25), doneAction: 2);
		tone = SinOsc.ar([freq, freq + 1.5], LocalIn.ar(2) * decay, amp * 0.6).tanh * env;
		snd = Pluck.ar(
		        in: WhiteNoise.ar(amp),
		        trig: Impulse.kr(0),

		        maxdelaytime: 0.1,
		        delaytime: freq.reciprocal,
		        decaytime: decay,
		        coef: coef) * env;
		LocalOut.ar(snd + tone);
	    Out.ar(0, [snd + tone, snd + tone]);
	}).add;

	SynthDef(\simple, {|amp = 0.1, freq = 440, gate = 1, coef = 0.1, attack = 0.02, decay = 0.1, sustain = 0.5, release = 0.2|

		var env, tone;
		// env = EnvGen.kr(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		env = EnvGen.kr(Env.linen(attack, 0, release), doneAction: 2);
		tone = SinOsc.ar([freq, freq + 1.5], LFSaw.ar([freq*3,freq*3.01],0,0.1), amp * 0.6 * env).tanh;
	    Out.ar(0, tone);
	}).add;

	ptn = Ndef(\pe,
		Pbind(
		    \instrument, \simple,
		    // \hash, Pwhite(0,1e10),
		    \amp, Pwhite(0.1, 0.3),
		    // \coef, Pseq([0.7,0.4,0.5,0.1,0.9], inf),
		    \coef, Pfunc{ my.getSynchronous.linlin(0,1.0,0.01,0.99)},
		    // \dur, Prand([0.1, 0.2, 0.4] * 2, inf),
		    // \type, \midi,
		    // \midiout, midiOut,


		    \root, Pseq([0,3,-2,1,-4,-2].stutter(21), inf),
		    \octave,Prand([4,5],inf),
		    \note, Pseq([0,2,4,9,7,11], inf),
		    // \note, Prand([0,4,7,11,12], inf),
		    \sh, Pseq([0].stutter(21), inf),
		    // \dur, Pseq([0.5,0.5,0.5,0.25,0.5,0.25], inf),
		    \dur, Pfunc{ 2.pow(mx.getSynchronous.linlin(0,1.0,1,5).floor).reciprocal * 2},
		    \attack, Pfunc{ my.getSynchronous.linlin(0,1.0,0.002,0.5)},//Pwhite(0.002,0.1),
		    //\decay, 0.02,//Pwhite(0.02,0.2),
		    \release, Pwhite(0.02,1.3),//Pfunc{ my.getSynchronous.linlin(0,1.0,0.02,5.5)},//Pwhite(0.05,1.3),
		    \rel, Pkey(\release),
		    \param1, Pwhite(1,20),
		    \param2, Pwhite(1,5),
		    \param3, 5,//Pwhite(0,7),

			\osc, Pfunc{|e| 
				var clock = ptn.source.asStream.clock;
				e.rel.postln;
				// clock.bar.mod(4).postln; //!! somewhere in the bar !!
				// netAddr.sendBundle(0.0, ["/shadow", 0, e.note, e.dur, e.attack, e.decay, e.coef]);
				["/shadow",e.sh, e.dur, e.attack, e.rel, e.param1, e.param2, e.param3].postln;
				netAddr.sendMsg("/shadow", e.sh, e.dur, e.attack, e.rel, e.param1, e.param2, e.param3);
			},
		);
	).play;
	Synth(\mouseX, [\bus, mx.index]);
	Synth(\mouseY, [\bus, my.index]);
	//------------------------------------------------------
	QtGUI.palette = QPalette.dark; 
	window = Window("",Rect(0,0,Window.screenBounds.width/2, Window.screenBounds.height/2)
		.center_(Window.availableBounds.center)
	).front;
	//------------------------------------------------------
	window.onClose = ({
		// MIDIdef.freeAll;
		Ndef.clear;
		o.free;
		midiOut.allNotesOff(0);
		s.freeAll;
	});
	CmdPeriod.doOnce({window.close});
	)
