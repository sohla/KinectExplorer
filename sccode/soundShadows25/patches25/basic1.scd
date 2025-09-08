var active = Dictionary.new(4);

//------------------------------------------------------
~init = {|patch|

	SynthDef(\basicSin, {|out = 0, freq = 160, amp = 0.1, attack = 2, decay = 0.1, sustain = 0.8, release = 1.9, gate = 1, pan = 0, lfof = 1|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var lfo = Saw.ar(lfof,1).lag(0.03);
		var sig = SinOsc.ar(freq, 0, amp * lfo) + Saw.ar(freq * 1.007, amp * 0.2 * lfo);
		Out.ar(out, Pan2.ar(sig * env, pan));

	}).add;

};

//------------------------------------------------------
~deinit = {|patch|

	// postf("deinit : % \n", patch.file);
	active.do({|o,k| o.set(\gate, 0)});
};

//---------------------------------------------------
~onBlobInit = {|blob, blobsDict|
	
	var synth = Synth.new(\basicSin, [\gate,1]);
	active.put(blob.label, synth);

	// postf("blob init: % \n", blob.label);
	
};

//------------------------------------------------------
~onBlobUpdate = {|blob, blobsDict|

	 active.at(blob.label).set(\freq, 40 + blob.center.getnSynchronous(2)[0].linexp(0.25,0.75,50,11200));
	 active.at(blob.label).set(\pan, blob.center.getnSynchronous(2)[0].linlin(0.15,0.65,-1,1));
	 active.at(blob.label).set(\amp, blob.perimeter.getnSynchronous(2)[0].linexp(0.01,4,0.1,0.3));
	 active.at(blob.label).set(\lfof, blob.center.getnSynchronous(2)[0].linexp(0.15,0.65,1,40));
	// blob.perimeter.getnSynchronous(2)[0].postln;
};

//------------------------------------------------------
~onBlobDeinit = {|blob, blobsDict|

	var synth = active.at(blob.label);
	synth.set(\gate, 0);
	active.removeAt(blob.label);

	// postf("blob deinit: % \n", blob.label);

};


//------------------------------------------------------
~onPlotData = {|blobsDict|	
	blobsDict.size
};

//------------------------------------------------------
~onBlobData = {|blob|
};
