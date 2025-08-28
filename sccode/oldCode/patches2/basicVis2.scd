var patterns = Array.fill(4,{nil});
var index = 0;
var pairs = Dictionary.new(4);
var noteAddr = "";
var globalAddr = "";
var fadeValues = [1,1,1,1];

var findNextRunning = {
	var index = 0;
	patterns.do({|e,i|
		if(e == nil,{
			index = i;
		});
	});
	index
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

	SynthDef(\glow, {|out = 0, attack = 0.004, release = 0.9, freq = 100, gate = 1, coef = 0.0, tf = 1, amp = 0.3, ff = 10500, rf = 0.5|
		var env = EnvGen.ar(Env.perc(attack, release, 1, -7), gate, doneAction: 2);
		var trig = Impulse.ar(XLine.ar(tf, 1, attack + (release * 0.5)));
		var sub = LFTri.ar(freq, [0,pi/3], 0.09);
		var sig = Splay.ar({|i|
	    	var f = freq * (i+1);
	    	Pluck.ar(
	    		BrownNoise.ar(1), 
	    		trig,  
	    		f.reciprocal, 
	    		f.reciprocal, 
	    		Demand.ar(trig, 0, Dwhite(1, 10)),
	        	coef: coef
	        )} !2);

		var filter = MoogFF.ar(sig, ff.lag(0.1), rf);
		Out.ar(out, (filter + sub) * env * amp);

	}).add;

	noteAddr = patch.noteAddr;
	globalAddr  = patch.globalAddr;

};

//------------------------------------------------------
~deinit = {|patch|

	postf("deinit : % \n", patch.file);

	patterns.do({|p,i|

		// hack together a blob model with label
		// to pass to blob deinit, giving us a nice fade
		var label = pairs.findKeyForValue(i);
		if(label!=nil,{
			var b = (\label:label);
			~onBlobDeinit.(b, nil);
		});

		// just stop everything
		// p.stop; 
		// p.clear(1);
		// p.free;
		// patterns.put(i,nil);
	});

	pairs = Dictionary.new(4);

};

//---------------------------------------------------
~onBlobInit = {|blob, blobsDict|

	var i = findNextRunning.();

	var vizMessage = {|e, i|
		if(noteAddr != nil, {
			{noteAddr.sendMsg("/shadow", 
				"shape", e[\shape],
				"duration", e[\vdur],
				"attack", e[\vatt],
				"release", e[\vrel],
				"color", e[\color],
				"scale", e[\scale] * fadeValues[i],
				"sx", e[\sx],
				"sy", e[\sy],
				"ex", e[\ex],
				"ey", e[\ey],
				"imageindex", e[\imageindex],
				"rotstart",e[\rotstart],
				"rotend", e[\rotend],

				"speed", 1,//e[\speed],
				"freq", 20,
				"amp", 0.04,

				"wobble", e[\wobble],
			);}.defer(0.1);
		});
	};

	var notes = [0,4,8,12];

	var ptn = Pdef("pa_"++i,
		Pbind(
		    \instrument, \glow,
		    \amp, Pswitch([0.3,0.8,0.8,1.3], i),
		    \octave, Pswitch([
		    	7,
		    	7,
		    	5,
				Pseq([2,3,4,3], inf),
		    ], i),
		    \attack, Pswitch([0.4,0.001,0.001,0.001], i),
		    \decay, 0.1,
		    \sustain, 0.3, 
		    \release,  Pswitch([8.6,0.9,3.9,Pwhite(0.9,1.9)], i),
		    \dur, Pswitch([
		    	4,
		    	Pseq([0.125,0.125,Rest(0.5)], inf),
		    	0.125*3,
		    	0.125
		    ], i),
		    \root, Pswitch([
		    	Pseq([0].stutter(2), inf),
		    	Pseq([0].stutter(32), inf),
		    	Pseq([0].stutter(21), inf),
		    	Pseq([0].stutter(64), inf),
		    ], i),
		    \note, Pswitch([
		    	Pseq([[0,4,-2],[2,5,0]].stutter(1), inf),
		    	Pseq([-2,10], inf),
		    	Pseq([7,5,4,2,-2].stutter(3), inf),
			    Pseq([0,0,-2,4,0,0,5,-2,5,5,-2,2,0,7,7,7].stutter(4), inf)
		    ], i),

		    \coef, Pswitch([
		    	0.3,
		    	Pwhite(0.001,0.1),
		    	0.3,
				Pwhite(0.9,0.87),
		    ], i),
		    \tf, Pswitch([40,1,1,1], i),
		    \ff, 11400,
		    \rf, 1,

		    // visuals
		    \shape, 3,

		    \vdur, 0.1,
		    \vatt, 0.05,
		    \vrel, 0.1,
		    \color, Pswitch([0,0.5,Pkey(\note).linlin(0,11,0.0,0.2),1], i),
		    \scale, Pswitch([2,0.5,1,0.6], i) * 4,
		    \sx, Pfunc({blob.center.getnSynchronous(2)[0].linlin(0,1,-1,1)}),
		    \sy, -1,
		    \ex, Pkey(\sx),
		    \ey, 1,
		    \imageindex, 14,
		    \rotstart, -90,
		    \rotend, -90,
		    \speed, 10,
		    // \freq, 1,
		    \wobble, 1.1,

			\osc, Pfunc{|e| 

				if(e[\dur].isKindOf(Rest) != true,{
					vizMessage.(e, i);
				});
				true // must return true 
			}
	  	)
	);

	fadeValues[i] = 1.0;
	patterns.put(i,ptn);

	if(i != nil, {
		pairs.put(blob.label, i);
		patterns[i].quant = [1, 0];
		patterns[i].play();
	});
};

//------------------------------------------------------
~onBlobDeinit = {|blob, blobsDict|

	var i = pairs.removeAt(blob.label);
	var fadeTime = 2; //• add to blob
	var fadeRate = 0.1;
	var fadeSteps = (fadeTime / fadeRate).floor;

	if(i != nil,{
		
		// calcualte fade value (used for visuals)
		SystemClock.sched(0.0,
		    Routine({ 
		    	fadeSteps.do({
					
					fadeValues[i] = fadeValues[i] - (1.0 / (fadeTime / fadeRate));	        
			        fadeRate.yield;
			        // fadeValues.postln;
		    	}) ;
		    });
		);

		// patterns[i].stop;
		patterns[i].clear(fadeTime);
		// Ndef.all.values[0].clean;
		patterns.put(i,nil);
	});
	
};

//------------------------------------------------------
~onBlobUpdate = {|blob, blobsDict|

};

//------------------------------------------------------
~onPlotData = {|blobsDict|
	
	5
};

//------------------------------------------------------
~onBlobData = {|blob|
	
};

