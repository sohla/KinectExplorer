var pairs = Dictionary.new(4);
var patterns = Array.fill(4,{nil});
var fadeValues = [1,1,1,1];
var index = 0;
var noteAddr = nil;
var globalAddr = nil;
var vp;
var group = Group.new;
var verbSynth;
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



	SynthDef(\conex, {|out = 0, gate = 1, amp = 0.5, freq = 120, attack = 0.007, release = 0.9, vib = 2, va = 0.01, ring = 0.1|


		var fs = Array.geom(5, freq, 2.01);
		var as = [0.7,0.5,0.05,0.02,0.01,0.005];
		var ff = Array.rand(5, vib, vib + (vib/4));
		var rs = Array.series(5, 16, -1.3);
		var env = EnvGen.ar(Env.perc(attack, release), gate, doneAction: 2);
		var nenv = EnvGen.ar(Env.perc(attack * 0.01, release * 0.01));
		var venv = EnvGen.ar(Env.perc(attack * 2, release * 2));
		var imp = BLowShelf.ar(HPF.ar( LPF.ar(PinkNoise.ar((0.007 * nenv)), 16000), 240), 40, 1, -2).clip;
		var sig = DynKlank.ar(
			`[fs * LFCub.ar(ff,0,va*env,1), as, rs], 
			imp,
			[1,1.012], 0 ,ring) ;
		Out.ar(out, sig * amp * env * 30);

	}).add;


	SynthDef(\delay1, {|inBus = 0, outBus = 0, gate = 1|
		var in = In.ar(inBus, 2);
		var env = EnvGen.ar(Env.adsr(0.01,0.01,1,3), gate, doneAction: 2);
		var sig = CombL.ar(in, 1/4, 1/4, 0.2);
		Out.ar(outBus, (in+sig) * env);
	}).add;

	noteAddr = patch.noteAddr;
	globalAddr  = patch.globalAddr;

	// verbSynth  = Synth.head(group,\delay1, [\inBus, bus, \outBus,0]);

	//----------------------------------------------------------------------------
	// vis
	//----------------------------------------------------------------------------
	globalAddr.sendMsg("/xfade",0.1);//0 off 1 mix 

	~setPolyline.(1,1,0);

	4.0.do({|i|
		var c = [Color.white, Color.blue, Color.green, Color.white];
		~setPolylineColor.(i,Color.red.asArray);
	});

	// each polyline (blob)
	// globalAddr.sendMsg("/poly_r", 0); 
	// globalAddr.sendMsg("/poly_g",0.5); 
	// globalAddr.sendMsg("/poly_b", 1); 
	globalAddr.sendMsg("/poly_a", 1); 



	~setColorRamp.(Color(0,1,0).asArray, 50);

	// ~setBackground0.();
	~setBackground1.(Color(1,0,1).asArray);
	// ~setBackground2.(blur:0.9, step:0.09);
	// ~setBackground3.(index:8, scale:1, rot:0.01, mode:31, color:Color(0,0.8,1).asArray);

	~setDisplace.(mix:1.0, x:3, y:3, period:5, noise:1.2, z:0.3);
	// ~setDisplace.(mix:0.0);
	 ~setFeedback.(mix:0.9, opacity:0.96, hue:0.1, x:0, y:0.0, dx:-0.2, dy:-0.2, edgeColor:Color(1,1,1).asArray, edgeBlack:0.0, edgeStength:0.0);
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
		    \instrument, \conex,
		    // \out, bus,
		    \group, group,

			\octave, Pswitch([
				Prand([3,4], inf),
				Prand([3,7], inf),
				Prand([1], inf),
				Prand([3,4,5,6,7], inf)
			], i),
			\note, Pswitch([
				Prand([0,2,3,5], inf),
				Prand([0,-2,-4,-5,-7], inf),
				0,
				Prand([0,2,-2,-4,5,7], inf)
			], i),
			\root, Pswitch([
				0,
				0,
				0,
				Pseq([0].stutter(12), inf)
			], i),
			\dur, Pswitch([
				Prand([1,2], inf),
				Prand([3/4] * 2, inf),
				1/2,
				Prand([1/4,1/4,1/8], inf)
			], i),
			\amp, Pswitch([
				0.3,
				0.4,
				0.4,
				0.2
			]*3, i),
			\attack, Pswitch([
				0.7,
				Pwhite(0.02,0.13),
				Pwhite(0.01,0.03),
				Pwhite(0.003,0.01)
			], i),
			\release, Pswitch([
				11,
				Pwhite(2.5,3.4),
				Pwhite(0.5,1.1),
				Pwhite(0.1,5.6)
			], i),
			\vib, Pswitch([
				5,
				50,
				10,
				Prand([1,2,20,200], inf)
			], i),
		    // \ring, Pfunc({blob.rect.getnSynchronous(4)[3].linlin(130,160,0.01,0.9)}),
		    \ring, Pfunc({blob.area.getSynchronous.linlin(6,8,0.01,0.9)}),
		    \va, Pfunc({blob.center.getnSynchronous(2)[0].linlin(0.11,0.72,0.005,0.06)}),


		    // visuals
		    \shape,7,
		    \vdur, 0.03,
		    \vatt, 0.01,
		    \vrel, 0.1,
		    \color, Pswitch([0,0.25,0.50,0.75], i),
		    \scale, 1,
		    \scx, 10,//Pfunc({blob.rect.getnSynchronous(4)[2].linlin(50,150,0.7,2)}),
		    \scy, Pswitch([
				5,
				0.1,
				0.2,
				0.01
			], i),
		    \sx, Pswitch([
				0,
				0,
				0,
				0
			], i),
		    \sy, Pswitch([
				0.5,
				0,
				-0.9,
				0.8
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
					if(i==1,{
						// "go".postln;
							 ~setFeedback.(mix:1.0.rand, opacity:0.96, hue:0.1, x:0, y:0.0, dx:-0.2, dy:-0.2, edgeColor:Color(1,1,1).asArray, edgeBlack:0.0, edgeStength:0.0);

					});
					// e[\test].postln;
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

