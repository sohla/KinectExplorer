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





b = NetAddr("192.168.1.55",57000);

b = NetAddr("127.0.0.1",57000);

( 
{
b.sendMsg("/inputSettings/pixelpoint/persistance", 1);
b.sendMsg("/inputSettings/clear/on", 1);0.1.wait;
b.sendMsg("/inputSettings/pixelpoint/persistance", 15);
b.sendMsg("/inputSettings/clear/on", 0);
}.fork
)

b.sendMsg("/inputSettings/blur/blur", 10);

b.sendMsg("/inputSettings/nearfar/far", 255);
b.sendMsg("/inputSettings/nearfar/far", 100);


b.sendMsg("/inputSettings/realtime/realtime", 0);
b.sendMsg("/inputSettings/realtime/realtime", 1);
b.sendMsg("/inputSettings/pixel_recorder/recording", true);
b.sendMsg("/inputSettings/pixel_recorder/recording", false);
b.free;









(
	SynthDef(\basicSin, {|out = 0, freq = 160, amp = 0.1|
		var sig = SinOsc.ar(freq, 0, amp)!2;
		Out.ar(out, sig);

	}).add;


)


