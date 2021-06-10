
(
SynthDef(\axx, {|attack = 0.004, release = 0.9, freq = 120, gate = 1, vib = 1|

	var env = EnvGen.ar(Env.perc(attack, release, 1, -7), gate, doneAction: 2);
	var sig = SinOsc.ar(freq * vib, 0, 0.3);
	Out.ar(0, sig * env);

}).add;

)

a = Synth.new(\axx, [\release,20]);

(
	Ndef(\pp,
		Pbind(
			\instrument, \simple,
			\octave, Prand([2,5,6,7,8], inf),
			\note, 30,//Prand([0,2,-2,-4,5,7], inf),
			\root, Pseq([0,12].stutter(12), inf),
			\dur, Prand([1/4,1/4,1/8], inf),
			\dur, 1,
			\amp, 0.5,
			\attack, Pwhite(0.005,0.6, inf),
			\vib, 2
		)
	).play;
)

Pdef(\pp).quant = 0; 
FreqScope.new(1400, 700, 0, server: s);
s.peakCPU
s.meter
Pdef.clear


(
{
	var fs = Array.makeScaleCps(groundNote: 110, type: 'major');
	var as = [1,0.1,0.2,0.02,1,0.3,0.7,0.5];//(1..8).reciprocal;
	var rs = [1];//(1..8).reciprocal;

	fs.size.postln;
	Splay.arFill(16,
		{

			DynKlank.ar(
				`[fs, as, rs], 
				HPF.ar(PinkNoise.ar(0.007),400)
			) * 0.5

		},
		1,
		1,
		0);


}.play;
)


(
SynthDef(\dk_blobi, {|a=100,b=100,c=100,d=100,e=100,f=100,g=100,h=100, amp = 0.5|

	var as = (1..8).reciprocal * 0.7;//Array.makeScaleCps(groundNote: 141.62556530114, type: 'major');
	var fs = [a,b*2,c*4,d*8,e*16,f*32,g*64,h*128].lag(1) ;//(1..8).reciprocal;
	var rs = [1];//(1..8).reciprocal;

	var sig = 	Splay.arFill(16,
	{

		DynKlank.ar(
			`[fs, as, rs], 
			LPF.ar(PinkNoise.ar(0.007),400)
		) * amp

	},
	1,
	1,
	0);

	Out.ar(0,sig.clip(0,1));

}).send(s);

)

a = Synth.new(\dk_blobi);
d = [\a];
a.set(d[0],0.1)

(
    {
    	Splay.ar({|i|
    		var f = 35 * 2.pow(i+1) * 0.5;
    		Pluck.ar(BrownNoise.ar(0.2), Impulse.kr(MouseY.kr(1,100)),  f.reciprocal, f.reciprocal, MouseX.kr(0.1,10),
        coef:MouseY.kr(-0.999, 0.999, lag:1.6))} !2)

    }.play(s)
)


(
	SynthDef("dekator", {|out = 0, freq = 100, amp = 0.5, gate = 1, coef = 0, ring = 1, octave = 2|
		var snd = Splay.ar({|i|
    		var f = freq.cpsmidi * 2.pow(i+octave) * 0.5;
    		Pluck.ar(
    			BrownNoise.ar(0.2), 
    			gate,  
    			f.reciprocal, 
    			f.reciprocal, 
    			ring,
    			coef:coef);
    	} !2);
		Out.ar(0, snd);
	}).add;
)



(
	Pdef(\a,
		Pbind(
			\instrument, "dekator",
			\note, Pseq([0,24,48,73], inf),
			\octave, 2,
			\dur, Pseq([0.5,0.25,0.125,0.125], inf),
			\amp, 0.5,
			\coef, Pwhite(0.8,0.9),
			\ring, 0.1//Pwhite(0.1,1)
		)
	).play(quant:1);
)



(
	Pdef(\b,
		Pbind(
			\instrument, "dekator",
			\note, Pseq([0,24,48,73], inf),
			\octave, 4,
			\dur, 0.5,
			\amp, 0.5,
			\coef, Pwhite(0.2,0.6),
			\ring, Pwhite(1,9)
		)
	).play(quant:1);
)









(
b = {
	var trig, seq, demand, cricket;
	
	// instead of [metro], Impulse.kr is used here. Delta t = 17 ms equates to 58.82 Hz.
	trig = Impulse.kr(MouseX.kr(2.5,26.0));
	
	// the main idea of the following line was to use an approach
	// that uses the same coefficients as described in the pd patch
	// seq = Dseq(Array.fill(41, {|i| if(i<41, {(i+2)/9},{0}) }),inf);
	seq = Dseq(Array.rand(42,1,4),inf);
	demand = Demand.kr(trig,0,seq);
	
	// Implementation of the pd code for pulses including amplitude grow:
	// cricket = EnvGen.ar(Env.new([0, 1, 1, 0], [0.0001, 0.0001, 0]), trig) * demand;
	
	// 2nd implementation: pure data seemed to slightly disobey its own specifications, 
	// so I analysed the waveform and came up with this:
	cricket = EnvGen.ar(Env.new([0, 1, 0], [2/44100, 0]), trig) * demand;
	
	
	cricket = OnePole.ar(cricket, exp(-2pi * (1000 * SampleDur.ir)));
	cricket = (
			// changed the Q factor of the first 3 BPFs to approximate farnells sound 
			BPF.ar(cricket, MouseY.kr(200,19000) + ((0..2)*50), 400.reciprocal, 100)).sum 
			+ BPF.ar(cricket, MouseY.kr(100,17000),250.reciprocal, 42
	);		   
	cricket = ((cricket - OnePole.ar(cricket, exp(-2pi * (400 * SampleDur.ir)))) * 0.5)!2;
}.play;
)





{ MoogFF.ar(LFSaw.ar([55, 55.3], 1, 0.1),MouseX.kr(4, 3398),3) }.play(s);





(
    {
    	Splay.ar({|i|
    		var f = 55 * 2.pow(i+1) * 0.5;
    		Pluck.ar(BrownNoise.ar(0.05), Impulse.kr(MouseY.kr(1,100)),  f.reciprocal, f.reciprocal, MouseX.kr(0.1,10),
        coef:MouseX.kr(-0.999, 0.999, lag:1.6))} !2)

    }.play(s)
)



(
Ndef(\x,{
	a = SinOsc.ar([55,55.5], Ndef(\x).ar * LFNoise1.ar(0.1,3) ,LFNoise1.ar(3,2)).tanh;
	9.do{
		a = AllpassL.ar(a,0.3,{0.2.rand+0.1}!2,5)
	};
	a.tanh * 0.5
}).play

)

(
{
	var fs = Array.makeScaleCps(groundNote: 440, type: 'major');
	var as = [1,0.1,0.2,0.02,1,0.3,0.7,0.5];//(1..8).reciprocal;
	var rs = [1];//(1..8).reciprocal;

	fs.size.postln;
	Splay.arFill(16,
		{

			DynKlank.ar(
				`[fs, as, rs], 
				HPF.ar(PinkNoise.ar(0.007),400)
			) * 0.5

		},
		1,
		1,
		0);


}.play;
)









(
SynthDef(\bell, {
	|fs=1, t60=1, pitchy=1, amp=0.25, gate=1|
	var sig, exciter;
	//exciter = Impulse.ar(0);
	exciter = WhiteNoise.ar() * EnvGen.ar(Env.perc(0.001, 0.05), gate) * 0.05;
	sig = Klank.ar(
		`[
			[1, 2, 2.803, 3.871, 5.074, 7.81, 10.948, 14.421],   // freqs
			[1, 0.044, 0.891, 0.0891, 0.794, 0.1, 0.281, 0.079], // amplitudes
			[1, 0.205, 1, 0.196, 0.339, 0.047, 0.058, 0.047]*t60     // ring times
		],
		exciter,
		freqscale:fs*pitchy);
	// sig = FreeVerb.ar(sig) * amp;
	DetectSilence.ar(sig * amp, 0.001, 0.5, doneAction:2);
	Out.ar(0, sig!2);
}).add
)


// 2. Test a single note
x = Synth(\bell, [\fs, 60.midicps, \t60, 9.177, \pitchy, 8]);


// 3. Test different textures

// glokenspiel
(
Pbind(
	\instrument, \bell,
	\fs, Pseq( (60..72), 1).midicps,
	\t60, 6,
	\pitchy, 4,
	\dur, 0.25
).play;
)

// tubular bells
(
Pbind(
	\instrument, \bell,
	\fs, Pseq( (60..72), 1).midicps,
	\t60, 9,
	\pitchy, 1,
	\dur, 1
).play;
)

// xilophone
(
Pbind(
	\instrument, \bell,
	\fs, Pseq( (60..72), 1).midicps,
	\t60, 1,
	\pitchy, 4,
	\dur, 0.25
).play;
)

// marimba
(
Pbind(
	\instrument, \bell,
	\fs, Pseq( (60..72), inf).midicps,
	\t60, 0.5,
	\pitchy, 0.25,
	\dur, 0.25
).play;
)




