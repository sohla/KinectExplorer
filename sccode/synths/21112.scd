(
SynthDef(\synth21112, { |out=0|
	var spd = MouseY.kr(0.03,0.09);
	var nsa = RHPF.ar(BrownNoise.ar(0.1), LFSaw.ar(spd*2,1).linexp(-1,1,20,19000));
	var sig = SinOsc.ar(spd,LFPar.ar(spd,0,pi) *[1,1.02], nsa);
	Out.ar(out, sig);
}).play;
)
