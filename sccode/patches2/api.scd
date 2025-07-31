var active = Dictionary.new(4);
var noteAddr = nil;
var globalAddr = nil;
var group = Group.new;
var dir = 0.1;
var cols = [Color.red, Color.green, Color.blue, Color.yellow];
//------------------------------------------------------
~init = {|patch|

	SynthDef(\basicSin, {|out = 0, freq = 160, amp = 0.3, attack = 2, decay = 0.1, sustain = 0.8, release = 1.9, gate = 1, pan = 0|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var sig = SinOsc.ar(freq, 0, amp * env);

		Out.ar(out, Pan2.ar(sig,pan));

	}).add;

	noteAddr = patch.noteAddr;
	globalAddr  = patch.globalAddr;


	//----------------------------------------------------------------11------------
	// vis
	//----------------------------------------------------------------------------
	globalAddr.sendMsg("/xfade",1);//0 off 1 mix

	~setPolyline.(1,1,1); // render, lineWidth, solid
	~setRGBColor.([1,1,1,1]); // weird mixer for all the blobs. keeping it white lets polylineColor work

	// each polyline (blob)
	4.do({|i|
		var c = cols[i];
		~setPolylineColor.(i,c.asArray);
	});

	~setColorRamp.(Color.white.asArray, 1);

	// ~setBackground0.(); // alpha bg
	~setBackground1.(Color.grey(0.8).asArray); // bg with solid color
	// ~setBackground2.(blur:2, step:0.07); // not really bg : blurs blobs with lines (wip)
	// ~setBackground3.(index:1, scale:0.3, rot:0.01, mode:31, color:Color(1,1,0).asArray); // using images and some color

	// ~setDisplace.(mix:1.0, x:0, y:30.2, period:1, noise:1, z:0.1);//x/y movement, z=speed
	~setDisplace.(mix:0.0);
	// ~setFeedback.(mix:0.5, opacity:0.99, hue:-0.05, x:0, y:0.0, dx:0.0, dy:0.0, edgeColor:Color(1,1,1).asArray, edgeBlack:0.0, edgeStength:0.0);//
	~setFeedback.(mix:0);
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
	// ~setBackground0.();

	// ~setBackground3.(index:10.rand.floor, scale:1.2, rot:active.size * dir , mode:31, color:Color(1,1,1).asArray);
};

//------------------------------------------------------
~onBlobDeinit = {|blob, blobsDict|

	var synth = active.removeAt(blob.label);
	synth.set(\gate, 0);
	// ~setBackground0.();
	// ~setBackground3.(index:2, scale:0.8, rot:active.size * dir , mode:31, color:Color(0.1,1,0.2).asArray);
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
