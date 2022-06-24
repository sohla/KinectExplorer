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

	~setPolyline.(1,3,1);

	// 4.0.do({|i|
	// 	var c = Color(0,((i+1)*0.2),1,0.1);
	// 	~setPolylineColor.(i,c.asArray);
	// });

	// each polyline (blob)
	globalAddr.sendMsg("/poly_r", 0); 
	globalAddr.sendMsg("/poly_g",0.5); 
	globalAddr.sendMsg("/poly_b", 1); 
	globalAddr.sendMsg("/poly_a", 0.001); 



	~setColorRamp.(Color(0,0.8,1).asArray, 30);

	// ~setBackground0.();
	// ~setBackground1.(Color.red.asArray);
	// ~setBackground2.(blur:0.9, step:0.09);
	~setBackground3.(index:8, scale:1, rot:0.01, mode:31, color:Color(0,0.8,1).asArray);

	~setDisplace.(mix:1.0, x:1, y:0.2, period:1.2, noise:2, z:0);
	// ~setDisplace.(mix:0.0);
	~setFeedback.(mix:0.1, opacity:0.999, hue:0.02, x:0, y:0.02, dx:0.0, dy:0.0, edgeColor:Color(1,1,1).asArray, edgeBlack:0.0, edgeStength:0.1);
	// ~setFeedback.(mix:0);


};

//------------------------------------------------------
~deinit = {|patch|

	postf("deinit : % \n", patch.file);

	// ~setBackground0.();

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
		    \amp, Pfunc({blob.rect.getnSynchronous(4)[2].linlin(50,150,0.6,0.1)}),
		    // \octave, Prand([4,5,6,7],inf),//Pswitch([Prand([3,4,5,6],inf),6,4,3], i),

		    \octave, Pswitch([2,4,5,6,7],Pfunc({blob.rect.getnSynchronous(4)[2].linlin(50,150,4,0).floor}) ),
		    \attack, 0.02,
		    \decay, 0.02,
		    \sustain, 0.5, //make sure sustain is not to low!
		    \release,  1.9,
		    // \dur, 0.3,
		    // \dur, 0.4,//Pfunc({blob.velocity.getnSynchronous(2)[0].abs.linlin(0,4, 3, 0.1)}),
		    \dur, Pfunc({blob.velocity.getSynchronous.abs.linlin(0,3.4,1.5,0.1)}),
		    \root, Pswitch( notes,Pfunc{blob.center.getnSynchronous(2)[0].linlin(0.31,0.73,0,4).floor}),
		    \note, Pseq([0,4,8], inf),
		    \dt, Pswitch([ Pwhite(0.02,0.03),Pwhite(0.004,0.013),Pwhite(0.001,0.002),0.01] * 1.2, i),
		    \ff, Pwhite(300, 900),
		    \rf, 0.003,
		    \dis, 0.05,
		    \df, Pswitch([1,8,7,4,1]*0.1, i),

		    // visuals
		    \shape,7,//9 textures	
		    \vdur, 0.6,
		    \vatt, 0.01,
		    \vrel, Pswitch([0.97,0.6,0.8,0.5] * 3, i),
		    \color, Pwhite(0.0,1.0),
		    \scale, 10,
		    \scx, 20,
		    \scy, PLFTri(60,0,1,0,inf).linlin(-1,1,0.001,0.01),
		    \sx, Pfunc({blob.center.getnSynchronous(2)[0].linlin(0.3,0.7,-1,1)}),
		    \sy, -0.95,
		    \ex, Pkey(\sx),
		    \ey,  Pwhite(0.7,1),
		    \imageindex, Pwhite(0,15).floor,
		    \rotstart, 0,
		    \rotend, 0,
		    \speed, 1,
		    \vmix, PLFTri(140,0,0.4,0.5,inf),
		    // \freq, 1,
		    \wobble, 0,

		    

		    \bc, Pwhite(0,15),

			\osc, Pfunc{|e| 
				if(e[\dur].isKindOf(Rest) != true,{
					vizMessage.(e, i);
					~setFeedback.(mix:e[\vmix], opacity:0.997, hue:0.02, x:0, y:0.02, dx:0.0, dy:0.0, edgeColor:Color(1,1,1).asArray, edgeBlack:0.0, edgeStength:0.1);
					e[\test].postln;
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

