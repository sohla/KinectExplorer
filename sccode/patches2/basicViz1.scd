var patterns = Array.fill(4,{nil});
var index = 0;
var pairs = Dictionary.new(4);
var oscSender = "hi";

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
		// p.stop; 
		p.clear(1);
		p.free;
		patterns.put(i,nil);
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
				"scale", e[\scale] * blob.fadeValue,
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

	var notes = [0,4,8];

	var ptn = Ndef("pa_"++i,
		Pbind(
		    \instrument, Pswitch([\a,\a,\a,\a], i),
		    \amp, 0.3,
		    \octave, 7 - i,
		    \attack, 0.02,
		    \decay, 0.1,
		    \sustain, 0.3, //make sure sustain is not to low!
		    \release,  1.7,
		    \dur, Pswitch([
		    	Pseq([1,Rest(0.5)], inf),
		    	Pseq([0.5,Rest(0.25)], inf),
		    	Pseq([0.1,Rest(0.1),0.1,0.1], inf),
		    	Pseq([0.2,0.2,Rest(0.5)], inf),
		    ], i),
		    \root, Pswitch( notes,Pfunc{blob.center.getnSynchronous(2)[0].linlin(0,1,0,3).floor}),
		    \note, Pseq([0,7,11], inf),
		    \dt, Pswitch([ Pwhite(0.02,0.03),Pwhite(0.004,0.013),Pwhite(0.001,0.002),0.01], i),
		    \ff, Pwhite(300, 700),
		    \rf, 0.003,
		    \dis, 0.05,
		    \df, Pswitch([9,8,7,4,1], i),

		    // visuals
		    \shape, 6,
		    \vdur, 0.15,
		    \vatt, 0.1,
		    \vrel, 0.9,
		    \color, Pfunc({blob.center.getnSynchronous(2)[0].linlin(0,1,0,0.999)}),
		    \scale, 0.3,
		    \sx, Pfunc({blob.center.getnSynchronous(2)[0].linlin(0,1,-1,1)}),
		    \sy, -1,
		    \ex, Pkey(\sx),
		    \ey, 1,//Pfunc({blob.rect.getnSynchronous(4)[3].linlin(160,250,0,1).floor}),
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

	blob.fadeValue = 1.0;
	// i.postln;
	patterns.put(i,ptn);

	if(i != nil, {
		pairs.put(blob.label, i);
		patterns[i].quant = [1, 0];
		patterns[i].play;
	});
};

//------------------------------------------------------
~onBlobDeinit = {|blob, blobsDict|

	var i = pairs.removeAt(blob.label);
	var fadeTime = 4;
	var fadeRate = 0.1;
	var fadeSteps = (fadeTime / fadeRate).floor;

	"deinit blob".postln;
	
	if(i != nil,{
		
		// calcualte fade value (used for visuals)
		SystemClock.sched(0.0,
		    Routine({ 
		    	fadeSteps.do({
					
					blob.fadeValue = blob.fadeValue - (1.0 / (fadeTime / fadeRate));	        
			        fadeRate.yield;
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
	
	blobsDict.size
};


