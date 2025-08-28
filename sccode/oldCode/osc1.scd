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



//----------------------------------------------------
// QLAB OSC FUN

b = NetAddr("192.168.1.53",53100);
b.sendMsg("/hit/1/start");





// getting QLab repy
OSCFunc.trace(true); // Turn posting on
c.sendMsg("/workspace/A8A2F5B3-A638-43AB-A1BC-DCABF35C87E6/cueLists");
OSCFunc.trace(false); // Turn posting off



// cue qlab
c = NetAddr("192.168.1.60",53000);
c.sendMsg("/workspace/A8A2F5B3-A638-43AB-A1BC-DCABF35C87E6/go", 1);


// make a netowrk cue

//fadeIn and play a hit
(
var cue = 100;
var hit = 6;
var fadeIn = 4;

c.sendMsg("/workspace/A8A2F5B3-A638-43AB-A1BC-DCABF35C87E6/new", "network", cue.asString);
c.sendMsg("/workspace/A8A2F5B3-A638-43AB-A1BC-DCABF35C87E6/cue/"++(cue+1)++"/messageType", 2);
c.sendMsg("/workspace/A8A2F5B3-A638-43AB-A1BC-DCABF35C87E6/cue/"++(cue+1)++"/customString", "/hit/"++hit++"/start");
c.sendMsg("/workspace/A8A2F5B3-A638-43AB-A1BC-DCABF35C87E6/cue/"++(cue+1)++"/continueMode", 1);
c.sendMsg("/workspace/A8A2F5B3-A638-43AB-A1BC-DCABF35C87E6/cue/"++(cue+1)++"/postWait", 0.5);
cue = cue + 1;
c.sendMsg("/workspace/A8A2F5B3-A638-43AB-A1BC-DCABF35C87E6/new", "network", "");
c.sendMsg("/workspace/A8A2F5B3-A638-43AB-A1BC-DCABF35C87E6/cue/"++(cue+1)++"/messageType", 2);
c.sendMsg("/workspace/A8A2F5B3-A638-43AB-A1BC-DCABF35C87E6/cue/"++(cue+1)++"/customString", "/dim 0 "++fadeIn);
)


// talk to go button

c = NetAddr("192.168.1.53",53100);

(
	c.sendMsg("/hit/5/start");
	c.sendMsg("/dim",0,4);
)
(
	c.sendMsg("/dim",1,4);
	{c.sendMsg("/hit/5/stop")}.defer(4)
)

c.sendMsg("/hit/5/stop");

