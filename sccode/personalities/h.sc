var channel = 9;
var name = \h;
var isHit = false;
var roots = [0,5,2];

~init = {|midiOut, bf|
	"d init".postln;

	~pattern = Pdef(name,
		~bind = Pbind(
			\note, Pseq([0,1,2,3,4,5,6,7,8,9,10,11,12].stutter(1),inf),
			\func, Pfunc({|e| bf.(e)}),
			\args, #[],
		);
	);

	Pdef(name).set(\dur,0.25);
	Pdef(name).set(\root,0);
	// Pbindef(name, \root, Pseq([0,3,8,5].stutter(64),inf));
	// Pbindef(name, \octave, 3);
	Pdef(name).set(\octave,5);
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

	var beat = 2.pow(blobs[0].pWidth.rateFiltered.explin(30,120,2,3).floor).reciprocal;
	var oct = (blobs[0].pWidth.rateFiltered.linexp(30,120,1,4).floor);
	var ca = (blobs[0].pWidth.rateFiltered.linlin(30,120,80,60).floor);
	var cb = (blobs[0].pWidth.rateFiltered.linlin(30,120,80,60).floor);
	var cc = (blobs[0].pWidth.rateFiltered.linlin(30,120,80,0).floor);
	
	// Pdef(name).set(\dur,beat);
	// Pdef(name).set(\octave, 3 + oct);



	 midiOut.control(channel, 29, ca);
	// midiOut.control(channel, 23, cb);
	// midiOut.control(channel, 28, cc);
};

~deinit = {|midiOut|
	"d deinit".postln;

	Pdef(name).stop();
	Pdef(name).clear;
	midiOut.allNotesOff(channel);

};
