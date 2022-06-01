var runningPatterns = Array.fill(4,{nil});
var index = 0;
var pairs = Dictionary.new(4);


var findNextRunning = {
	var index = 0;
	runningPatterns.do({|e,i|
		if(e == nil,{
			index = i;
		});
	});
	index
};

var getPattern = {|i, blob|

	var notes = [0,-2, -3, -5, -7, -8 ,-10];
	var patterns = [
		Pbind(
		    \instrument, Pswitch([\a,\a,\a,\a], i),
		    \amp, 0.9,
		    \root, 0,
		    \octave, 2,
		    \attack, 0.001,
		    \decay, 0.1,
		    \sustain, 0.4,
		    \release,  0.1,
		    \dur, Pseq([0.4, Rest(0.1), 0.3, 0.2,0.2], inf),
		    \note, Pseq([2,12,5,7].stutter(5), inf),
		    \dt, 0.03,
		    \ff, Pwhite(700, 900),
		    \rf, 0.003,
		    \dis, 0.05,
		    \df, 1
	  	),
		Pbind(
		    \instrument, Pswitch([\a,\a,\a,\a], i),
		    \amp, 0.3,
		    \root, 0,
		    \octave, Prand([6, 7, 8], inf),
		    \attack, 0.003,
		    \decay, 0.01,
		    \sustain, 0.2,
		    \release,  Pfunc{blob.rect.getnSynchronous(4)[3].linlin(120,190,0.1,1.3)},
		    \dur, 0.1,
		    \note, Pswitch( notes,Pfunc{blob.center.getnSynchronous(2)[0].linlin(0,1,0,6).floor}).stutter(3),
		    \dt, Pwhite(0.01, 0.02),
		    \ff, Pwhite(1500, 1700),
		    \rf, 0.3,
		    \dis, 0.05,
		    \df, Pfunc{blob.rect.getnSynchronous(4)[2].linlin(70,180,1,25)}
	  	),
		Pbind(
		    \instrument, Pswitch([\a,\a,\a,\a], i),
		    \amp, 0.2,
		    \root, 0,
		    \octave, 7,
		    \attack, 3.03,
		    \decay, 0.3,
		    \sustain, 0.9,
		    \release,  2.3,
		    \dur, 0.4 * 6,
		    \note, Pseq([0,-3,-7,-10], inf),
		    \dt, 0.006,
		    \ff, Pwhite(300, 700),
		    \rf, 0.003,
		    \dis, 0.05,
		    \df, 4
	  	),

		Pbind(
		    \instrument, Pswitch([\a,\a,\a,\a], i),
		    \amp, 0.4,
		    \root, 0,
		    \octave, 5,
		    \attack, 0.03,
		    \decay, 0.1,
		    \sustain, 0.3,
		    \release,  1.3,
		    \dur, Pseq([0.1, Rest(0.1), 0.2, 0.1, 0.1], inf),
		    \note, Pxrand([0,2,5,9], inf),
		    \dt, 0.03,
		    \ff, Pwhite(100, 500),
		    \rf, 0.02,
		    \dis, 0.07,
		    \df, 6
	  	),

	];
	patterns[i]

};

//------------------------------------------------------
~init = {|patch|

	postf("init : % \n", patch.file);

	SynthDef(\a, {|out = 0, freq = 160, amp = 0.3, attack = 0.01, decay = 4.02, sustain = 0.8, release = 0.9, gate = 1, ff = 500, rf = 1, dis = 0.1, df = 5, dt = 1|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var sig = SinOsc.ar([freq,freq + (freq * dt)], LocalIn.ar(2) * LFNoise1.ar(dis,df), amp);
		var filter = MoogFF.ar(sig, ff.lag(0.1), rf);
		var comb = CombL.ar(filter, 0.3, 0.2, 0.2,1);
		LocalOut.ar(filter);
		Out.ar(out, comb * env);

	}).add;

};
//------------------------------------------------------
~deinit = {|patch|

	postf("deinit : % \n", patch.file);

	runningPatterns.do({|p,i|
		// p.stop; 
		p.clear(10);
		p.free;
		runningPatterns.put(i,nil);
	});

	pairs = Dictionary.new(4);

};

//---------------------------------------------------
~onBlobInit = {|blob, blobsDict|

	var i = findNextRunning.();
	var ptn = Ndef("basic4_"++i, getPattern.(i,blob));

	runningPatterns.put(i,ptn);

	if(i != nil, {
		pairs.put(blob.label, i);
		runningPatterns[i].quant = [0.4, 0];
		runningPatterns[i].play;
	});
};

//------------------------------------------------------
~onBlobDeinit = {|blob, blobsDict|

	var i = pairs.removeAt(blob.label);
	if(i != nil,{
		// runningPatterns[i].stop;
		runningPatterns[i].clear(1); //fade
		runningPatterns.put(i,nil);
	});
	
};

//------------------------------------------------------
~onBlobUpdate = {|blob, blobsDict|

};

//------------------------------------------------------
~onPlotData = {|blobsDict|
	
	blobsDict.size
};


