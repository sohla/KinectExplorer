(
SynthDef(\blaz, {|out = 0, freq = 120, amp = 0.5, attack = 0.01, decay = 0.03, sustain = 0.8, release = 0.9, gate = 1, harm = 1, rq = 0.2, fa = 10000|

	var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
	var sig = (BHiPass.ar(
		LFNoise2.ar(2)**1.4,
		[freq, freq + (freq * 0.01)],
		rq, //MouseX.kr(0.001,0.3,\exponential),
		fa - freq)
	).tanh  * 0.5;
	var vib = LFCub.ar(freq * harm, 0, env, 1);
	Out.ar(out, LeakDC.ar(sig) * amp * env * vib);
}).add;

SynthDef(\mouseX, { |bus| Out.kr(bus, MouseX.kr(0,1.0))}).add;
SynthDef(\mouseY, { |bus| Out.kr(bus, MouseY.kr(0,1.0))}).add;

)

(

	var mx = Bus.control(s,1);
	var my = Bus.control(s,1);
	var mxs = Synth(\mouseX, [\bus, mx.index]);
	var mys = Synth(\mouseY, [\bus, my.index]);

	Pdef(\a,
		Pbind(
			\instrument, \blaz,
			\octave, Prand([2,3,4,5], inf),
			\note, Prand([0,4,5,7,10,12], inf),
			\root, Pseq([0,3,-2].stutter(8*8), inf),
			\dur, 1/6,
			\amp, 0.3,
			\harm, Pfunc{ my.getSynchronous.linlin(0, 1.0, 1, 8).floor},
			\attack, 0.045,
			\release, 2.0,
			\rq, Pfunc{ mx.getSynchronous.linlin(0, 1.0, 0.01, 0.3)},
			\fa, Pfunc{ my.getSynchronous.linlin(0, 1.0, 20, 19900)},
		)
	).play;
)

FreqScope.new(1400, 400, 0, server: s);
s.peakCPU
s.meter
Pdef.clear



