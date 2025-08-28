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
	SynthDef(\basicSin, {|out, freq = 160, amp = 0.1, attack = 0.002, decay = 0.001, sustain = 0.2, release = 1.01, gate = 1, pan = 0, dt = 0.02|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var sig = SinOsc.ar([freq, freq + (freq * dt)], 0, amp * env);

		Out.ar(out, Pan2.ar(sig,pan));

	}).add;

	// patterns = Array.fill(4, {|i|
	// 		Ndef("pa_"++i,
	// 			Pbind(
	// 			    \instrument, \basicSin, 
	// 			    \amp, 0.3,
	// 			    \root, 0,
	// 			    \octave, 3 + i,
	// 			    \dur, 0.1 * (i+1),
	// 			    \note, 7 * i
	// 		  	)
	// 		);
	// });
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
		[0,4,7,11,12],
		[7,9,7,9,9],
		[0,0,7,7,12],
	];

	var ptn = Pdef("pa_"++i,
		Pbind(
		    \instrument, \basicSin, 
		    \amp, Pswitch([0.1,0.2,0.4,0.8]*0.5, i),
		    \root, 0,
		    \octave, 6 - i,
		    \attack, Pswitch([ Pwhite(0.001,0.06),0.002,0.003,0.005], i),
		    \decay, 0.1,
		    \sustain, Pswitch([ 0.02,0.01,0.01,0.03], i), //make sure sustain is not to low!
		    \release,  Pswitch([Pwhite(1.5,0.03),0.9,1.3,1.5], i),
		    \dur, Pswitch([0.1,0.2,0.4,0.8], i),
		    \note, Pswitch( notes[i],Pfunc{blob.center.getnSynchronous(2)[0].linlin(0,1,0,5).floor}),
		    \dt, Pswitch([ Pwhite(0.02,0.03),Pwhite(0.024,0.033),Pwhite(0.001,0.002),0.002]*12, i),
	  	)
	);
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
//------------------------------------------------------
~onBlobData = {|blob|
	
};


