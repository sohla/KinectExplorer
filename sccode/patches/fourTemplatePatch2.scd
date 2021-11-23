var oct = 0;
var note = 0;
var scale = 1;
var poolSize = 4;
var names = [\aaPtn, \bbPtn, \ccPtn, \ddPtn];
var isPlayingBlob = Array.fill(poolSize, false);
var patterns = Array.new(poolSize);
var cb = [Bus.control(s,1),Bus.control(s,1),Bus.control(s,1),Bus.control(s,1),Bus.control(s,1)];
var binds = Array.new(poolSize);
var notes = [Bus.control(s,1),Bus.control(s,1),Bus.control(s,1),Bus.control(s,1),Bus.control(s,1)];


//------------------------------------------------------
~init = {|model|
	postf("init : % \n", model.file);

	{
		SynthDef(\aa, {|out = 0, freq = 160, amp = 0.3, attack = 0.01, decay = 4.02, sustain = 0.8, release = 0.9, gate = 1, ff = 500, rf = 1|

			var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
			var sig = SinOsc.ar([freq,freq + 3.rand],0, amp) + Saw.ar([freq,freq + 6.rand], amp) * env;
			var filter = MoogFF.ar(sig, ff.lag(0.1), rf);
			Out.ar(out, filter);

		}).add;
		
		s.sync

	}.fork;
	i=0;
	b = Pbind(
			\instrument, \aa,
			// musics
		    \instrument, \aa,
		    \amp, Pwhite(0.3, 0.2),
		    \root, 0,//Pseq([0,3,6,-3].stutter(27), inf),
		    \scale, 3,
		     \octave, Pfunc{ 3 + i },//Prand([0,1,2,3,4,5,6,7,8,9,10].stutter(7),inf),
		    \note, Pfunc{ notes[i].getSynchronous.()},//Pseq([0], inf),
		    \dur, 0.2,//Pfunc{ 2.pow(mx.getSynchronous.linlin(0,1.0,1,6).floor).reciprocal * 2.5},
		    \attack, Pwhite(0.001,0.01),
		    \decay, Pwhite(0.2,0.9),
		    \release, 1.2,//Pfunc{ my.getSynchronous.linlin(0,1.0,0.005,4.5)},//Pwhite(0.05,1.3),
		    \rel, Pkey(\release),
		    \ff, 700,//Pfunc{ mx.getSynchronous.linexp(0,1.0,100,12000)},
		    \rf, Pseq([3,0,3,1,1,3,1], inf),//Pfunc{ my.getSynchronous.linlin(0,1.0,0,4)},


		    //visuals
		    \sh, 6,
		    \param1, 1,
		    \param2, 2,
		    \param3, 3,
		    \sx, 0,//Pfunc{ cb.getSynchronous.().linlin(0,8,-1,1)},//(Pkey(\note) + (Pkey(\octave) * 12)).linlin(30,80,-1.8,1.8),
		    \sy, 0,
		    \ex, Pkey(\sx),
		    \ey, Prand([-1.5,1.5], inf),
		    // \oct, Pkey(\octave),
		    \pp, 999,

		    // osc out
			\osc, Pfunc{|e| 
	
				if(isPlayingBlob[i] == true,{
				
					model.netAddr.sendMsg("/shadow", 
						"shape", e.sh,
						"duration", e.dur,
						"attack", e.attack * 1,
						"release", e.rel * 2,
						"color", i.linlin(0,4,0,0.99),//(e.note + (e.octave * 12)).linlin(30,80,0,0.99),//e.param1,//colour
						"scale", 0.5,//(e.note + (e.oct * 12)).linexp(0,127,2,0.2),//scale
						"sy", cb[i].getSynchronous.(),//(e.note + (e.octave * 12)).linlin(30,80,-1.8,1.8),//sx
						"sx", -1,//sy
						"ey", cb[i].getSynchronous.(),//(e.note + (e.octave * 12)).linlin(30,80,-1.8,1.8),//ex
						"ex", 0,//ey
						"imageIndex", 12,
						"blur", 0.5,
						
						"par7", 0,//e.param2.linlin(1,6,0.1,1), // wobble
						"par8", 0,//e.octave.linlin(3,6,28,10),
						// "par9", (e.note + (oct * 12)).linlin(0,127,6,1),
					);
				});
				true
			}
			);

	Ndef(\aaPtn,b).set(\note,0);
	Ndef(\bbPtn,b).set(\note,4);
	Ndef(\ccPtn,b).set(\note,7);
	Ndef(\ddPtn,b).set(\note,11);


/*
	poolSize.do({|i|
		Ndef(names[i], 
			Pbind(
				// \args, #[],
			// musics
		    \instrument, \aa,
		    \amp, Pwhite(0.3, 0.2),
		    \root, 0,//Pseq([0,3,6,-3].stutter(27), inf),
		    \scale, 3,
		     \octave, Pfunc{ 3 + i },//Prand([0,1,2,3,4,5,6,7,8,9,10].stutter(7),inf),
		    \note, Pfunc{ notes[i].getSynchronous.()},//Pseq([0], inf),
		    \dur, 0.2,//Pfunc{ 2.pow(mx.getSynchronous.linlin(0,1.0,1,6).floor).reciprocal * 2.5},
		    \attack, Pwhite(0.001,0.01),
		    \decay, Pwhite(0.2,0.9),
		    \release, 1.2,//Pfunc{ my.getSynchronous.linlin(0,1.0,0.005,4.5)},//Pwhite(0.05,1.3),
		    \rel, Pkey(\release),
		    \ff, 700,//Pfunc{ mx.getSynchronous.linexp(0,1.0,100,12000)},
		    \rf, Pseq([3,0,3,1,1,3,1], inf),//Pfunc{ my.getSynchronous.linlin(0,1.0,0,4)},


		    //visuals
		    \sh, 6,
		    \param1, 1,
		    \param2, 2,
		    \param3, 3,
		    \sx, 0,//Pfunc{ cb.getSynchronous.().linlin(0,8,-1,1)},//(Pkey(\note) + (Pkey(\octave) * 12)).linlin(30,80,-1.8,1.8),
		    \sy, 0,
		    \ex, Pkey(\sx),
		    \ey, Prand([-1.5,1.5], inf),
		    // \oct, Pkey(\octave),
		    \pp, 999,

		    // osc out
			\osc, Pfunc{|e| 
	
				if(isPlayingBlob[i] == true,{
				
					model.netAddr.sendMsg("/shadow", 
						"shape", e.sh,
						"duration", e.dur,
						"attack", e.attack * 1,
						"release", e.rel * 2,
						"color", i.linlin(0,4,0,0.99),//(e.note + (e.octave * 12)).linlin(30,80,0,0.99),//e.param1,//colour
						"scale", 0.5,//(e.note + (e.oct * 12)).linexp(0,127,2,0.2),//scale
						"sy", cb[i].getSynchronous.(),//(e.note + (e.octave * 12)).linlin(30,80,-1.8,1.8),//sx
						"sx", -1,//sy
						"ey", cb[i].getSynchronous.(),//(e.note + (e.octave * 12)).linlin(30,80,-1.8,1.8),//ex
						"ex", 0,//ey
						"imageIndex", 12,
						"blur", 0.5,
						
						"par7", 0,//e.param2.linlin(1,6,0.1,1), // wobble
						"par8", 0,//e.octave.linlin(3,6,28,10),
						// "par9", (e.note + (oct * 12)).linlin(0,127,6,1),
					);
				});
			},
	    );

		);

	});
	Ndef.all.postln;
*/
	// •• do we just need a pool of patterns we can use...?


	// patterns = Array.fill(poolSize, {|i|

	// 	Ndef(n[i]);
	// 	// Ndef(\aaPtn, binds[0]),
	// 	// Ndef(\bbPtn, binds[1]),
	// 	// Ndef(\ccPtn, binds[2]),
	// 	// Ndef(\ddPtn, binds[3]),
	// 	// Ndef(\aaPtn, binds[i]).quant_(0.2),
	// 	// Ndef(\bbPtn, binds[1]).quant_(0.2),
	// 	// Ndef(\ccPtn, binds[2]).quant_(0.2),
	// 	// Ndef(\ddPtn, binds[3]).quant_(0.2),
	// 	// Ndef(\eePtn, binds[4]).quant_(0.2),
	// });



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


	// patterns.do{|p|
	// 	if(p != nil,{
	// 		p.end(0.1);
	// 	});
	// };

	patterns = [];

	Ndef.clear(0.1);

	~init.(model);

};

//------------------------------------------------------
~deinit = {|model|

	postf("deinit : % \n", model.file);

	// patterns.do{|p|
	// 	if(p != nil,{
	// 		p.end(0.1);
	// 	});
	// };

	patterns = [];

	// need this for reloading or patterns after an edit
	Ndef.clear;

};

//---------------------------------------------------
~onInit = {|blob, blobsDict|

	var l = (blob.label.mod(poolSize));

	isPlayingBlob[l] = true;

	if(Ndef(names[l]).isMonitoring == false,{
		Ndef(names[l]).play(0.4);
		postf("playing : (%)[%] % \n", blob.label, l, Ndef(names[l]));
	});

};

//------------------------------------------------------
~onDeinit = {|blob, blobsDict|

	var l = (blob.label.mod(poolSize));

	isPlayingBlob[l] = false;

	if(Ndef(names[l]).isMonitoring == true,{
		Ndef(names[l]).end(0.8);
		postf("ending : (%)[%] % \n", blob.label, l, Ndef(names[l]));
	});

};

//------------------------------------------------------
~onUpdate = {|blob, blobsDict, model|

	var l = (blob.label.mod(poolSize));
	// var notes = [0,7,12,16];
	notes[l].value = blob.center.x.linlin(100,550,0,24).floor * 1;
	// oct = blobsDict.values[0].area.linexp(1.0,16.0,6,3).floor;
	// patterns[l].set(\note, note);
	// patterns[l].set(\octave, oct);
	// patterns[l].set(\ff, blob.area.linexp(1.0,8.0,400,6000));

	cb[l].value = blob.center.x.linlin(0,600,-2.0,1.6);
	

};

//------------------------------------------------------
~onData = {|blobsDict|
	[blobsDict.values[0].area.linexp(1.0,16.0,4,2).floor];
};
