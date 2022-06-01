var patterns = Array.fill(4,{nil});
var index = 0;
var pairs = Dictionary.new(4);


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

};
//------------------------------------------------------
~reload = {|patch|

	postf("reload : % \n", patch.file);

};

//------------------------------------------------------
~deinit = {|patch|

	postf("deinit : % \n", patch.file);

	patterns.do({|p,i|
		p.stop; 
		p.clear;
		p.free;
		patterns.put(i,nil);
	});

	pairs = Dictionary.new(4);

};

//---------------------------------------------------
~onBlobInit = {|blob, blobsDict|

	var i = findNextRunning.();

	var notes = [
		[0,4,4,11,12],
		[0,4,7,5,12],
		[7,9,12,14,12],
		[0,4,-5,-7,0],
	];

	var ptn = Pdef("pa_"++i,
		Pbind(
		    \instrument, Pswitch([\a,\a,\a,\a], i),
		    \amp, Pswitch([0.3,0.3,0.4,0.8], i),
		    \root, 0,
		    \octave, 6 - i,
		    \attack, Pswitch([ Pwhite(0.001,0.06),0.002,0.003,0.005], i),
		    \decay, 0.1,
		    \sustain, Pswitch([ 0.02,0.01,0.01,0.03], i), //make sure sustain is not to low!
		    \release,  Pswitch([Pwhite(1.5,0.03),0.9,1.3,1.5], i),
		    \dur, Pswitch([
		    	Prand([0.1,Rest(0.1),0.3], inf),
		    	Prand([0.4,Rest(0.2),0.2], inf), 
		    	Pseq([0.4,0.1,0.1,0.2], inf),
		    	Pseq([0.8,Rest(0.4)],inf) 
		    ], i),
		    \note, Pswitch( notes[i],Pfunc{blob.center.getnSynchronous(2)[0].linlin(0,1,0,5).floor}),
		    \dt, Pswitch([ Pwhite(0.02,0.03),Pwhite(0.004,0.013),Pwhite(0.001,0.002),0.01], i),
		    \ff, Pwhite(300, 700),
		    \rf, 0.003,
		    \dis, 0.05,
		    \df, Pswitch([9,8,7,4,1], i),
	  	)
	);

	i.postln;
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
		patterns[i].stop;
		patterns[i].clear;
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


