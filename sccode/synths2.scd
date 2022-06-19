

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
        VOsc.ar(bufoffset+x, [80, 81] * 0.5, [LFNoise2.kr(12.1,0.5), LFNoise2.kr(20.2,0.5)], 0.3)
    )
}).play(s,[\out, 0, \bufoffset, 0]);
)




(
s.waitForBoot({
    var amplitudes = [0, 1, 1, -2, 1];
    var wavs = [
        Wavetable.chebyFill(256+1, amplitudes, normalize: true, zeroOffset: true),
        Wavetable.chebyFill(256+1, amplitudes, normalize: true, zeroOffset: false)
    ];
    b = wavs.collect{ arg wav; Buffer.loadCollection(s, wav) };
    s.sync;
    x = {
        var in = SinOsc.ar(100, 0, SinOsc.kr(1.1, 0, 0.5, 0.5));
        Shaper.ar(b, in ) ++ LeakDC.ar(Shaper.ar(b[1], in))
    }.scope;
})
)
x.free; b.do(_.free); b = nil;



/*
formula-based morphing wavetable synth

inspired by Xfer Records Serum, in particular the "formula parser." VOsc3 doesn't antialias as well as
Serum, but if you stay in the bass for fundamental frequencies it should sound ok.
*/

// allocate buffer memory (do this only once)
// 256 frames of 2048-sample wavetables
(
~samples = 2048;
~frames = 256;
b = Buffer.allocConsecutive(~frames, s, ~samples * 2, completionMessage: { "done".postln; });
)

// fill in buffers
// you can do this multiple times, even live code it while synth is running
(
var formulas, formula;

formulas = (
    // I ported some Serum formulas if you want to experiment
    'lo-fi triangle': { |x, z| round((z * 14 + 2) * x.abs) / (z * 7 + 1) - 1 },
    'harmonic sync': { |x, z| var w = (x + 1) / 2; sin(w * pi) * sin(w * pi * (62 * z * z * z + 2)) },
    'brassy': { |x, z| sin(pi * x.sign * x.abs.pow((1 - z + 0.1) * pi * pi)) },
    'saw/sine reveal': { |x, z| if(x + 1 > (z * 2), x, sin(x * pi)) },
    'i can has kickdrum': { |x, z| sin(pi * z * z * 32 * log10(x + 1.1)) },
    'midpoint mischief': { |x, z| 0.5 * cos(x * 0.5pi) * (x.sin * pi + ((1 - z) * sin(z * pow(x * x, z) * 32pi))) },
    'taffy': { |x, z| sin(x * 2pi) * cos(x * pi) * cos(z * pi * pi * (abs(pow(x * 2, 3) - 1))) },
    // try your own!
    // x is the sample position in the from -1 to 1, and z is the frame position from 0 to 1
);

formula = formulas['taffy'];

b.do { |table, frame|
    var signal, z;
    z = frame / ~frames;
    signal = Signal.fill(~samples, { |j|
        var x;
        x = j / ~samples * 2 - 1;
        formula.(x, z);
    });
    table.loadCollection(signal.asWavetable);
    signal.free;
};
)

(
SynthDef(\bass, {
    var snd, wavetableControl, freq, ffreq;
    freq = \freq.kr(440).varlag(0.1, warp: \exp);
    wavetableControl = MouseX.kr(0,1);//LFNoise2.kr(1).range(0, 1.0) ** 3;
    ffreq = LFNoise2.kr(6.3).exprange(400, 8000);
    snd = VOsc3.ar(b[0].bufnum + (wavetableControl * (~frames - 1)), *freq * [-0.1, 0, 0.1].midiratio);
    snd = snd + (SinOsc.ar(freq * 0.5) * -3.dbamp);
    snd = tanh(snd * 1.4);
    snd = RLPF.ar(snd, ffreq, 0.8);
    snd = snd * Env.adsr(0.1, 0.3, 0.7, 0.1).kr(2, \gate.kr(1));
    snd = Pan2.ar(snd, \pan.kr(0), \amp.kr(0.1));
    Out.ar(\out.kr(0), snd);
}).add;
)

(
Pmono(\bass, *[
    octave: 3,
    amp: 0.4,
    dur: 3.0,
    scale: Scale.minor,
    degree: Pseq([7, 6, 2, 3, 5], inf),
    legato: 1.1
]).play;
)

// contributors so far: nathan ho





// A.Broz: Shepard-Risset glissando demo (2020-10-31)

(
/*
                 ,
                /
             `\_\
                 \
                /O\
               '   '
*/
SynthDef(\shepard, #{ |freq=440, dur=20, direction=1, amp=0.2|
	var partialCount = 4;
	var octRange = 2 ** (partialCount / 2);
	var cycle = 1 / (partialCount * dur);
	var width = if(direction >= 0, 1, 0);
	var sig = partialCount.collect { |n|
		var offset = n / partialCount;
		var phase = (3 * pi / 2) + (2 * pi * offset);
		var vol = SinOsc.kr(cycle, phase).range(0, 1);
		var ratio = VarSaw.kr(cycle, offset, width).exprange(1/octRange, octRange);
		SinOsc.ar(freq * ratio) * vol;
	}.sum;
	sig = sig!2 * (amp / partialCount) * Line.kr(0, 1, 5); // fade in
	sig = JPverb.ar(sig); // reverb
	Out.ar(0, sig);
}).add;

Synth(\shepard,[\dur,5])

~playShep = #{ |fund=300, chord=([1, 5/4, 3/2]), dir=(-1), dur=40, amp=0.1|
	chord.collect { |r| (
		instrument: \shepard,
		freq: fund * r,
		dur: dur,
		direction: dir,
		amp: amp,
	).play };
};
)

// falling chord
~shep = ~playShep.value;

// rising chord
~shep = ~playShep.(100, [1, 1.2, 1.5], 1, 7, 0.1);

// free all
~shep do: _.free;

FreqScope.new;


Pfxb

