var active = Dictionary.new(4);
var notes = [50,54+12,57,61+12] - 12;
var root = [0,3,-2,5].stutter(4);
var synths = Array.fill(4,{nil});
var pairs = Dictionary.new(4);

var findNextRunning = {
	var index = 0;
	synths.do({|e,i|
		if(e == nil,{
			index = i;
		});
	});
	index
};


//------------------------------------------------------
~init = {|patch|

	SynthDef(\chordal, {|out = 0, freq = 120, amp = 0.5, attack = 0.01, decay = 0.03, sustain = 0.4, release = 0.9, gate = 1, harm = 1, lfn = 200|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var	exc = LFNoise2.ar(lfn, 0.1, 1); 

		var sig = (DynKlank.ar(`[
				Array.series(12, [freq,freq+0.3], [freq,freq+0.5] * harm),
				Array.geom(12,0.9,0.8*exc),
				Array.fill(12,3)
			], exc) * 0.02).softclip;
		var tone = SinOsc.ar([freq, freq + (freq * 0.003)] * 1,0,0.2 * env);
		Out.ar(out, LeakDC.ar(sig + tone) * amp * env);
	}).add;
};

//------------------------------------------------------
~deinit = {|patch|

	postf("deinit : % \n", patch.file);
	active.do({|o,k| o.free});

	synths.do({|o,i|
		if(o != nil,{
			o.set(\gate, 0);
		});
	});

	pairs = Dictionary.new(4);

};
//---------------------------------------------------
~onBlobInit = {|blob, blobsDict|

	var i = findNextRunning.();

	if(i != nil, {
		var synth = Synth.new(\chordal, [\gate,1, \freq, (notes[0]).midicps, \attack, 0.02, \sustain, 1.0, \decay, 0.9, \release, 0.9]);

		notes = notes.rotate(-1);
		root = root.rotate(-1);

		synths.put(i,synth);

		pairs.put(blob.label, i);
	});	

};

//------------------------------------------------------
~onBlobDeinit = {|blob, blobsDict|

	var i = pairs.removeAt(blob.label);

	if(i != nil,{
		synths.at(i).set(\gate, 0);
		synths.put(i,nil);
	});


};

//------------------------------------------------------
~onBlobUpdate = {|blob, blobsDict|

	var i = pairs.at(blob.label);
	if(i != nil,{
		synths.at(i).set(\lfn, blob.area.getSynchronous.linexp(7,42,80,12500));
		// synths.at(i).get(\freq, {|f|
			// synths.at(i).set(\freq, (notes[0] + root[0]).midicps);
		// });
		// synths.at(i).set(\freq, root[0].midicps);
		//synths.at(i).set(\harm, blob.center.getnSynchronous(2)[0].linlin(0.05,0.85,1,2));
	});
};

//------------------------------------------------------
~onPlotData = {|blobsDict|
	
	blobsDict.size
};

