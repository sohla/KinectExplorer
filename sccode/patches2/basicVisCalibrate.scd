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

	globalAddr.sendMsg("/xfade",10);//0 off 1 mix 

	~setPolyline.(1,3,1, Color(1,1,1,1).asArray);

	// each polyline (blob)
	4.0.do({|i|
		var c = Color.red;
		~setPolylineColor.(i,c.asArray);
	});


	// global color ramp
	globalAddr.sendMsg("/ramp_r", 1); 
	globalAddr.sendMsg("/ramp_g", 0.0); 
	globalAddr.sendMsg("/ramp_b", 0.0); 

	globalAddr.sendMsg("/ramp_hue1", 0); 

	// background
	globalAddr.sendMsg("/background_index",1);//0 off 1 mix 
	
	// background (index 1)
	globalAddr.sendMsg("/background_r", 1); 
	globalAddr.sendMsg("/background_g", 1); 
	globalAddr.sendMsg("/background_b", 0); 

	// background (index 2)
	globalAddr.sendMsg("/cell_blur", 0.9);
	globalAddr.sendMsg("/cell_step", 0.03);

	// background (index 3)
	globalAddr.sendMsg("/background_image_index", 2); 
	globalAddr.sendMsg("/background_image_scale",3); 
	globalAddr.sendMsg("/background_image_rotspeed", 0); 
	globalAddr.sendMsg("/background_image_blendmode",1); //0-look it up!

	// displace polyline
	globalAddr.sendMsg("/displace_mix", 0);//on/off 
	globalAddr.sendMsg("/displace_x", 10); 
	globalAddr.sendMsg("/displace_y", 10); 
	globalAddr.sendMsg("/displace_period", 0.3); 
	globalAddr.sendMsg("/displace_noise_harmonic", 0); 
	globalAddr.sendMsg("/displace_speedz",1); 


	globalAddr.sendMsg("/feedback_mix", 0); 
	globalAddr.sendMsg("/feedback_opacity", 0.98); 

	globalAddr.sendMsg("/feedback_hue", 0); 

	globalAddr.sendMsg("/feedback_x", 0); //-1 1
	globalAddr.sendMsg("/feedback_y", 0); 

	globalAddr.sendMsg("/feedback_displacex",0.0); //-1 1
	globalAddr.sendMsg("/feedback_displacey", 0.0); 

	globalAddr.sendMsg("/feedback_edge_r", 1); 
	globalAddr.sendMsg("/feedback_edge_g", 1); 
	globalAddr.sendMsg("/feedback_edge_b", 1); 

	globalAddr.sendMsg("/feedback_edge_blacklevel", 0.0); 
	globalAddr.sendMsg("/feedback_edge_strength", 0.0); 

	// vp = Pdef("va_",
	// 	Pbind(
	// 		\amp, 0,
	// 		\dur, 0.3,
	// 		\func, Pfunc({|e|
	// 			1.0.do({|i|
	// 				// var i = 2 ;
	// 				var c = Color.rand(0.0,1.0);
	// 					// globalAddr.sendMsg("/background_image_scale", 0); 
	// 					// globalAddr.sendMsg("/background_image_index", 10.rand.floor); 
	// 					// globalAddr.sendMsg("/background_image_scale", 2.rand.floor); 

	// 					// globalAddr.sendMsg("/background_image_index", 12.rand.floor); 

	// 				// // [i,c].postln;
	// 				// globalAddr.sendMsg("/poly_r"++(i+1), c.red); 
	// 				// globalAddr.sendMsg("/poly_g"++(i+1), c.green); 
	// 				// globalAddr.sendMsg("/poly_b"++(i+1), c.blue); 
	// 				// globalAddr.sendMsg("/poly_a"++(i+1), 0.5); 
	// 					// globalAddr.sendMsg("/feedback_mix", 2.rand.floor); 
	// // globalAddr.sendMsg("/feedback_displacex",2.rand.floor); //-1 1
	// // globalAddr.sendMsg("/feedback_displacey", 2.rand.floor); 
	// // globalAddr.sendMsg("/displace_mix", 2.0.rand.floor); 

	// 					// globalAddr.sendMsg("/background_r", c.red); 
	// 					// globalAddr.sendMsg("/background_g", c.green); 
	// 					// globalAddr.sendMsg("/background_b", c.blue); 

	// 			});
	// 		})
	// 	)
	// ).play;

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
				"shape", e[\shape],
				"duration", e[\vdur],
				"attack", e[\vatt],
				"release", e[\vrel],
				"color", e[\color],
				"scale", e[\scale],//* fadeValues[i],
				"sx", e[\sx],
				"sy", e[\sy],
				"ex", e[\ex],
				"ey", e[\ey],
				"scx", e[\scx],
				"scy", e[\scy],

				"imageindex", e[\imageindex],
				"rotstart",e[\rotstart],
				"rotend", e[\rotend],

				"speed", 1,//e[\speed],
				"amp", 0.04,//????

				"wobble", e[\wobble],
			);}.defer(0.1);
		});
	};

	var notes = [0,4,8,12];
	
	var ptn = Pdef("aa_"++i,
		Pbind(
		    \instrument, Pswitch([\ab,\ab,\ab,\ab], i),
		    \group, group,
		    \amp, Pswitch([0.5,0.3,0.4,0.4]*1, i),
		    \octave, Pswitch([3,6,4,3], i),
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
		    ], i),
		    \root, Pswitch( notes,Pfunc{blob.center.getnSynchronous(2)[0].linlin(0.31,0.73,0,4).floor}),
		    \note, Pseq([0,7,11], inf),
		    \dt, Pswitch([ Pwhite(0.02,0.03),Pwhite(0.004,0.013),Pwhite(0.001,0.002),0.01] * 1.2, i),
		    \ff, Pwhite(300, 900),
		    \rf, 0.003,
		    \dis, 0.05,
		    \df, Pswitch([1,8,7,4,1]*0.1, i),

		    // visuals
		    \shape,7,//9 textures	
		    \vdur, 0.02,
		    \vatt, 0.01,
		    \vrel, 0.3,
		    \color, Pwhite(0.0,0.999),
		    \scale,1,
		    \scx,1,
		    \scy, 1,
		    \sx, Pfunc({blob.center.getnSynchronous(2)[0].linlin(0.31,0.72,-1,1)}),
		    \sy, 0,
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

