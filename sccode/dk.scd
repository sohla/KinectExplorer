( 
SynthDef(\dk, {|out = 0, freq = 100, amp = 1.0, attack = 0.05, decay = 0.35, sustain = 0.1, release = 14.6, gate = 1, ff = 1, rf = 100|
	
	var enva = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
	var envb = EnvGen.ar(Env.adsr(attack, decay * 0.2, sustain, release * 0.1), gate, doneAction: 2);

	var as = (1..8).reciprocal * 0.7;
	// var fs = [freq,freq*2,freq*4,freq*8,freq*16,freq*32,freq*64,freq*128];
	var fs = [freq,freq*2];

	var sig = 	Splay.arFill(2,
	{|i|

		DynKlank.ar(
			`[fs * Line.ar(1,1.025,decay), as * LFCub.ar(rf,0,0.49 * enva,0.7), LFCub.ar(0.2,0,0.98,1.0)] , 
			HPF.ar(LFNoise1.ar(12000,0.05 * envb), ff)

		) * amp

	},
	1,
	1,
	0);

	Out.ar(0,sig.clip(0,1) * enva * freq.explin(100,1000,1,0.6));

}).send(s);

)

a = Synth.new(\dk,[\freq, 200]);
s.meter
(
	Pdef(\dkp,
		Pbind(
			\instrument, \dk,
			\octave, Pseq([2,3,4,5,4,6], inf),
			\note, Prand([0,5,10,5,10,15,10], inf),
			\root, Pseq([0,-2].stutter(14), inf),
			\dur, Pseq([0.2,0.1,0.1, Rest(0.2), 0.1, 0.1, 0.2, Rest(0.1), 0.1] * 3, inf),
			\amp, 0.7,
			\ff, Prand([1,1200], inf),
			\rf, Pwhite(1,1200),
			\attack, Pwhite(0.01,0.04),
			\decay, Pwhite(0.05,0.15),
			\release, Pwhite(11,21),
		)
	).play;
)