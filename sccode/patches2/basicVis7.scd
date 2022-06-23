var noteAddr = "";
var globalAddr = "";
var synths = Array.fill(8,{nil});
var pairs = Dictionary.new(8);
var notes = [50,54+12,57,61+12];
var root = [0,-2,3,-4,-5].stutter(14);
var sx = 0;
var group = Group.new;
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
		var lfo = LFCub.ar(0.1,0,0.014,1);

		var sig = (DynKlank.ar(`[
				Array.series(12, [freq,freq+0.3] * lfo, [freq,freq+0.5] * harm * lfo),
				Array.geom(12,0.9,0.8*exc),
				Array.fill(12,3)
			], exc) * 0.02).softclip;
		var tone = SinOsc.ar([freq, freq + (freq * 0.003)] * 1,0,0.2 * env);
		Out.ar(out, LeakDC.ar(sig + tone) * amp * env);
	}).add;


	SynthDef(\verb1, {|out = 0, gate = 1|
		var in = In.ar(out, 2);
		var env = EnvGen.ar(Env.adsr(0.01,0.01,1,5), gate, doneAction: 2);
		var sig = JPverb.ar(in, 15, 0.1, 5, 0.7, 0.6, 3.8, 0.6,0.6,0.5);
		ReplaceOut.ar(out, sig * env);
	}).add;

	noteAddr = patch.noteAddr;
	globalAddr  = patch.globalAddr;

	// group = Group.new;
	verbSynth  = Synth.head(group,\verb1, [\out,0]);


	globalAddr.sendMsg("/poly_render", 1); 
	globalAddr.sendMsg("/poly_linewidth",5); 
	globalAddr.sendMsg("/poly_solid", 1); 
	globalAddr.sendMsg("/poly_r", 1); 
	globalAddr.sendMsg("/poly_g", 1); 
	globalAddr.sendMsg("/poly_b", 1); 
	globalAddr.sendMsg("/poly_a", 1); 

	4.0.do({|i|
		// var i = 2 ;
		var c = Color.black;//rand(0.0,1.0);
		// [i,c].postln;
		globalAddr.sendMsg("/poly_r"++(i+1), c.red); 
		globalAddr.sendMsg("/poly_g"++(i+1), c.green); 
		globalAddr.sendMsg("/poly_b"++(i+1), c.blue); 
		globalAddr.sendMsg("/poly_a"++(i+1), 1); 
	});

	// globalAddr.sendMsg("/xfade", 1);//0 off 1 mix 

	globalAddr.sendMsg("/background_index", 2);//0 off 1 bg 2 energy 
	globalAddr.sendMsg("/background_r", 0); 
	globalAddr.sendMsg("/background_g", 1); 
	globalAddr.sendMsg("/background_b", 0); 


	globalAddr.sendMsg("/xfade", 1);//0 off 1 mix 
	globalAddr.sendMsg("/cell_blur", 0.9);
	globalAddr.sendMsg("/cell_step", 0.09);


	globalAddr.sendMsg("/displace_mix", 0);//on/off 
	globalAddr.sendMsg("/displace_x", 0); 
	globalAddr.sendMsg("/displace_y", 0.0); 
	globalAddr.sendMsg("/displace_period", 0.2); 
	globalAddr.sendMsg("/displace_noise_harmonic", 1); 
	globalAddr.sendMsg("/displace_speedz", 0.02); 


	globalAddr.sendMsg("/feedback_mix", 0); 
	globalAddr.sendMsg("/feedback_opacity", 0.9); 


	globalAddr.sendMsg("/feedback_hue", 0); 

	globalAddr.sendMsg("/feedback_x", 0); //-1 1
	globalAddr.sendMsg("/feedback_y", 1); 

	globalAddr.sendMsg("/feedback_displacex",1); //-1 1
	globalAddr.sendMsg("/feedback_displacey", 1); 

	globalAddr.sendMsg("/feedback_edge_r", 0); 
	globalAddr.sendMsg("/feedback_edge_g", 0); 
	globalAddr.sendMsg("/feedback_edge_b", 0); 

	globalAddr.sendMsg("/feedback_edge_blacklevel", 0); 
	globalAddr.sendMsg("/feedback_edge_strength", 0); 

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
				"shape", 7,
				"duration", 0.1,
				"attack", 0.03,
				"release", 0.3,
				"color", blob.center.getnSynchronous(2)[0].linlin(0,1,0,0.18),
				"scale", 1,
				"scx", 20,
				"scy", 0.1,
				"sx", sx,
				"sy", 0,
				"ex", sx,
				"ey", 0,
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
		var synth = Synth.head(group, \chordal, [\gate,1, \freq, (notes[0] + root[0] + [0,-12,0,0,12].choose).midicps, \attack, 0.8, \sustain, 1.0, \decay, 0.9, \release, 0.1]);

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
		synths.at(i).set(\lfn, blob.rect.getnSynchronous(4)[2].linexp(20,102,200,20000));
		synths.at(i).set(\harm, blob.rect.getnSynchronous(4)[2].linexp(20,102,0.5,1.5));
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
	// blob.rect.getnSynchronous(4)[2].postln;
	rect.width * -1
};
