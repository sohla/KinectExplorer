(
	var window;
	var midiOut;
	var netAddr = NetAddr.new("127.0.0.1", 10000);    // create the NetAddr
	var o;

	var mx = Bus.control(s,1);
	var my = Bus.control(s,1);


	//------------------------------------------------------
	MIDIClient.init;

	midiOut = MIDIOut.newByName("IAC Driver", "Bus 1", dieIfNotFound: true);
	midiOut.latency_(0.00);

	//------------------------------------------------------
	SynthDef(\mouseX, { |bus| Out.kr(bus, MouseX.kr(0,1.0))}).add;
	SynthDef(\mouseY, { |bus| Out.kr(bus, MouseY.kr(0,1.0))}).add;

	Ndef(\pe,
		a = Pbind(
		    \note, Prand([0,2,4,5,7,10], inf),
			\octave, Prand([4,6,7], inf),
		//     \note, Pseq([0,2,4,6,8,10], inf),
		// 	\octave, Pseq([1,2,3,4,5,6,7,8,9,10].stutter(6), inf),
			\dur, Pfunc{ mx.getSynchronous.linlin(0,1.0,0.5,0.05)},
			\amp, 0.5,
			// \state, Pseq([0,100],inf),
			\type, \midi,
			\midiout, midiOut,
			\chan, 0,
		);

		b = Pbind(
			\dur, Pfunc{ 2.pow(mx.getSynchronous.linlin(0,1.0,1,4).floor).reciprocal},
			\type, \midi,
			\midiout, midiOut,
			\chan, 0,
			\midicmd, \control,
			\ctlNum, 1,
			\control, Pseq(Array.fill(100, {|i| 64 + (sin(i * 0.07)*64)}), inf),
		);

		Ppar([a,b]);

	).play;

	Synth(\mouseX, [\bus, mx.index]);
	Synth(\mouseY, [\bus, my.index]);

	//------------------------------------------------------

	QtGUI.palette = QPalette.dark; 

	window = Window("",Rect(0,0,Window.screenBounds.width/2, Window.screenBounds.height/2)
		.center_(Window.availableBounds.center)
	).front;

	window.layout = HLayout();

	window.layout.add(
	);

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


