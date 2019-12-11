var channel = 7;
var name = \f;

~init = {|midiOut, bf|
	"d init".postln;

	~pattern = Pdef(name,
		~bind = Pbind(
			\note, Pseq([0,2].stutter(1),inf),
			\func, Pfunc({|e| bf.(e)}),
			\args, #[],
		);
	);

	Pdef(name).set(\dur,0.5);
	Pdef(name).set(\root,1);
	// Pbindef(name, \root, Pseq([0,3,8,5].stutter(32),inf));
	Pdef(name).set(\octave,0);
	Pdef(name).set(\amp,0.8);
	Pdef(name).set(\type,\midi);
	Pdef(name).set(\midiout,midiOut);
	Pdef(name).set(\chan,channel);
	Pdef(name).play();


};
~community = {|b,e|
	if(e.chan == 6,{
		Pdef(name).set(\root,e.root);
	});
};


~volume = {|v|
	Pdef(name).set(\amp,v);
};

~update = {|blobs,i,midiOut|

	var beat = (blobs[0].pWidth.rateFiltered.explin(30,120,1,4).floor * 0.25).reciprocal;
	var oct = (blobs[0].pWidth.rateFiltered.linlin(30,120,1,2).floor);
	var ca = (blobs[0].pWidth.rateFiltered.linlin(30,120,30,47).floor);
	var cb = (blobs[0].pWidth.rateFiltered.linlin(30,120,30,127).floor);
	var cc = (blobs[0].pWidth.rateFiltered.linlin(30,120,80,0).floor);


	Pdef(name).set(\dur,beat);
	Pdef(name).set(\octave, 2 + oct);


	midiOut.control(channel, 26, ca);
	// midiOut.control(channel, 25, cb);
	// midiOut.control(channel, 28, cc);
};

~deinit = {|midiOut|
	"d deinit".postln;

	Pdef(name).stop();
	Pdef(name).clear;
	midiOut.allNotesOff(channel);

};
