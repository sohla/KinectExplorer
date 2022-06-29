var pairs = Dictionary.new(4);
var patterns = Array.fill(4,{nil});
var fadeValues = [1,1,1,1];
var index = 0;
var noteAddr = nil;
var globalAddr = nil;
var vp;
var group = Group.new;
var root = 0;

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


	SynthDef(\dweep2, {|out = 0, freq = 100.0, amp = 0.1, attack = 0.003, decay = 0.05, sustain = 0.15, release = 2.6, gate = 1, viba = 1.0, dist =0.1|
		
		var enva = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);

		var l = LocalIn.ar(2);
		var j = LFCub.ar( viba, 0, 0.02, 1);

		var sig = PitchShift.ar(
			SinOscFB.ar( [freq, freq + (freq * 0.006)], dist),
		[0.02,0.021],
		j
		);
		LocalOut.ar(sig.tanh);

		// sig = Splay.arFill(3, {|i|
		// 	AllpassL.ar(sig, 0.1, 0.05 * i, 0.2 + (0.1 * i));

		// });

		Out.ar(out, sig * enva * amp);

	}).add;

	SynthDef(\swimming2, {|out = 0, attack = 0.004, release = 1.9, freq = 120, gate = 1, ring = 0.23, amp = 1|

		var env = EnvGen.ar(Env.adsr(attack, 0.07, 0.7,release, 1, -7), gate, doneAction: 2);
		var sig = 0;
		var p, z, trig;
		p = 11;	// number of partials per channel
		p.do({ |i|
			sig = FSinOsc.ar(
					[freq * (i+1+0.02.rand),freq * (i+1+0.01.rand)],
					0,
					Decay2.kr(
						Dust.kr(
							[1,1],
							LFNoise1.kr(0.3 * (i+1), 1.0 / (i+1)**2	)
						),
						0.03,
						ring	
					),
					sig
			);
		});
		Out.ar(out, sig * env * amp);
	}).add;


	noteAddr = patch.noteAddr;
	globalAddr  = patch.globalAddr;


	//----------------------------------------------------------------------------
	// vis
	//----------------------------------------------------------------------------
	globalAddr.sendMsg("/xfade",1.1);//0 off 1 mix 

	~setPolyline.(0,1,1);

	4.0.do({|i|
		var c = [Color.red, Color.blue, Color.green, Color.white];
		~setPolylineColor.(i,c[i].asArray);
	});

	// each polyline (blob)
	// globalAddr.sendMsg("/poly_r", 0); 
	// globalAddr.sendMsg("/poly_g",0.5); 
	// globalAddr.sendMsg("/poly_b", 1); 
	globalAddr.sendMsg("/poly_a", 0.5); 



	~setColorRamp.(Color(0,1,0).asArray, 30);

	// ~setBackground0.();
	~setBackground1.(Color.white.asArray);
	// ~setBackground2.(blur:0.9, step:0.09);
	// ~setBackground3.(index:8, scale:1, rot:0.01, mode:31, color:Color(0,0.8,1).asArray);

	// ~setDisplace.(mix:1.0, x:1.6, y:10, period:3, noise:1.2, z:0);
	~setDisplace.(mix:0.0);
	~setFeedback.(mix:1, opacity:0.8, hue:0.0, x:0, y:0, dx:0.4, dy:0.0, edgeColor:Color(1,1,1).asArray, edgeBlack:0.0, edgeStength:0.0);
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

	var notes = [0,2,4,5,7,9,10];
	
	var ptn = Pdef("jj_"++i,
		Pbind(
		    \instrument, Pswitch([\swimming2,\swimming2,\swimming2,\dweep2], i),
		    \group, group,
			\octave, Pswitch([
				6,
				5,
				5,
				Pseq([[2,3],5,7,6,5,4], inf)
			], i),
			\note, Pswitch([
				13,
				9,
				2,
				Prand([0,5,9].stutter(6), inf)
			], i),
			\root, Pswitch([
				root,
				root,
				root,
				Pseq([0-3,2-3,4-3].stutter(18), inf)
			], i),

			\ring, Pswitch([
				0.1,
				0.1,
				0.1,
				0.1
			], i),

			\dur, Pswitch([
				0.3,
				0.3,
				0.3,
				0.3
			], i),
			\amp, Pswitch([
				2,
				2,
				2,
				0.1
			], i),
		    \dist, Pfunc{blob.rect.getnSynchronous(4)[2].linlin(50,65,0.1,1.3)},
		    \viba, Pfunc{blob.rect.getnSynchronous(4)[3].linlin(80,150,0.1,30)},


		    \attack, 0.02,
		    \decay, 0.02,
		    \sustain, 0.5, //make sure sustain is not to low!
		    \release,  2.6,

		    // \vib, Pfunc{blob.area.getSynchronous.linlin(3,8,0.1,10)},
		    // \test, Pfunc{blob.area.getSynchronous.linlin(3,8,0.1,100)},

		    // \root, Pswitch([
		    // 	Pseq([0].stutter(2), inf),
		    // 	Pseq([0].stutter(32), inf),
		    // 	Pseq([0].stutter(21), inf),
		    // 	Pseq([0].stutter(64), inf),
		    // ], i),


		    // visuals
		    \shape,Pswitch([4,3,5,0], i),//9 textures	
		    \vdur, 0.01,
			\vatt, Pswitch([
				0.01,
				0.01,
				0.01,
				0.01
			], i),
			\vrel, Pswitch([
				0.5,
				0.5,
				0.5,
				0.26
			], i),
		    \color, Pswitch([0,0.25,0.50,PLFTri(100,0,0.5,0.5,inf)], i),
		    \scale, 1,
		    \scx, Pswitch([0.2,0.5,0.2,1], i),
		    \scy, Pswitch([0.2,0.5,0.2,7], i),
		    \sx, Pfunc{blob.center.getnSynchronous(2)[0].linlin(0.11,0.73,-1,1)},
		    \sy, Pswitch([1,1,1,-1], i),
		    \ex, Pkey(\sx),
		    \ey, Pswitch([-1,-1,-1,-1], i),
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
					// if(i==0,{
					// 	~setBackground1.(Color.rand.asArray);
					// });
					// if(i==3,{
					// 	root = e[\root];
					// });
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

