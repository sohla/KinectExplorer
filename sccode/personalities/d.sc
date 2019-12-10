var channel = 4;
var name = \d;
~init = {|midiOut|
	"d init".postln;

	Pdef(name,
		Pbind(
			\note, Pseq([0,2,-3,-5].stutter(2),inf),
			\octave, Pseq([4,3].stutter(1),inf),
			// \root, Pseq([0,3].stutter(36),inf),
			\args, #[],
		);
	);

	Pdef(name).set(\dur,0.5);
	//Pdef(name).set(\octave,4);
	Pdef(name).set(\amp,0.8);
	Pdef(name).set(\type,\midi);
	Pdef(name).set(\midiout,midiOut);
	Pdef(name).set(\chan,channel);
	Pdef(name).play();


};
~volume = {|v|
	Pdef(name).set(\amp,v);
};

~update = {|blobs,i,midiOut|

	//var beat = (blobs[0].rect.width.linlin(100,400,1,8).floor * 0.5).reciprocal;
	var beat = (blobs[0].pWidth.rateFiltered.explin(30,120,1,4).floor * 0.25).reciprocal;
	var ca = (blobs[0].pWidth.rateFiltered.linlin(30,120,0,127).floor).asInteger;
	var cb = (blobs[0].center.x.linlin(130,600,0,127).floor).asInteger;
	//ca.postln;
	Pdef(name).set(\dur,beat);
	Pdef(name).set(\root,blobs[0].root);
	midiOut.control(channel, 26, cb);
};

~deinit = {|midiOut|
	"d deinit".postln;

	Pdef(name).stop();
	Pdef(name).clear;
	midiOut.allNotesOff(channel);

};
