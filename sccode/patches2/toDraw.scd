var pairs = Dictionary.new(4);
var patterns = Array.fill(4,{nil});
var fadeValues = [1,1,1,1];
var index = 0;
var noteAddr = nil;
var globalAddr = nil;
var vp;
var group = Group.new;
var verbSynth;
var roots = [0,4,-1, 2];
// var bus = Bus.audio(s,2);

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


	SynthDef(\drawing1, {|out =0, attack = 0.1, release = 12.9, freq = 120, gate = 1, vib = 1, amp = 0.7, flt = 10000, lfoa = 0.2, lfof = 4|

		var env = EnvGen.ar(Env.perc(attack, release, 1, -7), gate, doneAction: 2);
		var fs = Array.makeScaleCps(groundNote: 263, type: 'major');
		var as = [1,0.1,0.2,0.02,1,0.3,0.7,0.5];
		var lfo = LFCub.ar(lfof,0,lfoa).linlin(-1,1,0.2,0.4);
		var rs = [1];
		var sig = Splay.arFill(1,
			{

				DynKlank.ar(
					`[freq + (lfo * freq), as, rs], 
					LPF.ar(PinkNoise.ar(0.007), flt);
				) * 0.5

			},
			1,
			1,
			0);
		Out.ar(out, sig * env * amp);
	}).add;

	noteAddr = patch.noteAddr;
	globalAddr  = patch.globalAddr;

	//----------------------------------------------------------------------------
	// vis
	//----------------------------------------------------------------------------
	globalAddr.sendMsg("/xfade",1);//0 off 1 mix 

	~setPolyline.(1,0.1,0);

	4.0.do({|i|
		var c = [Color.red, Color.blue, Color.green, Color.white];
		~setPolylineColor.(i,Color.grey.asArray);
	});

	// each polyline (blob)
	globalAddr.sendMsg("/poly_r", 1); 
	globalAddr.sendMsg("/poly_g",1); 
	globalAddr.sendMsg("/poly_b", 1); 
	globalAddr.sendMsg("/poly_a", 1); 



	~setColorRamp.(Color(0.5,1,0.5).asArray, 50);

	// ~setBackground0.();
	~setBackground1.(Color.white.asArray);
	// ~setBackground2.(blur:0.9, step:0.09);
	// ~setBackground3.(index:8, scale:1, rot:0.01, mode:31, color:Color(0,0.8,1).asArray);

	~setDisplace.(mix:1.0, x:1, y:1, period:3.2, noise:1.2, z:1);
	// ~setDisplace.(mix:0.0);
	  ~setFeedback.(mix:1, opacity:0.8987, hue:0.1, x:0, y:0.3, dx:-0.03, dy:-0.03, edgeColor:Color(0.2,0.5,0.8).asArray, edgeBlack:0.0, edgeStength:0.0);
	// ~setFeedback.(mix:0);


};

//------------------------------------------------------
~deinit = {|patch|

	postf("deinit : % \n", patch.file);

	// verbSynth.set(\gate, 0);

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
			\instrument, \drawing1,
		    // \out, bus,
		    \group, group,
		    \amp, 0.23,

			// \octave, Pseq([4,5,4,5], inf),
			// \note, Pseq([0,7,16], inf),
			\root, 2,//Pseq([0,4,-1, 2].stutter(20), inf),
			// \dur, Pseq([1/5, 1/5, 1/2.5, 1/5] * 3, inf),
			\amp, 1,
			\attack, Pwhite(0.01,0.04, inf),
			// \release, Pwhite(0.4,1.9, inf),

			\octave, Pswitch([
				Prand([6], inf),
				Prand([4], inf),
				Prand([3], inf),
				Prand([5], inf)
			], i),
			\note, Pswitch([
				Pseq([0,12,14,11,15], inf),
				Pxrand([15,17,19,21,23,26,29], inf),
				Pseq([0,-12,8,7], inf),
				Pseq([0,3,2,3], inf)
			], i),
			\dur, Pswitch([
				Pseq([0.3, Rest(0.3), 0.3] / 3, inf),
				1.2,
				Pseq([1.2, Rest(0.6), 0.6], inf),
				Pseq([0.6, Rest(0.3), 0.3, 0.3], inf)
			], i),
			\release, Pswitch([
				0.1,
				Pwhite(1.5,1.2),
				Pwhite(0.5,1.1),
				Pwhite(0.3,3.6)
			], i),

		    // visuals
		    \shape,Pswitch([3,0,5,8], i),
		    \vdur, 0.02,
		    \vatt, 0.01,
		    \vrel, 0.1,
		    \color, Pswitch([
		    	PLFTri(110,0,0.4,0.5,inf),
		    	PLFTri(190,0,0.4,0.5,inf),
		    	PLFTri(100,0,0.4,0.5,inf),
		    	PLFTri(240,0,0.4,0.5,inf)], i),
		    \scale, Pswitch([0.3,1,0.5,0.2], i),
		    \scx, Pswitch([1,20,1,1], i),
		    \scy, Pswitch([1,0.2,1,-1], i),
		    \sx, Pfunc{blob.center.getnSynchronous(2)[0].linlin(0.11,0.83,-1,1)},
		    \sy, -0.1,//Pfunc{blob.center.getnSynchronous(2)[1].linlin(0.2,0.93,-1,1)},
		    \ex, Pkey(\sx),// + Pwhite(-0.7,0.7),
		    \ey, -0.8,//Pwhite(0.0,0.6),
		    \imageindex, Pwhite(0,15).floor,
		    \rotstart, 0,
		    \rotend, 0,
		    \speed, 1,
		    \vmix, PLFTri(140,0,0.4,0.5,inf),
		    // \freq, 1,
		    \wobble, 8,

		    

		    \bc, Pwhite(0,15),

			\osc, Pfunc{|e| 
				if(e[\dur].isKindOf(Rest) != true,{
					vizMessage.(e, i);
					if(i==1,{
						roots = roots.rotate(-1);
					});
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

