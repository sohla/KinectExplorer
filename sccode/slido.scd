(
var a, c, d, s, z, y;
// reverberated sine percussion
d = 16; // number of percolators
c = 15; // number of comb delays
a = 12; // number of allpass delays
f = 98.midicps ;
p = 0;

play({

	p = [f,f+1] * MouseX.kr(1,2);
		// sine percolation sound :
	s = Mix.ar(Array.fill(d, { |i| SinOsc.ar(p * 0.25,0, LFCub.ar(p,[0,1],0.003 ,0.003) * MouseY.kr(0.001,1,\exponential)) }) );

		// reverb predelay time :
	z = DelayN.ar(s, 0.048);

		// 7 length modulated comb delays in parallel :
	y = Mix.ar(CombL.ar(z, 0.1, LFNoise1.kr(Array.fill(c,{0.03.rand}), 0.04, 0.05), MouseY.kr(1,20)));

		// chain of 4 allpass delays on each of two channels (8 total) :
	a.do({ y = AllpassN.ar(y, 0.050, [0.050.rand,0.050.rand], 1) });

		// add original sound to reverb and play it :
	s+(0.1*y)
}))



// {SinOsc.ar([210,211],0, LFCub.ar([0.4,0.42],[0,1],0.03,0.03))}.play

 var notes = [31,33,35,36,38,40];
	var trig = Impulse.kr(8);
	var p = Dseq([1,0,1,0,1,0,0,1,0,0,1,0,0,1,0,0], inf);
	var pch = Select.kr(MouseX.kr(0, 6).floor.asInteger, notes).midicps;//(31 