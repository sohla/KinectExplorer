var pairs = Dictionary.new(4);
var patterns = Array.fill(4,{nil});
var fadeValues = [1,1,1,1];
var index = 0;
var noteAddr = nil;
var globalAddr = nil;
var vp;
var group = Group.new;

// ••• GROUPSSSS!!!!!!



var findNextRunning = {
	var index = 0;
	patterns.do({|e,i|
		if(e == nil,{
			index = i;
		});
	});
	index
};
//------------------------------------------------------
~init = {|patch|


	postf("init : % \n", patch.file);

	SynthDef(\ab, {|out = 0, freq = 160, amp = 0.3, attack = 0.01, decay = 4.02, sustain = 0.8, release = 0.9, gate = 1, ff = 500, rf = 1, dis = 0.1, df = 5, dt = 1|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var sig = SinOsc.ar([freq,freq + (freq * dt)], LocalIn.ar(2) * LFNoise1.ar(dis,df), amp);
		var filter = MoogFF.ar(sig, ff.lag(0.1), rf);
		var comb = CombL.ar(filter, 0.3, 0.2, 0.2,1);
		LocalOut.ar(filter);
		Out.ar(out, comb * env);

	}).add;

	noteAddr = patch.noteAddr;
	globalAddr  = patch.globalAddr;


	//----------------------------------------------------------------------------
	// vis
	//----------------------------------------------------------------------------
	globalAddr.sendMsg("/xfade",1);//0 off 1 mix

	~setPolyline.(1,1,1);

	// each polyline (blob)
	4.0.do({|i|
		var c = Color.new(1,0,1,0);
		~setPolylineColor.(i,Color.blue.asArray);
	});

	~setColorRamp.(Color.green.asArray, 10);

	// ~setBackground0.(); 
	~setBackground1.(Color.white.asArray);
	// ~setBackground2.(blur:0.4, step:0.3);
	// ~setBackground3.(index:8, scale:1, rot:0.01, mode:31, color:Color.white.asArray);

	// ~setDisplace.(mix:1, x:1, y:1, period:0.3, noise:1, z:0);
	~setDisplace.(mix:0.0);
	~setFeedback.(mix:1, opacity:0.96, hue:0.02, x:0.0, y:1.0, dx:0.0, dy:0.0, edgeColor:Color(0,1,1).asArray, edgeBlack:0.0, edgeStength:0.0);
	// ~setFeedback.(mix:0);

};

//------------------------------------------------------
~deinit = {|patch|

	postf("deinit : % \n", patch.file);

	// if(globalAddr != nil, {
	// 	globalAddr.sendMsg("/poly_render",0)
	// });

	patterns.do({|p,i|

		// hack together a blob model with label
		// to pass to blob deinit, giving us a nice fade
		var label = pairs.findKeyForValue(i);
		if(label!=nil,{
			var b = (\label:label);
			~onBlobDeinit.(b, nil);
		});

		// just stop everything
		// p.stop;
		// p.clear(1);
		// p.free;
		// patterns.put(i,nil);
	});

	pairs = Dictionary.new(4);
	// vp.clear;
	// group.free;

};

//---------------------------------------------------
~onBlobInit = {|blob, blobsDict|

	var i = findNextRunning.();

	var vizMessage = {|e, i|
		if(noteAddr != nil, {
			{noteAddr.sendMsg("/shadow",
				"shape", e[\shape],"duration", e[\vdur],"attack", e[\vatt],"release", e[\vrel],"color", e[\color],
				"scale", e[\scale],"sx", e[\sx],"sy", e[\sy],"ex", e[\ex],"ey", e[\ey],"scx", e[\scx],"scy", e[\scy],"imageindex", e[\imageindex],
				"rotstart",e[\rotstart],"rotend", e[\rotend],"speed", 1,"amp", 0.04,"wobble", e[\wobble]
			);}.defer(0.1);
		});
	};

	var notes = [0,4,8,12];

	var ptn = Pdef("aa_"++i,
		Pbind(
		    \instrument, Pswitch([\ab,\ab,\ab,\ab], i),
		    \group, group,
		    \amp, Pswitch([0.5,0.3,0.4,0.4]*1, i),
		    \octave, Prand([4,5,6,7],inf),//Pswitch([Prand([3,4,5,6],inf),6,4,3], i),
		    \attack, 0.02,
		    \decay, 0.02,
		    \sustain, 0.5, //make sure sustain is not to low!
		    \release,  1.9,
		    \dur, //0.3,
		    Pswitch([
		    	Pseq([1], inf),
		    	Pseq([0.5], inf),
		    	Pseq([0.125], inf),
		    	Pseq([0.5], inf),
		    ] , i),
		    \root, Pswitch( notes,Pfunc{blob.center.getnSynchronous(2)[0].linlin(0.31,0.73,0,4).floor}),
		    \note, Pseq([0,7,11], inf),
		    \dt, Pswitch([ Pwhite(0.02,0.03),Pwhite(0.004,0.013),Pwhite(0.001,0.002),0.01] * 1.2, i),
		    \ff, Pwhite(800, 5900),
		    \rf, 0.03,
		    \dis, 0.05,
		    \df, Pswitch([1,8,7,4,1]*0.3, i),

		    // visuals
		    \shape,1,//9 textures
		    \vdur, 0.06,
		    \vatt, 0.01,
		    \vrel, Pswitch([0.97,0.6,0.8,0.5], i),
		    \color, 0,//Pswitch([0,0.25,0.5,0.75], i),//Pwhite(0.0,0.999),
		    \scale, 1,
		    \scx, 1,//0.7,
		    \scy, 1,//Pswitch([0.06, 0.09,0.04,0.05] * 1.51, i),
		    \sx, Pfunc({blob.center.getnSynchronous(2)[0].linlin(0.31,0.72,-1,1)}),
		    \sy, 1,
		    \ex, Pkey(\sx),
		    \ey, Pkey(\sy),
		    \imageindex, Pwhite(0,15).floor,
		    \rotstart, 0,
		    \rotend, 0,
		    \speed, 1,
		    // \freq, 1,
		    \wobble, 0,

		    \bc, Pwhite(0,15),

			\osc, Pfunc{|e|
				if(e[\dur].isKindOf(Rest) != true,{
					vizMessage.(e, i);
				});
				true // !!! must return true !!!
			}
	  	)
	);


	fadeValues[i] = 1.0;
	patterns.put(i,ptn);

	if(i != nil, {
		pairs.put(blob.label, i);
		patterns[i].quant = [1, 0];
		patterns[i].play();
	});
};

//------------------------------------------------------
~onBlobDeinit = {|blob, blobsDict|

	var i = pairs.removeAt(blob.label);
	var fadeTime = 3; //• add to blob
	var fadeRate = 0.1;
	var fadeSteps = (fadeTime / fadeRate).floor;

	if(i != nil,{

		// calcualte fade value (used for visuals)
		// SystemClock.sched(0.0,
		//     Routine({
		//     	fadeSteps.do({

		// 			fadeValues[i] = fadeValues[i] - (1.0 / (fadeTime / fadeRate));

		// 			if(fadeValues[i] < 0.0001, {fadeValues[i] = 0});

		// 	        fadeRate.yield;
		// 	        // fadeValues.postln;
		//     	});
		//     });
		// );
		// patterns[i].stop;
		patterns[i].clear();
		// Ndef.all.values[0].clean;
		patterns.put(i,nil);
		// "off".postln;

	});

};

//------------------------------------------------------
~onBlobUpdate = {|blob, blobsDict|
// [blob.depthCamWidth, blob.depthCamHeight].postln;
};

//------------------------------------------------------
~onPlotData = {|blobsDict|

	blobsDict.size
};

//------------------------------------------------------
~onBlobData = {|blob|

};

