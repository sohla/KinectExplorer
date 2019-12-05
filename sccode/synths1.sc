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
