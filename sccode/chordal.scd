(
SynthDef(\chordal, {|out = 0, freq = 120, amp = 0.5, attack = 0.01, decay = 0.03, sustain = 0.4, release = 0.9, gate = 1, harm = 1|

	var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
	var	exc = LFNoise2.ar(MouseX.kr(200,500,\exponential), MouseY.kr(0.001,0.1), 1); 
	var sig = (DynKlank.ar(`[
			Array.series(12, [freq,freq+0.3], [freq,freq+0.5] * harm),
			Array.geom(12,1,MouseY.kr(0.1,1.2)),
			Array.fill(12, MouseX.kr(1.0,0.1))
		], exc) * 0.02).softclip;
	var tone = SinOsc.ar([freq, freq + (freq * 0.003)] * 1,0,0.2 * env);
	Out.ar(out, LeakDC.ar(sig + tone) * amp * env);
}).add;

SynthDef(\mouseX, { |bus| Out.kr(bus, MouseX.kr(0,1.0))}).add;
SynthDef(\mouseY, { |bus| Out.kr(bus, MouseY.kr(0,1.0))}).add;

)


a = Synth.new(\chordal,[\freq, 68 *2]);

(

	var mx = Bus.control(s,1);
	var my = Bus.control(s,1);
	var mxs = Synth(\mouseX, [\bus, mx.index]);
	var mys = Synth(\mouseY, [\bus, my.index]);

	Pdef(\a,
		Pbind(
			\instrument, \chordal,
			\octave, Prand([3,4,5], inf),
			\note, Prand([0,3].stutter(8), inf),
			\root, Pseq([0,-2].stutter(8*8), inf),
			\dur, Pseq([1.5,Rest(1.5),1,1,2].reciprocal * 0.2,inf),
			\amp, 0.6,
			\attack, 0.005,
			\release, Prand([0.2,0.3,0.1,0.26,0.12,0.28,0.21,2.2],inf),
			\harm, Prand([1,2,3,4,5,6,7,8,9],inf)
		)
	).play;
)

(
	var mx = Bus.control(s,1);
	var my = Bus.control(s,1);
	var mxs = Synth(\mouseX, [\bus, mx.index]);
	var mys = Synth(\mouseY, [\bus, my.index]);

	Pdef(\a,
		Pbind(
			\instrument, \chordal,
			\octave, Prand([3,5,6], inf),
			\note, Pseq([0,2,0,2,-2,-5,-7,-3,-5], inf),
			\root, Pseq([0].stutter(8*8), inf),
			\dur, Pseq([1.5,Rest(1.5),1,1,2] * 0.125,inf),
			\amp, 0.9,
			\attack, Pwhite(0.5,1),
			\release, Prand([4.9,2.2] * 0.25,inf),
			\harm, Prand([1,2,3,4],inf)
		)
	).play;


	Pdef(\b,
		Pbind(
			\instrument, \chordal,
			\octave, Prand([8,9], inf),
			\note, Pseq([0], inf),
			\root, Pseq([0,2].stutter(45), inf),
			\dur, Pseq([1,Rest(1)] * 0.125 * 0.5,inf),
			\amp, 0.04,
			\attack, Pwhite(0.005,0.04),
			\release, Prand([0.09,0.12,0.17,0.12,14.12] * 0.25,inf),
			\harm, Prand([1,2,3,4],inf)
		)
	).play;


	Pdef(\c,
		Pbind(
			\instrument, \chordal,
			\octave, Prand([6], inf),
			\note, Pseq([0], inf),
			\root, Pseq([0,-2,5,4,7,9,5,4].stutter(2), inf),
			\dur, Pseq([1, Rest(1)] * 0.75 * 0.5,inf),
			\amp, 0.2,
			\attack, Pwhite(0.05,0.4),
			\decay, 0.5,
			\sustain, 0.6,
			\release, 9.6,
			\harm, Prand([1,2,3,4]*0.5,inf)
		)
	).play;

)