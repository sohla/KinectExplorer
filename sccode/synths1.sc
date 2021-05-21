(
{
	var fs = Array.makeScaleCps(groundNote: 141.62556530114, type: 'major');
	var as = [1,0.1,0.2,0.02,1,0.3,0.7,0.5];//(1..8).reciprocal;
	var rs = [1];//(1..8).reciprocal;

	fs.size.postln;
	Splay.arFill(16,
		{

			DynKlank.ar(
				`[fs, as, rs], 
				LPF.ar(PinkNoise.ar(0.007),400)
			) * 0.5

		},
		1,
		1,
		0);


}.play;
)


(
SynthDef(\dk_blobi, {|a=100,b=100,c=100,d=100,e=100,f=100,g=100,h=100, amp = 0.5|

	var as = (1..8).reciprocal * 0.1;//Array.makeScaleCps(groundNote: 141.62556530114, type: 'major');
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
    		var f = 74 * 2.pow(i+1) * 0.5;
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
			\ring, Pwhite(0.1,1)
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
