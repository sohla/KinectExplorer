var active = Dictionary.new(4);
var notes = [50,54,57,61];
var root = [0,3,-2,5].stutter(28);


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
	active.do({|o,k| o.free});
};
//---------------------------------------------------
~onBlobInit = {|blob, blobsDict|

	var synth = Synth.new(\basicSin, [\gate,1, \freq, (notes[0] + root[0]).midicps, \attack, 0.02, \sustain, 0.3, \decay, 0.9, \release, 0.9]);
	{synth.set(\gate,0)}.defer(1);
	notes = notes.rotate(-1);
	root = root.rotate(-1);
};

//------------------------------------------------------
~onBlobDeinit = {|blob, blobsDict|

	
	var synth = Synth.new(\basicSin, [\gate,1, \freq, (notes[0] + root[0]).midicps, \attack, 0.02, \sustain, 0.1, \decay, 0.9, \release, 0.9]);
	{synth.set(\gate,0)}.defer(1);
	notes = notes.rotate(-1);
	root = root.rotate(-1);

};

//------------------------------------------------------
~onBlobUpdate = {|blob, blobsDict|

	 // active.at(blob.label).set(\freq, 40 + blob.center.getnSynchronous(2)[0].linexp(0,1,2,7070));
	 // active.at(blob.label).set(\pan, blob.center.getnSynchronous(2)[0].linlin(0,1,-1,1));
};

//------------------------------------------------------
~onPlotData = {|blobsDict|
	
	blobsDict.size
};

