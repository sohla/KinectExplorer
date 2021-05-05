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

	SynthDef(\simple, {|amp = 0.1, freq = 440, decay = 5, coef = 0.1, attack = 0.02|

		var env, snd, tone;
		env = EnvGen.kr(Env.linen(attack, 0, decay * 0.25), doneAction: 2);
		tone = SinOsc.ar([freq, freq + 1.5],0, amp * 0.6).tanh * env;
	    Out.ar(0, tone);
	}).add;

	ptn = Ndef(\pe,
		Pbind(
		    \instrument, \simple,
		    \octave,[3,4],
		    \hash, Pwhite(0,1e10),
		    // \root, Pseq([0,3,-2,1,-4,-2].stutter(21), inf),
		    \note, Pseq([0,3,7,2,6,4,1], inf),
		    \id, Pseq([0,1,2,3,4,5,6,7], inf),
		    \amp, Pwhite(0.1, 0.3),
		    \decay, Pwhite(0.4, 4),
		    // \coef, Pseq([0.7,0.4,0.5,0.1,0.9], inf),
		    \coef, Pfunc{ my.getSynchronous.linlin(0,1.0,0.01,0.99)},
		    // \dur, Prand([0.1, 0.2, 0.4] * 2, inf),
		    \dur, Pfunc{ 2.pow(mx.getSynchronous.linlin(0,1.0,1,4).floor).reciprocal * 2},
		    \attack, Pseq([0.02,0.11,0.02,0.17], inf),
		    \type, \midi,
		    \midiout, midiOut,
		    \tt, Ptime(inf), 
			\osc, Pfunc{|e| 
<<<<<<< HEAD
				// e.postln;
				var clock = ptn.source.asStream.clock;
				clock.bar.mod(4).postln; //!! somewhere in the bar !!
				netAddr.sendBundle(0.0, ["/shadow"+e.note, e.hash, e.note, e.dur, e.attack, e.decay, e.coef]);
=======
				 e.id.postln;
				netAddr.sendBundle(0.0, ["/shadow"+e.note, 8, e.note, e.dur, e.attack, e.decay, e.coef]);
>>>>>>> 9987946f9019459de81e466148c7fef96c841d1e
			},
		);
	).play(quant:1);
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
		// s.freeAll;
	});
	CmdPeriod.doOnce({window.close});
	)
