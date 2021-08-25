( 
SynthDef(\voiv, {|out = 0, attack = 0.01, decay = 0.3, sustain = 0.8, release = 0.9, freq = 120.0, gate = 1, amp = 1.0, wobf = 1, woba = 0.003, verb = 1, voice = 0.5|

	var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
	var fe = EnvGen.ar(Env.perc(0.01,decay), gate);
	var fd = EnvGen.ar(Env.perc(0.01,decay * 0.6), gate);
	var fm = LFCub.ar(wobf * (1-fd),0,woba,1);//0.013
	var fs = [1,2,3,5,10] * freq * fm;
	var as = [1,0.5,0.3,0.1,1];
	var rs = [1,1,1,1,0.01];
	var tone = Saw.ar([freq, freq + (freq * 0.01) ],0.3 * fe);
	var sig = Splay.arFill(7,{
			DynKlank.ar(
				`[fs, as, rs], 
				PinkNoise.ar(0.08) * fe
			) * 0.5
		},
		1,
		1,
	0);

	tone = tone.blend( SinOsc.ar(freq, pi, fd), voice);
	sig = sig.blend(tone,0.47);

	Out.ar(out, sig * amp * env);

}).add;

)

a = Synth.new(\voiv, [\freq, 540]);

s.meter
(
Pdef(\a,
	Pbind(
		\instrument, \voiv,
		\octave, Pseq([3,4,5,3,6,4,5,3,5,3,6,3,5], inf),
		\note, Pseq([0,3,8,7], inf),
		\root, Pseq([0,3,1,4].stutter(13), inf),
		\dur, Pseq([1/5,Rest(1/5),1/5,1/2.5,1/2.5,1/5,1/1.25,1/5,1/5,1/10,1/10,1/10,1/10], inf),
		\amp, 0.8, 
		\attack, Pwhite(0.001,0.03),
		\decay, Pwhite(0.01,2.92),
		\wobf, Pwhite(4,9),
		\woba, Pwhite(0.003,0.05),
		\voice, Pwhite(0.0,1.0),
		// \verb, Pwhite(0.1,10),
	)
).play;
)