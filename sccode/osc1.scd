n= NetAddr("127.0.0.1", 57120);

(
SynthDef(\ss, {|out = 0|
	var sig = SinOsc.ar(111/2,0,0.3);

	Out.ar(0,sig);

}).send(s);
)


s.sendMsg('/s_new', \ss, 1000, 1, 0);


n.sendMsg('/s_new', \ss, 1000, 1, 0);
 





a = Synth.new(\ss);
a.free



o = OSCFunc({ |msg, time, addr, recvPort|
	[msg, time, addr, recvPort].postln;
}, '/gate0');

o.free;



o = OSCFunc({ |msg, time, addr, recvPort|
	[msg, time, addr, recvPort].postln;
}, '/poscr');

o.free;