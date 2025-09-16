(

SynthDef(\synth0302, { |out=0, freq= 100, gate=1, att=0.01, dec=0.01, sus=0.9, rel=3.3, amp=1, am=0.05|
    var env = EnvGen.kr(Env.adsr(att, dec,sus, rel), gate, levelScale: amp, doneAction: 2);
	var trig = Trig.ar(gate, 0.1).slew(0.001,0.001);

	var spr = Spring.ar(trig,freq * 0.000005,0.00001).range(0.98,1.02);
	var spa = Spring.ar(trig,am,0.00001).range(0.2,1);

	var sig = Splay.ar( {SinOsc.ar(exprand(freq, freq+(freq/32)) * spr,0,0.3)} !8);
	Out.ar(out, sig * env * spa);

}).add;
)


(

Pdef(\a,
	Pbind(
		\instrument, \synth0302,
		\octave, Pxrand([2,3,4,5,6], inf),
		\degree, Prand([0,5,12,15,17,19], inf),
		\root, Pseq([0].stutter(24), inf),
		\dur, Pseq([0.2,Rest(1.6)] * 1, inf),
		\att, Pwhite(1.48, 1.95),
		\dec, 0.1,
		\sus, 0.8,
		\rel, 12,
		\amp, Pkey(\octave).linlin(2,6,0.5,0.08) * 4,
		\am, Pwhite(0.02,0.05)

	)
);

Pdef(\a).play;


)

s.freqscope
ServerOptions.devices
Server.local.options.inDevice
Server.local.options.outDevice

(

var input = ServerOptions.devices.indexOfEqual("SERIES 208i");
var output = ServerOptions.devices.indexOfEqual("SERIES 208i");
var o = Server.local.options;

o.inDevice = ServerOptions.devices[input];
o.outDevice = ServerOptions.devices[output];

s.reboot;
);




Signal.chebyFill(513,[1,0.5,0.5,0.01]).plot