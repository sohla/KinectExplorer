(
SynthDef(\frog, {|attack = 0.004, release = 1.9, freq = 120, gate = 1, vib = 1, amp = 0.1|

	var env = EnvGen.ar(Env.perc(attack, release, 1, -7), gate, doneAction: 2);
	var sig = MoogFF.ar(
		LFSaw.ar(
			[freq + (freq * LFCub.ar(freq*MouseY.kr(0.5, 3, lag: 0.7), 0, 0.49, 0.006) ), 
			freq + (freq * LFCub.ar(freq*MouseY.kr(0.5, 3, lag: 0.7), 0, 0.49, 0.006) )], 
			[0,0.5], 
			0.5),
		env.linlin(0,1,500, MouseX.kr(100, 10000, lag: 0.3)),
		-4
	);
	var sub = SinOsc.ar(freq, [0,1.36], 0.5);
	Out.ar(0, (sig + sub) * env * amp);
}).add

)

s.avgCPU
s.meter

a = Synth.new(\frog, [\release,2]);

(
	Ndef(\frogPtn,
		Pbind(
			\instrument, \frog,
			\octave, Pseq([2,4,5,4,5] + 1, inf),
			\note, Pseq([0,7,4], inf),
			\root, Pseq([0,4,-1, 2].stutter(20), inf),
			\dur, Pseq([1/5, 1/5, 1/2.5, 1/5] * 10, inf),
			\amp, 0.1,
			\attack, Pwhite(2.001,0.006, inf),
			\release, Pwhite(29.1,16.9, inf),
		)
	).play;
)

(
	Ndef(\frogPtn,
		Pbind(
			\instrument, \frog,
			\octave, Pseq([2,4,5,4,5], inf),
			\note, Pseq([0,7,11,16], inf),
			\root, Pseq([4,-1, 2,0].stutter(20), inf),
			\dur, Pseq([1/5, 1/5, 1/2.5, 1/5], inf),
			\amp, 0.5,
			\attack, Pwhite(0.001,0.006, inf),
			\release, Pwhite(0.3,1.9, inf),
		    \rel, Pkey(\release),
		    \vib, 50,//Pwhite(1.0,16.0),
		)
	).play;
)
Ndef(\frogPtn).fadeTime = 15;
Ndef(\frogPtn).end;


