var active = Dictionary.new(4);
var noteAddr = nil;
var globalAddr = nil;
var group = Group.new;

//------------------------------------------------------
~init = {|patch|

	SynthDef(\basicSin, {|out = 0, freq = 160, amp = 0.3, attack = 2, decay = 0.1, sustain = 0.8, release = 1.9, gate = 1, pan = 0|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var sig = SinOsc.ar(freq, 0, amp * env);

		Out.ar(out, Pan2.ar(sig,pan));

	}).add;

	noteAddr = patch.noteAddr;
	globalAddr  = patch.globalAddr;


	//----------------------------------------------------------------------------
	// vis
	//----------------------------------------------------------------------------
	globalAddr.sendMsg("/xfade",2);//0 off 1 mix 

	~setPolyline.(1,5,1);

	// each polyline (blob)
	4.0.do({|i|
		var c = Color(1,0.3,0,1);
		~setPolylineColor.(i,c.asArray);
	});

	~setColorRamp.(Color.red.asArray, 60);

	//~setBackground0.();
	// ~setBackground1.(Color.red.asArray);
	//~setBackground2.(blur:0.4, step:0.3);
	~setBackground3.(index:8, scale:1, rot:0.01, mode:31, color:Color(1,0,0).asArray);

	~setDisplace.(mix:1.0, x:3.2, y:3.2, period:1, noise:0.5, z:0.2);
	// ~setDisplace.(mix:0.0);
	~setFeedback.(mix:1, opacity:0.98, hue:0.0, x:0, y:-0.1, dx:1, dy:1, edgeColor:Color(0,1,0).asArray, edgeBlack:0.0, edgeStength:1.0);
	// ~setFeedback.(mix:0);
};

//------------------------------------------------------
~deinit = {|patch|

	postf("deinit : % \n", patch.file);
	active.do({|o,k| o.set(\gate, 0)});
	~setBackground3.(index:8, scale:1, rot:0.01, mode:31, color:Color(0,0,0).asArray);
	~setDisplace.(mix:0.0);
	~setFeedback.(mix:0);
		~setPolyline.(0);
};
//---------------------------------------------------
~onBlobInit = {|blob, blobsDict|

	var synth = Synth.head(group, \basicSin, [\gate,1]);
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
