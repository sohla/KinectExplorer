( 
SynthDef(\rfrmge, { |out, gate = 1, amp = 0.6, freq = 300, attack = 0.001, decay = 0.001, sustain = 0.0, release = 0.001|

    var enva = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);


    var sig = GrainFM.ar(
        2,
        Impulse.kr(freq / 2), 
        0.05,//LFCub.ar(MouseX.kr(1,100),0,0.0125,0.0375),
        freq, freq * 2, 
        LFTri.ar(MouseY.kr(1,10),0,10,5),
        LFPulse.ar(freq / 2, [0,pi], 0.5));

    var dig = Saw.ar([freq,freq+2],enva);
        Out.ar(out, dig * enva * amp)
}).add;

)
s.meter
s.scope
// use built-in env
x = Synth(\rfrmge, [\freq, 1240])
y = Synth(\rfrmge, [\freq, 540])


(
Pdef(\rfrmgea,
    Pbind(
        \instrument, \rfrmge,
        \octave, Pseq([[3,5],6,7], inf),
        \note, Pseq([0,4,-3,-3].stutter(6), inf),
        \root, Pseq([0].stutter(18), inf),
        \dur, 0.3,
        \amp, 0.9, 
    )
).play;
)