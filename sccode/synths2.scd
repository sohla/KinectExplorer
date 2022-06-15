

(

SynthDef(\improv, { |out=0, ad=1, dd=1, adp=1, ddp=1, minf=100, maxf=660, as=0.5, ds=0.6|

	var gen = Gendy1.ar(ad, dd, adp, ddp, minf, maxf, as, ds, mul: 0.1);

	var splay = Splay.ar( {Gendy1.ar(ad, dd, adp, ddp, Lag.kr(minf,10), Lag.kr(maxf,1), as, ds, mul: 0.1)} !10);
	Out.ar(out, splay);
}).add;

VarGui(
    synthCtr:[
    	\ad, [0, 6, \lin, 1, 1], 
    	\dd, [0, 6, \lin, 1, 1],
    	\adp, [0.01, 1.0, \exp, 0.01, 1],
    	\ddp, [0.01, 1.0, \exp, 0.01, 1],
    	\minf, [10, 500, \exp, 1, 100],
    	\maxf, [10, 1000, \exp, 1, 660],
    	\as, [0.0, 1.0, \lin, 0.01, 0.5],
    	\ds, [0.0, 1.0, \lin, 0.01, 0.5]
    ], 
    synth: \improv
).gui;

)



(
{
	var trig, snd, freqs;
	trig = Impulse.ar(4);
	freqs = (60.5 + [0, 2, 4, 5, 7, 9, 10]).midicps;
	snd = Pluck.ar(Hasher.ar(Sweep.ar(trig)) * -10.dbamp, trig, freqs.reciprocal, freqs.reciprocal, 0.9, 0.5);
	snd = LeakDC.ar(snd).sum;
	snd = MoogFF.ar(snd, LFNoise2.kr(1).linexp(-1, 1, 150, 10000), 0);
	snd = snd ! 2;
	snd;
}.play(fadeTime: 0);
)




(
s = Server.local;
// allocate and fill tables 0 to 7
8.do({ arg i;
    var n, a;
    // allocate table
    s.sendMsg(\b_alloc, i, 1024);
    // generate array of harmonic amplitudes
    n = (i+1)**2;
    a = Array.fill(n, { arg j; ((n-j)/n).squared.round(0.001) });
    // fill table
    s.performList(\sendMsg, \b_gen, i, \cheby, 7, a);
    // the argument '7' here is a flag for the \sine1 wave fill method -
    // see the "Wave Fill Commands" section in the Server Command Reference 
});
)

(
SynthDef("help-VOsc",{ arg out=0, bufoffset=0;
    var x;
    // mouse x controls the wavetable position
    x = MouseX.kr(0,7);
    Out.ar(out,
        VOsc.ar(bufoffset+x, [520, 521] * 0.5, [LFNoise2.kr(12.1,0.5), LFNoise2.kr(20.2,0.5)], 0.3)
    )
}).play(s,[\out, 0, \bufoffset, 0]);
)

