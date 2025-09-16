(
SynthDef(\synth18, { |out=0, freq=100, gate=1, att=1.03, dec=0.2, sus=0.8, rel=0.1, amp=0.3, mx = 1, my = 0|
	var env = EnvGen.ar(Env.adsr(att, dec,sus, rel), gate, doneAction:2);
	var in = LocalIn.ar(2);
	var sig = Splay.arFill(8, {|i|
		var imx = MouseX.kr(0.1,10, \exponential);//mx * (i+1).reciprocal;
		var imy = 1;//MouseY.kr(-1,1);//my * (i+1).reciprocal;
		SinOsc.ar(freq * (1 + (0.001 * (i+1)))).pow(imx).cubed.cubed.scaleneg(imy);
	});

	var senv = EnvGen.ar(Env.adsr(att, dec,sus, rel), gate, 0.5);
	var sub = SinOsc.ar([freq, freq + (freq * 0.009)] , 0, senv);
	var verb = LeakDC.ar(CombC.ar(sig + (in * 0.2),0.2,[0.064,0.063], 1));
	LocalOut.ar(sig +  verb);
	Out.ar(out, ((sig) + sub + verb) * amp * env * 0.5);
}).add;

)

(
a = Synth(\synth18, [\freq, 47.midicps, \amp, 0.2]);
b = Synth(\synth18, [\freq, 54.midicps, \amp, 0.2]);
c = Synth(\synth18, [\freq, 58.midicps, \amp, 0.3]);
d = Synth(\synth18, [\freq, 35.midicps, \amp, 0.5]);
f = Synth(\synth18, [\freq, 63.midicps, \amp, 0.1]);
)

(
a = Synth(\synth18, [\freq, 35.midicps, \amp, 0.5]);
b = Synth(\synth18, [\freq, 47.midicps, \amp, 0.3]);
// c = Synth(\synth18, [\freq, 66.midicps, \amp, 0.1]);
// d = Synth(\synth18, [\freq, 71.midicps, \amp, 0.05]);
// f = Synth(\synth18, [\freq, 76.midicps, \amp, 0.01]);
)

(
Pbindef(\ap,
		\instrument, \synth18,
		\dur, Pseq([0.2, 0.1, 0.1, 0.2, Rest(0.1), 0.1], inf),
		\note, Pseq([0,3,8,7,12,5,2,0,3], inf),
		\octave, Pseq([3].stutter(9), inf),
	\root, Pseq([0,3,1,-2].stutter(18), inf),
		\mx, Pwhite(1,100),
	\att, 0.001,
	\sus, 0.3,
		\my, Pwhite(-1,1),
	\amp,0.2

).play(quant:0.2);


)
