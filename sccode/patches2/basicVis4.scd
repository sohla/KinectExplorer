var patterns = Array.fill(4,{nil});
var index = 0;
var pairs = Dictionary.new(4);
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
		if(noteAddr != nil, {
			{noteAddr.sendMsg("/shadow", 
				"shape", e[\shape],
				"duration", e[\dur],
				"attack", e[\attack] ,
				"release", e[\release] * 0.4,
				"color", e[\color],
				"scale", e[\scale],
				"sx", e[\sx],
				"sy", e[\sy],
				"ex", e[\ex],
				"ey", e[\ey],
				"imageindex", e[\imageindex],
				"rotstart",e[\rotstart],
				"rotend", e[\rotend],
				"amp", e[\amp],
				"speed", e[\speed],
				"freq", 1,
				"wobble", e[\wobble],
			);}.defer(0.1);
		});
	};

	var notes = [
		[0,4,4,11,12],
		[0,4,7,5,12],
		[4,12,7,9,5,14,0,16],
		[0,4,-5,-7,0],
	];

	var ptn = Pdef("pa_"++i,
		Pbind(
		    \instrument, Pswitch([\a,\a,\a,\a], i),
		    \amp, Pswitch([0.2,0.2,0.3,0.8], i),
		    \root, 0,
		    \octave, 6 - i,
		    \attack, Pswitch([ Pwhite(0.001,0.06),0.002,0.003,0.005] * 0.1, i),
		    \decay, 0.1,
		    \sustain, Pswitch([ 0.02,0.01,0.01,0.03], i), //make sure sustain is not to low!
		    \release,  Pswitch([Pwhite(1.5,0.03),0.9,1.3,1.5], i) * 2,
		    \dur, Pswitch([
		    	Prand([0.1,Rest(0.1),0.3], inf),
		    	Prand([0.4,Rest(0.2),0.2], inf), 
		    	Pseq([0.4,0.1,Rest(0.1),0.2], inf),
		    	Pseq([0.8,Rest(0.4)],inf) 
		    ], i),
		    \note, Pswitch( notes[i],Pfunc{blob.center.getnSynchronous(2)[0].linlin(0.3,0.7,0,5).floor}),
		    \dt, 0.001,//Pswitch([ Pwhite(0.02,0.03),Pwhite(0.004,0.013),Pwhite(0.001,0.002),0.01], i),
		    \ff, 14000,//Pwhite(300, 1700),
		    \rf, 0.002,
		    \dis, 1,
		    \df, 2,//Pswitch([9,8,7,4,1], i),

		    // visuals
		    \shape, Pswitch([7,6,3,6], i),
		    \color, Pkey(\ff).linlin(300,700,0,1),
		    \scale, Pswitch([1,4,Pwhite(1.03,2.1),4], i),
		    \sy, Pswitch([0,0,0,Pkey(\note).linlin(-7,4,-1.5,1.5)], i),
		    \sx, Pfunc{blob.center.getnSynchronous(2)[0].linlin(0,1,-1.5,1.5)},
		    \ey, Pkey(\sy),
		    \ex, Pkey(\sx),
		    \imageindex, 0,
		    \rotstart, 0,
		    \rotend, 0,
		    \speed, 1,
		    // \freq, 1,
		    \wobble, 1,

			\osc, Pfunc{|e| 
				vizMessage.(e, i);
			}
	  	)
	);


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
	if(i != nil,{
		// patterns[i].stop;
		patterns[i].clear(1);
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

