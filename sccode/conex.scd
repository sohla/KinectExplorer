(
SynthDef(\conex, {|out = 0, gate = 1, amp = 0.5, freq = 120, attack = 0.007, release = 0.9, vib = 2|


	var fs = Array.geom(5, freq, 2.01);
	var as = [0.7,0.5,0.05,0.02,0.01,0.005];
	var ff = Array.rand(5, vib, vib + (vib/2));
	var rs = Array.series(5, 16, -1.3);
	var env = EnvGen.ar(Env.perc(attack, release), gate, doneAction: 2);
	var nenv = EnvGen.ar(Env.perc(attack * 0.01, release * 0.01));
	var venv = EnvGen.ar(Env.perc(attack * 3, release * 2));
	var imp = BLowShelf.ar(HPF.ar( LPF.ar(PinkNoise.ar(0.007 * nenv), 20800), 240), 40, 1, -10).clip;
	var sig = DynKlank.ar(
		`[fs * LFCub.ar(ff,0,0.02,1), as, rs], 
		imp,
		[1,1.012]) ;
	Out.ar(out, sig * amp * env * 50);

}).add;
)



(
	Ndef(\ptn,
		Pbind(
			\instrument, \conex,
			\octave, Prand([2,4,5,6,7], inf),
			\note, Prand([0,2,-2,-4,5,7], inf),
			\root, Pseq([0,12].stutter(12), inf),
			// \dur, Prand([1/4,1/4,1/8], inf),
			\dur, Prand([1/5], inf),
			\amp, 0.5,
			\attack, Pwhite(0.003,0.01),
			\release, Pwhite(0.1,0.6),
			\vib, Pwhite(1,4)
		)
	).play;
)


a = Synth.new(\conex);

FreqScope.new(1400, 700, 0, server: s);
s.peakCPU
s.meter
s.freqscope
Pdef.clear



