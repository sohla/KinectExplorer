(
SynthDef(\bleep, { |freq=1000, rate=1, width=0.9|
	var sig = LFPulse.kr(rate * 6, 0, width) * Pulse.ar([freq, freq + 1], 0.1, 0.1);
	Out.ar(0, sig);
}).add

)




Synth.new(\bleep, [\freq,1000, \rate, 0.5, \width, 0.9]);
Synth.new(\bleep, [\freq,1440, \rate, 0.9, \width, 0.4]);
Synth.new(\bleep, [\freq,2000, \rate, 1.2, \width, 0.1]);


//Fig 58.7: Red alert
//Complete patch, saw + second harmonic, resonators, distortion and post filters to create 
//fixed resonance. Contains the subpatch shown in fig 58.6.

(
	SynthDef(\red, { |freq = 100|
 
	var env, redAlert, dfbe, aIn, bIn, cIn, aOut, bOut, cOut;
 
	# aIn, bIn, cIn = LocalIn.ar(7).clumps([5,1,1]);
 
	env = [
		EnvGen.ar(Env.new([0,1,1,0], [0.9, 0.3, 0.0])), 
		EnvGen.ar(Env.new([0,1,1,0], [0.01, 0.88, 0.01]))
	];
	env[0] = LFSaw.ar(env[0].sqrt * freq + freq, 1, 0.5, 0.5);
	env[0] = (env[0] - 0.5) + ((env[0] * 2 * 2pi).cos * 0.3);
	redAlert = (env[0] - OnePole.ar(env[0], exp(-2pi * (1 * SampleDur.ir)))) * env[1];
	redAlert = redAlert + (cIn * 0.006) * 0.2;
 
 
	// fig 58.6: Delay feedback element
	dfbe = 0!6;
	redAlert = redAlert + (aIn * 0.7);
	5.do{|i| dfbe[i] = DelayN.ar(redAlert[i], 0.1, [0.015, 0.022, 0.035, 0.024, 0.011][i])};
	aOut = dfbe[0..4]; 
 
	redAlert = redAlert[0..4].sum;
	redAlert = (redAlert - OnePole.ar(redAlert, exp(-2pi * (12 * SampleDur.ir))));
 
	dfbe[5] = redAlert + (bIn * 0.7);
	dfbe[5] = DelayN.ar(dfbe[5], 0.1, 0.061);
	# bOut, cOut = dfbe[5]!2;
	LocalOut.ar(aOut ++ bOut ++ cOut);
 
	redAlert = Clip.ar(redAlert * 4, -1, 1);
	redAlert = BPF.ar(redAlert, [740, 1400, 1500, 1600], (12!4).reciprocal) ++ (redAlert * 0.5);
	Out.ar(0, (redAlert.sum * 0.2)!2);
 
}).add;
)
 
// ALL HANDS!! BATTLESTATIONS!
e = Synth(\red, [\freq, 10]);
e = Synth(\red, [\freq, 111]);






//Chaos engine hum
(
{
	SinOsc.ar(10 + (50 * SinOsc.kr([30, 31], 0, SinOsc.kr(61, Saw.kr(0.12345, 678, 9), 0.2, 0.8), Pulse.kr([25, 25.5], 0.25, 0.125, -0.25))), 0, 0.5, 0);
}.play();
)


(
SynthDef("radiostatic", {arg out=0;
	var hum, sineSweep, tuning, dustNoise, staticNoise, humFreq, numHarms;
	
	numHarms = 7;
	humFreq = 60;
	hum = Array.fill(numHarms, {|i| SinOsc.ar( (i+1) * humFreq, 0, 1/numHarms)});
	hum = hum.sum;
	dustNoise = Dust.ar(LFNoise1.ar(0.5).range(100,8000));
	staticNoise = hum * dustNoise * LFNoise1.ar(1).range(0.5, 2);
	
	sineSweep = SinOsc.ar(LFNoise2.ar(1).range(20, 11000));
	tuning = SinOsc.ar(10000).ring4(sineSweep) * LFNoise2.ar(1.1).range(0.05, 0.1);

	Out.ar(out,  Pan2.ar(staticNoise + tuning, 0));
}).add;
)
	
a = Synth("radiostatic");



// random deep fryer. can turn in to rain, waves and other stuff.
// nice with multichannel iteration. Change number at "!2".
// volume compensation for high quality filter with "1/q.sqrt" for mul in BPF.
// variable "dist" for distortion, increasing can go loud, decrease "amp" if so.
// LFNoise1 with noisefreq,noisemul,noiseoffset gives it the wavy feel.

(
SynthDef(\friture, {
	arg amp=0.5, dist=2, dens=12, dustamp=1, offset=0, noisefreq=2, noisemul=2,
	noiseoffset=0, frq1=200, frq2=2500, rq1=0.5, rq2=0.1, out=0;

	var sig, env;

	sig = {BPF.ar((Dust2.ar(dens, dustamp, offset)*LFNoise1.ar(noisefreq,noisemul,noiseoffset)),rrand(frq1,frq2),q=rrand(rq1,rq2),1/q.sqrt)}!2;
	sig = (sig*dist).tanh*amp;


	Out.ar(out,sig);

	}).add;
)

y = Synth.new(\friture);
y.free;

y.set(\dens,161);
y.set(\amp,0.5);
y.set(\dist,1);
y.set(\rq1,0.2);
y.set(\rq2,0.4);
y.set(\frq1,133);
y.set(\frq2,193);
y.set(\noisefreq,1);
y.set(\noisemul,2);
y.set(\noiseoffset,(-2));
y.set(\out,0);