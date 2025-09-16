(
SynthDef( \double, { |out=0, amp=0.7, atk=0.01, dcy=0.1, sus=0.1, rel=0.1, gate=1, frq=111|
	var env = EnvGen.ar(Env.adsr(atk,dcy,sus,rel), MouseButton.kr(0,1).round);
	var move = Slope.kr(MouseX.kr(0,0.5,\linear,0.5)).abs;
	var trig = MouseButton.kr(0,1,1);
	var sig = PinkNoise.ar(move.lag(move.lincurve(0.0,0.5,1.2,0.1,-7)) + env);
	Out.ar(out, sig !2 * amp);
}).add
)
Synth(\double)