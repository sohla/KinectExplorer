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

			"shape", 10,

			"duration", e.dur,
			"attack", e.attack * 1,
			"release", e.rel * 0.01,

			"color", i.linlin(0,3,0,0.99),

			"scale", 0.2,

			"sx", cb[i].getSynchronous.(),
			"sy", -1,
			"ex", cb[i].getSynchronous.(),
			"ey", 2,

			"imageindex", e.ii,

			"rotstart",0,
			"rotend", 0,

			"amp", 0.43,
			"speed", 2,
			"freq", 3,

			"wobble", 6,
		);
	};



	SynthDef(\drawing1, {|out = 0, attack = 8.004, release = 12.9, freq = 120, gate = 1, vib = 0.01, amp = 0.7, vs = 1|

		var env = EnvGen.ar(Env.perc(attack, release, 1, -7), gate, doneAction: 2);
		var fs = Array.makeScaleCps(groundNote: 263, type: 'major');
		var as = [1,0.1,0.2,0.02,1,0.3,0.7,0.5];
		var rs = [1];
		var sig = Splay.arFill(4,
			{

				DynKlank.ar(
					`[freq * LFCub.ar(vs,0,vib,1), as, rs], 
					LPF.ar(PinkNoise.ar(0.007), MouseX.kr(100,1000));
				) * 0.5

			},
			1,
			1,
			0);
		Out.ar(out, sig * env * amp * MouseY.kr(0,1, lag:0.1));
	}).add;





	poolSize.do({|i|
	
		var bi =	Pbind(

		    \instrument, \drawing1, //Pswitch([\b, \c, \a, \d], i, inf),


			\octave, Prand([4,5,6,5], inf),
			// \note, Pseq([0,7,16], inf),


		    \note, Pswitch(
		    
		    	[Pseq([0], inf), 
		    	Pseq([7], inf), 
		    	Pseq([16], inf), 
		    	Pseq([0,7], inf)], i, inf),


			\root, Pseq([0,4,-1, 2].stutter(20), inf),
			\dur, Pseq([1/10,1/10,1/5, 1/2.5, 1/2.5, 1/5] * 4, inf),
			\amp, 1,
			\attack, Pwhite(0.001,0.01, inf),
			\release, Pwhite(8.1,6.9, inf),


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
	patterns[l].set(\vib, blobsDict.values[0].rect.width.linexp(0,170,0.001,0.2));
	patterns[l].set(\vs, blobsDict.values[0].rect.width.linexp(0,170,0.001,45));
	//•• patterns[l].set(\release, blobsDict.values[0].rect.width.linexp(0,190,0.004, l+1));
	
	// patterns[l].isPlaying.postln;

	cb[l].value = blob.center.x.linlin(0,600,-3.5, 3.5);

	// patterns[l].set(\
	
	

};

//------------------------------------------------------
~onData = {|blobsDict|
	[blobsDict.values[0].rect.width.linlin(80,120,0,10)];
};

