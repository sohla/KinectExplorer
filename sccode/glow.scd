

(
SynthDef(\glow, {|attack = 0.004, release = 0.9, freq = 100, gate = 1, vib = 1|

	var env = EnvGen.ar(Env.perc(attack, release, 1, -7), gate, doneAction: 2);
	 var trig = Impulse.ar(XLine.ar(40, 1, attack + (release * 0.5)));
	//var trig = MouseX.kr(0.1,100);
	var sig = Splay.ar({|i|
    	var f = freq * 2.pow(i+1) * 0.5;
    	Pluck.ar(
    		BrownNoise.ar(0.2), 
    		trig,  
    		// // Impulse.ar( LFCub.ar([0.31,0.312], 0, 50, 60)),  
    		// // Impulse.ar( 55), Demand
    		// BrownNoise.ar(0.2,0.19),
    		f.reciprocal, 
    		f.reciprocal, 
    		Demand.ar(trig, 0,Dwhite(1, 10)),
    		// MouseX.kr(0.1,10),
        	coef:MouseY.kr(-0.999, 0.999, lag:1.6)  
        	// coef:Demand.ar(trig, 0,Dwhite(0.65, 0.85))
        )} !2);


	Out.ar(0, sig * env);

}).add;

)
s.meter
s.peakCPU
a = Synth.new(\glow, [\release,7]);

(
	Ndef(\glowPtn,
		Pbind(
			\instrument, \glow,
			\octave, Prand([2,4,5,6], inf),
			// \note, Prand([0,2,5,9,11], inf),
			\note, Prand([0,4,7], inf),
			\root, Pseq([0,2].stutter(16), inf),
			\dur, Prand([0.5], inf),
			\dur, 0.5,
			\amp, 0.1,
			\attack, Pwhite(6,9, inf),
			\release, Pwhite(5,6, inf),
		)
	).play;
)


{Blip.ar(1,30)}.scope