(
SynthDef(\buk, {|out=0, att=0.004, dec=0.2, sus=0.8, rel=0.9, freq = 100, gate = 1, coef=0.2, dd = 1|

	var env = EnvGen.ar(Env.adsr(att, dec, sus, rel), gate, doneAction: 2);
	var trig = Impulse.ar(XLine.ar(Rand(25,40), Rand(1,3) , dd) * 0.6);
	//var trig = MouseX.kr(0.1,100);
	var sig = Pluck.ar(
    		BrownNoise.ar(0.2),
    		trig,
    		freq.reciprocal,
    		freq.reciprocal,
    		Demand.ar(trig, 0,Dwhite(1, 10)),
        	coef: coef
	);

	Out.ar(0, sig * env);

}).add;



	Ndef(\glowPtn,
		Pbind(
			\instrument, \buk,
			\octave, Pxrand([3,4,5], inf),
		\note, Pseq([0,3,8,7,5,5,4,0,-2,4,0,-5,-2,-2].stutter(3), inf),
			\root, Pseq([0,5].stutter(14*3), inf),
			\dur, 0.8,
			\amp, 0.1,
			\att, Pwhite(0.006,0.009, inf),
			\rel, Pwhite(0.5,1.6, inf),
		\dd, Pkey(\dur) + Pkey(\rel),
		\coef, Pwhite(0.5,0.9)


		)
	).play;
)

