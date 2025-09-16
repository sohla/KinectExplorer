var synths = Dictionary.new(4);

// ------------------------------------------------------
~init = {|patch|

  var colors = [Color.red, Color.yellow, Color.blue, Color.cyan, Color.green];
SynthDef(\waves22, { |out=0, gate=0, amp = 0.2|
    var env = EnvGen.ar(Env.asr(1.3,1.0,8 ), gate, doneAction:2);

	var spd = 0.03.rrand(0.09);//MouseY.kr(0.03,0.09);
	var nsa = RHPF.ar(BrownNoise.ar(0.1), LFSaw.ar(spd*2,1).linexp(-1,1,200,19000));
	var sig = SinOsc.ar(spd,LFPar.ar(spd,0,pi) *[1,1.02], nsa);
	Out.ar(out, sig * env * amp);
}).add;
	// ~setOSCReset.(1);
	~setXfade.(1);

	~setPolyline.(1,1,1);
  ~setRGBColor.([1,1,1,1]); //might need to reset in globals OSC IN

	// ~setBackground0.(); 
	// ~setBackground1.(Color.white().asArray);
	~setBackground2.(blur:0.7, step:0.03, index:1, color:Color.yellow.lighten(0.5).asArray);
	// ~setBackground3.(index:25, scale:1, rot:0, mode:31, color:Color.blue.asArray);


	// each polyline (blob)
	4.do({|i|
		// var c = Color.new(0,1/2,0.5/2,1);
		var c = Color.black().lighten(0.1);
		// var c = Color.hsv(0.1 + (0.05 * i),1,1);
    // var c = colors[i];
		~setPolylineColor.(i,c.asArray); // might be broken
	});

	// ~setDisplace.(mix:1, x:3, y:10, period:0.1, noise:0.2, z:1);
	~setDisplace.(mix:0.5, x:0.5, y:0, period:1, noise:5, z:0);
	// ~setDisplace.(mix:0.0);

	~setFeedback.(mix:1, opacity:0.9, hue:0.02, x:0.0, y:0.04, dx:0.0, dy:0.0, edgeColor:Color(0,1,0).asArray, edgeBlack:0.3, edgeStength:0.9);
	// ~setFeedback.(mix:0);
  

};

//------------------------------------------------------
~deinit = {|patch|
  synths.do({|p,i|
    p.set(\gate, 0);
  });
  synths.free;

};

//---------------------------------------------------
~onBlobInit = {|blob, blobsDict|
	// postf("blob init: % \n", blob.label);
  var synth = Synth(\waves22, [\gate, 1]);
  synths.put(blob.label, synth);

};

//------------------------------------------------------
~onBlobUpdate = {|blob, blobsDict|
  synths.at(blob.label).set(\filterFreq, blob.center.getnSynchronous(2)[0].linexp(0,1.0,300,1700));
  synths.at(blob.label).set(\mx, blob.center.getnSynchronous(2)[1].linexp(0,2.0,0.2,0.9));
  synths.at(blob.label).set(\my, blob.center.getnSynchronous(2)[1].linexp(0,2.0,0.2,0.9));
};

//------------------------------------------------------
~onBlobDeinit = {|blob, blobsDict|
	// postf("blob deinit: % \n", blob.label);
  synths.at(blob.label).set(\gate, 0);
  synths.removeAt(blob.label);

};


//------------------------------------------------------
~onPlotData = {|blobsDict|	
};

//------------------------------------------------------
~onBlobData = {|blob|
};
