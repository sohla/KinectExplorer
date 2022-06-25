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



	SynthDef(\blaz, {|out = 0, freq = 120, amp = 0.5, attack = 0.01, decay = 0.03, sustain = 0.8, release = 0.9, gate = 1, harm = 1, rq = 0.2, fa = 10000|

		var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var sig = (BHiPass.ar(
			LFNoise2.ar(2)**1.4,
			[freq, freq + (freq * 0.01)],
			rq, //MouseX.kr(0.001,0.3,\exponential),
			fa - freq)
		).tanh  * 0.3;
		var vib = LFCub.ar(freq * harm, 0, env, 1);
		Out.ar(out, LeakDC.ar(sig) * amp * env * vib);
	}).add;


	noteAddr = patch.noteAddr;
	globalAddr  = patch.globalAddr;

	// verbSynth  = Synth.head(group,\delay1, [\inBus, bus, \outBus,0]);

	//----------------------------------------------------------------------------
	// vis
	//----------------------------------------------------------------------------
	globalAddr.sendMsg("/xfade",1);//0 off 1 mix 

	~setPolyline.(0,1,1);

	4.0.do({|i|
		var c = [Color.red, Color.blue, Color.green, Color.white];
		~setPolylineColor.(i,c[i].asArray);
	});

	// each polyline (blob)
	// globalAddr.sendMsg("/poly_r", 0); 
	// globalAddr.sendMsg("/poly_g",0.5); 
	// globalAddr.sendMsg("/poly_b", 1); 
	globalAddr.sendMsg("/poly_a", 1); 



	~setColorRamp.(Color(1,0.1,0).asArray, 50);

	// ~setBackground0.();
	~setBackground1.(Color.white.asArray);
	// ~setBackground2.(blur:0.99, step:0.3);
	// ~setBackground3.(index:8, scale:1, rot:0.01, mode:31, color:Color(0,0.8,1).asArray);

	// ~setDisplace.(mix:1.0, x:1.6, y:10, period:0.3, noise:1.2, z:0);
	~setDisplace.(mix:0.0);
	 ~setFeedback.(mix:1, opacity:0.96, hue:0.1, x:0, y:-0.1, dx:1, dy:1, edgeColor:Color(1,0,0).asArray, edgeBlack:0.0, edgeStength:0.2);
	// ~setFeedback.(mix:0);


};

//------------------------------------------------------
~deinit = {|patch|

	postf("deinit : % \n", patch.file);
// 
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

	var notes = [0,2,4,5,7,9,10];
	
	var ptn = Pdef("dd_"++i,
		Pbind(
		    \instrument, \blaz,
		    \group, group,
		    \amp, 0.23,
			\octave, Pfunc{blob.center.getnSynchronous(2)[0].linlin(0.31,0.73,2,7).floor},//Prand([2,3,4,5]+1, inf),

			\attack, Pwhite(0.02, 0.045),
		    \decay, 0.02,
		    \sustain, 0.5, //make sure sustain is not to low!
			\release, Pfunc{blob.rect.getnSynchronous(4)[3].linlin(50,120,1.1,0.02)},

			\note, Prand([0,4,5,7,10,12], inf),
			\root, Pseq([0].stutter(8*8), inf),
			\dur, Pswitch([
		    	Pseq([Rest(2/6), Rest(1/6), 1/6], inf),
		    	Pseq([Rest(2/6), 1/6, Rest(1/6)], inf),
		    	Pseq([Rest(1/6), 1/6, Rest(2/6)], inf),
				Pseq([1/6,Rest(1/6), Rest(2/6)], inf),
		    ]


			\harm, Pwhite(1,2),
			\rq, Pfunc{blob.rect.getnSynchronous(4)[3].linlin(50,120,0.6,0.08)},//Pwhite(0.1,0.3),
			\fa, Pfunc{blob.center.getnSynchronous(2)[0].linexp(0.31,0.73,1050,18000)},


		    // visuals
		    \shape,Pswitch([7,7,7,7],i),//9 textures	
		    \vdur, 0.08,
		    \vatt, 0.02,
		    \vrel, 0.1,
		    \color, Pswitch([0,0.25,0.50,0.75], i),
		    \scale, Pswitch([0.8,0.2,0.3,0.3],i),
		    \scx, 3,//Pfunc({blob.rect.getnSynchronous(4)[2].linlin(50,150,0.7,2)}),
		    \scy, 20,
		    \sx, Pfunc{blob.center.getnSynchronous(2)[0].linlin(0.31,0.73,-1,1)},
		    \sy, 0,
		    \ex, Pkey(\sx),
		    \ey,  Pkey(\sy),
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

