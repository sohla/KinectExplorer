( 
SynthDef(\rfrmge, { |out, gate = 1, amp = 0.3, freq = 300, attack = 0.001, decay = 0.001, sustain = 0.5, release = 0.1|

    var enva = EnvGen.ar(Env.adsr(attack, decay, sustain, release), doneAction:2);
    var trig = Impulse.kr(7.6);
    var pch = Demand.kr(trig, 0, Drand(freq - 125, freq + 125, inf));
    var freqdev = WhiteNoise.kr(20);
    var sig = GrainFM.ar(
        2,
        trig, 
        MouseY.kr(0.1,0.02),// LFCub.ar(MouseX.kr(1,100),0,0.0125,0.0375),
        [440 + freqdev, 430 + freqdev],
        440 + freqdev * 3,

        //[freq * 0.99, freq * 1.02] , 
        // LFTri.ar(MouseY.kr(1,10000),0,10,5),
        // LFPulse.ar(freq / 2, [0,pi], 0.5)
    );

    var dig = Saw.ar([freq,freq+2],enva);
        Out.ar(out, sig * amp)
}).add;

)
x = Synth(\rfrmge, [\freq, 740, \sustain, 0, \decay, 0.5])
y = Synth(\rfrmge, [\freq, 540])

s.meter
s.scope
// use built-in env


( 
Pdef(\a,
    Pbind(
        \instrument, \rfrmge,
        \octave, Pseq([3,4,6,7], inf),
        \note, Pseq([0,4,-3,-3].stutter(6), inf),
        \root, Pseq([0].stutter(18), inf),
        \dur, 0.3,
        \amp, 0.4,
        // \attack, 0.01,
        \decay, 0.9,
        \sustain, 0.0,
        // \release, 0.9 
    )
).play;
)





