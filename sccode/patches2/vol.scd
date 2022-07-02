var pairs = Dictionary.new(4);
var patterns = Array.fill(4,{nil});
var fadeValues = [1,1,1,1];
var index = 0;
var noteAddr = nil;
var globalAddr = nil;
var vp;
var group = Group.new;
var roots = [0,5,-2];
var root = Bus.control(s,1);
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


	SynthDef(\fm, {
		arg out=0, pan=0, amp=0.25, freq=111, atk=0.03, rel=0.2,
		mInd1=0.5, mInd2=0.5, mInd3=0.5, mInd4=0.5, mInd5=0.5, mInd6=0.5;

		var gainEnv = EnvGen.ar(Env.perc(atk, rel), \gt.kr(1), doneAction:2);
		var sig, cascade_0, cascade_1;

		cascade_0 = SinOsc.ar(freq, SinOsc.ar(freq * \ratio3.kr(1), pi * 0.5).range(0, mInd3) ) * \amp_3.kr(0.5);
		cascade_0 = SinOsc.ar(freq, SinOsc.ar(freq * \ratio2.kr(1), pi * 0.5).range(0, mInd2) + cascade_0.range(0,mInd2)) * \amp_2.kr(0.5);
		cascade_0 = SinOsc.ar(freq, SinOsc.ar(freq * \ratio1.kr(1), pi * 0.5).range(0, mInd1) + cascade_0.range(0,mInd1)) * \amp_1.kr(0.5);

		cascade_1 = SinOsc.ar(freq, SinOsc.ar(freq * \ratio6.kr(1), pi * 0.5).range(0, mInd6) + LocalIn.ar(1).range(0, mInd6)) * \amp_6.kr(0.5);
		cascade_1 = SinOsc.ar(freq, SinOsc.ar(freq * \ratio5.kr(1), pi * 0.5).range(0, mInd5) + cascade_1.range(0,mInd5)) * \amp_5.kr(0.5);
		cascade_1 = SinOsc.ar(freq, SinOsc.ar(freq * \ratio4.kr(1), pi * 0.5).range(0, mInd4) + cascade_1.range(0,mInd4)) * \amp_4.kr(0.5);

		LocalOut.ar(cascade_1 * \fb.kr(0.9));

		sig = Mix([cascade_0, cascade_1]);

		sig = sig * gainEnv;

		sig = Pan2.ar(sig, pan, amp);
		sig = LeakDC.ar(sig);
		OffsetOut.ar(out, sig)
	}).add;

	noteAddr = patch.noteAddr;
	globalAddr  = patch.globalAddr;


	//----------------------------------------------------------------------------
	// vis
	//----------------------------------------------------------------------------
	globalAddr.sendMsg("/xfade",1.1);//0 off 1 mix 

	~setPolyline.(1,1,1);

	4.0.do({|i|
		var c = [Color.red, Color.blue, Color.green, Color(1,1,0)];
		~setPolylineColor.(i,c[i].asArray);
	});

	// each polyline (blob)
	// globalAddr.sendMsg("/poly_r", 0); 
	// globalAddr.sendMsg("/poly_g",0.5); 
	// globalAddr.sendMsg("/poly_b", 1); 
	globalAddr.sendMsg("/poly_a", 0.5); 



	~setColorRamp.(Color(0,1,0).asArray, 90);

	// ~setBackground0.();
	~setBackground1.(Color(1,1,0).asArray);
	// ~setBackground2.(blur:0.9, step:0.09);
	// ~setBackground3.(index:8, scale:1, rot:0.01, mode:31, color:Color(0,0.8,1).asArray);

	~setDisplace.(mix:1.0, x:3, y:1, period:3, noise:1.2, z:0);
	// ~setDisplace.(mix:0.0);
	~setFeedback.(mix:1, opacity:0.494, hue:0.0, x:0, y:-0.0, dx:-1.0, dy:-1.0, edgeColor:Color(0,0,0).asArray, edgeBlack:0.0, edgeStength:1.0);
	 //~setFeedback.(mix:0);

	//----------------------------------------------------------------------------
	vp = Pdef("vas_",
		Pbind(
			\amp, 0,
			\dur, 20,
			\func, Pfunc({|e|
				// ~setBackground3.(index:10.rand.floor, scale:e[\sc], rot:0, mode:9, color:Color(1,e[\yellow],0).asArray);
				roots = roots.rotate(-1);
				// roots[0].postln;
				root.set(roots[0]);

			})
		)
	).play;
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
	vp.clear;
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
		    \instrument, \fm,
		    \group, group,
			\octave, Pswitch([
				4,
				6,
				5,
				Pseq([2,3], inf)
			], i),
			\note, Pswitch([
				Pseq([7,9].stutter(1), inf),
				Pseq([9,7,12,9].stutter(8), inf),
				Pseq([0,4,5,7,4,5].stutter(8), inf),
				Pseq([0,5,9].stutter(4), inf)
			], i),
			\root, Pfunc{root.getSynchronous},

			\ring, Pswitch([
				0.1,
				0.1,
				0.1,
				0.1
			], i),

			\dur, Pswitch([
				Pseq([0.2,0.3,0.3,0.2], inf),
				Pseq([0.2,0.4,0.2,0.2], inf),
				Pseq([0.2,0.1,Rest(0.2),0.2], inf),
				0.2
			], i),
			\amp, Pswitch([
				0.3,
				0.2,
				0.4,
				1
			] * 0.45, i),
			\mInd1, Pwhite(0,5),
			\mInd2, Pwhite(0,0.4),
			\mInd3, Pwhite(0,0.5),
			\mInd4, Pwhite(0,5),
			\mInd5, Pwhite(0,0.2),
			\mInd6, Pwhite(0,0.1),			
				    

		    \atk, Pswitch([
				Pwhite(0.06,0.006),
				Pwhite(0.006,0.002),
				Pwhite(0.06,0.006),
				Pwhite(0.008,0.003)
			], i),

		    \decay, 0.02,
		    \sustain, 0.5, //make sure sustain is not to low!
		    \rel,  Pswitch([
				Pwhite(0.1,0.9),
				Pwhite(0.1,0.3),
				Pwhite(0.1,0.9),
				Pwhite(0.1,0.2)
			], i),

		    // \vib, Pfunc{blob.area.getSynchronous.linlin(3,8,0.1,10)},
		    // \test, Pfunc{blob.area.getSynchronous.linlin(3,8,0.1,100)},

		    // \root, Pswitch([
		    // 	Pseq([0].stutter(2), inf),
		    // 	Pseq([0].stutter(32), inf),
		    // 	Pseq([0].stutter(21), inf),
		    // 	Pseq([0].stutter(64), inf),
		    // ], i),


		    // visuals
		    \shape,Pswitch([0,0,0,0], i),//9 textures	
		    \vdur, 0.01,
			\vatt, Pswitch([
				0.01,
				0.01,
				0.01,
				0.01
			], i),
			\vrel, Pswitch([
				0.1,
				0.1,
				0.1,
				0.1
			], i),
		    \color, Pswitch([
		    	PLFTri(80,0,0.1,0.6,inf),
		    	PLFTri(80,0,0.1,0.4,inf),
		    	PLFTri(80,0,0.1,0.2,inf),
		    	PLFTri(80,0,0.1,0.0,inf)
		    ], i),
		    \scale, 1,
		    \scx, 1.3,
		    \scy, 0.8,
		    \sx, Pfunc{blob.center.getnSynchronous(2)[0].linlin(0.21,0.83,-1,1)},
		    \sy, Pswitch([
				Pkey(\note).linlin(6,11,-1,1),
				Pkey(\note).linlin(6,16,-1,1),
				Pkey(\note).linlin(0,12,-1,1),
				Pkey(\note).linlin(4,13,-1,1)
			], i),

		    \ex, Pkey(\sx),
		    \ey, Pkey(\sy),
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

