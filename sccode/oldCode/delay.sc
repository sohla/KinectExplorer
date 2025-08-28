(
		var output = ServerOptions.devices.indexOfEqual("USB Audio Device");
		var input = ServerOptions.devices.indexOfEqual("USB Audio Device");

		o = Server.local.options;
		o.inDevice = ServerOptions.devices[input];
		o.outDevice = ServerOptions.devices[output];
		o.memSize = 8192 * 2;
		o.numInputBusChannels = 2;
		o.numOutputBusChannels = 2;
		s.reboot;
)
s.quit
s.meter
(
SynthDef(\delay,{|out=0, fb=0.3, dt=0.2, gate=1, pr=1.0, amp=0.9|
	var in = PitchShift.ar(SoundIn.ar(0), 0.8, pr);
	var li = LocalIn.ar(1);
	var ft = HPF.ar(LPF.ar(in, 12000), 120);
	var dly = DelayL.ar(ft + (li * fb), 0.8, dt );
	var mix = dly + ft;
	var env = EnvGen.ar(Env.asr(2.0,1.0,1.0),gate);

	LocalOut.ar(mix);
	Out.ar(out, mix!2 * env * amp);
}).add;


)

(
var delay = Synth(\delay, [\fb, 0.3,\dt, 0.8, \gate, 0]);
OSCFunc({|msg| delay.set(\gate, msg[1])},"\delay");
OSCFunc({|msg| delay.set(\dt, msg[1])},"\dt");
OSCFunc({|msg| delay.set(\pr, msg[1])},"\pr");
OSCFunc({|msg| delay.set(\amp, msg[1])},"\amp");

)