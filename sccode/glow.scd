(
SynthDef(\glow, {|attack = 0.004, release = 0.9, freq = 100, gate = 1, vib = 1, coef = 0.0|

	var env = EnvGen.ar(Env.perc(attack, release, 1, -7), gate, doneAction: 2);
	 var trig = Impulse.ar(XLine.ar(40, 1, attack + (release * 0.5)));
	//var trig = MouseX.kr(0.1,100);
	var sig = Splay.ar({|i|
    	var f = freq * 2.pow(i+1) * 0.5;
    	Pluck.ar(
    		BrownNoise.ar(0.2), 
    		trig,  
    		f.reciprocal, 
    		f.reciprocal, 
    		Demand.ar(trig, 0,Dwhite(1, 10)),
        	coef: coef//MouseY.kr(-0.999, 0.999, lag:1.6)  
        )} !2);


	Out.ar(0, sig * env);

}).add;

)
s.meter
s.peakCPU
a = Synth.new(\glow, [\release,2]);

(
	Ndef(\glowPtn,
		Pbind(
			\instrument, \glow,
			\octave, Prand([2], inf),
			// \note, Prand([0,2,5,9,11], inf),
			\note, Prand([0], inf),
			\root, Pseq([0,-3,-5,-6,-3].stutter(16), inf),
			\dur, Prand([0.5], inf),
			\dur, 0.5,
			\amp, 0.1,
			\attack, Pwhite(6,9, inf),
			\release, Pwhite(5,6, inf),
		)
	).play;
)



(
	Ndef(\glowPtn,
		Pbind(
			\instrument, \glow,
			\octave, Prand([2,4,6], inf),
			\note, Pseq([0,3,7,11,12], inf),
			\root, Pseq([0,-3,2,-1].stutter(16), inf),
			\dur, Prand([0.5], inf),
			\dur, 0.2,
			\amp, 0.1,
			\attack, Pwhite(0.01,0.02, inf),
			\release, Pwhite(0.3,0.6, inf),
			\coef, Pwhite(0.6,0.01, inf)
		)
	).play;
)