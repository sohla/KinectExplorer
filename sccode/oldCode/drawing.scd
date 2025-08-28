(
SynthDef(\drawing1, {|out =0, attack = 0.1, release = 12.9, freq = 120, gate = 1, vib = 1, amp = 0.7, flt = 10000, lfoa = 1, lfof = 4|

	var env = EnvGen.ar(Env.perc(attack, release, 1, -7), gate, doneAction: 2);
	var fs = Array.makeScaleCps(groundNote: 263, type: 'major');
	var as = [1,0.1,0.2,0.02,1,0.3,0.7,0.5];
	var lfo = LFCub.ar(lfof,0,lfoa).linlin(-1,1,0.2,0.4);
	var rs = [1];
	var sig = Splay.arFill(16,
		{

			DynKlank.ar(
				`[freq + (lfo * freq), as, rs], 
				LPF.ar(PinkNoise.ar(0.007), flt);
			) * 0.5

		},
		1,
		1,
		0);
	Out.ar(out, sig * env * amp);
}).add

)

s.avgCPU
s.meter

a = Synth.new(\drawing1, [\release,22]);

(
	Ndef(\drawing1,
		Pbind(
			\instrument, \drawing1,
			\octave, Pseq([4,5,4,5], inf),
			\note, Pseq([0,7,16], inf),
			\root, Pseq([0,4,-1, 2].stutter(20), inf),
			\dur, Pseq([1/5, 1/5, 1/2.5, 1/5] * 3, inf),
			\amp, 1,
			\attack, Pwhite(0.001,0.006, inf),
			\release, Pwhite(4.1,6.9, inf),
		)
	).play;
)


Ndef(\drawing1).fadeTime = 20;
Ndef(\drawing1).end;