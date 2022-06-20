var active = Dictionary.new(4);
//------------------------------------------------------
~init = {|patch|

	SynthDef(\basicSin, {|out = 0, freq = 160, amp = 0.1, attack = 2, decay = 0.1, sustain = 0.8, release = 1.9, gate = 1, pan = 0|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var sig = SinOsc.ar(freq, 0, amp * env);

		Out.ar(out, Pan2.ar(sig,pan));

	}).add;

};

//------------------------------------------------------
~deinit = {|patch|

	postf("deinit : % \n", patch.file);
	active.do({|o,k| o.set(\gate, 0)});
};
//---------------------------------------------------
~onBlobInit = {|blob, blobsDict|

	var synth = Synth.new(\basicSin, [\gate,1]);
	active.put(blob.label, synth);
};

//------------------------------------------------------
~onBlobDeinit = {|blob, blobsDict|

	var synth = active.removeAt(blob.label);
	synth.set(\gate, 0);
};

//------------------------------------------------------
~onBlobUpdate = {|blob, blobsDict|

	 active.at(blob.label).set(\freq, 40 + blob.center.getnSynchronous(2)[0].linexp(0,1,2,7070));
	 active.at(blob.label).set(\pan, blob.center.getnSynchronous(2)[0].linlin(0.05,0.85,-1,1));
};

//------------------------------------------------------
~onPlotData = {|blobsDict|
	
	blobsDict.size
};

//------------------------------------------------------
~onBlobData = {|blob|
	
};
