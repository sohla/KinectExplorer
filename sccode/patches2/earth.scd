var active = Dictionary.new(4);
var noteAddr = nil;
var globalAddr = nil;
var group = Group.new;
var dir = 0.1;

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
	globalAddr.sendMsg("/xfade",7);//0 off 1 mix 

	~setPolyline.(1,3,1);

	// each polyline (blob)
	4.0.do({|i|
		var c = Color(1,1,1,1);
		~setPolylineColor.(i,c.asArray);
	});

	~setColorRamp.(Color.blue.asArray, 10);

	// ~setBackground0.();
	//~setBackground2.(blur:0.4, step:0.3);
	~setBackground3.(index:2, scale:0.6, rot:0.1, mode:31, color:Color(1,1,1).asArray);

	~setDisplace.(mix:1.0, x:3.2, y:0.2, period:0.3, noise:0.2, z:0.3);
	// ~setDisplace.(mix:0.0);
	~setFeedback.(mix:1, opacity:0.91, hue:0.0, x:0, y:0.1, dx:0, dy:0, edgeColor:Color(0,0,1).asArray, edgeBlack:0.0, edgeStength:0.0);
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

	var p = [50,62,69,74] * 0.7;
	var synth = Synth.head(group, \basicSin, [\gate,1, \freq, p.choose.midicps]);
	active.put(blob.label, synth);
	dir = dir * -1;

	~setBackground3.(index:10.rand.floor, scale:1.2, rot:active.size * dir , mode:31, color:Color(1,1,1).asArray);
};

//------------------------------------------------------
~onBlobDeinit = {|blob, blobsDict|

	var synth = active.removeAt(blob.label);
	synth.set(\gate, 0);
	~setBackground3.(index:2, scale:0.8, rot:active.size * dir , mode:31, color:Color(0.1,1,0.2).asArray);
};

//------------------------------------------------------
~onBlobUpdate = {|blob, blobsDict|
	var val= 0;	
	active.at(blob.label).set(\amp, blob.center.getnSynchronous(2)[0].linlin(0,1,0,0.3));
	active.at(blob.label).set(\pan, blob.center.getnSynchronous(2)[0].linlin(0.05,0.85,-1,1));

	// awesome energy
	// blobsDict.do({|o,k|
	//  	if(o.state == 2,{
	//  		val = val + o.velocity.getnSynchronous(2)[0].abs.linlin(0,10,0,10);
	//  	});
	// });
	// ~setBackground3.(rot:val);
};

//------------------------------------------------------
~onPlotData = {|blobsDict|

	var val= 0;	
	//blobsDict.size
	 blobsDict.do({|o,k|

	 	if(o.state == 2,{
	 		val = val + o.velocity.getnSynchronous(2)[0].abs.linlin(0,100,0,10);
	 	});
	 });
	 val
};

//------------------------------------------------------
~onBlobData = {|blob|
	
};
