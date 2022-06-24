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
	SynthDef(\glow, {|out = 0, attack = 0.004, release = 0.9, freq = 100, gate = 1, coef = 0.0, tf = 1, amp = 0.3, ff = 10500, rf = 0.5|
		var env = EnvGen.ar(Env.perc(attack, release, 1, -7), gate, doneAction: 2);
		var trig = Impulse.ar(XLine.ar(tf, 1, attack + (release * 0.5)));
		var sub = LFTri.ar(freq, [0,pi/3], 0.09);
		var sig = Splay.ar({|i|
	    	var f = freq * (i+1);
	    	Pluck.ar(
	    		BrownNoise.ar(1), 
	    		trig,  
	    		f.reciprocal, 
	    		f.reciprocal, 
	    		Demand.ar(trig, 0, Dwhite(1, 10)),
	        	coef: coef
	        )} !2);

		var filter = MoogFF.ar(sig, ff.lag(0.1), rf);
		Out.ar(out, (filter + sub) * env * amp);

	}).add;
	noteAddr = patch.noteAddr;
	globalAddr  = patch.globalAddr;


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
	globalAddr.sendMsg("/poly_a", 0.5); 



	~setColorRamp.(Color(0,1,0).asArray, 50);

	// ~setBackground0.();
	~setBackground1.(Color.black.asArray);
	// ~setBackground2.(blur:0.9, step:0.09);
	// ~setBackground3.(index:8, scale:1, rot:0.01, mode:31, color:Color(0,0.8,1).asArray);

	// ~setDisplace.(mix:1.0, x:1.6, y:10, period:3, noise:1.2, z:0);
	~setDisplace.(mix:0.0);
	 ~setFeedback.(mix:1, opacity:0.96, hue:0.1, x:0, y:0.9, dx:0, dy:0, edgeColor:Color(1,1,1).asArray, edgeBlack:0.0, edgeStength:0.0);
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
	
	var ptn = Pdef("aa_"++i,
		Pbind(
		    \instrument, \glow,
		    \group, group,
		    \amp, 0.3,//Pfunc({blob.rect.getnSynchronous(4)[2].linlin(50,150,0.6,0.1)}),
		    // \octave, Prand([4,5,6,7],inf),//Pswitch([Prand([3,4,5,6],inf),6,4,3], i),

	//	    \octave, Pswitch([2,3,4,5], i),
		    \octave, Pswitch([
		    	7 - Pfunc{blob.center.getnSynchronous(2)[0].linlin(0.31,0.73,1,3).floor},
		    	7 - Pfunc{blob.center.getnSynchronous(2)[0].linlin(0.31,0.73,1,3).floor},
		    	5 - Pfunc{blob.center.getnSynchronous(2)[0].linlin(0.31,0.73,1,3).floor},
				Pseq([2,3,4,3], inf) * Pfunc{blob.center.getnSynchronous(2)[0].linlin(0.31,0.73,1,3).floor},
		    ], i),
		    \attack, 0.02,
		    \decay, 0.02,
		    \sustain, 0.5, //make sure sustain is not to low!
		    \release,  Pfunc({blob.rect.getnSynchronous(4)[2].linlin(50,150,0.2,3.2)}),
		    // \dur, 0.2,
		    \dur, Pswitch([
		    	4,
		    	Pseq([0.125,0.125,Rest(0.5)], inf),
		    	0.125*3,
		    	0.125
		    ], i),

		    // \note, Pswitch( notes,Pfunc{blob.center.getnSynchronous(2)[0].linlin(0.31,0.73,0,6).floor}),
		    
		    \note, Pswitch([
		    	Pseq([[0,4,-2],[2,5,0]].stutter(1), inf),
		    	Pseq([-2,10], inf),
		    	Pseq([7,5,4,2,-2].stutter(3), inf),
			    Pseq([0,0,-2,4,0,0,5,-2,5,5,-2,2,0,7,7,7].stutter(4), inf)
		    ], i),

		    \root, Pswitch([
		    	Pseq([0].stutter(2), inf),
		    	Pseq([0].stutter(32), inf),
		    	Pseq([0].stutter(21), inf),
		    	Pseq([0].stutter(64), inf),
		    ], i),

		    // \root, Pseq([0,5,-2].stutter(60), inf),
		    \dt, Pswitch([ Pwhite(0.02,0.03),Pwhite(0.004,0.013),Pwhite(0.001,0.002),0.01] * 1.2, i),
		    \ff, Pwhite(300, 900),
		    \rf, 0.003,
		    \dis, 0.05,
		    \df, Pswitch([1,8,7,4,1]*0.1, i),
		    \coef, Pswitch([
		    	0.3,
		    	Pwhite(0.001,0.1),
		    	0.3,
				Pwhite(0.9,0.87),
		    ], i),
		    \tf, Pswitch([40,1,1,1], i),
		    \ff, 11400,
		    \rf, 1,
		    // visuals
		    \shape,7,//9 textures	
		    \vdur, 0.01,
		    \vatt, 0.01,
		    \vrel, 0.6,
		    \color, Pswitch([0,0.25,0.50,0.75], i),
		    \scale, 1,
		    \scx, Pfunc({blob.rect.getnSynchronous(4)[2].linlin(50,150,0.7,2)}),
		    \scy, 0.1,
		    \sx, Pfunc{blob.center.getnSynchronous(2)[0].linlin(0.31,0.73,-1,1)},
		    \sy, -0.9,
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

