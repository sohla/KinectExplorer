var noteAddr = "";
var globalAddr = "";
var synths = Array.fill(8,{nil});
var pairs = Dictionary.new(8);
var notes = [50,54+12,57,61+12] ;
var root = [0,-2,3,-4,-5].stutter(14);
var sx = 0;
var group;
var verbSynth;

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
		var	exc = LFNoise2.ar(lfn, 0.06, 1); 

		var sig = (DynKlank.ar(`[
				Array.series(12, [freq,freq+0.3], [freq,freq+0.5] * harm),
				Array.geom(12,0.9,0.8*exc),
				Array.fill(12,3)
			], exc) * 0.02).softclip;
		var tone = SinOsc.ar([freq, freq + (freq * 0.003)] * 1,0,0.2 * env);
		Out.ar(out, LeakDC.ar(sig + tone) * amp * env);
	}).add;


	SynthDef(\verb1, {|out = 0, gate = 1|
		var in = In.ar(out, 2);
		var env = EnvGen.ar(Env.adsr(0.01,0.01,1,5), gate, doneAction: 14);
		var sig = JPverb.ar(in, 15, 0.1, 5, 0.7, 0.6, 3.8, 0.6,0.6,0.5);
		ReplaceOut.ar(out, sig * env);
	}).add;

	noteAddr = patch.noteAddr;
	globalAddr  = patch.globalAddr;

	group = Group.new;
	verbSynth  = Synth.head(group,\verb1, [\out,0]);


	globalAddr.sendMsg("/poly_render", 1); 
	globalAddr.sendMsg("/poly_linewidth",3); 
	globalAddr.sendMsg("/poly_solid", 1); 
	globalAddr.sendMsg("/poly_r", 1); 
	globalAddr.sendMsg("/poly_g", 0); 
	globalAddr.sendMsg("/poly_b", 1); 
	globalAddr.sendMsg("/poly_a", 0.5);//? 


	globalAddr.sendMsg("/feedback_mix",1); 
	globalAddr.sendMsg("/feedback_opacity", 0.9); 

	globalAddr.sendMsg("/feedback_x", 0); //-1 1
	globalAddr.sendMsg("/feedback_y", 0.5); 

	globalAddr.sendMsg("/feedback_displacex", 2); //-1 1
	globalAddr.sendMsg("/feedback_displacey", 0); 

	globalAddr.sendMsg("/feedback_edge_r", 1); 
	globalAddr.sendMsg("/feedback_edge_g", 0); 
	globalAddr.sendMsg("/feedback_edge_b", 0); 

	globalAddr.sendMsg("/feedback_edge_blacklevel", 0); 
	globalAddr.sendMsg("/feedback_edge_strength", 0.2); 
};

//------------------------------------------------------
~deinit = {|patch|

	postf("deinit : % \n", patch.file);

	synths.do({|o,i|
		if(o != nil,{
			o.postln;
			o.set(\gate, 0);
		});
	});
	verbSynth.set(\gate, 0);

	pairs = Dictionary.new(4);
	synths = Array.fill(8,{nil});
};
//---------------------------------------------------
~onBlobInit = {|blob, blobsDict|

	var i = findNextRunning.();

	var vizMessage = {|i|
		if(noteAddr != nil, {
			noteAddr.sendMsg("/shadow", 
				"shape", 5,
				"duration", 0.1,
				"attack", 0.03,
				"release", 1.8,
				"color", blob.center.getnSynchronous(2)[0].linlin(0,1,0,0.99),
				"scale", 1,
				"scx", 0.01,
				"scy", 1,
				"sx", sx,
				"sy", -1,
				"ex", sx,
				"ey", 1,
				"imageindex", 0,
				"rotstart",0,
				"rotend", 0,

				"speed", 1,//e[\speed],
				"freq", 20,
				"amp", 0.04,

				"wobble", 0,
			);
		});
	};

	if(i != nil, {
		var synth = Synth.head(group, \chordal, [\gate,1, \freq, (notes[0] + root[0] + [0,-12,0,0,12].choose).midicps, \attack, 0.02, \sustain, 1.0, \decay, 0.9, \release, 0.1]);

		vizMessage.(i);
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
		sx = blob.center.getnSynchronous(2)[0].linlin(0.31,0.72,-1,1);
	});
};

//------------------------------------------------------
~onPlotData = {|blobsDict|
	
	blobsDict.size
};

//------------------------------------------------------
~onBlobData = {|blob|
	
	var rect  = Rect.fromArray(blob.rect.getnSynchronous(4));
	rect.width * -1
};
