/*
poly_render	1
poly_linewidth	1
poly_r	1
poly_g	1
poly_b	1
poly_a	1
poly_solid	1
poly_r1	0.5256772
poly_g1	0.4037037
poly_b1	0.5899158
poly_a1	1
poly_r2	0.8434553
poly_g2	0.905377
poly_b2	0.953554
poly_a2	1
poly_r3	0.3657314
poly_g3	0.8912058
poly_b3	0.2633678
poly_a3	1
poly_r4	0.6390325
poly_g4	0.9091134
poly_b4	0.2246641
poly_a4	1
feedback_mix	0
feedback_opacity	0.98
feedback_x	0
feedback_y	0
feedback_displacex	0
feedback_displacey	0
feedback_edge_r	0
feedback_edge_g	0
feedback_edge_b	0
feedback_edge_blacklevel	0
feedback_edge_strength	0
background_r	0
background_g	0
background_b	0
background_index	0
displace_speedx	0
displace_speedy	0
displace_speedz	0
displace_period	1
displace_noise_harmonic	0
displace_x	0
displace_y	0
displace_mix	0

*/

var pairs = Dictionary.new(4);
var patterns = Array.fill(4,{nil});
var fadeValues = [1,1,1,1];
var index = 0;
var noteAddr = "";
var globalAddr = "";

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

	noteAddr = patch.noteAddr;
	globalAddr  = patch.globalAddr;

	globalAddr.sendMsg("/poly_render", 1); 
	globalAddr.sendMsg("/poly_linewidth", 1); 
	globalAddr.sendMsg("/poly_solid", 1); 
	globalAddr.sendMsg("/poly_r", 1); 
	globalAddr.sendMsg("/poly_g", 1); 
	globalAddr.sendMsg("/poly_b", 1); 
	globalAddr.sendMsg("/poly_a", 1); 

	4.0.do({|i|
		// var i = 2 ;
		var c = Color.grey(0.2);//Color.rand(0.0,1.0);
		// [i,c].postln;
		globalAddr.sendMsg("/poly_r"++(i+1), c.red); 
		globalAddr.sendMsg("/poly_g"++(i+1), c.green); 
		globalAddr.sendMsg("/poly_b"++(i+1), c.blue); 
		globalAddr.sendMsg("/poly_a"++(i+1), 1); 
	});

	// globalAddr.sendMsg("/background_r", 1); 
	// globalAddr.sendMsg("/background_g", 0); 
	// globalAddr.sendMsg("/background_b", 0); 
	// globalAddr.sendMsg("/background_index", 0); 


	globalAddr.sendMsg("/feedback_mix", 1); 
	globalAddr.sendMsg("/feedback_opacity", 0.5); 

	globalAddr.sendMsg("/feedback_x", -0.5); 
	globalAddr.sendMsg("/feedback_y", -0.5); 

	globalAddr.sendMsg("/feedback_displacex", 0); 
	globalAddr.sendMsg("/feedback_displacey", 0); 

	globalAddr.sendMsg("/feedback_edge_r", 1); 
	globalAddr.sendMsg("/feedback_edge_g", 1); 
	globalAddr.sendMsg("/feedback_edge_b", 1); 

	globalAddr.sendMsg("/feedback_edge_blacklevel", 0); 
	globalAddr.sendMsg("/feedback_edge_strength", 0.1); 


};

//------------------------------------------------------
~deinit = {|patch|

	postf("deinit : % \n", patch.file);
	
	globalAddr.sendMsg("/poly_render",0); 

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
				"scx", e[\scx],
				"scy", e[\scy],

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
		    \instrument, Pswitch([\a,\a,\a,\a], i),
		    \amp, Pswitch([0.5,0.3,0.4,0.4], i),
		    \octave, Pswitch([3,6,5,4], i),
		    \attack, 0.02,
		    \decay, 0.1,
		    \sustain, 0.3, //make sure sustain is not to low!
		    \release,  1.7,
		    \dur, 0.5,
		    // Pswitch([
		    // 	Pseq([1], inf),
		    // 	Pseq([0.5], inf),
		    // 	Pseq([0.125], inf),
		    // 	Pseq([0.5], inf),
		    // ], i),
		    \root, Pswitch( notes,Pfunc{blob.center.getnSynchronous(2)[0].linlin(0,1,0,4).floor}),
		    \note, Pseq([0,7,11], inf),
		    \dt, Pswitch([ Pwhite(0.02,0.03),Pwhite(0.004,0.013),Pwhite(0.001,0.002),0.01] * 1.2, i),
		    \ff, Pwhite(300, 900),
		    \rf, 0.003,
		    \dis, 0.05,
		    \df, Pswitch([1,8,7,4,1], i),

		    // visuals
		    \shape, 0,
		    \vdur, 0.02,
		    \vatt, 0.01,
		    \vrel, 0.3,
		    \color, 0.5,//Pswitch([0,0.3,Pkey(\note).linlin(0,11,0.1,0.2),0.9], i),
		    \scale, 1,
		    \scx, 1,
		    \scy, 1,
		    \sx, Pfunc({blob.center.getnSynchronous(2)[0].linlin(0.37,0.85,-1,1)}),
		    \sy, 0,
		    \ex, Pkey(\sx),
		    \ey, Pkey(\sy),
		    \imageindex, 14,
		    \rotstart, -90,
		    \rotend, -90,
		    \speed, 10,
		    // \freq, 1,
		    \wobble, 1.1,

		    \bc, Pwhite(0,15),

		    // \test, Pfunc({|e|
		    // 	"note on".postln;
		    // 	{"note off".postln;}.defer(e[\dur]/2);
		    // }),
			\osc, Pfunc{|e| 

				// {
				// 4.do({|i|
				// 	var c = Color.rand(0.0,1.0);
				// 	// [i,c].postln;
				// 	globalAddr.sendMsg("/poly_r"++(i+1), c.red); 
				// 	globalAddr.sendMsg("/poly_g"++(i+1), c.green); 
				// 	globalAddr.sendMsg("/poly_b"++(i+1), c.blue); 
				// 	globalAddr.sendMsg("/poly_a"++(i+1), 1); 
				// });
				// }.defer(0.15);

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
	
	blobsDict.size
};

//------------------------------------------------------
~onBlobData = {|blob|
	
};

