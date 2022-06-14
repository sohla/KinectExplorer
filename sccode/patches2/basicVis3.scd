var patterns = Array.fill(4,{nil});
var index = 0;
var pairs = Dictionary.new(4);
var oscSender = "hi";
var fadeValues = [1,1,1,1];
var previousBlobsSize = 0;

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

	oscSender = patch.netAddr;

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
		if(oscSender != nil, {
			{oscSender.sendMsg("/shadow", 
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

	// var ptn = Pdef("pa_"++i,
	// 	Pbind(
	// 	    \instrument, \a,
	// 	    \amp, Pswitch([0.4], i),
	// 	    \octave, Pswitch([
	// 	    	3,
	// 	    	4,
	// 	    	5,
	// 			6,
	// 	    ], i),
	// 	    \attack, Pswitch([0.02,0.001,0.001,0.001], i),
	// 	    \decay, 0.1,
	// 	    \sustain, 0.3, 
	// 	    \release,  Pswitch([1,1,1,1], i),
	// 	    \dur, Pswitch([
	// 	    	1,
	// 	    	0.5,
	// 	    	0.25,
	// 	    	0.125
	// 	    ], i),
	// 	    \root, Pswitch([
	// 	    	Pseq([0].stutter(2), inf),
	// 	    	Pseq([0].stutter(32), inf),
	// 	    	Pseq([0].stutter(21), inf),
	// 	    	Pseq([0].stutter(64), inf),
	// 	    ], i),
	// 	    \note, Pswitch([
	// 	    	Pseq([0], inf),
	// 	    	Pseq([0], inf),
	// 	    	Pseq([0], inf),
	// 		    Pseq([0], inf)
	// 	    ], i),

	// 	    \dat, Pfunc({|e|
	// 	    	// blob.center.getnSynchronous
	// 	    	true
	// 	    }),
	// 	    // visuals
	// 	    \shape, 4,

	// 	    \vdur, 0.5,
	// 	    \vatt, 0.05,
	// 	    \vrel, 0.5,
	// 	    \color, Pswitch([0,0.3,Pkey(\note).linlin(0,11,0.1,0.2),0.9], i),
	// 	    \scale, Pswitch([2,0.5,1,0.6], i),
	// 	    \sx, Pfunc({blob.center.getnSynchronous(2)[0].linlin(0,1,-1,1)}),
	// 	    \sy, 0,
	// 	    \ex, Pkey(\sx),
	// 	    \ey, -1,
	// 	    \imageindex, 14,
	// 	    \rotstart, -90,
	// 	    \rotend, -90,
	// 	    \speed, 10,
	// 	    // \freq, 1,
	// 	    \wobble, 1.1,

	// 		\osc, Pfunc{|e| 

	// 			if(e[\dur].isKindOf(Rest) != true,{
	// 				vizMessage.(e, i);
	// 			});
	// 			true // must return true 
	// 		}
	//   	)
	// );

	// fadeValues[i] = 1.0;
	// patterns.put(i,ptn);

	// if(i != nil, {
	// 	pairs.put(blob.label, i);
	// 	patterns[i].quant = [1, 0];
	// 	patterns[i].play();
	// });

};

//------------------------------------------------------
~onBlobDeinit = {|blob, blobsDict|

	// var i = pairs.removeAt(blob.label);
	// var fadeTime = 2; //• add to blob
	// var fadeRate = 0.1;
	// var fadeSteps = (fadeTime / fadeRate).floor;

	// if(i != nil,{
		
	// 	// calcualte fade value (used for visuals)
	// 	SystemClock.sched(0.0,
	// 	    Routine({ 
	// 	    	fadeSteps.do({
					
	// 				fadeValues[i] = fadeValues[i] - (1.0 / (fadeTime / fadeRate));	        
	// 		        fadeRate.yield;
	// 		        // fadeValues.postln;
	// 	    	}) ;
	// 	    });
	// 	);

	// 	// patterns[i].stop;
	// 	patterns[i].clear(fadeTime);
	// 	// Ndef.all.values[0].clean;
	// 	patterns.put(i,nil);
	// });
	
};

//------------------------------------------------------
~onBlobUpdate = {|blob, blobsDict|

	if(blobsDict.size != previousBlobsSize,{
		[blob.label,"change"].postln;
	});
	previousBlobsSize = blobsDict.size;
};

//------------------------------------------------------
~onPlotData = {|blobsDict|


	1
};
