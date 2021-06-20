(
SynthDef(\drawing1, {|attack = 8.004, release = 12.9, freq = 120, gate = 1, vib = 1, amp = 0.7|

	var env = EnvGen.ar(Env.perc(attack, release, 1, -7), gate, doneAction: 2);
	var fs = Array.makeScaleCps(groundNote: 263, type: 'major');
	var as = [1,0.1,0.2,0.02,1,0.3,0.7,0.5];//(1..8).reciprocal;
	var rs = [1];//(1..8).reciprocal;
	var sig = Splay.arFill(16,
		{

			DynKlank.ar(
				`[fs, as, rs], 
				HPF.ar(PinkNoise.ar(0.007),400)
			) * 0.5

		},
		1,
		1,
		0);
	Out.ar(0, sig * env * amp);
}).add

)

s.avgCPU
s.meter

a = Synth.new(\drawing1, [\release,22]);

