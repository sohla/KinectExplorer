(
SynthDef(\blaz, {|out = 0, freq = 120, amp = 0.5, attack = 0.01, decay = 0.3, sustain = 0.1, release = 0.9, gate = 1, harm = 1|

	var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
	var sig = (BHiPass.ar(
		LFNoise2.ar(2)**1.4,
		[freq, freq + (freq * 0.01)],
		MouseX.kr(0.001,0.3,\exponential),
		MouseY.kr(20,10900,\exponential) - freq)
	).tanh  * 0.5;
	var vib = LFCub.ar(freq * harm, 0, env, 1);
	Out.ar(out, LeakDC.ar(sig) * amp * env * vib);
}).add;
)

(
	Pdef(\a,
		Pbind(
			\instrument, \blaz,
			\octave, Prand([2,3,4,5], inf),
			\note, Prand([0,4,5,7,10,12], inf),
			\root, Pseq([0,3,-2].stutter(8*8), inf),
			\dur, 1/8,
			\amp, 0.3,
			\harm, Prand([1,2,3,4,5,6,7,8], inf)
		)
	).play;
)

FreqScope.new(1400, 700, 0, server: s);
s.peakCPU
s.meter
Pdef.clear