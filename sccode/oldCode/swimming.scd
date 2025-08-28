(
SynthDef(\swimming, {|out = 0, attack = 0.004, release = 1.9, freq = 120, gate = 1, ring = 0.23|

	var env = EnvGen.ar(Env.adsr(attack, 0.07, 0.7,release, 1, -7), doneAction: 2);
	var sig = 0;
	var p, z, trig;
	p = 11;	// number of partials per channel
	p.do({ |i|
		sig = FSinOsc.ar(
				[freq * (i+1+0.02.rand),freq * (i+1+0.01.rand)],
				0,
				Decay2.kr(
					Dust.kr(
						[1,1],
						LFNoise1.kr(0.3 * (i+1), 1.0 / (i+1)**2	)
					),
					0.03,
					ring	
				),
				sig
		);
	});
	Out.ar(out, sig * env * 1);
}).add;

)

s.avgCPU
s.meter

a = Synth.new(\swimming, [\release,2, \freq, 400]);

(
	Ndef(\swimmingPtn,
		Pbind(
			\instrument, \swimming,
			\octave, Pseq([4,5,4,5], inf),
			\note, Pseq([0,7,11,16], inf),
			\root, Pseq([0,4,-1, 2].stutter(20), inf),
			\dur, Pseq([1/5, 1/5, 1/2.5, 1/5]*8, inf),
			\amp, 1,
			\attack, Pwhite(1,4, inf),
			\release, Pwhite(2.9,6.9, inf),
			\ring,1
		)
	).play;
)

/*
how to use : needs to go somewhere else / strange

*/