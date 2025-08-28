var oct = 0;
var note = 0;
var scale = 1;
var poolSize = 4;
var isPlayingBlob = Array.fill(poolSize, false);
var patterns = Array.new(poolSize);
var cb = [Bus.control(s,1),Bus.control(s,1),Bus.control(s,1),Bus.control(s,1),Bus.control(s,1)];
var binds = Array.new(poolSize);
var notes = [Bus.control(s,1),Bus.control(s,1),Bus.control(s,1),Bus.control(s,1),Bus.control(s,1)];
var oscSender;
var vizMessage;

//------------------------------------------------------
~init = {|model|

	postf("init : % \n", model.file);
	oscSender = model.netAddr;


	vizMessage = {|e, i|
		oscSender.sendMsg("/shadow", 

			"shape", 3,

			"duration", e.dur,
			"attack", e.attack * 1,
			"release", e.rel * 1,

			"color", i.linlin(0,3,0,0.99),

			"scale", 2,

			"sx", cb[i].getSynchronous.(),
			"sy", 0,
			"ex", cb[i].getSynchronous.(),
			"ey", 0,

			"imageindex", e.ii,

			"rotstart",45,
			"rotend", 45,

			"amp", 0.43,
			"speed", 2,
			"freq", 3,

			"wobble", 6,
		);
	};



	SynthDef(\glow, {|out = 0, attack = 0.004, release = 0.9, freq = 100, gate = 1, vib = 1, coef = 0.0|

		var env = EnvGen.ar(Env.perc(attack, release, 1, -7), gate, doneAction: 2);
		 var trig = Impulse.ar(XLine.ar(40, 1, attack + (release * 0.5)));
		//var trig = MouseX.kr(0.1,100);
		var sig = Splay.ar({|i|
	    	var f = freq * 2.pow(i+1) * 0.5;
	    	Pluck.ar(
	    		BrownNoise.ar(0.2), 
	    		trig,  
	    		f.reciprocal, 
	    		f.reciprocal, 
	    		Demand.ar(trig, 0,Dwhite(1, 10)),
	        	coef: coef//MouseY.kr(-0.999, 0.999, lag:1.6)  
	        )} !2);


		Out.ar(out, sig * env);

	}).add;





	poolSize.do({|i|
	
		var bi =	Pbind(

		    \instrument, \glow, //Pswitch([\b, \c, \a, \d], i, inf),


			\octave, Pswitch([2, 4, 5, 6], i, inf),
			// \note, Pseq([0,3,7,11,12], inf),


			\note, Pswitch(
		    
		    	[Pseq([0,12], inf), 
		    	Pseq([3,7,0], inf), 
		    	Pseq([0,7,12,7], inf), 
		    	Pseq([11,12,0,11,12], inf)], i, inf),

			\root, Pseq([0,-3,2,-1].stutter(16), inf),
			\dur, Prand([0.5], inf),
			\dur, 0.15,
			\amp, 0.1,
			\attack, Pwhite(0.01,0.02, inf),
			\release, Pwhite(0.3,0.6, inf),
			\coef, Pwhite(0.6,0.01, inf),


		    // \amp, Pwhite(0.3, 0.2),
		    // \root, Pseq([0, -2].stutter(70), inf),//Pfunc{ notes[i].getSynchronous.()},
		    // \scale, 1,

		    // \octave, Pswitch([3, 4, 5, 6], i, inf),

		    // \note, Pswitch(
		    
		    // 	[Pseq([0,5,10], inf), 
		    // 	Pseq([5,4,0], inf), 
		    // 	Pseq([0,7,2,5,4], inf), 
		    // 	Pseq([0,12,10,2,4], inf)], i, inf),
		    // \stretch, 1.3,
		    // \dur, Pswitch(
		    
		    // 	[Pseq([0.2], inf), 
		    // 	Pseq([0.2, 0.4], inf), 
		    // 	Pseq([0.4, 0.1, 0.1], inf), 
		    // 	Pseq([0.2, 0.2, 0.2], inf)], i, inf),

		    // \harm, Pswitch([1, 3, 7, 11], i, inf),
		    // \attack, Pwhite(0.007,0.01),
		    // \decay, Pswitch(
		    // 	[Pseq([0.1], inf), 
		    // 	Pseq([0.3], inf), 
		    // 	Pseq([0.2], inf), 
		    // 	Pseq([1.3], inf)], i, inf),
		    // \release, Pswitch(
		    // 	[Pseq([0.1], inf), 
		    // 	Pseq([0.4], inf), 
		    // 	Pseq([0.2], inf), 
		    // 	Pseq([1.2], inf)], i, inf),



		    \rel, Pkey(\release),
		    \ff, Pwhite(300, 7000),
		    \rf, Pseq([3,0,3,1,1,3,1], inf),

		    \sh, 6,//Pswitch([3, 4, 6, 10], i, inf),

		    \ii, Pswitch([1, 4, 7, 10], i, inf),

		    // osc out for viz
			\osc, Pfunc{|e| 
				if(isPlayingBlob[i] == true, { vizMessage.(e, i)});
				true
			},
	    );

		binds = binds.add(bi);

	});


	// •• do we just need a pool of patterns we can use...?

	n = [\aPtn, \bPtn, \cPtn, \dPtn];

	patterns = Array.fill(poolSize, {|i|
		Ndef(n[i], binds[i]).quant_(0.2);
	});



	// problem is we need multi channels for data streams

	// Ndef(\bbPtn).set(\dur, 0.1);
	// Ndef(\bbPtn).set(\release, 0.1);
	// Ndef(\ccPtn).set(\dur, 0.4);
	// Ndef(\ddPtn).set(\dur, 0.3);
	// Ndef(\ddPtn).set(\release, 0.1);
	// Ndef(\ddPtn).set(\dur, 0.2);
	// Ndef(\ddPtn).set(\release, 0.1);

	// s.queryAllNodes;
	// patterns.size.postln;

};

//------------------------------------------------------
~reload = {|model|

	postf("reload : % \n", model.file);

	patterns.do{|p|
		if(p != nil,{
			p.end(0.1);
		});
	};

	patterns = [];

	Ndef.clear(0.1);

	~init.(model);

};

//------------------------------------------------------
~deinit = {|model|

	postf("deinit : % \n", model.file);

	patterns.do{|p|
		if(p != nil,{
			p.end(0.1);
		});
	};

	patterns = [];

	// need this for reloading or patterns after an edit
	// Ndef.clear;

};

//---------------------------------------------------
~onInit = {|blob, blobsDict|

	var l = (blob.label.mod(patterns.size));

	isPlayingBlob[l] = true;


	if(patterns[l].isMonitoring == false,{
		// s.queryAllNodes;
		// patterns[l].rebuild;
		patterns[l].play(0.1);
		postf("playing : (%)[%] % \n", blob.label, l, patterns[l]);
	});
	patterns[l].group.postln;
	// oscSender.sendMsg("/shadow", 

	// 					"shape", 10,

	// 					"duration", 1,
	// 					"attack", 0.1,
	// 					"release", 1,

	// 					"color", 0,//i.linlin(0,4,0,0.99),//(e.note + (e.octave * 12)).linlin(30,80,0,0.99),

	// 					"scale", 1,//(e.note + (e.oct * 12)).linexp(0,127,2,0.2),

	// 					"sx", 0,//(e.note + (e.octave * 12)).linlin(30,80,-1.8,1.8),
	// 					"sy", 0,
	// 					"ex", 0,//(e.note + (e.octave * 12)).linlin(30,80,-1.8,1.8),
	// 					"ey", 0,

	// 					"imageindex", 13,

	// 					"rotstart", 45,
	// 					"rotend", 135,


	// 					"wobble", 100,//e.param2.linlin(1,6,0.1,1), // wobble
	// 				);

};

//------------------------------------------------------
~onDeinit = {|blob, blobsDict|

	var l = (blob.label.mod(patterns.size));

	isPlayingBlob[l] = false;

	if(patterns[l].isMonitoring == true,{
		patterns[l].stop(0.3);
		postf("ending : (%)[%] % \n", blob.label, l, patterns[l]);
	});



};

//------------------------------------------------------
~onUpdate = {|blob, blobsDict, model|

	var l = (blob.label.mod(patterns.size));
	// var notes = [0,7,12,16];
	// notes[l].value = blob.center.x.linlin(100,550,3,7).floor;

	//blobsDict.values[0].rect.width.linlin(0,120,0,10)

	// oct = blobsDict.values[0].area.linexp(1.0,16.0,6,3).floor;
	// patterns[l].set(\note, note);
	// patterns[l].set(\octave, oct);
	patterns[l].set(\ff, blobsDict.values[0].rect.width.linlin(0,120,400,12000));
	// patterns[l].set(\release, blobsDict.values[0].rect.width.linexp(0,190,0.004, l+1));
	
	// patterns[l].isPlaying.postln;

	cb[l].value = blob.center.x.linlin(0,600,-3.5, 3.5);

	// patterns[l].set(\
	
	

};

//------------------------------------------------------
~onData = {|blobsDict|
	[blobsDict.values[0].rect.width.linlin(80,120,0,10)];
};

