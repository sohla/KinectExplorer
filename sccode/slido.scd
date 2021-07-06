(
SynthDef(\blaz, {|out = 0, freq = 120, amp = 0.5, attack = 0.01, decay = 0.2, sustain = 0.8, release = 0.9, gate = 1, wob = 0.023|

	var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
	var sig;
	var d = 4; 
	var a = 8; 
	var p = [freq, freq+0.1];

	sig = Mix.ar(Array.fill(d, { |i| SinOsc.ar(p,0, LFCub.ar([p,p+1], (i+1) * pi/4, 0.003 ,0.003) * env) }));
	y = Mix.ar(CombL.ar(sig, 0.3, SinOsc.kr( Array.fill(a, {|i| (i+1) * 0.03}), 0, wob, 0.21), 1));

	sig = sig + (0.5*y);

	Out.ar(out, LeakDC.ar(sig * amp * env));

}).add;

)

(
	Pdef(\a,
		Pbind(
			\instrument, \blaz,
			\octave, Prand([2,3,4,5], inf),
			\note, Prand([0,4,5,7,10,12], inf),
			\root, Pseq([0,3,-2].stutter(8*8), inf),
			\dur, 3,
			\amp, 0.9,
			\attack, 0.45,
			\release, 4.0,
			\wob, Pwhite(0.02,0.08),
		)
	).play;
)

(
	Pdef(\b,
		Pbind(
			\instrument, \blaz,
			\octave, Prand([2,3,4,5], inf),
			\note, Prand([0,4,5,7,10,12], inf),
			\root, Pseq([0,3,-2].stutter(8*8), inf),
			\dur, 0.1,
			\amp, 0.9,
			\attack, 0.005,
			\release, 1.3,
			\wob, 0.03,
		)
	).play;
)
