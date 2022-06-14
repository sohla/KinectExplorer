(
SynthDef(\slido, {|out = 0, freq = 120, amp = 0.5, attack = 0.01, decay = 0.2, sustain = 0.8, release = 0.9, gate = 1, wobf = 0.023|

	var enva = EnvGen.ar(Env.adsr(attack / 2, decay / 2, sustain, release /2), gate);
	var envb = EnvGen.ar(Env.adsr(attack, decay, sustain, release), doneAction: 2);
	var sig;
	var d = 2; 
	var a = 2; 
	var p = [freq, freq+0.1];

	sig = Mix.ar(Array.fill(d, { |i| SinOsc.ar(p,0, LFCub.ar([p,p+1], (i+1) * pi/4, 0.003 ,0.003) * enva) }));
	y = Mix.ar(CombL.ar(sig, 0.3, SinOsc.kr( Array.fill(a, {|i| (i+1) * 0.009}), 0, wobf, 0.21), 1));

	sig = sig + (0.5*y);

	Out.ar(out, LeakDC.ar(sig * amp * envb));

}).add;

)

(
	Pdef(\a,
		Pbind(
			\instrument, \slido,
			\octave, Prand([2,3,4,5], inf),
			\note, Prand([0,4,5,7,10,12], inf),
			\root, Pseq([0,3,-2].stutter(8*8), inf),
			\dur, 3,
			\amp, 0.9,
			\attack, 0.45,
			\decay, 3,
			\release, 4.0,
			\wobf, Pwhite(0.01,0.03),
		)
	).play;
)

(
	Pdef(\b,
		Pbind(
			\instrument, \slido,
			\octave, Prand([5,6,7], inf),
			\note, Prand([0,4,5,7,10,12], inf),
			\root, Pseq([0,3,-2].stutter(8*8), inf),
			\dur, 0.1,
			\amp, 2.9,
			\attack, 0.005,
			\release, 0.4,
			\wobf, 0.03,
		)
	).play;
)


( 
	Pdef(\c,
		Pbind(
			\instrument, \slido,
			\octave, Prand([3,5,7], inf),
			\note, Prand([0,10,4,6,2], inf),
			\root, Pseq([0,2,4].stutter(8*8), inf),
			\dur, 2,
			\amp, 1,
			\attack, 1.005,
			\release, 2.4,
			\wobf, 0.09,
		)
	).play;
)
(
	Pdef(\d,
		Pbind(
			\instrument, \slido,
			\octave, Prand([3,4,5], inf),
			\note, Prand([0,4,5,7,10,12], inf),
			\root, Pseq([0,3,-2].stutter(8*8), inf),
			\dur, 0.2,
			\amp, 2.9,
			\attack, 0.005,
			\release, 0.4,
			\wobf, 0.3,
		)
	).play;
)

/*
further exploration
mouse control

*/
