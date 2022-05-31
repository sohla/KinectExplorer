var patterns = [];
var index = 0;
var pairs = Dictionary.new(4);


var findNextRunning = {
	var index = nil;
	patterns.do({|e,i|
		if(e.isMonitoring == false,{
			index = i;
		});
	});
	index
};
//------------------------------------------------------
~init = {|patch|

	postf("init : % \n", patch.file);
	SynthDef(\basicSin, {|out, freq = 160, amp = 0.1, attack = 0.002, decay = 0.1, sustain = 0.8, release = 0.1, gate = 1, pan = 0|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var sig = SinOsc.ar(freq, 0, amp * env);

		Out.ar(out, Pan2.ar(sig,pan));

	}).add;

	patterns = Array.fill(4, {|i|
			Ndef("pa_"++i,
				Pbind(
				    \instrument, \basicSin, 
				    \amp, 0.3,
				    \root, 0,
				    \octave, 3 + i,
				    \dur, 0.1 * (i+1),
				    \note, 0
			  	)
			);
	});
};

//------------------------------------------------------
~reload = {|patch|

	postf("reload : % \n", patch.file);

};

//------------------------------------------------------
~deinit = {|patch|

	postf("deinit : % \n", patch.file);

	patterns.do({|p|
		if(p != nil,{
			p.end(0.2); //stops and free's but needs some time to do so
		});
	});

	pairs = Dictionary.new(4);

};

//---------------------------------------------------
~onBlobInit = {|blob, blobsDict|

	var i = findNextRunning.();

	if(i != nil, {
		pairs.put(blob.label, i);
		patterns[i].play(0.1);
	});

};

//------------------------------------------------------
~onBlobDeinit = {|blob, blobsDict|

	var i = pairs.removeAt(blob.label);
	if(i != nil,{
		patterns[i].stop(0.4);
	});
	
};

//------------------------------------------------------
~onBlobUpdate = {|blob, blobsDict|

};

//------------------------------------------------------
~onPlotData = {|blobsDict|
	
	blobsDict.size
};




// Ndef(\sound, { |freq = 56, numHarm = 10| Blip.ar(freq, numHarm, 30) * 0.2 }).play;
// Ndef(\sound).set(\freq, 15);
// Ndef(\sound).set(\freq, 15, \numHarm, 100);

// Ndef(\lfo, { LFNoise2.kr(2).exprange(10, 200) });
// Ndef(\sound).map(\numHarm, Ndef(\lfo));
// Ndef(\sound).set(\numHarm, nil); // unmap.
// Ndef(\sound).stop;
// Ndef(\sound).play;
// Ndef(\sound).clear;
// Ndef(\sound).free;
// Ndef(\lfo).clear
// Ndef.clear
// Ndef.all





