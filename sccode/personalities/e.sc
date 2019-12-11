var channel = 6;
var name = \e;

~init = {|midiOut, bf|
	"d init".postln;

	~pattern = Pdef(name,
		~bind = Pbind(
			\note, Pseq([0,7,5,12,2,11,9,7].stutter(4),inf),
			\func, Pfunc({|e| bf.(e)}),
			\args, #[],
		);
	);

	Pdef(name).set(\dur,0.5);
	//Pdef(name).set(\root,0);
	Pbindef(name, \root, Pseq([0,3,8,5].stutter(32),inf));
	Pbindef(name, \octave, Pseq([3,4].stutter(1),inf));
	// Pdef(name).set(\octave,4);
	Pdef(name).set(\amp,0.8);
	Pdef(name).set(\type,\midi);
	Pdef(name).set(\midiout,midiOut);
	Pdef(name).set(\chan,channel);
	Pdef(name).play();


};
~community = {|b,e|
	// [b,e].postln;
};


~volume = {|v|
	Pdef(name).set(\amp,v);
};

~update = {|blobs,i,midiOut|

	var beat = (blobs[0].pWidth.rateFiltered.explin(30,120,1,16).floor).reciprocal;
	var oct = (blobs[0].pWidth.rateFiltered.linlin(30,120,1,4).floor);
	var ca = (blobs[0].pWidth.rateFiltered.linlin(30,120,0,80).floor);
	var cb = (blobs[0].pWidth.rateFiltered.linlin(30,120,30,80).floor);
	var cc = (blobs[0].pWidth.rateFiltered.linlin(30,120,80,0).floor);


	Pdef(name).set(\dur,beat);
	//Pdef(name).set(\octave, 3 + oct);


	midiOut.control(channel, 21, ca);
	midiOut.control(channel, 25, cb);
	midiOut.control(channel, 28, cc);
};

~deinit = {|midiOut|
	"d deinit".postln;

	Pdef(name).stop();
	Pdef(name).clear;
	midiOut.allNotesOff(channel);

};
