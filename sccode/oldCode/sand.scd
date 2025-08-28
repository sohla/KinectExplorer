(
SynthDef(\sand, {|out = 0, freq = 160, amp = 0.3, attack = 0.01, decay = 4.02, sustain = 0.8, release = 0.9, gate = 1, ns = 9|

	var enva = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
	var envb = EnvGen.ar(Env.sine(attack + decay, 1), gate);
	var df = WhiteNoise.kr(ns);
	var sig = GrainFM.ar(2, Impulse.kr(MouseY.kr(0.8,80)), MouseX.kr(0.001,1, \exponential), [freq + df, freq - df], freq * [2,3.03] * 4, 0.1 * enva);
	var sub = SinOsc.ar([freq - df, freq + df], 0, 0.6);
	Out.ar(out, (sig * sub) + (sub * 0.1) * 0.7 * amp * enva);

}).add;

)

a = Synth.new(\sand);
s.peakCPU
s.meter
s.unmute
(
		Pdef(\a,
			Pbind(
				\instrument, \sand,
				\octave, Prand([2,4,5,6], inf),
				\note, Prand([0,4,5,7,10,12], inf),
				\root, Pseq([0,3,-2].stutter(8*8), inf),
				\dur, Pseq([0.2 ,Rest(0.1), 0.4, 0.4], inf),
				\amp, 0.7,
				\attack, Pwhite(0.001, 0.06),
				\decay, 0.9,
				\release, 1.1,
				\ns, Pwhite(2,20),
			)
		).play;
)


