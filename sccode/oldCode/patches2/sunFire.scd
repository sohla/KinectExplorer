var active = Dictionary.new(4);
var noteAddr = nil;
var globalAddr = nil;
var group = Group.new;
var dir = 0.1;
var vp;
//------------------------------------------------------
~init = {|patch|

	SynthDef(\basicSin, {|out = 0, freq = 160, amp = 0.1, attack = 2, decay = 0.1, sustain = 0.8, release = 1.9, gate = 1, pan = 0|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var sig = SinOsc.ar(freq, 0, amp * env);

		Out.ar(out, Pan2.ar(sig,pan));

	}).add;

	noteAddr = patch.noteAddr;
	globalAddr  = patch.globalAddr;


	//----------------------------------------------------------------------------
	// vis
	//----------------------------------------------------------------------------
	globalAddr.sendMsg("/xfade",1);//0 off 1 mix 

	~setPolyline.(1,3,1);

	// each polyline (blob)
	4.0.do({|i|
		var c = Color(1,1,0,1);
		~setPolylineColor.(i,c.asArray);
	});

	~setColorRamp.(Color.black.asArray, 60);

	// ~setBackground0.();
	~setBackground1.(Color(0,0,1).asArray);
	// ~setBackground2.(blur:0.9, step:0.8);
	// ~setBackground3.(index:2, scale:0.6, rot:0, mode:9, color:Color(1,1,0).asArray);

	~setDisplace.(mix:1.0, x:10.5, y:0.5, period:1.7, noise:0, z:0.0);
	// ~setDisplace.(mix:0.0);
	~setFeedback.(mix:1, opacity:0.91, hue:0.0, x:0.0, y:0.33, dx:0.3, dy:0.0, edgeColor:Color(1,1,0).asArray, edgeBlack:0.0, edgeStength:0.2);
	// ~setFeedback.(mix:0);

	//----------------------------------------------------------------------------
	vp = Pdef("va_",
		Pbind(
			\amp, 0,
			\dur, 0.3,
			\yellow, Pwhite(0.5,1.0),
			\sc, Pwhite(0.58,0.62),
			\func, Pfunc({|e|
				// ~setBackground3.(index:10.rand.floor, scale:e[\sc], rot:0, mode:9, color:Color(1,e[\yellow],0).asArray);


			})
		)
	).play;
	
};

//------------------------------------------------------
~deinit = {|patch|

	postf("deinit : % \n", patch.file);
	active.do({|o,k| o.set(\gate, 0)});
	// ~setBackground0.();
	// ~setBackground3.(index:8, scale:0.6, rot:0.01, mode:31, color:Color(0,0,0).asArray);
	// ~setDisplace.(mix:0.0);
	// ~setFeedback.(mix:0);
	// ~setPolyline.(0,3,1);
	vp.clear;
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
	var val= 0;	
	active.at(blob.label).set(\freq, 40 + blob.center.getnSynchronous(2)[0].linexp(0,1,2,7070));
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
