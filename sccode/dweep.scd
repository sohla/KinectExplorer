( 
SynthDef(\dweep, {|out = 0, freq = 100.0, amp = 0.7, attack = 0.003, decay = 0.05, sustain = 0.15, release = 2.6, gate = 1, ff = 1, rf = 100|
	
	var enva = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
	var envb = EnvGen.ar(Env.adsr(attack * 26, decay * 16, sustain, release * 16), gate);

	var buf = LocalBuf(2048, 2);
	var gb;
	var l = LocalIn.ar(2);
	var k = LFSaw.ar(l,0,1,1);
	var j = LFCub.ar( MouseY.kr(0.1,140), 0, 0.02, 1);//Line.ar(3,1,1)

	var sig = PitchShift.ar(
		SinOscFB.ar( [freq, freq + (freq * 0.006)], MouseX.kr(0,1.3)),//
	[0.02,0.021],
	j
	);
	LocalOut.ar(sig.tanh);

	sig = Splay.arFill(1, {|i|
		AllpassN.ar(sig, 0.1, 0.05 * i, 0.5 + (0.1 * i));

	});



	Out.ar(0, sig * enva * amp);

}).send(s);

)



a = Synth.new(\dweep, [\freq, 150]);
s.scope
s.meter
s.peakCPU


(
Pdef(\a,
	Pbind(
		\instrument, \dweep,
		\octave, Pseq([[2,3],5,7,6,5,4], inf),
		\note, Prand([0,5,9].stutter(6), inf),
		\root, Pseq([0,2,4].stutter(18), inf),
		\dur, 0.3,
		\amp, 0.6, 
	)
).play;
)



