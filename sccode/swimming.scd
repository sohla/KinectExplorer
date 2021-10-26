(
SynthDef(\swimming, {|attack = 0.004, release = 1.9, freq = 120, gate = 1, vib = 1|

	var env = EnvGen.ar(Env.adsr(attack, 0.07, 0.7,release, 1, -7), doneAction: 2);
	var sig = 0;
	var p, z, trig;
	p = 11;	// number of partials per channel
	p.do({ |i|
		sig = FSinOsc.ar(
				[freq * (i+1+0.02.rand),freq * (i+1+0.01.rand)],
				0,
				CombL.ar(
				Decay2.kr(
					Dust.kr(
						[1,1],
						LFNoise1.kr(0.3 * (i+1), 1.0 / (i+1)**2	)
					),
					0.03,
					0.08	
				),
				[0.3, 0.2], [0.1, 0.2], 1.0),
				sig
		);
	});


	Out.ar(0, sig * env);
}).add;

)

s.avgCPU
s.meter

a = Synth.new(\swimming, [\release,2]);

(
	Ndef(\swimmingPtn,
		Pbind(
			\instrument, \swimming,
			\octave, Pseq([2,4,5,4,5], inf),
			\note, Pseq([0,7,11,16], inf),
			\root, Pseq([0,4,-1, 2].stutter(20), inf),
			\dur, Pseq([1/5, 1/5, 1/2.5, 1/5]*8, inf),
			\amp, 1,
			\attack, Pwhite(1,4, inf),
			\release, Pwhite(2.9,6.9, inf),
		)
	).play;
)

/*
how to use : needs to go somewhere else / strange

*/