var active = Dictionary.new(4);


//------------------------------------------------------
~init = {|patch|

	postf("init : % \n", patch.file);
	SynthDef(\basicSin, {|out = 0, freq = 160, amp = 0.1, attack = 0.002, decay = 0.1, sustain = 0.8, release = 0.1, gate = 1, pan = 0|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var sig = SinOsc.ar(freq, 0, amp * env);

		Out.ar(out, Pan2.ar(sig,pan));

	}).add;
};

//------------------------------------------------------
~reload = {|patch|

	postf("reload : % \n", patch.file);

};

//------------------------------------------------------
~deinit = {|patch|

	postf("deinit : % \n", patch.file);
	// Ndef.clear(0);
	active.postln;
	active.do({|o,k| o.stop});
	active.free;
};
//---------------------------------------------------
~onBlobInit = {|blob, blobsDict|

	var pattern = Pbind(
			\instrument, \basicSin,
			\note, Pfunc({blob.center.getnSynchronous(2)[0].linlin(0,1,0,46)}),
			\octave, 3,
			\dur, 0.3,
			\amp, 0.2,
			// \func, Pfunc({[blob.label,blob.center].postln;})
	);

	active.put(blob.label, pattern);
	pattern.play;
};

//------------------------------------------------------
~onBlobDeinit = {|blob, blobsDict|
	
	var pattern = active.removeAt(blob.label);
	pattern.postln;
	pattern.stop;
		
};

//------------------------------------------------------
~onBlobUpdate = {|blob, blobsDict|

};

//------------------------------------------------------
~onPlotData = {|blobsDict|
	
	blobsDict.size
};

