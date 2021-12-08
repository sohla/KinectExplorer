(
	var window;
	var faders = [];
	// var numControlers = 8, faderOffset = 81, firstButtonOffset = 65, secondButtonOffset = 73, numChannels = 1;

	var bootServer = {|f|
	
		var input = ServerOptions.devices.indexOfEqual("SERIES 208i");
		 var output = ServerOptions.devices.indexOfEqual("SERIES 208i");
		// var input = ServerOptions.devices.indexOfEqual("ZoomAudioD");
		// var output = ServerOptions.devices.indexOfEqual("External Headphones");
		// var output = ServerOptions.devices.indexOfEqual("Soundflower (2ch)");
		// var output = ServerOptions.devices.indexOfEqual("External Headphones");
		// var input = ServerOptions.devices.indexOfEqual("Built-in Microph");
		// var output = ServerOptions.devices.indexOfEqual("Built-in Output");

		o = Server.local.options;
		o.inDevice = ServerOptions.devices[input];
		o.outDevice = ServerOptions.devices[output];
		// o.sampleRate = 44100.000000;
		o.memSize = 8192 * 4;
		o.numInputBusChannels = 2;
		o.numOutputBusChannels = 2;

		s.waitForBoot{
			"💫 P H O E N i X 💫".postln;
			f.();
		};
	};


	//------------------------------------------------------
	bootServer.({

	SynthDef(\glow, {|attack = 0.004, release = 0.9, freq = 100, gate = 1, vib = 1, amp = 0.3, lpf = 18000, mx = 0.5, my = 0.5|

		var env = EnvGen.ar(Env.perc(attack, release, 1, -7), gate, doneAction: 2);
		 var trig = Impulse.ar(XLine.ar(40, 1, attack + (release * 0.5)));
		//var trig = MouseX.kr(0.1,100);
		var sig = Splay.ar({|i|
	    	var f = freq * 2.pow(i+1) * 0.5;
	    	Pluck.ar(
	    		HPF.ar(BrownNoise.ar(0.2), mx.linexp(0,1,440,10)),//MouseX.kr(440,10, \exponential)), 
	    		trig,  
	    		f.reciprocal + 0.2, 
	    		f.reciprocal, 
	    		// Demand.ar(trig, 0,Dwhite(1, 10)),
	    		// MouseX.kr(0.01,10),
	    		mx.linlin(0,1,0.01,10),
	        	// coef:MouseY.kr(-0.999, 0.999, lag:1.6)  
	        	coef: my.linlin(0,1,-0.999, 0.999).lag(1.6)
	        	// coef:Demand.ar(trig, 0,Dwhite(0.65, 0.85))
	        )} !2);

		sig = LPF.ar(sig, lpf);
		Out.ar(0, sig * env * 0.5 * amp);

	}).add;

	SynthDef(\dweep, {|out = 0, freq = 100.0, amp = 0.7, attack = 0.003, decay = 0.05, sustain = 0.15, release = 2.6, gate = 1, 
		ff = 1, rf = 100, mx = 0.5, my = 0.5|
	
		var enva = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var envb = EnvGen.ar(Env.adsr(attack * 26, decay * 16, sustain, release * 16), gate);
		var gb;
		var l = LocalIn.ar(2);
		var k = LFSaw.ar(l,0,1,1);
		var j = LFCub.ar( my.linexp(0,1,0.1,140), 0, 0.02, 1);//Line.ar(3,1,1)
		var sig = PitchShift.ar(
			SinOscFB.ar( [freq, freq + (freq * 0.006)], mx.linlin(0,1,0.001,1.3)),//
		[0.02,0.021],
		j
		);
		LocalOut.ar(sig.tanh);

		sig = Splay.arFill(3, {|i|
			AllpassL.ar(sig, 0.1, 0.05 * i, 0.2 + (0.1 * i));

		});
		Out.ar(0, sig * enva * amp);

	}).send(s);


	SynthDef(\frog, {|attack = 0.004, release = 1.9, freq = 120, gate = 1, vib = 1, amp = 0.1,
		mx = 0.5, my = 0.5|

		var env = EnvGen.ar(Env.perc(attack, release, 1, -7), gate, doneAction: 2);
		var sig = MoogFF.ar(
			LFSaw.ar(
				[freq + (freq * LFCub.ar(freq*my.linlin(0,1,0.5, 3).lag2(0.7), 0, 0.49, 0.006) ), 
				freq + (freq * LFCub.ar(freq*mx.linlin(0,1,0.5, 3).lag2(0.7), 0, 0.49, 0.006) )], 
				[0,0.5], 
				0.5),
			env.linlin(0,1,500, mx.linlin(0,1,100, 10000).lag(0.3)),
			-4
		);
		var sub = SinOsc.ar(freq, [0,1.36], 0.5);
		Out.ar(0, (sig + sub) * env * amp);
	}).add;



	//------------------------------------------------------
	Ndef(\glowPtn,
		Pbind(
			\instrument, \glow,
			\octave, Prand([2,4,5,6]+1, inf),
			\note, Prand([0,4,7], inf),
			\root, Pseq([0,2].stutter(16), inf),
			\dur, Prand([0.5], inf),
			\dur, 0.5,
			\amp, 0,
			\attack, Pwhite(6,9, inf),
			\release, Pwhite(5,6, inf),
		)
	).play;

	Ndef(\glowPtn2,
		Pbind(
			\instrument, \glow,
			\octave, Prand([3], inf),
			\note, Prand([0], inf),
			\root, Pseq([0,-3,-5,-6,-3].stutter(16), inf),
			\dur, 0.55,
			\amp, 0,
			\attack, Pwhite(4,7, inf),
			\release, Pwhite(2,4, inf),
			\lpf, 180
		)
	).play;	


	Ndef(\wind, {|mFreq = 0.1, fFreq = 348, fRq = 0.1, amp = 0, mx = 0.5, my = 0.5|

		var src, mod;
		mod = {LFNoise2.ar(mFreq).range(0, 1)}!6;
		src = WhiteNoise.ar(mod.lagud(1, 4));
		src = RLPF.ar(src, my.linlin(0,1,49,500).lag3(2), mx.linlin(0,1,0.9,0.1));
		Splay.ar(src * amp);

	}).play;

	Ndef(\dweepPtn,
		Pbind(
			\instrument, \dweep,
			\octave, Pseq([[2,3],5,7,6,5,4], inf),
			\note, Prand([0,5,9].stutter(6), inf),
			\root, Pseq([0-3,2-3,4-3].stutter(30), inf),
			\dur, 0.33,
			\amp, 0.0, 
		)
	).play;


	Ndef(\frogPtn,
		Pbind(
			\instrument, \frog,
			\octave, Pseq([2,4,5,4,5], inf),
			\note, Pseq([0,7,11,16], inf),
			\root, Pseq([4,-1, 2,0].stutter(20), inf),
			\dur, Pseq([1/5, 1/5, 1/2.5, 1/5], inf),
			\amp, 0.0,
			\attack, Pwhite(0.001,0.006, inf),
			\release, Pwhite(0.3,1.9, inf),
		    \rel, Pkey(\release),
		    \vib, 50,
		)
	).play;

	//------------------------------------------------------

		MIDIClient.init;
		MIDIClient.sources;

		MIDIIn.connectAll;

			

		//------------------------------------------------------
		MIDIdef.cc(\glowamp,{|val| Ndef(\glowPtn).set(\amp,val.linlin(0,127,0,1)) }, 81, 0);
		MIDIdef.cc(\glowx,{|val| Ndef(\glowPtn).set(\mx,val.linlin(0,127,0,1)) }, 94, 0);
		MIDIdef.cc(\glowy,{|val| Ndef(\glowPtn).set(\my,val.linlin(0,127,0,1)) }, 82, 0);

		MIDIdef.cc(\glowamp2,{|val| Ndef(\glowPtn2).set(\amp,val.linlin(0,127,0,1)) }, 83, 0);
		MIDIdef.cc(\glow2y,{|val| Ndef(\glowPtn2).set(\my,val.linlin(0,127,0,1)) }, 94, 0);

		MIDIdef.cc(\windamp,{|val| Ndef(\wind).set(\amp,val.linlin(0,127,0,0.5)) }, 84, 0);
		MIDIdef.cc(\windmx,{|val| Ndef(\wind).set(\mx,val.linlin(0,127,0,1)) }, 85, 0);
		MIDIdef.cc(\windmy,{|val| Ndef(\wind).set(\my,val.linlin(0,127,0,1)) }, 94, 0);

		MIDIdef.cc(\dweepamp,{|val| Ndef(\dweepPtn).set(\amp,val.linexp(0,127,0.0001,1.0)) }, 86, 0);
		MIDIdef.cc(\dweepmx,{|val| Ndef(\dweepPtn).set(\mx,val.linlin(0,127,0,1)) }, 94, 0);
		MIDIdef.cc(\dweepmy,{|val| Ndef(\dweepPtn).set(\my,val.linlin(0,127,0,1)) }, 94, 0);

		MIDIdef.cc(\frogamp,{|val| Ndef(\frogPtn).set(\amp,val.linexp(0,127,0.0001,1.0)) }, 87, 0);
		MIDIdef.cc(\frogmx,{|val| Ndef(\frogPtn).set(\mx,val.linlin(0,127,0,1)) }, 94, 0);
		MIDIdef.cc(\frogmy,{|val| Ndef(\frogPtn).set(\my,val.linlin(0,127,0,1)) }, 94, 0);
	//------------------------------------------------------

	QtGUI.palette = QPalette.dark; 

	window = Window("phoenix",Rect(0,0,Window.screenBounds.width/3, Window.screenBounds.height/4)
		.center_(Window.availableBounds.center)
	).front;

	window.layout = HLayout(
		FreqScopeView()
				.freqMode_(1)
				.active_(true));

	window.layout.add(
	);

	//------------------------------------------------------

	window.onClose = ({

		faders.do{|mc|mc.free};
		MIDIdef.freeAll;
		Ndef.clear;
		s.freeAll;
		s.quit;
	});
	CmdPeriod.doOnce({window.close});
		});

)



// s.peakCPU