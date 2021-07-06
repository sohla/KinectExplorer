(
SynthDef(\drawing1, {|attack = 8.004, release = 12.9, freq = 120, gate = 1, vib = 1, amp = 0.7|

	var env = EnvGen.ar(Env.perc(attack, release, 1, -7), gate, doneAction: 2);
	var fs = Array.makeScaleCps(groundNote: 263, type: 'major');
	var as = [1,0.1,0.2,0.02,1,0.3,0.7,0.5];
	var rs = [1];
	var sig = Splay.arFill(16,
		{

			DynKlank.ar(
				`[freq, as, rs], 
				LPF.ar(PinkNoise.ar(0.007), MouseX.kr(100,1000));
			) * 0.5

		},
		1,
		1,
		0);
	Out.ar(0, sig * env * amp * MouseY.kr(0,1, lag:0.1));
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
			\dur, Pseq([1/5, 1/5, 1/2.5, 1/5] * 10, inf),
			\amp, 1,
			\attack, Pwhite(5.001,10.006, inf),
			\release, Pwhite(29.1,16.9, inf),
		)
	).play;
)


Ndef(\drawing1).fadeTime = 20;
Ndef(\drawing1).end;