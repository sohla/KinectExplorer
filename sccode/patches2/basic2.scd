var patterns = [];
var index = 0;
var pairs = Dictionary.new(4);

//------------------------------------------------------
~init = {|patch|

	postf("init : % \n", patch.file);
	SynthDef(\basicSin, {|out, freq = 160, amp = 0.1, attack = 0.002, decay = 0.1, sustain = 0.8, release = 0.1, gate = 1, pan = 0|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var sig = SinOsc.ar(freq, 0, amp * env);

		Out.ar(out, Pan2.ar(sig,pan));

	}).add;

	patterns = Array.fill(4, {|i|
		Pbind(
			\instrument, \basicSin,
			\note, (i*3),//Pfunc({blob.center.getnSynchronous(2)[0].linlin(0,1,0,46)}),
			\octave, 4,
			\dur, 0.3,
			\amp, 0.2,
			//\func, Pfunc({[blob.label].postln;})
		)
	});
};

//------------------------------------------------------
~reload = {|patch|

	postf("reload : % \n", patch.file);

};

//------------------------------------------------------
~deinit = {|patch|


};

//---------------------------------------------------
~onBlobInit = {|blob, blobsDict|

	index = index + 1;
	index = index.mod(4);

	patterns[index].play;
	pairs.put(blob.label, index);

};

//------------------------------------------------------
~onBlobDeinit = {|blob, blobsDict|

	var i = pairs.removeAt(blob.label);
	if(i != nil,{
		"STOP".postln;
		patterns[i].stop;
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
