(
	var window;
	var midiOut;
	var netAddr = NetAddr.new("127.0.0.1", 10000);    // create the NetAddr
	var o;

	var mx = Bus.control(s,1);
	var my = Bus.control(s,1);

	var point = Point(30,40);
	var pointDelta = Point(0,0);
	//------------------------------------------------------
	MIDIClient.init;

	midiOut = MIDIOut.newByName("IAC Driver", "Bus 1", dieIfNotFound: true);
	midiOut.latency_(0.00);



	pointDelta.addUniqueMethod(\tween,{|self,point,friction = 0.05|
		self.x = (friction * point.x) + ((1 - friction) * self.x);
		self.y = (friction * point.y) + ((1 - friction) * self.y);
	});

	//------------------------------------------------------
	SynthDef(\mouseX, { |bus| Out.kr(bus, MouseX.kr(0,1.0))}).add;
	SynthDef(\mouseY, { |bus| Out.kr(bus, MouseY.kr(0,1.0))}).add;

	Ndef(\pe,
		Pbind(
		    \note, Prand([0,2,4,5,7,10], inf),
			\octave, Prand([4,6,7], inf),
			\dur, Pfunc{ mx.getSynchronous.linlin(0,1.0,0.5,0.05)},
			\amp, 0.5,
			// \osc, Pfunc{|e| netAddr.sendMsg("/shadow", e.note, 3);},
			\osc, Pfunc{|e| netAddr.sendBundle(0.0, ["/shadow", 1, e.note, e.dur])},


			\type, \midi,
			\midiout, midiOut,
			\chan, 0,
		);

		// b = Pbind(
		// 	\dur, Pfunc{ 2.pow(mx.getSynchronous.linlin(0,1.0,1,4).floor).reciprocal},
		// 	\type, \midi,
		// 	\midiout, midiOut,
		// 	\chan, 0,
		// 	\midicmd, \control,
		// 	\ctlNum, 1,
		// 	\control, Pseq(Array.fill(100, {|i| 64 + (sin(i * 0.07)*64)}), inf),
		// );

		// Ppar([a,b]);

	).play;

	// Ndef(\pe,
	// 	a = Pbind(
	// 	    \note, Prand([0,2,4,5,7,10], inf),
	// 		\octave, Prand([4,6,7], inf),
	// 	//     \note, Pseq([0,2,4,6,8,10], inf),
	// 	// 	\octave, Pseq([1,2,3,4,5,6,7,8,9,10].stutter(6), inf),
	// 		\dur, Pfunc{ mx.getSynchronous.linlin(0,1.0,0.5,0.05)},
	// 		\amp, 0.5,
	// 		// \state, Pseq([0,100],inf),
	// 		\type, \midi,
	// 		\midiout, midiOut,
	// 		\chan, 0,
	// 	);

	// 	b = Pbind(
	// 		\dur, Pfunc{ 2.pow(mx.getSynchronous.linlin(0,1.0,1,4).floor).reciprocal},
	// 		\type, \midi,
	// 		\midiout, midiOut,
	// 		\chan, 0,
	// 		\midicmd, \control,
	// 		\ctlNum, 1,
	// 		\control, Pseq(Array.fill(100, {|i| 64 + (sin(i * 0.07)*64)}), inf),
	// 	);

	// 	Ppar([a,b]);

	// ).play;

	Synth(\mouseX, [\bus, mx.index]);
	Synth(\mouseY, [\bus, my.index]);

	//------------------------------------------------------

	QtGUI.palette = QPalette.dark; 

	window = Window("",Rect(0,0,Window.screenBounds.width/2, Window.screenBounds.height/2)
		.center_(Window.availableBounds.center)
	).front;

	window.layout = HLayout()
		.spacing_(0)
		.margins = [0, 0, 0, 0];

	window.layout.add(
		UserView()
			.background_(Color.grey(0.3))
			.animate_(true)
			.drawFunc = {

				Pen.addRect(window.view.bounds.insetBy(30));
				Pen.fillAxialGradient(Point(0,0), pointDelta, Color.red, Color.blue);

				Pen.fillColor = Color.yellow(1,0.2);
				Pen.addArc(pointDelta, 330, 0, 2pi);
				Pen.fill;

				pointDelta.tween(point,0.2);

			};
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

MIDIClient.init;
 m = MIDIOut(0);
(type: \composite, types: [\midi], midiout: m, degree: 0, dur: 3).play;