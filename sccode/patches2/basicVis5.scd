var active = Dictionary.new(4);
var noteAddr = nil;
var globalAddr = nil;

//------------------------------------------------------
~init = {|patch|

	SynthDef(\basicSin, {|out = 0, freq = 160, amp = 0.1, attack = 2, decay = 0.1, sustain = 0.8, release = 1.9, gate = 1, pan = 0|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var sig = SinOsc.ar(freq, 0, amp * env);

		Out.ar(out, Pan2.ar(sig,pan));

	}).add;

	noteAddr = patch.noteAddr;
	globalAddr  = patch.globalAddr;

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

	globalAddr.sendMsg("/xfade", 1);//0 off 1 mix 

	globalAddr.sendMsg("/background_index", 2);//0 off 1 mix 
	globalAddr.sendMsg("/background_r", 1); 
	globalAddr.sendMsg("/background_g", 1); 
	globalAddr.sendMsg("/background_b", 1); 


	globalAddr.sendMsg("/displace_mix", 1);//on/off 
	globalAddr.sendMsg("/displace_x", 1.2); 
	globalAddr.sendMsg("/displace_y", 1.2); 
	globalAddr.sendMsg("/displace_period", 0.2); 
	globalAddr.sendMsg("/displace_noise_harmonic", 0.5); 
	globalAddr.sendMsg("/displace_speedz", 0.2); 


	globalAddr.sendMsg("/feedback_mix", 1); 
	globalAddr.sendMsg("/feedback_opacity", 0.9); 


	globalAddr.sendMsg("/feedback_hue", 0); 

	globalAddr.sendMsg("/feedback_x", 0); //-1 1
	globalAddr.sendMsg("/feedback_y", 0); 

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
