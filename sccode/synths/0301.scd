(
SynthDef(\synth0301, { |out=0, gate=1, freq=100, att=0.01, dec=0.01, sus=0.9, rel=3.3, amp=0.5, ts=0.2, dt = 0.2, sq = 0.1, ds = 2|
	var env = EnvGen.ar(Env.adsr(att,dec,sus,rel), gate, doneAction: 2);
	var fenv = EnvGen.ar(Env.adsr(0.001 * ts, 1.8 * ts, 0, 0), gate, timeScale: 1, doneAction: 0);
	var sig = SinOscFB.ar([freq, freq + (freq * 0.0265)] , fenv * pi/2 , 0.2);
	var dly = DelayN.ar(sig, dt * 1.5, dt * 1.5, 1, sig);
	var sub = SinOsc.ar(freq * 0.5, dly * sq, ds * 0.3) + SinOsc.ar(freq * 0.25,0,2);
	Out.ar(out, (sub + dly) * env * amp * ds.reciprocal);
}).add;
)

(
~group = Group.new;
Pdef(\a,
	Pbind(
		\instrument, \synth0301,
		\group, ~group,
		\octave, Pxrand([2,3]+3, inf),
		\degree, Pseq([0,5,12,15,17,19], inf),
		\root, Pseq([0,5,-5,5].stutter(24), inf),
		\dur, 0.15,
		\att, 0.003,
		\dec, 0.2,
		\sus, 0.2,
		\rel, Pwhite(0.1,0.6),
		\amp, 0.5,//Pkey(\octave).linlin(2,6,0.5,0.08),
		\ts, Pwhite(0.05,0.5),
		\dt, Pkey(\dur) * 0.01,
		\sq, Pwhite(0.1,20),
		\ds, Pwhite(1,4),

	)
);

Pdef(\a).play;


)


~group.free
